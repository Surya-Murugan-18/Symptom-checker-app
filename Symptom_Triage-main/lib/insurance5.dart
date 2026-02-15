import 'package:flutter/material.dart';
// Refreshing file to fix potential compiler glitches
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/language/app_language.dart';

class NearbyHospitalsScreen extends StatelessWidget {
  const NearbyHospitalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage] ?? AppStrings.data[AppLanguage.english]!;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final padding = isMobile ? 16.0 : 24.0;

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
          strings['nearby_hospitals'] ?? 'Nearby Hospitals',
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
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 241, 249, 254),
                  borderRadius: BorderRadius.circular(8),
                  border: const Border(
                    left: BorderSide(
                      color: Color.fromARGB(255, 19, 88, 157),
                      width: 4,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF1976D2),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings['hospital_acceptance_disclaimer'] ?? 'Hospital insurance acceptance may vary.\nPlease confirm with the hospital desk before\nadmission.',
                        style: TextStyle(
                          color: const Color(0xFF1976D2),
                          fontSize: isMobile ? 13 : 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Hospital Card 1
              _buildHospitalCard(
                context: context,
                hospitalName: 'City Care Hospital',
                distance: '1.2 km',
                address: '124, Park Avenue, Downtown',
                acceptanceType: strings['cashless_available'] ?? 'Cashless Available',
                acceptanceColor: const Color(0xFF1FA59E),
                acceptedBy: (strings['accepted_by_label'] ?? 'Accepted: ') + 'Star Health, HDFC Ergo, ICICI Lombard',
                isMobile: isMobile,
              ),
              const SizedBox(height: 16),
              // Hospital Card 2
              _buildHospitalCard(
                context: context,
                hospitalName: 'Metro Polyclinic',
                distance: '2.5 km',
                address: 'Sector 4, Near Metro Station',
                acceptanceType: strings['reimbursement_supported'] ?? 'Reimbursement Supported',
                acceptanceColor: const Color(0xFFF57C00),
                acceptedBy: (strings['accepted_by_label'] ?? 'Accepted: ') + 'All Major Insurers',
                isMobile: isMobile,
              ),
              const SizedBox(height: 16),
              // Hospital Card 3
              _buildHospitalCard(
                context: context,
                hospitalName: 'Sunrise General Hospital',
                distance: '3.8 km',
                address: 'West Wing, Tech Park Road',
                acceptanceType: strings['cashless_available'] ?? 'Cashless Available',
                acceptanceColor: const Color(0xFF1FA59E),
                acceptedBy: (strings['accepted_by_label'] ?? 'Accepted: ') + 'Niva Bupa, Care, United',
                isMobile: isMobile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalCard({
    required BuildContext context,
    required String hospitalName,
    required String distance,
    required String address,
    required String acceptanceType,
    required Color acceptanceColor,
    required String acceptedBy,
    required bool isMobile,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital Name and Distance
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hospitalName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isMobile ? 17 : 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: const Color(0xFFF3F4F6), // light grey background
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: const Color(0xFFD1D5DB), // grey outline
      width: 1,
    ),
  ),
  child: Text(
    distance,
    style: TextStyle(
      color: Colors.black, // black text
      fontSize: isMobile ? 14 : 14,
      fontWeight: FontWeight.bold,
    ),
  ),
),

              ],
            ),
            const SizedBox(height: 8),
            // Address
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey.shade600,
                  size: 17,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: isMobile ? 13 : 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Acceptance Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: acceptanceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: acceptanceColor,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    acceptanceType,
                    style: TextStyle(
                      color: acceptanceColor,
                      fontSize: isMobile ? 13 : 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Accepted By
            Text(
              acceptedBy,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: isMobile ? 12 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}