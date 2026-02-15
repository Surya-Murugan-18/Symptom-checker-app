import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';

class GovernmentSchemes extends StatelessWidget {
  const GovernmentSchemes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenWidth = MediaQuery.of(context).size.width;

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
          strings['govt_health_schemes'] ?? 'Government Schemes',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 16 : 24,
            vertical: isMobile ? 16 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings['available_health_schemes'] ?? 'Available Health Schemes',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings['location_profile_based'] ?? 'Based on your location and profile',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Ayushman Bharat Card
              SchemeCard(
                schemeTitle: strings['pmjay_title'] ?? 'Ayushman Bharat (PM-JAY)',
                government: strings['central_govt'] ?? 'Central Government',
                governmentColor: Colors.orange,
                eligibilityTitle: strings['eligibility_label'] ?? 'ELIGIBILITY',
                eligibilityDescription:
                    strings['pmjay_eligibility'] ?? 'Families listed in SECC 2011 database. Low income households.',
                benefitsTitle: strings['benefits_label'] ?? 'BENEFITS',
                benefits: [
                  strings['pmjay_benefit1'] ?? 'Up to ₹5 Lakh coverage per family',
                  strings['pmjay_benefit2'] ?? 'Cashless treatment at empaneled hospitals',
                ],
              ),
              const SizedBox(height: 18),

              // State Health Assurance Card
              SchemeCard(
                schemeTitle: strings['state_health_assurance'] ?? 'State Health Assurance',
                government: strings['state_govt'] ?? 'State Government',
                governmentColor: const Color(0xFF2196F3),
                eligibilityTitle: strings['eligibility_label'] ?? 'ELIGIBILITY',
                eligibilityDescription:
                    strings['state_eligibility'] ?? 'Residents with annual income below ₹2.5 Lakh.',
                benefitsTitle: strings['benefits_label'] ?? 'BENEFITS',
                benefits: [strings['state_benefit1'] ?? 'Subsidized surgeries and procedures'],
              ),
              const SizedBox(height: 32),

              // View Required Documents Button
             SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    onPressed: () {
      // Add your action here
    },
    icon: const FaIcon(
      FontAwesomeIcons.fileLines,
      size: 22, // optional: slightly bigger icon
    ),
    label: Text(
      strings['view_required_docs'] ?? 'View Required Documents',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF199A8E),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        vertical: 22, // ⬆ increased height (was 16)
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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

class SchemeCard extends StatelessWidget {
  final String schemeTitle;
  final String government;
  final Color governmentColor;
  final String eligibilityTitle;
  final String eligibilityDescription;
  final String benefitsTitle;
  final List<String> benefits;

  const SchemeCard({
    Key? key,
    required this.schemeTitle,
    required this.government,
    required this.governmentColor,
    required this.eligibilityTitle,
    required this.eligibilityDescription,
    required this.benefitsTitle,
    required this.benefits,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Background Color
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: governmentColor.withOpacity(0.04),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scheme Title
                Text(
                  schemeTitle,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Government Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: governmentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    government,
                    style: TextStyle(
                      color: governmentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider Line
          Divider(
            color: Colors.grey[300],
            height: 1,
            thickness: 1,
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eligibility Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eligibilityTitle,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      eligibilityDescription,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Benefits Section
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefitsTitle,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: benefits
                          .map(
                            (benefit) => Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF199A8E),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      benefit,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}