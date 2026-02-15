import 'package:flutter/material.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({Key? key}) : super(key: key);

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
          AppStrings.data[AppState.selectedLanguage]?['terms_conditions'] ?? 'Terms & Conditions',
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
                      _buildSectionTitle(AppStrings.data[AppState.selectedLanguage]?['acceptance_terms'] ?? '1. Acceptance of Terms'),
                      _buildSectionText(
                        AppStrings.data[AppState.selectedLanguage]?['acceptance_terms_desc'] ?? 'By accessing and using SEV-AI, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle(AppStrings.data[AppState.selectedLanguage]?['use_license'] ?? '2. Use License'),
                      _buildSectionText(
                        AppStrings.data[AppState.selectedLanguage]?['use_license_desc'] ?? 'Permission is granted to temporarily download one copy of the materials (information or software) on SEV-AI for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:',
                      ),
                      _buildBulletPoint(
                          AppStrings.data[AppState.selectedLanguage]?['license_bullet_1'] ?? 'Modifying or copying the materials'),
                      _buildBulletPoint(
                          AppStrings.data[AppState.selectedLanguage]?['license_bullet_2'] ?? 'Using the materials for any commercial purpose or for any public display'),
                      _buildBulletPoint(
                          AppStrings.data[AppState.selectedLanguage]?['license_bullet_3'] ?? 'Attempting to decompile or reverse engineer the software'),
                      _buildBulletPoint(
                          AppStrings.data[AppState.selectedLanguage]?['license_bullet_4'] ?? 'Transferring the materials to another person or "mirror" the materials on any other server'),
                      _buildBulletPoint(
                          AppStrings.data[AppState.selectedLanguage]?['license_bullet_5'] ?? 'Removing any copyright or other proprietary notations from the materials'),
                      const SizedBox(height: 20),
                      _buildSectionTitle(AppStrings.data[AppState.selectedLanguage]?['disclaimer_title'] ?? '3. Disclaimer'),
                      _buildSectionText(
                        AppStrings.data[AppState.selectedLanguage]?['disclaimer_desc'] ?? 'The materials on SEV-AI are provided on an "as is" basis. SEV-AI makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle(AppStrings.data[AppState.selectedLanguage]?['limitations_title'] ?? '4. Limitations'),
                      _buildSectionText(
                        AppStrings.data[AppState.selectedLanguage]?['limitations_desc'] ?? 'In no event shall SEV-AI or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the materials on SEV-AI.',
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
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.black,
      ),
    );
  }

  Widget _buildSectionText(String text) {
    return Text(
      text,
      style: TextStyle(
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
              style: TextStyle(
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
