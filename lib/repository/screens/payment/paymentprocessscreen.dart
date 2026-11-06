import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/models/payment_method.dart';

/// Returned by [PaymentProcessScreen] once a payment is confirmed.
class PaymentResult {
  const PaymentResult({required this.reference});

  /// Masked payment detail shown on receipts, e.g. `•••• 4242`.
  final String reference;
}

class PaymentProcessScreen extends StatefulWidget {
  const PaymentProcessScreen({
    super.key,
    required this.method,
    required this.amount,
  });

  final PaymentMethod method;
  final int amount;

  @override
  State<PaymentProcessScreen> createState() => _PaymentProcessScreenState();
}

class _PaymentProcessScreenState extends State<PaymentProcessScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _cardNameController = TextEditingController();
  final TextEditingController _walletController = TextEditingController();
  final TextEditingController _mpinController = TextEditingController();

  bool _isProcessing = false;

  bool get _isCard => widget.method.id == 'card';

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNameController.dispose();
    _walletController.dispose();
    _mpinController.dispose();
    super.dispose();
  }

  String _digitsOf(String value) => value.replaceAll(RegExp(r'\D'), '');

  Future<void> _pay() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isProcessing = true);

    await Future<void>.delayed(const Duration(milliseconds: 1400));

    if (!mounted) return;

    final reference = _isCard
        ? '•••• ${_digitsOf(_cardNumberController.text).substring(12)}'
        : '${_digitsOf(_walletController.text).substring(0, 4)}'
              '•••${_digitsOf(_walletController.text).substring(7)}';

    Navigator.of(context).pop(PaymentResult(reference: reference));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme: _isProcessing
              ? const IconThemeData(color: Colors.transparent)
              : const IconThemeData(color: AppColors.textPrimary),
          automaticallyImplyLeading: !_isProcessing,
          title: Text(
            _isCard ? 'Card payment' : '${widget.method.name} payment',
            style: const TextStyle(
              fontFamily: 'bold',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _buildAmountCard(),
              const SizedBox(height: 14),
              _buildDetailsForm(),
              const SizedBox(height: 14),
              _buildSecureNote(),
            ],
          ),
        ),
        bottomNavigationBar: _buildPayBar(),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A101828),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: widget.method.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              widget.method.icon,
              size: 22,
              color: widget.method.color,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount to pay',
                  style: const TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 11.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rs ${widget.amount}',
                  style: const TextStyle(
                    fontFamily: 'bold',
                    fontSize: 19,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: widget.method.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.method.name,
              style: TextStyle(
                fontFamily: 'bold',
                fontSize: 10.5,
                color: widget.method.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A101828),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isCard ? 'Card details' : 'Wallet details',
              style: const TextStyle(
                fontFamily: 'bold',
                fontSize: 13.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 13),
            if (_isCard) ...[
              _buildField(
                key: const ValueKey('card-number-field'),
                controller: _cardNumberController,
                hint: 'Card number',
                icon: Icons.credit_card_rounded,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (_digitsOf(value ?? '').length != 16) {
                    return 'Enter the 16-digit card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildField(
                      key: const ValueKey('card-expiry-field'),
                      controller: _expiryController,
                      hint: 'MM/YY',
                      icon: Icons.calendar_today_outlined,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryFormatter(),
                      ],
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final expiry = value ?? '';
                        if (!RegExp(
                          r'^(0[1-9]|1[0-2])\/\d{2}$',
                        ).hasMatch(expiry)) {
                          return 'Use MM/YY';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      key: const ValueKey('card-cvv-field'),
                      controller: _cvvController,
                      hint: 'CVV',
                      icon: Icons.lock_outline_rounded,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final cvv = _digitsOf(value ?? '');
                        if (cvv.length < 3) return '3-4 digits';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildField(
                key: const ValueKey('card-name-field'),
                controller: _cardNameController,
                hint: 'Name on card',
                icon: Icons.person_outline_rounded,
                inputFormatters: [LengthLimitingTextInputFormatter(40)],
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if ((value ?? '').trim().length < 3) {
                    return 'Enter the name printed on the card';
                  }
                  return null;
                },
              ),
            ] else ...[
              _buildField(
                key: const ValueKey('wallet-number-field'),
                controller: _walletController,
                hint: '0345 1234567',
                icon: Icons.smartphone_rounded,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final number = _digitsOf(value ?? '');
                  if (!RegExp(r'^03\d{9}$').hasMatch(number)) {
                    return 'Enter a valid mobile wallet number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _buildField(
                key: const ValueKey('wallet-mpin-field'),
                controller: _mpinController,
                hint: '${widget.method.name} MPIN',
                icon: Icons.password_rounded,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                keyboardType: TextInputType.number,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _pay(),
                validator: (value) {
                  final mpin = _digitsOf(value ?? '');
                  if (mpin.length < 4 || mpin.length > 6) {
                    return 'MPIN must be 4-6 digits';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required Key key,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required List<TextInputFormatter> inputFormatters,
    required TextInputType keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onFieldSubmitted,
    bool obscureText = false,
    TextCapitalization? textCapitalization,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      key: key,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      textInputAction: textInputAction ?? TextInputAction.done,
      inputFormatters: inputFormatters,
      cursorColor: AppColors.primary,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onFieldSubmitted: onFieldSubmitted,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 14,
        letterSpacing: 0.4,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 13.5,
          letterSpacing: 0,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.fieldBackground,
        prefixIcon: Icon(icon, size: 19, color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: AppColors.primary, width: 1.6),
        errorBorder: _border(color: AppColors.danger),
        focusedErrorBorder: _border(color: AppColors.danger, width: 1.6),
        errorStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 11,
          color: AppColors.danger,
        ),
      ),
    );
  }

  OutlineInputBorder _border({Color? color, double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color ?? AppColors.border, width: width),
    );
  }

  Widget _buildSecureNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'This is a demo payment gateway. No real money is charged and '
              'your details never leave this device.',
              style: TextStyle(
                fontFamily: 'Regular',
                fontSize: 11.5,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.6,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            'Processing payment...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'bold',
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Pay Rs ${widget.amount}',
                      style: const TextStyle(
                        fontFamily: 'bold',
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Groups card digits into blocks of four: `4242 4242 4242 4242`.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 16 ? digits.substring(0, 16) : digits;

    final buffer = StringBuffer();
    for (var i = 0; i < limited.length; i++) {
      buffer.write(limited[i]);
      final position = i + 1;
      if (position % 4 == 0 && position != limited.length) {
        buffer.write(' ');
      }
    }

    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Formats expiry input as `MM/YY`.
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limited = digits.length > 4 ? digits.substring(0, 4) : digits;

    var text = limited;
    if (limited.length > 2) {
      text = '${limited.substring(0, 2)}/${limited.substring(2)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
