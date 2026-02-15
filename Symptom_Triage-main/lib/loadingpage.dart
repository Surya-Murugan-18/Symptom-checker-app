import 'package:flutter/material.dart';
import 'package:symtom_checker/login.dart';

// ✅ NEW IMPORTS (language system)
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';
import 'package:symtom_checker/userrole.dart';

class LanguageLoadingPage extends StatefulWidget {
  const LanguageLoadingPage({Key? key}) : super(key: key);

  @override
  State<LanguageLoadingPage> createState() => _LanguageLoadingPageState();
}

class _LanguageLoadingPageState extends State<LanguageLoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Navigate to Login after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const UserRolePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = const Color(0xFF1A9B8E);

    // ✅ CURRENT SELECTED LANGUAGE
    final lang = AppState.selectedLanguage;

    // ✅ LANGUAGE NAME
    final selectedLanguageText = {
      AppLanguage.tamil: 'தமிழ்',
      AppLanguage.english: 'English',
      AppLanguage.hindi: 'हिन्दी',
      AppLanguage.telugu: 'తెలుగు',
      AppLanguage.malayalam: 'മലയാളം',
      AppLanguage.marathi: 'मराठी',
    }[lang] ?? 'Loading...';

    // ✅ LANGUAGE DESCRIPTION
    final languageDescription = AppStrings.s('loading_desc', 'Health guidance in your language');

    // ✅ BIG BACKGROUND LETTER
    final backgroundGlyph = {
      AppLanguage.tamil: 'த',
      AppLanguage.english: 'E',
      AppLanguage.hindi: 'हि',
      AppLanguage.telugu: 'తెలుగు',
      AppLanguage.malayalam: 'മ',
      AppLanguage.marathi: 'मराठी',
    }[lang] ?? '';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Background glyph
            Positioned(
              right: -30,
              top: 360,
              child: Opacity(
                opacity: 0.08,
                child: Text(
                  backgroundGlyph,
                  style: const TextStyle(
                    fontSize: 300,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.only(left: 1.0, top: 22.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 52, vertical: 14),
                        decoration: const BoxDecoration(
                          color: Color(0x48FFFFFF),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(60),
                            bottomRight: Radius.circular(60),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Selected',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Language',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Center content
                Center(
                  child: Column(
                    children: [
                      Text(
                        selectedLanguageText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 86,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 36.0),
                        child: Text(
                          languageDescription,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Loader
                Center(
                  child: RotationTransition(
                    turns: _rotationController,
                    child: SizedBox(
                      width: 88,
                      height: 88,
                      child: CustomPaint(
                        painter: _RingPainter(),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 3),

                // Bottom indicator
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 120,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;

    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color.fromARGB(255, 71, 216, 207),
          Color.fromARGB(255, 113, 227, 220),
        ],
      ).createShader(
          Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.2,
      2.0,
      false,
      fgPaint,
    );

    final inner = Paint()..color = Colors.white.withOpacity(0.06);
    canvas.drawCircle(center, radius - 12, inner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
