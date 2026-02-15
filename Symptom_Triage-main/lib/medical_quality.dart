import 'package:flutter/material.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';

class MedicalQualityPage extends StatelessWidget {
  const MedicalQualityPage({Key? key}) : super(key: key);

  final Color appColor = const Color(0xFF199A8E);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    final isMobile = MediaQuery.of(context).size.width < 768;
    final horizontalPadding = isMobile ? 16.0 : 40.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          strings['medical_quality_title'] ?? 'Medical Quality',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth =
              constraints.maxWidth > 800 ? 800 : constraints.maxWidth;

          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(strings['mq_section_1_title'] ?? '1. Clinical Guidelines'),
                      _buildSectionText(
                        strings['mq_section_1_text'] ?? 'SEV-AI uses evidence-based medical guidelines from:',
                      ),
                      _buildBulletPoint(strings['mq_cdc'] ?? 'CDC (Centers for Disease Control and Prevention)'),
                      _buildBulletPoint(strings['mq_who'] ?? 'WHO (World Health Organization)'),
                      _buildBulletPoint(strings['mq_nhs'] ?? 'NHS (National Health Service) guidelines'),
                      _buildBulletPoint(strings['mq_joint_commission'] ?? 'Joint Commission on Accreditation standards'),
                      const SizedBox(height: 20),
                      _buildSectionTitle(strings['mq_section_2_title'] ?? '2. Symptom Triage Algorithm'),
                      _buildSectionText(
                        strings['mq_section_2_text'] ?? 'Our triage system classifies symptoms into four care levels based on urgency and risk factors:',
                      ),
                      _buildBulletPoint(strings['mq_self_care'] ?? 'Self-Care: Minor symptoms manageable at home'),
                      _buildBulletPoint(strings['mq_telehealth'] ?? 'Telehealth: Symptoms suitable for remote consultation'),
                      _buildBulletPoint(strings['mq_clinic_visit'] ?? 'Clinic Visit: Conditions requiring in-person evaluation'),
                      _buildBulletPoint(strings['mq_emergency_care'] ?? 'Emergency Care: Life-threatening symptoms requiring immediate attention'),
                      const SizedBox(height: 20),
                      _buildSectionTitle(strings['mq_section_3_title'] ?? '3. Red-Flag Detection'),
                      _buildSectionText(
                        strings['mq_section_3_text'] ?? 'The system includes automated red-flag detection for potentially serious conditions and immediately escalates to emergency care recommendations when critical symptoms are identified.',
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle(strings['mq_section_4_title'] ?? '4. Clinical Validation'),
                      _buildSectionText(
                        strings['mq_section_4_text'] ?? 'SEV-AI has undergone independent clinical validation studies demonstrating accuracy and safety in symptom classification. The system is continuously updated with latest medical research and guidelines.',
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle(strings['mq_section_5_title'] ?? '5. Limitations'),
                      _buildSectionText(
                        strings['mq_section_5_text'] ?? 'SEV-AI does not provide medical diagnoses. It is a decision support tool to help you navigate healthcare appropriately. Always consult qualified healthcare professionals for diagnosis and treatment decisions.',
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF555555),
        height: 1.6,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: 14,
              color: appColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF555555),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
