import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/doctor_session.dart';
import 'package:symtom_checker/video_call_page.dart';

class DoctorConsultViewDetails extends StatefulWidget {
  final int? appointmentId;

  const DoctorConsultViewDetails({
    Key? key,
    this.appointmentId,
  }) : super(key: key);

  @override
  State<DoctorConsultViewDetails> createState() =>
      _DoctorConsultViewDetailsState();
}

class _DoctorConsultViewDetailsState extends State<DoctorConsultViewDetails> {
  static const Color appColor = Color(0xFF199A8E);
  static const Color titleColor = Colors.black;
  static const Color backgroundColor = Colors.white;

  Map<String, dynamic>? appointment;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentDetails();
  }

  Future<void> _fetchAppointmentDetails() async {
    if (widget.appointmentId == null) return;
    
    final session = DoctorSession();
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/appointments/${widget.appointmentId}"),
        headers: {"Authorization": "Bearer ${session.token}"},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            appointment = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching appointment details: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    if (appointment == null) return;
    
    setState(() => _isLoading = true);
    final session = DoctorSession();
    
    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/appointments/${appointment!['id']}/$status"),
        headers: {"Authorization": "Bearer ${session.token}"},
      );

      if (response.statusCode == 200) {
        _fetchAppointmentDetails();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Appointment ${status}ed successfully!")),
        );
      }
    } catch (e) {
      debugPrint("Error updating appointment status: $e");
      setState(() => _isLoading = false);
    }
  }

  void _handleBackButton() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (appointment == null) {
      return const Scaffold(body: Center(child: Text("Appointment not found")));
    }

    final isMobile = MediaQuery.of(context).size.width < 600;
    final patient = appointment!['patient'] ?? {};
    final status = appointment!['status'] ?? 'PENDING';
    final isPaid = appointment!['paid'] ?? false;

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
          'Consultation Details',
          style: TextStyle(
            color: titleColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Info
              _buildPatientCard(patient, isMobile),
              const SizedBox(height: 24),

              // Appointment Info
              _buildInfoRow(Icons.calendar_today, "Date", appointment!['date'] ?? ""),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.access_time, "Time", appointment!['time'] ?? ""),
              const SizedBox(height: 12),
              _buildInfoRow(Icons.info_outline, "Status", status, color: _getStatusColor(status)),
              const SizedBox(height: 24),

              // Symptoms
              const Text("Symptoms/Reason", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(appointment!['reason'] ?? "No reason provided", style: TextStyle(color: Colors.grey[700])),
              const SizedBox(height: 32),

              // Actions
              if (status == 'PENDING') ...[
                _buildActionButton("Accept Appointment", appColor, () => _updateStatus('accept')),
                const SizedBox(height: 12),
                _buildActionButton("Reject Appointment", Colors.red, () => _updateStatus('reject')),
              ] else if (status == 'ACCEPTED' || status == 'PAID') ...[
                Row(
                  children: [
                    Expanded(child: _buildCallButton(FontAwesomeIcons.video, "Video Call", isPaid, true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildCallButton(FontAwesomeIcons.phone, "Voice Call", isPaid, false)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildActionButton("Mark as Completed", Colors.blue, () => _updateStatus('complete')),
              ] else if (status == 'COMPLETED') ...[
                const Center(
                  child: Text("This consultation is completed", 
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient, bool isMobile) {
    final name = "${patient['firstName'] ?? ''} ${patient['lastName'] ?? ''}";
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: appColor.withOpacity(0.1),
            child: Text(name.isNotEmpty ? name[0] : "?", style: const TextStyle(color: appColor)),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("${patient['gender'] ?? 'Unknown'} • ${patient['email'] ?? ''}", 
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text("$label: ", style: TextStyle(color: Colors.grey[600])),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black)),
      ],
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildCallButton(IconData icon, String label, bool isPaid, bool isVideo) {
    final bool canCall = isPaid; // Restricted to paid appointments
    return Opacity(
      opacity: canCall ? 1.0 : 0.5,
      child: InkWell(
        onTap: canCall ? () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCallPage(
            channelName: "appt_${appointment!['id']}",
            isVideoCall: isVideo,
          )));
        } : () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Call available after payment confirmation")),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: appColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: appColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              FaIcon(icon, color: appColor, size: 20),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: appColor, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING': return Colors.orange;
      case 'ACCEPTED': return Colors.blue;
      case 'PAID': return Colors.green;
      case 'COMPLETED': return Colors.grey;
      case 'REJECTED': return Colors.red;
      default: return Colors.black;
    }
  }
}
