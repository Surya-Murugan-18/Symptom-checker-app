import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'api_config.dart';
import 'user_session.dart';
import 'package:symtom_checker/health%20monitotring%206.dart';
import 'package:symtom_checker/health%20monitotring%207.dart';
import 'package:symtom_checker/health%20monitotring%208.dart';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';

class HealthVitalsPage extends StatefulWidget {
  const HealthVitalsPage({Key? key}) : super(key: key);

  @override
  State<HealthVitalsPage> createState() => _HealthVitalsPageState();
}

class _HealthVitalsPageState extends State<HealthVitalsPage> {
  Timer? _timer;
  Map<String, dynamic>? _latestData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLatestHealthData();
    // Refresh data every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchLatestHealthData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLatestHealthData() async {
    final email = UserSession().email;
    if (email == null) return;

    try {
      final response = await http.get(Uri.parse('${ApiConfig.healthLatest}/$email'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _latestData = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching health data: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.data[AppState.selectedLanguage]!;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16.0 : 32.0,
              vertical: isMobile ? 16.0 : 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Title and Settings Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        strings['health_vitals_title'] ?? 'Your Health Vitals',
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Color(0xFF2D5F5D),
                          size: 24,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ConnectedDevicesPage()),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isMobile ? 8 : 12),

                // Last Updated Text
                Text(
                  strings['last_updated_just_now'] ?? 'Last updated: Just now',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 32),

                // Health Metrics Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = isMobile ? 2 : 4;
                    double spacing = isMobile ? 12 : 16;

                    String rawStatus = _latestData?['status'] ?? 'Normal';
                    String localizedStatus = (rawStatus == 'Normal') 
                        ? (strings['normal'] ?? 'Normal')
                        : rawStatus;

                    return GridView.count(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: spacing,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: isMobile ? 1.3 : 0.9,
                      children: [
                        _HealthMetricCard(
                          icon: Icons.favorite,
                          label: strings['heart_rate'] ?? 'Heart Rate',
                          value: _latestData?['heartRate']?.toString() ?? '--',
                          unit: strings['bpm'] ?? 'bpm',
                          status: localizedStatus,
                          showStatus: _latestData != null,
                          isMobile: isMobile,
                          onPressed: () {},
                        ),
                        _HealthMetricCard(
                          icon: Icons.water_drop_outlined,
                          label: strings['spo2'] ?? 'SpO₂',
                          value: _latestData?['spo2']?.toString() ?? '--',
                          unit: '%',
                          status: '',
                          showStatus: false,
                          isMobile: isMobile,
                          onPressed: () {},
                        ),
                        _HealthMetricCard(
                          icon: Icons.thermostat_outlined,
                          label: strings['temperature'] ?? 'Temperature',
                          value: _latestData?['temperature']?.toString() ?? '--',
                          unit: '°F',
                          status: '',
                          showStatus: false,
                          isMobile: isMobile,
                          onPressed: () {},
                        ),
                        _HealthMetricCard(
                          icon: Icons.air,
                          label: strings['resp_rate'] ?? 'Resp. Rate',
                          value: _latestData?['respiratoryRate']?.toString() ?? '--',
                          unit: strings['bpm'] ?? 'bpm',
                          status: '',
                          showStatus: false,
                          isMobile: isMobile,
                          onPressed: () {},
                        ),
                      ],
                    );
                  },
                ),
                SizedBox(height: isMobile ? 24 : 32),

                // Disclaimer
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF4F3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    strings['vitals_disclaimer'] ?? 'Values shown are for awareness only and not for medical diagnosis.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5B6F6D),
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: isMobile ? 24 : 32),

                // View Trends Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HealthMonitoring7Page()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2D7A78),
                      side: const BorderSide(
                        color: Color(0xFF2D7A78),
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        Text(
                          strings['view_trends_btn'] ?? 'View Trends',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D7A78),
                          ),
                        ),
                        const Spacer(),
                        const FaIcon(
                          FontAwesomeIcons.arrowTrendUp,
                          color: Color(0xFF2D7A78),
                          size: 24,
                        ),
                        const SizedBox(width: 18),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: isMobile ? 20 : 28),

                // Check Symptoms Section
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HealthMonitoring8Page()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isMobile ? 16 : 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFC9E4E0),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          strings['check_symptoms_btn'] ?? 'Check Symptoms',
                          style: TextStyle(
                            fontSize: isMobile ? 15 : 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D7A78),
                          ),
                        ),
                        const FaIcon(
                          FontAwesomeIcons.stethoscope,
                          color: Color(0xFF2D7A78),
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HealthMetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String status;
  final bool showStatus;
  final bool isMobile;
  final VoidCallback? onPressed;

  const _HealthMetricCard({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    required this.showStatus,
    required this.isMobile,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: const Color(0xFF2D7A78),
              width: isMobile ? 5 : 8,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(isMobile ? 14 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon + Normal Status (Right Side)
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF0F9F8),
                    shape: BoxShape.circle,
                  ),
                  padding: EdgeInsets.all(isMobile ? 8 : 10),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2D7A78),
                    size: 24,
                  ),
                ),

                const Spacer(),

                // Status on right side
                if (showStatus)
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5F3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 8 : 10,
                      vertical: isMobile ? 3 : 4,
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 12,
                        color: const Color(0xFF2D7A78),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: isMobile ? 8 : 10),

            // Label
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),

            SizedBox(height: isMobile ? 4 : 6),

            // Value and Unit
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                  TextSpan(
                    text: ' $unit',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 12,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
