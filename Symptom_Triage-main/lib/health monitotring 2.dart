import 'package:flutter/material.dart';
import 'package:symtom_checker/health%20monitotring%203.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class DataPrivacyPage extends StatefulWidget {
  const DataPrivacyPage({Key? key}) : super(key: key);

  @override
  State<DataPrivacyPage> createState() => _DataPrivacyPageState();
}

class _DataPrivacyPageState extends State<DataPrivacyPage> {
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final screenPadding = isDesktop ? 64.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenPadding,
            vertical: 40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shield Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF199A8E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.shield,
                  color: Color(0xFF199A8E),
                  size: 40,
                ),
              ),
              const SizedBox(height: 26),

              // Title
              Text(
                strings['data_privacy_title'] ?? 'Data & Privacy',
                style: TextStyle(
                  fontSize: isDesktop ? 36 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              SizedBox(
                width: isDesktop ? 600 : double.infinity,
                child: Text(
                  strings['data_privacy_desc'] ?? "We value your trust. Here's how we handle your health data.",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Privacy Cards
              SizedBox(
                width: isDesktop ? 600 : double.infinity,
                child: Column(
                  children: [
                    _PrivacyCard(
                      icon: Icons.visibility,
                      title: strings['awareness_only_title'] ?? 'Awareness Only',
                      description: strings['awareness_only_desc'] ??
                          'Vitals data is used only for your personal awareness and trend tracking.',
                      isDesktop: isDesktop,
                    ),
                    const SizedBox(height: 24),
                    _PrivacyCard(
                      icon: Icons.lock,
                      title: strings['private_secure_title'] ?? 'Private & Secure',
                      description: strings['private_secure_desc'] ??
                          'Your health data is encrypted and processed securely on your device.',
                      isDesktop: isDesktop,
                    ),
                    const SizedBox(height: 24),
                    _PrivacyCard(
                      icon: Icons.security,
                      title: strings['no_sharing_title'] ?? 'No Sharing',
                      description: strings['no_sharing_desc'] ??
                          'We never share your personal health data with third parties without consent.',
                      isDesktop: isDesktop,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              // Understood Button
              SizedBox(
                width: isDesktop ? 600 : double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ConnectDevicePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF199A8E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    strings['understood_btn'] ?? 'Understood',
                    style: TextStyle(
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDesktop;

  const _PrivacyCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDesktop,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF199A8E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF199A8E),
              size: 24,
            ),
          ),
          const SizedBox(width: 20),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isDesktop ? 15 : 13,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
