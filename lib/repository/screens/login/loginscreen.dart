import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/account_store.dart';
import 'package:quick_kart/repository/screens/home/homescreen.dart';
import 'package:quick_kart/repository/screens/login/googleaccountsheet.dart';
import 'package:quick_kart/repository/screens/login/signupscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  String? _errorText;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _phoneFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String _normaliseMobileNumber(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 11 && digits.startsWith('0')) {
      return digits.substring(1);
    }
    return digits;
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _normaliseMobileNumber(_phoneController.text);

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    await AccountStore.load();
    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;

    if (!AccountStore.phoneExists(phone)) {
      setState(() {
        _isLoading = false;
        _errorText = 'No account found. Please create an account first.';
      });
      return;
    }

    final account = await AccountStore.authenticate(
      phone: phone,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (account == null) {
      setState(() {
        _isLoading = false;
        _errorText = 'Incorrect mobile number or password.';
      });
      return;
    }

    setState(() => _isLoading = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(phoneNumber: account.phone),
      ),
      (route) => false,
    );
  }

  Future<void> _openSignup() async {
    final registeredPhone = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );

    if (!mounted || registeredPhone == null) return;

    setState(() {
      _phoneController.text = registeredPhone;
      _passwordController.clear();
      _errorText = null;
    });
    _showMessage('Account created successfully. Please login to continue.');
    _passwordFocusNode.requestFocus();
  }

  Future<void> _handleGoogleLogin() async {
    FocusScope.of(context).unfocus();
    await AccountStore.load();

    if (!mounted) return;

    final profile = await showModalBottomSheet<GoogleProfile>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const GoogleAccountSheet(),
    );

    if (profile == null || !mounted) return;

    setState(() {
      _isGoogleLoading = true;
      _errorText = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 400));

    final account = await AccountStore.signInWithGoogle(
      name: profile.name,
      email: profile.email,
    );

    if (!mounted) return;

    setState(() => _isGoogleLoading = false);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomeScreen(phoneNumber: account.phone),
      ),
      (route) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Regular', fontSize: 14),
          ),
          backgroundColor: AppColors.ink,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildFormSheet()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 26),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 3),
                          Text(
                            '10 MIN DELIVERY',
                            style: TextStyle(
                              fontFamily: 'bold',
                              fontSize: 9.5,
                              letterSpacing: 0.8,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Quick',
                            style: TextStyle(
                              fontFamily: 'bold',
                              fontSize: 34,
                              height: 1,
                              letterSpacing: -1.6,
                              color: AppColors.ink,
                            ),
                          ),
                          Text(
                            'Kart',
                            style: TextStyle(
                              fontFamily: 'bold',
                              fontSize: 34,
                              height: 1,
                              letterSpacing: -1.6,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Daily essentials at lightning speed.',
                      style: TextStyle(
                        fontFamily: 'Regular',
                        fontSize: 13,
                        color: AppColors.ink.withValues(alpha: 0.62),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              _buildLogoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCard() {
    return SizedBox(
      width: 116,
      height: 124,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 10,
            left: 0,
            child: Container(
              width: 106,
              height: 106,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  'assets/images/quickkart_logo.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer_outlined, size: 12, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    '10 min',
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSheet() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 30,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 30),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: 26,
                      letterSpacing: -0.4,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Login with your mobile number and password to keep shopping.',
                    style: TextStyle(
                      fontFamily: 'Regular',
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildPhoneField(),
                  const SizedBox(height: 14),
                  _buildPasswordField(),
                  if (_errorText != null) ...[
                    const SizedBox(height: 14),
                    _buildErrorBox(),
                  ],
                  const SizedBox(height: 18),
                  _buildLoginButton(),
                  const SizedBox(height: 18),
                  _buildTrustRow(),
                  const SizedBox(height: 18),
                  _buildTermsText(),
                  const SizedBox(height: 20),
                  _buildDivider(),
                  const SizedBox(height: 18),
                  _buildGoogleButton(),
                  const SizedBox(height: 18),
                  _buildSignupLink(),
                ],
              ),
            ),
          ),
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
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 16,
        letterSpacing: 1,
        color: AppColors.textPrimary,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      onFieldSubmitted: (_) => _passwordFocusNode.requestFocus(),
      validator: (value) {
        final number = _normaliseMobileNumber(value ?? '');
        if (number.isEmpty) {
          return 'Please enter your mobile number';
        }
        if (number.length != 10 || !number.startsWith('3')) {
          return 'Enter a valid mobile number (e.g. 0300 1234567)';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Mobile number',
        hintStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.fieldBackground,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '+92',
                style: TextStyle(
                  fontFamily: 'bold',
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Container(width: 1, height: 22, color: AppColors.border),
            ],
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(color: AppColors.primary, width: 1.6),
        errorBorder: _fieldBorder(color: AppColors.danger),
        focusedErrorBorder: _fieldBorder(color: AppColors.danger, width: 1.6),
        errorStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 12,
          color: AppColors.danger,
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      focusNode: _passwordFocusNode,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      cursorColor: AppColors.primary,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 16,
        color: AppColors.textPrimary,
      ),
      onFieldSubmitted: (_) => _handleLogin(),
      validator: (value) {
        if ((value ?? '').isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: 'Password',
        hintStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.fieldBackground,
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          size: 20,
          color: AppColors.textSecondary,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() => _obscurePassword = !_obscurePassword);
          },
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            size: 19,
            color: AppColors.textSecondary,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(color: AppColors.primary, width: 1.6),
        errorBorder: _fieldBorder(color: AppColors.danger),
        focusedErrorBorder: _fieldBorder(color: AppColors.danger, width: 1.6),
        errorStyle: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 12,
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
      borderRadius: BorderRadius.circular(16),
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
                fontSize: 12,
                height: 1.45,
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
                    'Login',
                    style: TextStyle(
                      fontFamily: 'bold',
                      fontSize: 16,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
      ),
    );
  }

  Widget _buildTrustRow() {
    return Row(
      children: [
        Expanded(
          child: _buildTrustItem(
            icon: Icons.bolt_rounded,
            label: '10 min delivery',
          ),
        ),
        Container(width: 1, height: 22, color: AppColors.border),
        Expanded(
          child: _buildTrustItem(icon: Icons.eco_outlined, label: 'Farm fresh'),
        ),
        Container(width: 1, height: 22, color: AppColors.border),
        Expanded(
          child: _buildTrustItem(
            icon: Icons.lock_outline_rounded,
            label: 'Secure pay',
          ),
        ),
      ],
    );
  }

  Widget _buildTrustItem({required IconData icon, required String label}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: AppColors.primary),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Regular',
              fontSize: 10.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Regular',
          fontSize: 11.5,
          height: 1.5,
          color: AppColors.textSecondary,
        ),
        children: [
          const TextSpan(text: 'By continuing, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(
              fontFamily: 'bold',
              color: AppColors.textPrimary,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(
              fontFamily: 'bold',
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: TextStyle(
              fontFamily: 'Regular',
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(child: Divider(color: AppColors.border, thickness: 1)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: _isLoading || _isGoogleLoading ? null : _handleGoogleLogin,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isGoogleLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F3F4),
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontFamily: 'bold',
                        fontSize: 14,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Flexible(
                    child: Text(
                      'Continue with Google',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'bold',
                        fontSize: 14.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSignupLink() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        const Text(
          'New to QuickKart?',
          style: TextStyle(
            fontFamily: 'Regular',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: _openSignup,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Create an account',
            style: TextStyle(
              fontFamily: 'bold',
              fontSize: 13,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
