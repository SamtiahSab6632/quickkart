import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/account_store.dart';
import 'package:quick_kart/domain/models/account.dart';

class GoogleProfile {
  const GoogleProfile({required this.name, required this.email});

  final String name;
  final String email;
}

class GoogleAccountSheet extends StatefulWidget {
  const GoogleAccountSheet({super.key});

  @override
  State<GoogleAccountSheet> createState() => _GoogleAccountSheetState();
}

class _GoogleAccountSheetState extends State<GoogleAccountSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late final List<Account> _savedAccounts;
  late bool _showForm;

  @override
  void initState() {
    super.initState();
    _savedAccounts = AccountStore.accounts
        .where((account) => account.isGoogleAccount && account.email.isNotEmpty)
        .toList();
    _showForm = _savedAccounts.isEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _continueWithProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(
      GoogleProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
      ),
    );
  }

  void _selectAccount(Account account) {
    Navigator.of(
      context,
    ).pop(GoogleProfile(name: account.name, email: account.email));
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildHeader(),
                    const SizedBox(height: 20),
                    if (_showForm) _buildForm() else _buildAccountChooser(),
                    const SizedBox(height: 16),
                    const Text(
                      'Demo Google sign-in - your profile is stored only on this device.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Regular',
                        fontSize: 10.5,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F4),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: const Text(
            'G',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 22,
              color: Color(0xFF4285F4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Continue with Google',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 20,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Choose a Google account for QuickKart.',
                style: TextStyle(
                  fontFamily: 'Regular',
                  fontSize: 12.5,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.close_rounded,
            size: 21,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountChooser() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final account in _savedAccounts) ...[
          _buildSavedAccount(account),
          const SizedBox(height: 10),
        ],
        _buildUseAnotherAccount(),
        if (_savedAccounts.isNotEmpty) ...[
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSavedAccount(Account account) {
    final label = account.name.isNotEmpty ? account.name : account.email;
    final initial = label.trim().isEmpty
        ? 'G'
        : label.trim().characters.first.toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _selectAccount(account),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.fieldBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontFamily: 'bold',
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'bold',
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        account.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Regular',
                          fontSize: 11.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUseAnotherAccount() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _showForm = true),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.person_add_alt_1_rounded,
                    size: 20,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Use another account',
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            key: const ValueKey('google-name-field'),
            controller: _nameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            cursorColor: AppColors.primary,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [LengthLimitingTextInputFormatter(60)],
            style: const TextStyle(
              fontFamily: 'Regular',
              fontSize: 14.5,
              color: AppColors.textPrimary,
            ),
            validator: (value) {
              if ((value ?? '').trim().length < 2) {
                return 'Enter the name on your Google account';
              }
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Full name',
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const ValueKey('google-email-field'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            cursorColor: AppColors.primary,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            inputFormatters: [LengthLimitingTextInputFormatter(120)],
            onFieldSubmitted: (_) => _continueWithProfile(),
            style: const TextStyle(
              fontFamily: 'Regular',
              fontSize: 14.5,
              color: AppColors.textPrimary,
            ),
            validator: (value) {
              final email = (value ?? '').trim();
              if (email.isEmpty) return 'Enter your Google email';
              final valid = RegExp(
                r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
              ).hasMatch(email);
              if (!valid) return 'Enter a valid email address';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Google email',
              icon: Icons.alternate_email_rounded,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _continueWithProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 15,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
          if (_savedAccounts.isNotEmpty) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _showForm = false),
                child: const Text(
                  'Back to accounts',
                  style: TextStyle(
                    fontFamily: 'bold',
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
      filled: true,
      fillColor: AppColors.fieldBackground,
      prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: _border(),
      enabledBorder: _border(),
      focusedBorder: _border(color: AppColors.primary, width: 1.6),
      errorBorder: _border(color: AppColors.danger),
      focusedErrorBorder: _border(color: AppColors.danger, width: 1.6),
      errorStyle: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 11.5,
        color: AppColors.danger,
      ),
    );
  }

  OutlineInputBorder _border({
    Color color = AppColors.border,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
