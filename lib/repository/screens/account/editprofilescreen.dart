import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quick_kart/domain/constants/appcolors.dart';
import 'package:quick_kart/domain/data/account_store.dart';
import 'package:quick_kart/domain/models/account.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.account});

  final Account account;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late String _photoBase64;

  bool _isSaving = false;
  bool _isPickingPhoto = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account.name);
    _phoneController = TextEditingController(text: widget.account.phone);
    _emailController = TextEditingController(text: widget.account.email);
    _photoBase64 = widget.account.photoBase64;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String _normaliseMobileNumber(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 11 && digits.startsWith('0')) {
      return digits.substring(1);
    }
    return digits;
  }

  Uint8List? get _photoBytes {
    if (_photoBase64.isEmpty) return null;
    try {
      return base64Decode(_photoBase64);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickPhoto() async {
    if (_isPickingPhoto) return;

    setState(() => _isPickingPhoto = true);

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 700,
        maxHeight: 700,
        imageQuality: 82,
        requestFullMetadata: false,
      );

      if (picked == null) {
        if (mounted) setState(() => _isPickingPhoto = false);
        return;
      }

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        _photoBase64 = base64Encode(bytes);
        _isPickingPhoto = false;
        _errorText = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPickingPhoto = false;
        _errorText = 'Could not open the gallery. Please try again.';
      });
    }
  }

  void _removePhoto() {
    setState(() => _photoBase64 = '');
  }

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = widget.account.isGoogleAccount
        ? widget.account.phone
        : _normaliseMobileNumber(_phoneController.text);
    final email = widget.account.isGoogleAccount
        ? _emailController.text.trim().toLowerCase()
        : widget.account.email;

    if (!widget.account.isGoogleAccount &&
        phone != widget.account.phone &&
        AccountStore.phoneExists(phone)) {
      setState(() {
        _errorText = 'This mobile number is already registered.';
      });
      return;
    }

    if (widget.account.isGoogleAccount &&
        email != widget.account.email &&
        AccountStore.emailExists(email)) {
      setState(() {
        _errorText = 'This Google email is already in use.';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorText = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));

    final updated = await AccountStore.updateCurrentUser(
      name: _nameController.text,
      phone: phone,
      email: email,
      photoBase64: _photoBase64,
    );

    if (!mounted) return;

    if (updated == null) {
      setState(() {
        _isSaving = false;
        _errorText = 'Could not update your profile. Please try again.';
      });
      return;
    }

    setState(() => _isSaving = false);
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit profile'), centerTitle: true),
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
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildFormCard(),
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
    final initial = widget.account.name.trim().isEmpty
        ? 'Q'
        : widget.account.name.trim().characters.first.toUpperCase();

    final photo = _photoBytes;

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.26),
                    blurRadius: 20,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: ClipOval(
                child: photo == null
                    ? Text(
                        initial,
                        style: const TextStyle(
                          fontFamily: 'bold',
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      )
                    : Image.memory(
                        photo,
                        width: 92,
                        height: 92,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        errorBuilder: (context, error, stackTrace) => Text(
                          initial,
                          style: const TextStyle(
                            fontFamily: 'bold',
                            fontSize: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: GestureDetector(
                onTap: _isPickingPhoto ? null : _pickPhoto,
                child: Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: _isPickingPhoto
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.photo_camera_rounded,
                          size: 17,
                          color: Colors.white,
                        ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _isPickingPhoto ? null : _pickPhoto,
              icon: const Icon(Icons.photo_library_outlined, size: 17),
              label: Text(
                photo == null ? 'Choose from gallery' : 'Change photo',
              ),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                textStyle: const TextStyle(fontFamily: 'bold', fontSize: 12.5),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            if (photo != null) ...[
              Container(width: 1, height: 18, color: AppColors.border),
              TextButton(
                onPressed: _removePhoto,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Remove photo',
                  style: TextStyle(
                    fontFamily: 'bold',
                    fontSize: 12.5,
                    color: AppColors.danger,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Profile details',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'bold',
            fontSize: 23,
            letterSpacing: -0.4,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          widget.account.isGoogleAccount
              ? 'Add a profile photo and update your name or Google email.'
              : 'Add a profile photo and update your name or mobile number.',
          textAlign: TextAlign.center,
          style: const TextStyle(
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
          TextFormField(
            key: const ValueKey('profile-name-field'),
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
              final name = (value ?? '').trim();
              if (name.isEmpty) return 'Please enter your full name';
              if (name.length < 2) return 'Name is too short';
              return null;
            },
            decoration: _inputDecoration(
              hint: 'Full name',
              icon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 14),
          if (widget.account.isGoogleAccount)
            _buildEmailField()
          else
            _buildPhoneField(),
          if (_errorText != null) ...[
            const SizedBox(height: 14),
            _buildErrorBox(),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.6,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: _isSaving
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
                          'Save changes',
                          style: TextStyle(
                            fontFamily: 'bold',
                            fontSize: 15.5,
                            letterSpacing: 0.1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.check_rounded, size: 18),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      key: const ValueKey('profile-phone-field'),
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      cursorColor: AppColors.primary,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onFieldSubmitted: (_) => _saveProfile(),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 14.5,
        letterSpacing: 0.6,
        color: AppColors.textPrimary,
      ),
      validator: (value) {
        final number = _normaliseMobileNumber(value ?? '');
        if (number.isEmpty) return 'Please enter your mobile number';
        if (number.length != 10 || !number.startsWith('3')) {
          return 'Enter a valid mobile number (e.g. 0300 1234567)';
        }
        return null;
      },
      decoration: _inputDecoration(
        hint: 'Mobile number',
        icon: Icons.phone_outlined,
        prefix: Padding(
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
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      key: const ValueKey('profile-email-field'),
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      cursorColor: AppColors.primary,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onFieldSubmitted: (_) => _saveProfile(),
      inputFormatters: [LengthLimitingTextInputFormatter(120)],
      style: const TextStyle(
        fontFamily: 'Regular',
        fontSize: 14.5,
        color: AppColors.textPrimary,
      ),
      validator: (value) {
        final email = (value ?? '').trim();
        if (email.isEmpty) return 'Please enter your Google email';
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
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? prefix,
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
      prefixIcon:
          prefix ?? Icon(icon, size: 20, color: AppColors.textSecondary),
      prefixIconConstraints: prefix == null
          ? null
          : const BoxConstraints(minWidth: 0, minHeight: 0),
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
}
