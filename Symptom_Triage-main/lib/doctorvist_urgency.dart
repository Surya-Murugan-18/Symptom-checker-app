import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/finddoctor.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class DoctorVisitUrgencyPage extends StatelessWidget {
  const DoctorVisitUrgencyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.black,
                size: 24,
              ),
            ),
          ),
        ),
        title: Text(
          strings['result_title'] ?? 'Result',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 20 : 40,
            vertical: 20,
          ),
          child: Column(
            children: [
              // Doctor Icon
              Container(
                width: isMobile ? 120 : 140,
                height: isMobile ? 120 : 140,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF17A697),
                ),
                child: Icon(
                  FontAwesomeIcons.stethoscope,
                  size: isMobile ? 60 : 70,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: isMobile ? 24 : 32),

              // Main Title
              Text(
                strings['doctor_visit_recommended'] ?? 'Doctor Visit Recommended',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 28 : 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),

              // Description
              Text(
                strings['consultation_advised'] ?? 'A medical consultation is advised for your symptoms.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              SizedBox(height: isMobile ? 32 : 40),

              // Why a doctor visit section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings['why_this_result'] ?? 'Why this result?',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      strings['doctor_visit_reason'] ?? 'Your symptoms require evaluation by a healthcare professional but do not appear to be an emergency.',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 24 : 32),

              // Recommended Specialist Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F7F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF17A697),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: isMobile ? 50 : 60,
                      height: isMobile ? 50 : 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF17A697),
                      ),
                      child: Icon(
                        FontAwesomeIcons.stethoscope,
                        size: isMobile ? 24 : 28,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: isMobile ? 16 : 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings['recommended_specialist'] ?? 'Recommended Specialist',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: isMobile ? 4 : 8),
                          Text(
                            strings['general_physician'] ?? 'General Physician',
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 32 : 40),

              // Nearby Clinics Section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  strings['nearby_clinics'] ?? 'Nearby Clinics',
                  style: TextStyle(
                    fontSize: isMobile ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),

              // Clinic Card 1
              _buildClinicCard(
                context,
                clinicName: 'City Health Clinic',
                specialty: 'General Medicine • Primary Care',
                rating: 4.8,
                distance: '1.8 km',
                imageUrl: 'assets/clinic1.jpg',
                isMobile: isMobile,
                strings: strings,
              ),
              SizedBox(height: isMobile ? 16 : 20),

              // Clinic Card 2
              _buildClinicCard(
                context,
                clinicName: 'WellCare Medical Center',
                specialty: 'Family Medicine • Walk-ins',
                rating: 4.6,
                distance: '2.4 km',
                imageUrl: 'assets/clinic2.jpg',
                isMobile: isMobile,
                strings: strings,
              ),
              SizedBox(height: isMobile ? 32 : 40),

              // Proceed Button
              SizedBox(
                width: double.infinity,
                height: isMobile ? 56 : 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FindDoctorsPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17A697),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    strings['proceed_to_consultation'] ?? 'Proceed to Consultation (Demo)',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 16 : 20),

              // Disclaimer Text
              Text(
                strings['clinic_demo_disclaimer'] ?? 'Clinic information shown is for demonstration purposes only.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: isMobile ? 20 : 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClinicCard(
    BuildContext context, {
    required String clinicName,
    required String specialty,
    required double rating,
    required String distance,
    required String imageUrl,
    required bool isMobile,
    required Map<String, String> strings,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Clinic Image
          Container(
            width: double.infinity,
            height: isMobile ? 160 : 180,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              color: Colors.grey[300],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Icon(
                      FontAwesomeIcons.hospital,
                      size: isMobile ? 50 : 60,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          ),

          // Clinic Details
          Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Clinic Name
                Text(
                  clinicName,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 10),

                // Rating Row
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          FontAwesomeIcons.solidStar,
                          size: isMobile ? 14 : 16,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Text(
                      '(${rating.toString()})',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 8 : 10),

                // Specialty
                Text(
                  specialty,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isMobile ? 10 : 12),

                // Distance Row
                Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.mapPin,
                      size: isMobile ? 14 : 16,
                      color: const Color(0xFF17A697),
                    ),
                    SizedBox(width: isMobile ? 6 : 8),
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: const Color(0xFF17A697),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 12 : 16),

                // View Details Button
                SizedBox(
                  width: double.infinity,
                  height: isMobile ? 44 : 48,
                  child: OutlinedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text((strings['viewing_details_msg'] ?? 'Viewing details for {clinicName}...')
                              .replaceAll('{clinicName}', clinicName)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF17A697),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      strings['view_details'] ?? 'View Details',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: const Color(0xFF17A697),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
