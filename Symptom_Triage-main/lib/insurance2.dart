import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/insurance3.dart';
import 'package:symtom_checker/insurance4.dart';
import 'package:symtom_checker/insurance5.dart';
import 'package:symtom_checker/insurance6.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';

class InsuranceAssistancePage extends StatelessWidget {
  const InsuranceAssistancePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 600
                ? 600
                : constraints.maxWidth;
            return Center(
              child: Container(
                width: maxWidth,
                padding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth > 600 ? 24 : 16,
                  vertical: 16,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Spacer(), // balances the close button
                          Text(
                            strings['insurance_assistance'] ?? 'Insurance Assistance',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
  
                      const SizedBox(height: 24),
  
                      // Title
                      Text(
                        strings['how_help_insurance'] ?? 'How can we help with insurance?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
  
                      // Subtitle
                      Text(
                        strings['select_topic_desc'] ?? 'Select a topic below to learn more.',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 32),
  
                      // Options List
                      _buildOptionCard(
                        icon: FontAwesomeIcons.fileShield, // Coverage / policy
                        title: strings['coverage_by_treatment'] ?? 'Coverage by Treatment',
                        subtitle: strings['coverage_desc_short'] ?? 'See what\'s typically covered for care',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InsuranceCoverageScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
  
                      _buildOptionCard(
                        icon: FontAwesomeIcons.landmark, // Government schemes
                        title: strings['govt_health_schemes'] ?? 'Government Health Schemes',
                        subtitle: strings['eligibility_desc_short'] ?? 'Check eligibility for state support',
                        onTap: () {
                          Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  GovernmentSchemes(),
                                ),
                              );
                        },
                      ),
                      const SizedBox(height: 16),
  
                      _buildOptionCard(
                        icon: FontAwesomeIcons.hospital, // Hospital / cashless
                        title: strings['hospital_insurance_acceptance'] ?? 'Hospital Insurance Acceptance',
                        subtitle: strings['cashless_facilities_desc'] ?? 'Find nearby cashless facilities',
                        onTap: () {
  
                          Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  NearbyHospitalsScreen(),
                                ),
                              );
                        },
                      ),
                      const SizedBox(height: 16),
  
                      _buildOptionCard(
                        icon: FontAwesomeIcons.fileCircleCheck, // Claims
                        title: strings['claim_process_guide'] ?? 'Claim Process Guide',
                        subtitle: strings['claim_step_desc'] ?? 'Step-by-step help for filing claims',
                        onTap: () {
  
                           Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  ClaimProcessGuide(),
                                ),
                              );
                        },
                      ),
  
                      const SizedBox(height: 32),
  
                      // Footer
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            strings['indicative_info_desc'] ?? 'Information provided is indicative. Please confirm\nspecific details with your insurance provider.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color.fromARGB(255, 118, 118, 118),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
  
                      // Bottom indicator
                      Center(
                        child: Container(
                          width: 100,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1F0ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF199A8E), size: 24),
              ),
              const SizedBox(width: 16),

              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9CA3AF),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
