import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/services/alarm_service.dart';

import 'package:http/http.dart' as http;
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';

class AlarmTriggerPage extends StatelessWidget {
  final int alarmId;
  final String medicineName;
  final String dosage;

  const AlarmTriggerPage({
    Key? key,
    required this.alarmId,
    required this.medicineName,
    required this.dosage,
  }) : super(key: key);

  Future<void> _recordDose(BuildContext context, String action) async {
    final medicationId = alarmId ~/ 100;
    final url = "${ApiConfig.baseUrl}/medications/$medicationId/$action";
    
    try {
      await http.post(
        Uri.parse(url),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );
    } catch (e) {
      debugPrint("Error recording $action: $e");
    }

    await AlarmService().stopAlarm(alarmId);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF199A8E),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Animated Heartbeat/Pill Icon
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.capsules,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Time for Medication!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              medicineName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              dosage,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            // Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Column(
                children: [
                  // TAKE BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () => _recordDose(context, 'take-dose'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF199A8E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'I HAVE TAKEN IT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // SNOOZE BUTTON
                  TextButton.icon(
                    onPressed: () async {
                      await AlarmService().stopAlarm(alarmId);
                      
                      // Reschedule for 10 minutes later
                      final snoozeTime = DateTime.now().add(const Duration(minutes: 10));
                      await AlarmService().setAlarm(
                        id: alarmId,
                        dateTime: snoozeTime,
                        assetPath: 'assets/OPPO.mp3',
                        title: "Snoozed: $medicineName",
                        body: "$medicineName, $dosage",
                      );
                      
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: const Icon(Icons.snooze, color: Colors.white),
                    label: const Text(
                      'Snooze (10 mins)',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),

                  // SKIP BUTTON
                  TextButton(
                    onPressed: () => _recordDose(context, 'skip-dose'),
                    child: const Text(
                      'Skip this dose',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
