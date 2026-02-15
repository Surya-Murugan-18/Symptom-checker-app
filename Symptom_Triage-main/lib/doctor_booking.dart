import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:intl/intl.dart';
import 'package:symtom_checker/models/appointment_model.dart';
import 'doctor_session.dart';
import 'doctor_modify_slot.dart';

class BookingRequestsPage extends StatefulWidget {
  const BookingRequestsPage({Key? key}) : super(key: key);

  @override
  State<BookingRequestsPage> createState() => _BookingRequestsPageState();
}

class _BookingRequestsPageState extends State<BookingRequestsPage> {
  List<Appointment> pendingAppointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final doctorId = DoctorSession().doctorId;
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/appointments/doctor/$doctorId"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Appointment> all = data.map((j) => Appointment.fromJson(j)).toList();
        if (mounted) {
          setState(() {
            pendingAppointments = all.where((a) => a.status == 'PENDING').toList();
            isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Error fetching requests: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _updateAppointmentStatus(Appointment request, String action) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/appointments/${request.id}/$action"),
      );
      if (response.statusCode == 200) {
        if (action == 'accept') {
          _showAppointmentAcceptedPopup(request);
        } else if (action == 'reject') {
          _showRequestRejectedPopup(request);
        }
        _fetchRequests();
      }
    } catch (e) {
      debugPrint("Error updating status: $e");
    }
  }

  void _handleAccept(Appointment request) {
    _showAcceptDialog(request);
  }

  void _showAcceptDialog(Appointment request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Accept Appointment?'),
          content: const Text('Confirm this appointment for the requested time.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateAppointmentStatus(request, 'accept');
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF199A8E)),
              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showAppointmentAcceptedPopup(Appointment request) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AppointmentSuccessPopup(
          title: 'Appointment Accepted',
          icon: FontAwesomeIcons.circleCheck,
          iconColor: const Color(0xFF4CAF50),
          backgroundColor: const Color(0xFFE8F5E9),
          onClose: () => Navigator.pop(context),
        );
      },
    );
  }

  void _handleReject(Appointment request) {
    _showRejectDialog(request);
  }

  void _showRejectDialog(Appointment request) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Reject Request?'),
          content: const Text('Are you sure you want to reject this booking request?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateAppointmentStatus(request, 'reject');
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935)),
              child: const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showRequestRejectedPopup(Appointment request) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _AppointmentSuccessPopup(
          title: 'Request Rejected',
          icon: FontAwesomeIcons.circleXmark,
          iconColor: const Color(0xFFE53935),
          backgroundColor: const Color(0xFFFFEBEE),
          onClose: () => Navigator.pop(context),
        );
      },
    );
  }

  void _handleModify(Appointment request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorModifySlot(
          patientName: request.patient?.fullName ?? 'Patient',
          initials: request.patient?.firstName.substring(0, 1) ?? 'P',
          currentDateTime: request.date,
        ),
      ),
    ).then((_) => _fetchRequests());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Booking Requests', style: TextStyle(color: Colors.black)),
      ),
      body: isLoading 
        ? const Center(child: CircularProgressIndicator())
        : pendingAppointments.isEmpty
          ? const Center(child: Text('No pending requests'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingAppointments.length,
              itemBuilder: (context, index) {
                return BookingRequestCard(
                  request: pendingAppointments[index],
                  onAccept: () => _handleAccept(pendingAppointments[index]),
                  onReject: () => _handleReject(pendingAppointments[index]),
                  onModify: () => _handleModify(pendingAppointments[index]),
                );
              },
            ),
    );
  }
}

class BookingRequestCard extends StatelessWidget {
  final Appointment request;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onModify;

  const BookingRequestCard({
    required this.request,
    required this.onAccept,
    required this.onReject,
    required this.onModify,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.teal,
                child: Text(
                  request.patient?.firstName.substring(0, 1) ?? 'P',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.patient?.fullName ?? 'Patient', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${request.patient?.age ?? "?"} yrs • ${request.patient?.gender ?? "Unknown"}'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text('${DateFormat('yyyy-MM-dd').format(request.date)} at ${request.time}'),
            ],
          ),
          const SizedBox(height: 12),
          Text('Reason: ${request.reason ?? "No reason provided"}'),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: onAccept, style: ElevatedButton.styleFrom(backgroundColor: Colors.teal), child: const Text('Accept', style: TextStyle(color: Colors.white)))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: onReject, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Reject', style: TextStyle(color: Colors.white)))),
              const SizedBox(width: 8),
              Expanded(child: OutlinedButton(onPressed: onModify, child: const Text('Modify'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppointmentSuccessPopup extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onClose;

  const _AppointmentSuccessPopup({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), onClose);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 64),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}