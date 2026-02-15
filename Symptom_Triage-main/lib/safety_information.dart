import 'package:flutter/material.dart';
import 'language/app_strings.dart';

class SafetyInformationPage extends StatelessWidget {
  const SafetyInformationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.s('safety_info_title', 'Safety information'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive design: different max width for desktop and mobile
          double maxWidth = constraints.maxWidth > 800 ? 800 : constraints.maxWidth;
          double horizontalPadding = constraints.maxWidth > 800 ? 40 : 24;
          
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle
                    Text(
                      AppStrings.s('safety_info_subtitle', 'Important: When to Seek Immediate Medical Help'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Description
                    Text(
                      AppStrings.s('safety_info_desc', 'SEV-AI is designed to provide general health guidance and care navigation.\nIt does not replace a doctor, hospital, or emergency services.'),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF333333),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Warning text
                    Text(
                      AppStrings.s('safety_info_warning', 'Do NOT use SEV-AI if you or someone with you is experiencing any of the following symptoms:'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Symptoms list
                    _buildBulletPoint(AppStrings.s('safety_symptom_1', 'Severe or tight chest pain, especially if accompanied by sweating, nausea, or pale skin')),
                    _buildBulletPoint(AppStrings.s('safety_symptom_2', 'Sudden weakness or numbness on one side of the face, arm, or leg')),
                    _buildBulletPoint(AppStrings.s('safety_symptom_3', 'Difficulty speaking, understanding speech, or sudden confusion')),
                    _buildBulletPoint(AppStrings.s('safety_symptom_4', 'Severe or worsening difficulty breathing')),
                    _buildBulletPoint(AppStrings.s('safety_symptom_5', 'Uncontrolled or heavy bleeding')),
                    _buildBulletPoint(AppStrings.s('safety_symptom_6', 'Seizures, convulsions, or loss of consciousness')),
                    _buildBulletPoint(AppStrings.s('safety_symptom_7', 'Sudden swelling of the face, lips, tongue, or throat')),
                    _buildBulletPoint(AppStrings.s('safety_symptom_8', 'Thoughts of self-harm or harming others')),
                    _buildBulletPoint(AppStrings.s('safety_symptom_9', 'Serious burns, major injuries, or injuries after an accident')),
                    _buildBulletPoint(AppStrings.s('safety_symptom_10', 'Any condition that feels life-threatening or rapidly worsening')),
                    
                    const SizedBox(height: 24),
                    
                    // Emergency section title
                    Text(
                      AppStrings.s('safety_action_title', 'What to Do in an Emergency'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Text(
                      AppStrings.s('safety_action_subtitle', 'If you experience any of the above symptoms:'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF333333),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Emergency actions
                    _buildBulletPoint(AppStrings.s('safety_action_1', 'Call your local emergency number immediately')),
                    _buildBulletPoint(AppStrings.s('safety_action_2', 'Visit the nearest Emergency Department')),
                    _buildBulletPoint(AppStrings.s('safety_action_3', 'Do not delay care by using this app')),
                    
                    const SizedBox(height: 5),
                    
                    Text(
                      AppStrings.s('safety_auto_assistance', 'SEV-AI will automatically highlight emergency situations and provide one-tap emergency assistance when critical symptoms are detected.'),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF333333),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Disclaimer section
                    Text(
                      AppStrings.s('medical_disclaimer_title', 'Medical Disclaimer'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildBulletPoint(AppStrings.s('disclaimer_1', 'SEV-AI does not provide medical diagnoses')),
                    _buildBulletPoint(AppStrings.s('disclaimer_2', 'Information is based on trusted public health guidelines')),
                    _buildBulletPoint(AppStrings.s('disclaimer_3', 'Always follow advice from qualified healthcare professionals')),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              fontSize: 20,
              color: Color(0xFF333333),
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF333333),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
