import 'package:flutter/material.dart';
import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/ai_store.dart';
import 'package:quick_kart/domain/models/catalog.dart';
import 'package:quick_kart/domain/services/ai_assistant.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key, required this.onAdd});

  final ValueChanged<Product> onAdd;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  static const List<String> _suggestions = [
    'Find cheap milk',
    'Fruits under Rs 300',
    'Fresh farm eggs',
    'Cleaning essentials',
  ];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();

  final List<AiChatTurn> _history = [];
  final List<_ChatMessage> _messages = [];

  bool _isSending = false;
  bool _hasKey = false;

  @override
  void initState() {
    super.initState();
    _hasKey = AiStore.hasKey;
    _messages.add(
      const _ChatMessage(
        isUser: false,
        text:
            'Hi! I am the QuickKart AI assistant. Tell me what you need — '
            'you can also add a budget, like "Fruits under Rs 300".',
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send([String? presetText]) async {
    final text = (presetText ?? _inputController.text).trim();
    if (text.isEmpty || _isSending) return;

    FocusScope.of(context).unfocus();
    if (presetText == null) _inputController.clear();

    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text));
      _history.add(AiChatTurn(isUser: true, text: text));
      _isSending = true;
    });
    _scrollToBottom();

    final result = await AiAssistant.ask(
      message: text,
      history: _history.take(_history.length - 1).toList(),
    );

    if (!mounted) return;

    setState(() {
      _messages.add(
        _ChatMessage(
          isUser: false,
          text: result.reply,
          products: result.products,
          isError: result.hadError,
        ),
      );
      _history.add(AiChatTurn(isUser: false, text: result.reply));
      _isSending = false;
    });
    _scrollToBottom();
  }

  void _addProduct(Product product) {
    widget.onAdd(product);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${product.name} added to cart',
            style: const TextStyle(fontFamily: 'Regular', fontSize: 13),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _addAll(List<Product> products) {
    for (final product in products) {
      widget.onAdd(product);
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${products.length} items added to cart',
            style: const TextStyle(fontFamily: 'Regular', fontSize: 13),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1200),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Future<void> _editKey() async {
    final keyController = TextEditingController();
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Gemini API key',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 17,
              color: AppColors.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AiStore.hasKey
                    ? 'AI Studio free key is saved on this device. Replace or '
                          'remove it anytime.'
                    : 'Get a free key: aistudio.google.com → "Get API key" → '
                          '"Create API key" and paste it here.',
                style: const TextStyle(
                  fontFamily: 'Regular',
                  fontSize: 12,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('ai-key-field'),
                controller: keyController,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: 'Paste API key',
                  filled: true,
                  fillColor: AppColors.fieldBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(13),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            if (AiStore.hasKey)
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop('remove'),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text(
                  'Remove key',
                  style: TextStyle(fontFamily: 'bold', fontSize: 13),
                ),
              ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontFamily: 'bold', fontSize: 13),
              ),
            ),
            FilledButton(
              key: const ValueKey('save-ai-key'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop('save'),
              child: const Text(
                'Save key',
                style: TextStyle(fontFamily: 'bold', fontSize: 13),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (action == 'save') {
      final key = keyController.text.trim();
      if (key.isEmpty) return;
      await AiStore.saveKey(key);
      if (!mounted) return;
      setState(() => _hasKey = true);
      _showSnackbar('API key saved. Replies will now come from the real AI.');
    } else if (action == 'remove') {
      await AiStore.saveKey('');
      if (!mounted) return;
      setState(() => _hasKey = false);
      _showSnackbar('API key removed. The app is running in demo mode.');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Regular', fontSize: 13),
          ),
          backgroundColor: AppColors.textPrimary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1600),
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestions = _messages.length <= 1 && !_isSending;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 17,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 9),
            const Text(
              'AI Assistant',
              style: TextStyle(
                fontFamily: 'bold',
                fontSize: 17,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Gemini API key',
            onPressed: _editKey,
            icon: Icon(
              _hasKey ? Icons.key_rounded : Icons.key_off_rounded,
              size: 22,
              color: _hasKey ? AppColors.success : AppColors.textSecondary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!_hasKey) _buildDemoBanner(),
            if (showSuggestions) _buildSuggestions(),
            Expanded(child: _buildMessages()),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: AppColors.primaryDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Demo mode is on. Add a free Gemini key — replies will come '
              'from the real AI.',
              style: const TextStyle(
                fontFamily: 'Regular',
                fontSize: 10.5,
                height: 1.4,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          GestureDetector(
            onTap: _editKey,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'Add key',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 10.5,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final term = _suggestions[index];
          return GestureDetector(
            onTap: () => _send(term),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 13,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    term,
                    style: const TextStyle(
                      fontFamily: 'bold',
                      fontSize: 11.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      itemCount: _messages.length + (_isSending ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isSending && index == _messages.length) {
          return _buildTypingBubble();
        }
        final message = _messages[index];
        return _buildBubble(message);
      },
    );
  }

  Widget _buildTypingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
            SizedBox(width: 10),
            Text(
              'AI is thinking...',
              style: TextStyle(
                fontFamily: 'Regular',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(_ChatMessage message) {
    if (message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
          constraints: const BoxConstraints(maxWidth: 280),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              fontFamily: 'Regular',
              fontSize: 12.5,
              height: 1.45,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    final total = message.products.fold(
      0,
      (sum, product) => sum + product.price,
    );

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(13),
        constraints: const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: message.isError
                ? AppColors.danger.withValues(alpha: 0.35)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isError)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      size: 13,
                      color: AppColors.danger,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'AI offline — demo matching',
                      style: TextStyle(
                        fontFamily: 'bold',
                        fontSize: 10,
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              message.text,
              style: const TextStyle(
                fontFamily: 'Regular',
                fontSize: 12.5,
                height: 1.45,
                color: AppColors.textPrimary,
              ),
            ),
            if (message.products.isNotEmpty) ...[
              const SizedBox(height: 10),
              for (final product in message.products) _buildProductRow(product),
              if (message.products.length > 1)
                OutlinedButton.icon(
                  onPressed: () => _addAll(message.products),
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 15),
                  label: Text(
                    'Add all • Rs $total',
                    style: const TextStyle(
                      fontFamily: 'bold',
                      fontSize: 11.5,
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                    minimumSize: const Size(0, 34),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: product.tint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Image.asset(
              emojiAssetPath(product.emoji),
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  Text(product.emoji, style: const TextStyle(fontSize: 19)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'bold',
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${product.unit} • Rs ${product.price}',
                  style: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _addProduct(product),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Text(
                'ADD',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 10.5,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('ai-input-field'),
                  controller: _inputController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (value) => _send(),
                  maxLines: 1,
                  cursorColor: AppColors.primary,
                  style: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask the AI — e.g. fruits under Rs 300',
                    hintStyle: const TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                    ),
                    filled: true,
                    fillColor: AppColors.fieldBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _isSending ? null : () => _send(),
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({
    required this.isUser,
    required this.text,
    this.products = const <Product>[],
    this.isError = false,
  });

  final bool isUser;
  final String text;
  final List<Product> products;
  final bool isError;
}
