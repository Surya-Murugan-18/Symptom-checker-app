import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:symtom_checker/languageselection.dart';
import 'package:symtom_checker/homepage.dart';
import 'package:symtom_checker/services/alarm_service.dart';
import 'package:symtom_checker/services/notification_service.dart';
import 'package:symtom_checker/alarm_trigger_page.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/foundation.dart';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:http/http.dart' as http;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe and Alarms only on mobile platforms
  if (!kIsWeb) {
    try {
      Stripe.publishableKey = "pk_test_51Pzzzzzzzzzzzzzz"; // Placeholder
      await Stripe.instance.applySettings();
      await AlarmService().init();
    } catch (e) {
      debugPrint("Service initialization failed: $e");
    }
  }

  await NotificationService().init();
  
  if (!kIsWeb) {
    Alarm.ringStream.stream.listen((alarmSettings) {
      debugPrint("Alarm ringing for ID: ${alarmSettings.id}");
      
      final bodyParts = alarmSettings.notificationSettings.body.split(', ');
      final medicineName = bodyParts.isNotEmpty ? bodyParts[0] : 'Medicine';
      final dosage = bodyParts.length > 1 ? bodyParts[1] : '';

      // Show a local pop-up notification
      NotificationService.showNotification(
        "Medication Reminder",
        "It's time for $medicineName ($dosage)",
      );

      // Save to backend notification box
      final userId = UserSession().userId;
      if (userId != null) {
        http.post(
          Uri.parse("${ApiConfig.baseUrl}/users/$userId/notifications"),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${UserSession().token}",
          },
          body: jsonEncode({
            "title": "Medication Reminder",
            "message": "It's time for $medicineName ($dosage)",
            "type": "MEDICATION"
          }),
        ).catchError((e) => debugPrint("Error saving medication notif: $e"));
      }

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => AlarmTriggerPage(
            alarmId: alarmSettings.id,
            medicineName: medicineName,
            dosage: dosage,
          ),
        ),
      );
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/homepage':
            return MaterialPageRoute(builder: (context) => const HealthcareHomePage());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LanguageSelectionPage());
          default:
            return null;
        }
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LanguageSelectionPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/logo.png',
                  width: 200,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1BAA9A).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        size: 100,
                        color: Color(0xFF1BAA9A),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  'Sev-ai',
                  style: TextStyle(
                    fontSize: 62,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1BAA9A),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
