import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/doctor_consultaions.dart' hide ConsultationDetailsPage;
import 'package:symtom_checker/doctor_consult_view_details.dart';
import 'doctor_session.dart';
import 'package:symtom_checker/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActiveConsultationsPage extends StatefulWidget {
  const ActiveConsultationsPage({Key? key}) : super(key: key);

  @override
  State<ActiveConsultationsPage> createState() =>
      _ActiveConsultationsPageState();
}

class _ActiveConsultationsPageState extends State<ActiveConsultationsPage> {
  // App color theme
  static const Color appColor = Color(0xFF199A8E);
  static const Color titleColor = Colors.black;
  static const Color backgroundColor = Colors.white;

  // Sample data for consultations
  // Data for consultations
  List<ConsultationData> consultations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchActiveConsultations();
  }

  Future<void> _fetchActiveConsultations() async {
    final doctorId = DoctorSession().doctorId;
    if (doctorId == null) return;

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/appointments/doctor/$doctorId"),
        headers: {"Authorization": "Bearer ${DoctorSession().token}"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            consultations = data
                .where((a) => a['status'] == 'ACCEPTED')
                .map((a) {
                  final p = a['patient'] ?? {};
                  final firstName = p['firstName'] ?? '';
                  final lastName = p['lastName'] ?? '';
                  return ConsultationData(
                    id: a['id'],
                    name: "$firstName $lastName".trim(),
                    age: int.tryParse(p['age']?.toString() ?? '0') ?? 0,
                    gender: p['gender'] ?? 'Unknown',
                    time: a['time'] ?? '--:--',
                    tag: 'Repeat Patient', // Logic for this can be added later
                    status: 'Active',
                    statusColor: const Color(0xFFE8F4F8),
                    statusTextColor: const Color(0xFF2196F3),
                    location: p['location'] ?? 'Unknown',
                    appointmentTime: a['time'] ?? '--:--',
                    symptomContext: a['reason'] ?? 'No reason provided',
                    initials: (firstName.isNotEmpty ? firstName[0] : "") + (lastName.isNotEmpty ? lastName[0] : ""),
                  );
                })
                .toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching active consultations: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _handleStartConsultation(ConsultationData consultation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorConsultViewDetails(
          appointmentId: consultation.id,
        ),
      ),
    );
  }

  void _handleViewDetails(ConsultationData consultation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorConsultViewDetails(
          appointmentId: consultation.id,
        ),
      ),
    );
  }

  void _handleBackButton() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet =
        MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 1024;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: titleColor, size: 24),
          onPressed: _handleBackButton,
        ),
        title: const Text(
          'Active Consultations',
          style: TextStyle(
            color: titleColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile
                ? 16
                : isTablet
                ? 24
                : 32,
            vertical: isMobile ? 16 : 24,
          ),
          child: Column(
            children: [
              isLoading 
                ? const Center(child: CircularProgressIndicator())
                : consultations.isEmpty
                  ? const Center(child: Text("No active consultations found"))
                  : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: consultations.length,
                itemBuilder: (context, index) {
                  return _ConsultationCard(
                    consultation: consultations[index],
                    isMobile: isMobile,
                    onStartPressed: () =>
                        _handleStartConsultation(consultations[index]),
                    onDetailsPressed: () =>
                        _handleViewDetails(consultations[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsultationCard extends StatelessWidget {
  final ConsultationData consultation;
  final bool isMobile;
  final VoidCallback onStartPressed;
  final VoidCallback onDetailsPressed;

  static const Color appColor = Color(0xFF199A8E);

  const _ConsultationCard({
    Key? key,
    required this.consultation,
    required this.isMobile,
    required this.onStartPressed,
    required this.onDetailsPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Name and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        consultation.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${consultation.age} yrs • ${consultation.gender}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: consultation.statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    consultation.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: consultation.statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Time and Tag Row
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.clock,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  consultation.time,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                if (consultation.tag != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      consultation.tag!,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Buttons Row
            Row(
              children: [
                Expanded(child: _buildStartButton()),
                const SizedBox(width: 12),
                Expanded(child: _buildDetailsButton()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onStartPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: appColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.video, size: 16),
            const SizedBox(width: 8),
            const Text(
              'Start',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsButton() {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        onPressed: onDetailsPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.eye, size: 16, color: Colors.grey.shade700),
            const SizedBox(width: 8),
            Text(
              'Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data model for consultation
class ConsultationData {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final String time;
  final String? tag;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final String location;
  final String appointmentTime;
  final String symptomContext;
  final String initials;

  ConsultationData({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.time,
    this.tag,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.location,
    required this.appointmentTime,
    required this.symptomContext,
    required this.initials,
  });
}
