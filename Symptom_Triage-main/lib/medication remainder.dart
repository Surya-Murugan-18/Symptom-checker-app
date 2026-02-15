import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/medication%202.dart';
import 'package:symtom_checker/language/app_strings.dart';

class MedicationReminderScreen extends StatelessWidget {
  const MedicationReminderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Pill Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFF199A8E).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: FaIcon(
                        FontAwesomeIcons.pills,
                        color: Color(0xFF199A8E),
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Title
                  Text(
                    AppStrings.s('medication_reminders_title', 'Medication Reminders'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  // Subtitle
                  Text(
                    AppStrings.s('medication_reminders_desc', 'Set reminders to take medicines on time as\nprescribed by your doctor.'),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  
                  // Features List
                 Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 249, 250, 250), // grey background
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD1D5DB), // grey outline
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        icon: FontAwesomeIcons.bell,
                        text: AppStrings.s('never_miss_dose', 'Never miss a dose'),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        icon: FontAwesomeIcons.circleCheck,
                        text: AppStrings.s('simple_alerts', 'Simple alerts'),
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        icon: FontAwesomeIcons.capsules,
                        text: AppStrings.s('easy_to_manage', 'Easy to manage'),
                      ),
                    ],
                  ),
                ),
                  const SizedBox(height: 60),
                  
                  // Add Reminder Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                              context,
                              MaterialPageRoute(
                                settings: const RouteSettings(name: '/medication_list'),
                                builder: (context) => MedicationReminders(),
                              ),
                            );
                        // Add your button action here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF199A8E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppStrings.s('lets_begin', 'Lets Begin'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Disclaimer
                  Text(
                    AppStrings.s('medical_disclaimer', 'This app does not provide medical advice.'),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
  required IconData icon,
  required String text,
}) {
  return Row(
    children: [
        const SizedBox(width: 20),
      /// Icon circle
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white, // white icon background
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD1D5DB), // grey outline
            width: 1,
          ),
        ),
        child: Center(
          child: FaIcon(
            icon,
            color: const Color(0xFF199A8E),
            size: 20,
          ),
        ),
      ),

      const SizedBox(width: 16),

      /// Text
      Expanded(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}

}