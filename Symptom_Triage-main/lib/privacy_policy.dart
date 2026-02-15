import 'package:flutter/material.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({Key? key}) : super(key: key);

  final Color appColor = const Color(0xFF199A8E);

  @override
  Widget build(BuildContext context) {
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
          AppStrings.data[AppState.selectedLanguage]?['privacy_policy'] ?? 'Privacy Policy',
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
                      _buildSectionTitle(AppStrings.data[AppState.selectedLanguage]?['privacy_protection'] ?? '1. Privacy Protection'),
                      _buildSectionText(
                        AppStrings.data[AppState.selectedLanguage]?['privacy_protection_desc'] ?? 'SEV-AI is committed to protecting your privacy. We collect only the minimum information necessary to provide you with high-quality healthcare guidance. Your data is encrypted and stored securely with industry-standard security practices.',
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle(AppStrings.data[AppState.selectedLanguage]?['info_collection'] ?? '2. Information Collection'),
                      _buildSectionText(
                        AppStrings.data[AppState.selectedLanguage]?['info_collection_desc'] ?? 'We collect health information provided by you during symptom assessment, including symptoms, medical history, and vital signs. This information is used solely to improve your healthcare recommendations and never sold to third parties.',
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle(AppStrings.data[AppState.selectedLanguage]?['data_security_policy'] ?? '3. Data Security'),
                      _buildSectionText(
                        AppStrings.data[AppState.selectedLanguage]?['data_security_policy_desc'] ?? 'All personal health information is protected using encryption technology (TLS 1.2+) during transmission and storage. Our systems undergo regular security audits and comply with HIPAA and GDPR requirements.',
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle(AppStrings.data[AppState.selectedLanguage]?['user_rights_title'] ?? '4. User Rights'),
                      _buildSectionText(
                        AppStrings.data[AppState.selectedLanguage]?['user_rights_desc'] ?? 'You have the right to:',
                      ),
                      _buildBulletPoint(
                          AppStrings.data[AppState.selectedLanguage]?['user_rights_bullet_1'] ?? 'Access your personal health data at any time'),
                      _buildBulletPoint(
                          AppStrings.data[AppState.selectedLanguage]?['user_rights_bullet_2'] ?? 'Request correction of inaccurate information'),
                      _buildBulletPoint(
                          AppStrings.data[AppState.selectedLanguage]?['user_rights_bullet_3'] ?? 'Request deletion of your account and data'),
                      _buildBulletPoint(
                          AppStrings.data[AppState.selectedLanguage]?['user_rights_bullet_4'] ?? 'Opt-out of optional analytics and marketing communications'),
                      const SizedBox(height: 20),
                      _buildSectionTitle(AppStrings.data[AppState.selectedLanguage]?['data_retention'] ?? '5. Data Retention'),
                      _buildSectionText(
                        AppStrings.data[AppState.selectedLanguage]?['data_retention_desc'] ?? 'Health records are retained for 5 years for continuity of care. You can request deletion at any time. After account deletion, anonymized data may be retained for research purposes.',
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
