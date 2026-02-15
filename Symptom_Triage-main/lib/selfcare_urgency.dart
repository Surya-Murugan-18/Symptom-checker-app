import 'package:flutter/material.dart';
import 'package:symtom_checker/homepage.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class SelfCareUrgencyPage extends StatelessWidget {
  const SelfCareUrgencyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage]!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive width calculation
            final isDesktop = constraints.maxWidth > 800;
            final maxWidth = isDesktop ? 600.0 : constraints.maxWidth;
            
            return Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 40.0 : 24.0,
                      vertical: 16.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Back button and Title
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  strings['result_title'] ?? 'Result',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 48), // Balance for back button
                          ],
                        ),
                        const SizedBox(height: 32),
                        
                        // Check icon
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2D9C95),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Self-Care Recommended title
                        Center(
                          child: Text(
                            strings['self_care_recommended'] ?? 'Self-Care Recommended',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Subtitle
                        Center(
                          child: Text(
                            strings['not_urgent_desc'] ?? 'Your symptoms do not appear to be urgent at this time.',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF757575),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 48),
                        
                        // Why this result section
                        Text(
                          strings['why_this_result'] ?? 'Why this result?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          strings['self_care_reason'] ?? 'Based on the symptoms you shared, your condition can usually be managed at home.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF757575),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // What you can do now section
                        Text(
                          strings['what_you_can_do'] ?? 'What you can do now',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Self-care bullets
                        _buildBulletPoint(strings['adequate_rest'] ?? 'Get adequate rest'),
                        const SizedBox(height: 16),
                        _buildBulletPoint(strings['drink_fluids'] ?? 'Drink plenty of fluids'),
                        const SizedBox(height: 16),
                        _buildBulletPoint(strings['healthy_food'] ?? 'Eat light and healthy food'),
                        const SizedBox(height: 16),
                        _buildBulletPoint(strings['monitor_symptoms'] ?? 'Monitor symptoms regularly'),
                        const SizedBox(height: 32),
                        
                        // Warning box
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFEF5350),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFEF5350),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.priority_high,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      strings['seek_help_if'] ?? 'Seek medical help if you notice',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFEF5350),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildWarningPoint(strings['fever_3_days'] ?? 'Fever lasting more than 3 days'),
                              const SizedBox(height: 12),
                              _buildWarningPoint(strings['chest_pain'] ?? 'Chest pain'),
                              const SizedBox(height: 12),
                              _buildWarningPoint(strings['breathing_difficulty'] ?? 'Breathing difficulty'),
                              const SizedBox(height: 12),
                              _buildWarningPoint(strings['worsening_pain'] ?? 'Severe or worsening pain'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Recheck Symptoms button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle recheck symptoms
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D9C95),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              strings['recheck_symptoms'] ?? 'Recheck Symptoms',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Back to Home button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton(
                            onPressed: () {
                              // Navigate to home
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HealthcareHomePage(),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2D9C95),
                              side: const BorderSide(
                                color: Color(0xFF2D9C95),
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              strings['back_to_home'] ?? 'Back to Home',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Footer disclaimer
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                strings['not_medical_diagnosis'] ?? 'Not a medical diagnosis',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF2D9C95),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 8),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFFEF5350),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
