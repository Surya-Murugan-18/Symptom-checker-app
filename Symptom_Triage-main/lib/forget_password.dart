import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/resetpassword.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';

/// Forgot password screen that mirrors the provided design with
class ForgetPasswordPage extends StatefulWidget {
  const ForgetPasswordPage({super.key});

  @override
  State<ForgetPasswordPage> createState() => _ForgetPasswordPageState();
}

enum _InputMode { email, phone }

class _ForgetPasswordPageState extends State<ForgetPasswordPage> {
  static const Color _primary = Color(0xFF0BA68C);
  static const Color _hint = Color(0xFF98A2B3);
  static const double _maxContentWidth = 480;
  final TextEditingController _emailController = TextEditingController(
    text: '',
  );
  
  final TextEditingController _phoneController = TextEditingController();

  _InputMode _mode = _InputMode.email;
  bool _emailTouched = false;
  bool _phoneTouched = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;

    if (value == null || value.isEmpty) {
      return strings['email_empty']!;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return strings['email_invalid']!;
    }

    return null;
  }

  String? _validateContact(String? value) {
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;

    if (value == null || value.trim().isEmpty) {
      return strings['contact_required']!;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return strings['contact_numbers_only']!;
    }

    if (value.length < 10) {
      return strings['contact_min_len']!;
    }

    return null;
  }

  String? get _currentValidationError {
    if (_mode == _InputMode.email) {
      if (!_emailTouched) return null;
      return _validateEmail(_emailController.text);
    } else {
      if (!_phoneTouched) return null;
      return _validateContact(_phoneController.text);
    }
  }

  bool get _isInputValid {
    return _currentValidationError == null &&
        (_mode == _InputMode.email
            ? _emailController.text.isNotEmpty
            : _phoneController.text.isNotEmpty);
  }

  bool _isSending = false;

  Future<void> _submit() async {
    final error = _currentValidationError;

    if (error != null) {
      return;
    }

    final value = _mode == _InputMode.email
        ? _emailController.text.trim()
        : _phoneController.text.trim();

    if (_mode == _InputMode.email) {
      setState(() => _isSending = true);
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': value}),
        );

        if (!mounted) return;
        setState(() => _isSending = false);

        if (response.statusCode == 200) {
          // Navigate to Reset Password page with contact info
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ResetPasswordPage(
                contact: value,
                isEmail: true,
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.body), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection error: $e'), backgroundColor: Colors.red),
        );
      }
    } else {
      // Phone mode — navigate directly (backend doesn't support phone reset yet)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(
            contact: value,
            isEmail: false,
          ),
        ),
      );
    }
  }

  

  @override
 Widget build(BuildContext context) {
  final lang = AppState.selectedLanguage;
  final strings = AppStrings.data[lang]!;

  return AnnotatedRegion<SystemUiOverlayStyle>(
    value: SystemUiOverlayStyle.dark,
    child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxWidth: _maxContentWidth),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                            ),
                            onPressed: () =>
                                Navigator.of(context).maybePop(),
                            splashRadius: 20,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(
                        strings['forgot_password_title']!,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        strings['forgot_password_desc']!,
                        style: const TextStyle(
                          color: _hint,
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w400,
                        ),
                      ),

                      const SizedBox(height: 28),

                      _SegmentedControl(
                        primary: _primary,
                        hint: _hint,
                        mode: _mode,
                        onChanged: (mode) =>
                            setState(() => _mode = mode),
                      ),

                      const SizedBox(height: 18),

                      _InputField(
                        primary: _primary,
                        hint: _hint,
                        isEmail: _mode == _InputMode.email,
                        controller: _mode == _InputMode.email
                            ? _emailController
                            : _phoneController,
                        isValid: _isInputValid,
                        errorMessage: _currentValidationError,
                        onChanged: (value) {
                          if (_mode == _InputMode.email) {
                            _emailTouched = true;
                          } else {
                            _phoneTouched = true;
                          }
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 0,
                          ),
                          child: _isSending
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  strings['reset_password']!,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

}

class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({
    required this.primary,
    required this.hint,
    required this.mode,
    required this.onChanged,
  });

  final Color primary;
  final Color hint;
  final _InputMode mode;
  final ValueChanged<_InputMode> onChanged;

  @override
 Widget build(BuildContext context) {
  final lang = AppState.selectedLanguage;
  final strings = AppStrings.data[lang]!;

  return Container(
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(28),
    ),
    padding: const EdgeInsets.all(4),
    child: Row(
      children: [
        Expanded(
          child: _SegmentButton(
            label: strings['email']!,
            selected: mode == _InputMode.email,
            primary: primary,
            hint: hint,
            onTap: () => onChanged(_InputMode.email),
          ),
        ),
        Expanded(
          child: _SegmentButton(
            label: strings['phone']!,
            selected: mode == _InputMode.phone,
            primary: primary,
            hint: hint,
            onTap: () => onChanged(_InputMode.phone),
          ),
        ),
      ],
    ),
  );
}

}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.selected,
    required this.primary,
    required this.hint,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color primary;
  final Color hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? primary : hint,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.primary,
    required this.hint,
    required this.isEmail,
    required this.controller,
    required this.isValid,
    this.errorMessage,
    this.onChanged,
  });

  final Color primary;
  final Color hint;
  final bool isEmail;
  final TextEditingController controller;
  final bool isValid;
  final String? errorMessage;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
  final lang = AppState.selectedLanguage;
  final strings = AppStrings.data[lang]!;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: controller,
          keyboardType: isEmail
              ? TextInputType.emailAddress
              : TextInputType.phone,
          inputFormatters: isEmail
              ? null
              : [FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]'))],
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(
                isEmail ? Icons.mail_outline : Icons.phone_outlined,
                color: primary,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            suffixIcon: isValid
                ? Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(Icons.check, color: primary),
                  )
                : null,

            // ✅ LOCALIZED HERE
            hintText: isEmail
                ? strings['email_hint']!
                : strings['phone_hint']!,

            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(
                color: errorMessage != null
                    ? Colors.red.shade300
                    : Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(28),
              borderSide: BorderSide(
                color: errorMessage != null ? Colors.red : primary,
                width: 1.2,
              ),
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      if (errorMessage != null) ...[
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            errorMessage!,
            style: TextStyle(
              color: Colors.red.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ],
  );
}

}
