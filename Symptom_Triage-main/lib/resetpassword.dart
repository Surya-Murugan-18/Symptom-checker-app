import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/newpassword.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';

class ResetPasswordPage extends StatefulWidget {
  final String contact; // Email or Phone
  final bool isEmail; // True if email, False if phone

  const ResetPasswordPage({
    super.key,
    required this.contact,
    required this.isEmail,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  static const Color _primary = Color(0xFF0BA68C);
  static const Color _hint = Color(0xFF98A2B3);
  static const Color _darkText = Color(0xFF1F2937);
  static const double _maxContentWidth = 480;

  late List<TextEditingController> _otpControllers;
  late List<FocusNode> _otpFocusNodes;
  bool _showSuccessMessage = false;
  String _successMessage = '';

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(4, (index) => TextEditingController());
    _otpFocusNodes = List.generate(4, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String _getMaskedContact() {
    if (widget.isEmail) {
      // Mask email: su***@gmail.com
      final parts = widget.contact.split('@');
      if (parts.length == 2) {
        final local = parts[0];
        final domain = parts[1];
        if (local.length > 2) {
          return '${local.substring(0, 2)}***@$domain';
        }
      }
      return '${widget.contact.substring(0, 2)}***';
    } else {
      // Mask phone: 08528188***
      if (widget.contact.length >= 5) {
        return '${widget.contact.substring(0, widget.contact.length - 3)}***';
      }
      return widget.contact;
    }
  }

  String _getSubtitleText() {
  final lang = AppState.selectedLanguage;
  final strings = AppStrings.data[lang]!;

  final masked = _getMaskedContact();

  if (widget.isEmail) {
    return strings['otp_email_subtitle']!
        .replaceAll('{value}', masked);
  } else {
    return strings['otp_phone_subtitle']!
        .replaceAll('{value}', masked);
  }
}


  void _onOtpChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 3) {
        _otpFocusNodes[index + 1].requestFocus();
      } else {
        _otpFocusNodes[index].unfocus();
      }
    }
  }

  void _onOtpBackspace(int index, String value) {
    if (value.isEmpty && index > 0) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  bool _isVerifying = false;

  Future<void> _handleResend() async {
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.contact}),
      );

      if (!mounted) return;

      setState(() {
        _showSuccessMessage = true;
        for (var controller in _otpControllers) {
          controller.clear();
        }
        if (response.statusCode == 200) {
          _successMessage = widget.isEmail
              ? strings['otp_resend_email_success']!
              : strings['otp_resend_phone_success']!;
        } else {
          _successMessage = 'Failed to resend code';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _showSuccessMessage = true;
        _successMessage = 'Connection error';
      });
    }

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showSuccessMessage = false);
      }
    });
  }

  Future<void> _handleVerify() async {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 4-digit code'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/verify-code'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.contact,
          'code': code,
        }),
      );

      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (response.statusCode == 200) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => NewPasswordPage(
              email: widget.contact,
              code: code,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid or expired code'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
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
                constraints:
                    const BoxConstraints(maxWidth: _maxContentWidth),
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
                        strings['otp_title']!,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _darkText,
                              fontSize: isMobile ? 24 : 28,
                            ),
                      ),

                      SizedBox(height: isMobile ? 10 : 12),

                      // Subtitle with masked contact
                      AnimatedOpacity(
                        opacity: _showSuccessMessage ? 0.5 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _getSubtitleText(),
                          style: TextStyle(
                            color: _hint,
                            fontSize: isMobile ? 14 : 15,
                            height: 1.4,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 24 : 32),

                      // Success Message
                      AnimatedOpacity(
                        opacity: _showSuccessMessage ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          margin: EdgeInsets.only(
                            bottom: _showSuccessMessage ? 16 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: _primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: _primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _successMessage,
                                  style: TextStyle(
                                    color: _primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(4, (index) {
                          return _OTPInputField(
                            controller: _otpControllers[index],
                            focusNode: _otpFocusNodes[index],
                            onChanged: (value) =>
                                _onOtpChanged(index, value),
                            onBackspace: (value) =>
                                _onOtpBackspace(index, value),
                            primary: _primary,
                          );
                        }),
                      ),

                      SizedBox(height: isMobile ? 28 : 36),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: isMobile ? 52 : 56,
                        child: ElevatedButton(
                          onPressed: _isVerifying ? null : _handleVerify,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primary,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                            textStyle: TextStyle(
                              fontSize: isMobile ? 15 : 17,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 0,
                          ),
                          child: Text(strings['verify']!),
                        ),
                      ),

                      SizedBox(height: isMobile ? 18 : 24),

                      // Resend Link
                      Center(
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: strings['otp_not_received']!,
                                style: TextStyle(
                                  color: _hint,
                                  fontSize: isMobile ? 13 : 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextSpan(
                                text: strings['resend']!,
                                style: TextStyle(
                                  color: _primary,
                                  fontSize: isMobile ? 13 : 14,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.none,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _handleResend,
                              ),
                            ],
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

class _OTPInputField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onBackspace;
  final Color primary;

  const _OTPInputField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
    required this.primary,
  });

  @override
  State<_OTPInputField> createState() => _OTPInputFieldState();
}

class _OTPInputFieldState extends State<_OTPInputField> {
  late FocusNode _internalFocusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode;
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _internalFocusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final inputSize = isMobile ? 60.0 : 72.0;

    return SizedBox(
      width: inputSize,
      height: inputSize,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) {
          if (event.isKeyPressed(LogicalKeyboardKey.backspace)) {
            widget.onBackspace(widget.controller.text);
          }
        },
        child: TextField(
          controller: widget.controller,
          focusNode: _internalFocusNode,
          maxLength: 1,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: _isFocused
                    ? widget.primary
                    : Colors.grey.shade300,
                width: _isFocused ? 2 : 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: widget.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          cursorColor: widget.primary,
        ),
      ),
    );
  }
}
