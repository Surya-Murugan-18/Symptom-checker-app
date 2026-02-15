import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/doctor-Profile.dart';
import 'package:symtom_checker/doctor_activetab.dart';
import 'package:symtom_checker/doctor_booking.dart';
import 'package:symtom_checker/doctor_calendar.dart';
import 'package:symtom_checker/doctor_completedtab.dart';
import 'package:symtom_checker/doctor_consult.dart';
import 'package:symtom_checker/doctor_createslot.dart';
import 'package:symtom_checker/doctor_messages_list.dart';
import 'package:symtom_checker/doctor_notifications.dart';
import 'package:symtom_checker/doctor_payment_pending.dart';
import 'package:symtom_checker/doctor_slot_created.dart';
import 'package:symtom_checker/doctor_statistics.dart';
import 'package:symtom_checker/doctordetail.dart';
import 'package:symtom_checker/doctordocuments.dart';
import 'package:symtom_checker/doctorsignin.dart';
import 'doctor_session.dart';
import 'package:symtom_checker/api_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:symtom_checker/doctor_consult_view_details.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({super.key});

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  int _selectedIndex = 0;
  bool _isOnline = true;
  final Color _primaryColor = const Color(0xFF199A8E);

  Map<String, dynamic> _stats = {
    "newBookings": 0,
    "activeConsultations": 0,
    "completedConsultations": 0,
    "todayAppointments": 0
  };
  List<dynamic> _todayAppointments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    final session = DoctorSession();
    if (session.doctorId == null) return;

    try {
      final statsResp = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/doctors/${session.doctorId}/stats"),
        headers: {"Authorization": "Bearer ${session.token}"},
      );
      final todayResp = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/doctors/${session.doctorId}/today"),
        headers: {"Authorization": "Bearer ${session.token}"},
      );

      if (mounted) {
        setState(() {
          if (statsResp.statusCode == 200) {
            _stats = jsonDecode(statsResp.body);
          }
          if (todayResp.statusCode == 200) {
            _todayAppointments = jsonDecode(todayResp.body);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching dashboard data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double maxWidth = constraints.maxWidth;
          bool isDesktop = maxWidth > 800;

          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _buildHeader(isDesktop, maxWidth),
                    Positioned(
                      left: isDesktop ? (maxWidth - 800) / 2 + 20 : 20,
                      right: isDesktop ? (maxWidth - 800) / 2 + 20 : 20,
                      bottom: 40,
                      child: _buildStatsGrid(isDesktop),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? (maxWidth - 800) / 2 : 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 35),
                      _buildQuickActions(),
                      const SizedBox(height: 35),
                      _buildAppointmentsHeader(),
                      const SizedBox(height: 20),
                      _buildAppointmentsList(),
                      const SizedBox(height: 120), // Bottom spacing for Nav Bar
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHeader(bool isDesktop, double maxWidth) {
    // Dynamic padding calculation prevents overlap on tablets/large phones
    double gridContentWidth = isDesktop ? 760 : maxWidth - 40; 
    double cardWidth = (gridContentWidth - 25) / 2; 
    double cardHeight = cardWidth / 1.8;
    double gridHeight = (cardHeight * 2) + 15; 
    double bottomPadding = gridHeight + 60; // Buffer for text

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: EdgeInsets.only(
        top: 40,
        bottom: bottomPadding,
        left: isDesktop ? (maxWidth - 800) / 2 + 20 : 25,
        right: isDesktop ? (maxWidth - 800) / 2 + 20 : 25,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(3),
                child: ClipOval(
                  child: DoctorSession().photoUrl?.startsWith('assets/') == true
                      ? Image.asset(DoctorSession().photoUrl!, fit: BoxFit.cover)
                      : (DoctorSession().photoUrl != null
                          ? Image.network(DoctorSession().photoUrl!, fit: BoxFit.cover)
                          : Image.asset('assets/D10.png', fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'Dr. ${DoctorSession().fullName.isNotEmpty ? DoctorSession().fullName : "Doctor"}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DoctorSession().specialization ?? 'Healthcare Professional',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Text(
                          "Change Availability",
                          style: TextStyle(color: Colors.black),
                        ),
                        content: Text(
                          _isOnline ? "Go Offline?" : "Go Online?",
                          style: const TextStyle(color: Colors.black),
                        ),
                        actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final session = DoctorSession();
                                try {
                                  final response = await http.put(
                                    Uri.parse("${ApiConfig.baseUrl}/doctors/${session.doctorId}/toggle-online"),
                                    headers: {
                                      "Authorization": "Bearer ${session.token}",
                                      "Content-Type": "application/json"
                                    },
                                    body: jsonEncode({"isOnline": !_isOnline}),
                                  );
                                  if (response.statusCode == 200) {
                                    setState(() {
                                      _isOnline = !_isOnline;
                                    });
                                  }
                                } catch (e) {
                                  debugPrint("Error toggling online status: $e");
                                }
                                if (mounted) Navigator.pop(context);
                              },
                              child: const Text(
                                "Confirm",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },

                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Center(
                      child: FaIcon(
                        _isOnline
                            ? FontAwesomeIcons.toggleOn
                            : FontAwesomeIcons.toggleOff,
                        size: 22,
                        color: _isOnline
                            ? const Color(0xFF199A8E)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isOnline ? const Color(0xFF199A8E) : Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildStatsGrid(bool isDesktop) {
  return GridView.count(
    crossAxisCount: 2,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 15,
    crossAxisSpacing: 25,
    childAspectRatio: 1.8,
    children: [
      _buildStatCard(
        icon: FontAwesomeIcons.bell,
        value: _stats['newBookings'].toString(),
        label: 'New Bookings',
        iconColor: const Color(0xFF4A90E2),
        bgColor: const Color(0xFFE3F2FD),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BookingRequestsPage()),
          );
        },
      ),
      _buildStatCard(
        icon: FontAwesomeIcons.video,
        value: _stats['activeConsultations'].toString(),
        label: 'Active',
        iconColor: const Color(0xFF199A8E),
        bgColor: const Color(0xFFE0F2F1),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ActiveConsultationsPage()),
          );
        },
      ),
      _buildStatCard(
        icon: FontAwesomeIcons.circleCheck,
        value: _stats['completedConsultations'].toString(),
        label: 'Completed',
        iconColor: const Color(0xFF199A8E),
        bgColor: const Color(0xFFE0F2F1),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CompletedConsultationsPage()),
          );
        },
      ),
      _buildStatCard(
        icon: LucideIcons.dollarSign,
        value: _stats['todayAppointments'].toString(),
        label: 'Today Total',
        iconColor: const Color(0xFFFFA726),
        bgColor: const Color(0xFFFFF3E0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoctorCalendar()),
          );
        },
      ),
    ],
  );
}


Widget _buildStatCard({
  required IconData icon,
  required String value,
  required String label,
  required Color iconColor,
  required Color bgColor,
  required VoidCallback onTap, // 👈 add this
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}



  Widget _buildQuickActions() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Quick Actions',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 20),

      Row(
        children: [
          Expanded(
            child: _buildActionItem(
              FontAwesomeIcons.plus,
              'Create Slot',
              onTap: () {
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(content: Text('Availability settings coming soon'))
                 );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionItem(
              FontAwesomeIcons.calendarDays,
              'Calendar',
              onTap: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DoctorCalendar()),
                      );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionItem(
              FontAwesomeIcons.chartSimple,
              'Statistics',
              onTap: () {
                Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DoctorStatistics()),
                      );
              },
            ),
          ),
        ],
      ),
    ],
  );
}


  Widget _buildActionItem(
  IconData icon,
  String label, {
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: _primaryColor, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildAppointmentsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Today\'s Appointments',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DoctorCalendar()),
                      );
          },
          child: Row(
            children: [
              Text(
                'View All',
                style: TextStyle(
                  color: _primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 4),
              Icon(LucideIcons.chevronRight, color: _primaryColor, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_todayAppointments.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "No appointments for today",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ),
      );
    }
    return Column(
      children: _todayAppointments.map((appt) {
        final patient = appt['patient'] ?? {};
        final firstName = patient['firstName'] ?? '';
        final lastName = patient['lastName'] ?? '';
        final name = "$firstName $lastName".trim();
        final initials = (firstName.isNotEmpty ? firstName[0] : "") + (lastName.isNotEmpty ? lastName[0] : "");
        
        return GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DoctorConsultViewDetails(appointmentId: appt['id'])),
            );
            _fetchDashboardData();
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: _buildAppointmentCard(
              name: name.isEmpty ? "Unknown Patient" : name,
              initials: initials.isEmpty ? "?" : initials.toUpperCase(),
              time: appt['time'] ?? "--:--",
              type: appt['reason'] ?? "General consultation",
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppointmentCard({
    required String name,
    required String initials,
    required String time,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.blueGrey.shade800,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      LucideIcons.clock,
                      size: 15,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text('•', style: TextStyle(color: Colors.grey.shade400)),
                    const SizedBox(width: 10),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Upcoming',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(FontAwesomeIcons.house, 'Home', 0),
          _buildNavItem(LucideIcons.messageSquare, 'Messages', 1),
          _buildNavItem(FontAwesomeIcons.calendarCheck, 'Consults', 2),
          _buildNavItem(FontAwesomeIcons.bell, 'Notifications', 3),
          _buildNavItem(FontAwesomeIcons.user, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
  bool isSelected = _selectedIndex == index;

  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorDashboard()),
          );
          break;

        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorMessagesList()),
          );
          break;

        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DoctorConsult()),
          );
          break;

        case 3:
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DoctorNotifications()),
          );
          break;

        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DoctorProfile()),
          );
          break;
      }
    },
    behavior: HitTestBehavior.opaque,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSelected)
          Container(
            width: 28,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        Icon(
          icon,
          color: isSelected ? _primaryColor : Colors.grey.shade400,
          size: 26,
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? _primaryColor : Colors.grey.shade400,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

}
