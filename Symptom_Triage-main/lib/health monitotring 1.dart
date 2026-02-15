import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/health%20monitotring%202.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class HealthMonitoringPage extends StatefulWidget {
  const HealthMonitoringPage({Key? key}) : super(key: key);

  @override
  State<HealthMonitoringPage> createState() => _HealthMonitoringPageState();
}

class _HealthMonitoringPageState extends State<HealthMonitoringPage> {
  @override
  Widget build(BuildContext context) {
    final lang = AppState.selectedLanguage;
    final strings = AppStrings.data[lang]!;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final horizontalPadding = isMobile ? 20.0 : 40.0;
    final verticalPadding = isMobile ? 24.0 : 32.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: isMobile
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: isMobile ? const Text('') : const SizedBox.shrink(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Health Icon
              Container(
                width: isMobile ? 60 : 80,
                height: isMobile ? 60 : 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(
                    Icons.favorite,
                    color: const Color(0xFF199A8E),
                    size: isMobile ? 32 : 44,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 20 : 32),

              // Title
              Text(
                strings['health_monitoring_header'] ?? 'Health Monitoring',
                style: TextStyle(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),

              // Description
              Text(
                strings['health_monitoring_desc'] ?? 'Connect supported smart devices to monitor basic health vitals such as heart rate and oxygen level.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF666666),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isMobile ? 28 : 40),

              // Supported Vitals Header
              Text(
                strings['supported_vitals_header'] ?? 'SUPPORTED VITALS',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),

              // Vitals Grid
              GridView(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 2,
                  crossAxisSpacing: isMobile ? 12 : 20,
                  mainAxisSpacing: isMobile ? 16 : 24,
                  childAspectRatio: isMobile ? 1.3 : 1.3,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _VitalCard(
                    icon: Icons.favorite,
                    label: strings['heart_rate'] ?? 'Heart Rate',
                    isMobile: isMobile,
                  ),
                  _VitalCard(
                    icon: Icons.water_drop,
                    label: strings['spo2'] ?? 'SpO₂ Level',
                    isMobile: isMobile,
                  ),
                  _VitalCard(
                    icon: Icons.thermostat,
                    label: strings['temp_label'] ?? 'Temperature',
                    isMobile: isMobile,
                  ),
                  _VitalCard(
                    icon: Icons.show_chart,
                    label: strings['bp_label'] ?? 'Blood Pressure',
                    isMobile: isMobile,
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 24 : 32),

              // Warning Banner
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFE5B4),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: const Color(0xFFD4A574),
                      size: isMobile ? 20 : 24,
                    ),
                    SizedBox(width: isMobile ? 12 : 16),
                    Expanded(
                      child: Text(
                        strings['awareness_disclaimer'] ?? 'This feature is for awareness only and not a medical diagnosis.',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8B6F47),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isMobile ? 24 : 32),

              // Connect Device Button
              SizedBox(
                width: double.infinity,
                height: isMobile ? 52 : 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DataPrivacyPage()),
                    );
                  },
                  icon: const FaIcon(
                    FontAwesomeIcons.circleCheck,
                    size: 20,
                  ),
                  label: Text(
                    strings['connect_device'] ?? 'Connect Device',
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF199A8E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 20 : 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _VitalCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isMobile;

  const _VitalCard({
    required this.icon,
    required this.label,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE8F7F5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF199A8E),
                size: isMobile ? 36 : 36,
              ),
              SizedBox(height: isMobile ? 10 : 12),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
