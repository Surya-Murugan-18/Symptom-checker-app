import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/signin.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';

class NewPasswordPage extends StatefulWidget {
  final String email;
  final String code;

  const NewPasswordPage({super.key, required this.email, required this.code});

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  static const Color _primary = Color(0xFF0BA68C);
  static const Color _hint = Color(0xFF98A2B3);
  static const Color _darkText = Color(0xFF1F2937);
  static const Color _errorColor = Color(0xFFEF4444);
  static const double _maxContentWidth = 480;

  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  late FocusNode _newPasswordFocus;
  late FocusNode _confirmPasswordFocus;

  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String? _newPasswordError;
  String? _confirmPasswordError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _newPasswordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();

    _newPasswordController.addListener(_validateNewPassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;

    if (value == null || value.isEmpty) {
      return strings['pwd_empty']!;
    }
    if (value.length < 8) {
      return strings['pwd_len']!;
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return strings['pwd_upper']!;
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return strings['pwd_number']!;
    }
    if (!value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      return strings['pwd_symbol']!;
    }
    return null;
  }

  void _validateNewPassword() {
    setState(() {
      _newPasswordError = _validatePassword(_newPasswordController.text);
    });
  }

  void _validateConfirmPassword() {
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;

    setState(() {
      if (_confirmPasswordController.text.isEmpty) {
        _confirmPasswordError = strings['pwd_empty']!;
      } else if (_confirmPasswordController.text != _newPasswordController.text) {
        _confirmPasswordError = strings['pwd_mismatch']!;
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _isFormValid() {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // Check if new password has no errors
    if (_validatePassword(newPassword) != null) {
      return false;
    }

    // Check if confirm password matches
    if (confirmPassword.isEmpty || confirmPassword != newPassword) {
      return false;
    }

    return true;
  }

  void _showSuccessDialog() {
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;
    final isMobile = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white, // ✅ FORCE WHITE
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 32,
                vertical: isMobile ? 72 : 40,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_circle,
                        color: _primary,
                        size: 48,
                      ),
                    ),
                  ),

                  SizedBox(height: isMobile ? 24 : 28),

                  // Success Title
                  Text(
                    strings['success']!,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _darkText,
                          fontSize: isMobile ? 22 : 26,
                        ),
                  ),

                  SizedBox(height: isMobile ? 12 : 16),

                  // Success Message
                  Text(
                    strings['password_reset_success']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _hint,
                      fontSize: isMobile ? 14 : 15,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: isMobile ? 28 : 36),

                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: isMobile ? 48 : 52,
                    child: ElevatedButton(
                      onPressed: () {
Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignInPage()),
                      );                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        textStyle: TextStyle(
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                        elevation: 0,
                      ),
                      child: Text(strings['login']!),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleCreatePassword() async {
    if (!_isFormValid()) {
      _validateNewPassword();
      _validateConfirmPassword();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'code': widget.code,
          'newPassword': _newPasswordController.text,
        }),
      );

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (response.statusCode == 200) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.body}'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 20 : 32,
                      vertical: isMobile ? 16 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back Button
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                              color: _darkText,
                            ),
                          ),
                        ),

                        SizedBox(height: isMobile ? 20 : 28),

                        // Title
                        Text(
                          strings['create_new_password']!,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: _darkText,
                                fontSize: isMobile ? 24 : 28,
                              ),
                        ),

                        SizedBox(height: isMobile ? 8 : 10),

                        // Subtitle
                        Text(
                          strings['create_password_desc']!,
                          style: TextStyle(
                            color: _hint,
                            fontSize: isMobile ? 14 : 15,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        SizedBox(height: isMobile ? 28 : 36),

                        // New Password Field
                        _buildPasswordField(
                          label: strings['new_password']!,
                          controller: _newPasswordController,
                          focusNode: _newPasswordFocus,
                          showPassword: _showNewPassword,
                          onShowPasswordToggle: () {
                            setState(() {
                              _showNewPassword = !_showNewPassword;
                            });
                          },
                          error: _newPasswordError,
                          isMobile: isMobile,
                        ),

                        SizedBox(height: isMobile ? 18 : 24),

                        // Confirm Password Field
                        _buildPasswordField(
                          label: strings['confirm_password']!,
                          controller: _confirmPasswordController,
                          focusNode: _confirmPasswordFocus,
                          showPassword: _showConfirmPassword,
                          onShowPasswordToggle: () {
                            setState(() {
                              _showConfirmPassword = !_showConfirmPassword;
                            });
                          },
                          error: _confirmPasswordError,
                          isMobile: isMobile,
                        ),

                        SizedBox(height: isMobile ? 32 : 40),

                        // Create Password Button
                        SizedBox(
                          width: double.infinity,
                          height: isMobile ? 52 : 56,
                          child: ElevatedButton(
                            onPressed:
                                _isSubmitting ? null : _handleCreatePassword,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primary,
                              disabledBackgroundColor: _primary.withOpacity(0.5),
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              textStyle: TextStyle(
                                fontSize: isMobile ? 16 : 17,
                                fontWeight: FontWeight.w600,
                              ),
                              elevation: 0,
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                                    height: isMobile ? 24 : 28,
                                    width: isMobile ? 24 : 28,
                                    child: const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(strings['create_password_button']!),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool showPassword,
    required VoidCallback onShowPasswordToggle,
    required String? error,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: TextStyle(
            color: _darkText,
            fontSize: isMobile ? 16 : 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: isMobile ? 8 : 10),

        // Password Input Field
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: error != null ? _errorColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: !showPassword,
            style: TextStyle(
              color: _darkText,
              fontSize: isMobile ? 15 : 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: TextStyle(
                color: _hint,
                fontSize: isMobile ? 15 : 16,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 18,
                vertical: isMobile ? 14 : 16,
              ),
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.lock_outline,
                  color: _primary,
                  size: isMobile ? 20 : 22,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(),
              suffixIcon: GestureDetector(
                onTap: onShowPasswordToggle,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    showPassword ? Icons.visibility : Icons.visibility_off,
                    color: _hint,
                    size: isMobile ? 20 : 22,
                  ),
                ),
              ),
              suffixIconConstraints: const BoxConstraints(),
            ),
            cursorColor: _primary,
          ),
        ),

        // Error Message
        if (error != null) ...[
          SizedBox(height: isMobile ? 6 : 8),
          Text(
            error,
            style: TextStyle(
              color: _errorColor,
              fontSize: isMobile ? 12 : 13,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}
