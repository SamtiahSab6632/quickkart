import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/account_store.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmFocusNode = FocusNode();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  String _normaliseMobileNumber(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 11 && digits.startsWith('0')) {
      return digits.substring(1);
    }
    return digits;
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _normaliseMobileNumber(_phoneController.text);
    if (phone.isEmpty) return;

    await AccountStore.load();

    if (!mounted) return;

    if (AccountStore.phoneExists(phone)) {
      setState(() {
        _errorText =
            'This mobile number is already registered. Please login instead.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 400));

    final account = await AccountStore.register(
      name: _nameController.text,
      phone: phone,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (account == null) {
      setState(() {
        _isLoading = false;
        _errorText = 'Could not create the account. Please try again.';
      });
      return;
    }

    setState(() => _isLoading = false);

    // Signup only creates the account. Clear the active session so the user
    // comes back to the login screen and signs in with the new credentials.
    AccountStore.logout();
    Navigator.of(context).pop(account.phone);
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
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          title: const Text(
            'Sign up',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildIntro(),
                      const SizedBox(height: 20),
                      _buildFormCard(),
                      const SizedBox(height: 18),
                      _buildLoginLink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.24),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/images/quickkart_logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Create your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'bold',
            fontSize: 24,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sign up with your mobile number and start shopping in minutes.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Regular',
            fontSize: 12.5,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A101828),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildField(
            controller: _nameController,
            hint: 'Full name',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _phoneFocusNode.requestFocus(),
            validator: (value) {
              if ((value ?? '').trim().length < 2) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildPhoneField(),
          const SizedBox(height: 14),
          _buildField(
            controller: _passwordController,
            focusNode: _passwordFocusNode,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            onToggleObscure: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _confirmFocusNode.requestFocus(),
            validator: (value) {
              final password = value ?? '';
              if (password.isEmpty) return 'Please create a password';
              if (password.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _confirmController,
            focusNode: _confirmFocusNode,
            hint: 'Confirm password',
            icon: Icons.lock_reset_rounded,
            obscure: _obscureConfirm,
            onToggleObscure: () {
              setState(() => _obscureConfirm = !_obscureConfirm);
            },
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleSignup(),
            validator: (value) {
              if ((value ?? '').isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 14),
            _buildErrorBox(),
          ],
          const SizedBox(height: 20),
          _buildSignupButton(),
          const SizedBox(height: 14),
          const Text(
            'By creating an account, you agree to our Terms of Service and Privacy Policy.',
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
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputAction textInputAction = TextInputAction.next,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      obscureText: obscure,
      textInputAction: textInputAction,
      cursorColor: AppColors.primary,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 14.5,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.fieldBackground,
        prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
        suffixIcon: onToggleObscure == null
            ? null
            : IconButton(
                onPressed: onToggleObscure,
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 19,
                  color: AppColors.textSecondary,
                ),
              ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(color: AppColors.primary, width: 1.6),
        errorBorder: _fieldBorder(color: AppColors.danger),
        focusedErrorBorder: _fieldBorder(color: AppColors.danger, width: 1.6),
        errorStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 11.5,
          color: AppColors.danger,
        ),
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      focusNode: _phoneFocusNode,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      cursorColor: AppColors.primary,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      validator: (value) {
        final number = _normaliseMobileNumber(value ?? '');
        if (number.isEmpty) return 'Please enter your mobile number';
        if (number.length != 10 || !number.startsWith('3')) {
          return 'Enter a valid mobile number (e.g. 0300 1234567)';
        }
        return null;
      },
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 14.5,
        letterSpacing: 0.6,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: 'Mobile number',
        hintStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.fieldBackground,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '+92',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 9),
              Container(width: 1, height: 20, color: AppColors.border),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(color: AppColors.primary, width: 1.6),
        errorBorder: _fieldBorder(color: AppColors.danger),
        focusedErrorBorder: _fieldBorder(color: AppColors.danger, width: 1.6),
        errorStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 11.5,
          color: AppColors.danger,
        ),
      ),
    );
  }

  OutlineInputBorder _fieldBorder({
    Color color = AppColors.border,
    double width = 1,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _buildErrorBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 17,
            color: AppColors.danger,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              _errorText!,
              style: const TextStyle(
                fontFamily: 'Regular',
                fontSize: 11.5,
                height: 1.45,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignup,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create account',
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: 15.5,
                      letterSpacing: 0.1,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'Already have an account?',
          style: TextStyle(
            fontFamily: 'Regular',
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Login',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 12.5,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
