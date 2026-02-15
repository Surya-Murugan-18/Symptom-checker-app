import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/doctorsignin.dart';
import 'package:symtom_checker/login.dart';
import 'package:symtom_checker/language/app_strings.dart';

void main() {
  runApp(const SevAIApp());
}

class SevAIApp extends StatelessWidget {
  const SevAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SEV-AI',
      theme: ThemeData(
        primaryColor: const Color(0xFF199A8E),
        fontFamily: 'Roboto',
      ),
      home: const UserRolePage(),
    );
  }
}

class UserRolePage extends StatefulWidget {
  const UserRolePage({Key? key}) : super(key: key);

  @override
  State<UserRolePage> createState() => _UserRolePageState();
}

class _UserRolePageState extends State<UserRolePage> {
  String selectedRole = 'doctor';

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          constraints: BoxConstraints(minHeight: screenHeight),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 24.0 : 48.0,
            vertical: isMobile ? 32.0 : 48.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: isMobile ? 24 : 48),

              // Logo
              Container(
                width: isMobile ? 80 : 100,
                height: isMobile ? 80 : 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF199A8E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.stethoscope,
                    size: isMobile ? 48 : 60,
                    color: const Color(0xFF199A8E),
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 32 : 48),

              // Title
              Text(
                AppStrings.s('app_title', 'SEV-AI'),
                style: TextStyle(
                  fontSize: isMobile ? 32 : 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),

              SizedBox(height: isMobile ? 8 : 12),

              // Subtitle
              Text(
                AppStrings.s('app_subtitle', 'Symptom Triage & Care Navigation'),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: isMobile ? 48 : 64),

              // Continue as
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  AppStrings.s('continue_as', 'Continue as'),
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              SizedBox(height: isMobile ? 24 : 32),

              Column(
                children: [
                  _buildRoleCard(
                    icon: FontAwesomeIcons.user,
                    title: AppStrings.s('role_patient', 'User'),
                    subtitle: AppStrings.s('role_patient_desc', 'Get symptom guidance'),
                    isSelected: selectedRole == 'patient',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                    isMobile: isMobile,
                  ),

                  SizedBox(height: isMobile ? 16 : 20),

                  _buildRoleCard(
                    icon: FontAwesomeIcons.userDoctor,
                    title: AppStrings.s('role_doctor', 'Doctor'),
                    subtitle: AppStrings.s('role_doctor_desc', 'Review cases & advise'),
                    isSelected: selectedRole == 'doctor',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => DoctorSignIn()),
                      );
                    },
                    isMobile: isMobile,
                  ),

                  SizedBox(height: isMobile ? 16 : 20),

                /*  _buildRoleCard(
                    icon: Icons.business,
                    title: strings['role_org'] ?? 'Organization',
                    subtitle: strings['role_org_desc'] ?? 'Manage clinics',
                    isSelected: selectedRole == 'organization',
                    onTap: () {
                      setState(() => selectedRole = 'organization');
                    },
                    isMobile: isMobile,
                  ), */
                ],
              ),

              SizedBox(height: isMobile ? 28 : 64),

              // Footer
              Text(
                AppStrings.s('terms_privacy', 'By continuing, you agree to our Terms & Privacy Policy'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Container(
              width: isMobile ? 48 : 56,
              height: isMobile ? 48 : 56,
              decoration: BoxDecoration(
                color: const Color(0xFF199A8E).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  size: isMobile ? 28 : 32,
                  color: const Color(0xFF199A8E)),
            ),
            SizedBox(width: isMobile ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: isMobile ? 4 : 6),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: isMobile ? 13 : 14,
                          color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
