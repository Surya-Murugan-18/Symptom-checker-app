import 'package:flutter/material.dart';
import 'package:symtom_checker/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Loading',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'SF Pro',
      ),
      home: const LanguageLoadingPage(),
    );
  }
}

class LanguageLoadingPage extends StatefulWidget {
  const LanguageLoadingPage({Key? key}) : super(key: key);

  @override
  State<LanguageLoadingPage> createState() => _LanguageLoadingPageState();
}

class _LanguageLoadingPageState extends State<LanguageLoadingPage>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;

  final String selectedLanguage = 'हिन्दी';
  final String languageDescription = 'आपकी भाषा में बुनियादी स्वास्थ्य संबंधी मार्गदर्शन';

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
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

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            // Big faint background glyph on the right
            Positioned(
              right: -50,
              top: 350,
              child: Opacity(
                opacity: 0.08,
                child: Text(
                  'हि',
                  style: TextStyle(
                    fontSize: 300,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Main content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header pill
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
                      // small spacer to emphasize pill style
                      const SizedBox(width: 8),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Centered language text and description
                Center(
                  child: Column(
                    children: [
                      Text(
                        selectedLanguage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 86,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 36.0),
                        child: Text(
                          languageDescription,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Circular progress
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

                // Bottom home indicator
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
        colors: [Color.fromARGB(255, 71, 216, 207), Color.fromARGB(255, 113, 227, 220)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Draw arc segment
    const start = -1.2; // radians
    const sweep = 2.0;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep,
        false, fgPaint);

    // inner small circle to match the look
    final inner = Paint()..color = Colors.white.withOpacity(0.06);
    canvas.drawCircle(center, radius - 12, inner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
