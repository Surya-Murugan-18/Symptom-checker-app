import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'documentsverification.dart';

class DoctorVerificationProgress extends StatefulWidget {
  const DoctorVerificationProgress({Key? key}) : super(key: key);

  @override
  State<DoctorVerificationProgress> createState() =>
      _DoctorVerificationProgressState();
}

class _DoctorVerificationProgressState extends State<DoctorVerificationProgress>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    // Auto-navigate after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const DocumentsVerification(),
          ),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;
    final maxWidth = isDesktop ? 600.0 : screenWidth;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Animated Icon
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.clock,
                        color: const Color(0xFFFFA500),
                        size: 50,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Title
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Text(
                    'Verification In Progress',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isDesktop ? 28 : 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Text(
                    'Our team is reviewing your\ndocuments. This usually takes 24-\n48 hours.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isDesktop ? 16 : 14,
                      color: const Color(0xFF666666),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Status Steps
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusStep(
                          icon: FontAwesomeIcons.circleCheck,
                          label: 'Documents Submitted',
                          isCompleted: true,
                          isDesktop: isDesktop,
                        ),
                        const SizedBox(height: 20),
                        _buildStatusStep(
                          icon: FontAwesomeIcons.circleQuestion,
                          label: 'Under Review',
                          isCompleted: false,
                          isActive: true,
                          isDesktop: isDesktop,
                        ),
                        const SizedBox(height: 20),
                        _buildStatusStep(
                          icon: FontAwesomeIcons.circleCheck,
                          label: 'Approved',
                          isCompleted: false,
                          isDesktop: isDesktop,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Footer text
                FadeTransition(
                  opacity: _opacityAnimation,
                  child: Text(
                    "We'll notify you once verified",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isDesktop ? 14 : 13,
                      color: const Color(0xFFAAAAAA),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusStep({
    required IconData icon,
    required String label,
    required bool isCompleted,
    bool isActive = false,
    required bool isDesktop,
  }) {
    Color iconColor;
    Color labelColor;

    if (isCompleted) {
      iconColor = const Color(0xFF199A8E);
      labelColor = const Color(0xFF199A8E);
    } else if (isActive) {
      iconColor = const Color(0xFFFFA500);
      labelColor = const Color(0xFFFFA500);
    } else {
      iconColor = const Color(0xFFCCCCCC);
      labelColor = const Color(0xFFCCCCCC);
    }

    return Row(
      children: [
        FaIcon(
          icon,
          color: iconColor,
          size: isDesktop ? 22 : 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            fontWeight: FontWeight.w500,
            color: labelColor,
          ),
        ),
      ],
    );
  }
}
