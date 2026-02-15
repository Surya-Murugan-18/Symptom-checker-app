import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:symtom_checker/doctor-Profile.dart';
import 'package:symtom_checker/doctor_dashboard.dart';
import 'package:symtom_checker/doctor_messages_list.dart';
import 'package:symtom_checker/doctor_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/doctor_session.dart';

import 'package:symtom_checker/doctor_consult_view_details.dart';

class DoctorConsult extends StatefulWidget {
  const DoctorConsult({Key? key}) : super(key: key);

  @override
  State<DoctorConsult> createState() => _DoctorConsultState();
}

class _DoctorConsultState extends State<DoctorConsult> {
  int _selectedIndex = 2; // Consults tab
  String _selectedFilter = 'Pending';
  final Color _primaryColor = const Color(0xFF199A8E);

  List<Map<String, dynamic>> _allConsultations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchConsultations();
  }

  Future<void> _fetchConsultations() async {
    final sess = DoctorSession();
    if (sess.doctorId == null) return;

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/appointments/doctor/${sess.doctorId}"),
        headers: {"Authorization": "Bearer ${sess.token}"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _allConsultations = data.map((a) {
              final p = a['patient'] ?? {};
              final fName = p['firstName'] ?? '';
              final lName = p['lastName'] ?? '';
              final fullName = "$fName $lName".trim();
              
              String status = 'Pending';
              if (a['status'] == 'ACCEPTED') status = 'Accepted';
              else if (a['status'] == 'REJECTED') status = 'Rejected';
              else if (a['status'] == 'COMPLETED') status = 'Completed';

              return {
                'id': a['id'],
                'name': fullName,
                'initials': fullName.isNotEmpty ? fullName[0] : '?',
                'date': a['date'] ?? '',
                'time': a['time'] ?? '',
                'category': sess.specialization ?? 'General',
                'status': status,
                'reason': a['symptoms'] ?? 'No reason provided',
              };
            }).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching consults: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
              child: Row(
                children: [
                  // Back Arrow
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  // Center Title
                  Expanded(
                    child: Center(
                      child: Text(
                        'Consultations',
                        style: TextStyle(
                          fontSize: isDesktop ? 28 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  // Right spacer to balance center alignment
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Divider(color: Colors.grey[300], height: 1, thickness: 1),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),

                      // Filter Buttons
                      SizedBox(
                        height: isDesktop ? 50 : 45,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildFilterButton('Pending', _getCountByStatus('Pending'), isDesktop),
                            const SizedBox(width: 12),
                            _buildFilterButton('Accepted', _getCountByStatus('Accepted'), isDesktop),
                            const SizedBox(width: 12),
                            _buildFilterButton('Completed', _getCountByStatus('Completed'), isDesktop),
                            const SizedBox(width: 12),
                            _buildFilterButton('Rejected', _getCountByStatus('Rejected'), isDesktop),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Consultations List
                      _buildConsultationsList(isDesktop),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFilterButton(String label, int count, bool isDesktop) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 18.0 : 14.0,
          vertical: isDesktop ? 12.0 : 8.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: isDesktop ? 15 : 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: isDesktop ? 13 : 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCountByStatus(String status) {
    return _allConsultations.where((consultation) => consultation['status'] == status).length;
  }

  Widget _buildConsultationsList(bool isDesktop) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    // Filter consultations by selected status
    final filteredConsultations = _allConsultations
        .where((consultation) => consultation['status'] == _selectedFilter)
        .toList();

    if (filteredConsultations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No $_selectedFilter consultations',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredConsultations.length,
      itemBuilder: (context, index) {
        final consultation = filteredConsultations[index];
        return _buildConsultationCard(consultation, isDesktop);
      },
    );
  }

  Widget _buildConsultationCard(
    Map<String, dynamic> consultation,
    bool isDesktop,
  ) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorConsultViewDetails(
              appointmentId: consultation['id'],
            ),
          ),
        );
        _fetchConsultations(); // Refresh list on return
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: isDesktop ? 60 : 50,
              height: isDesktop ? 60 : 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  consultation['initials'],
                  style: TextStyle(
                    fontSize: isDesktop ? 20 : 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Consultation Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    consultation['name'],
                    style: TextStyle(
                      fontSize: isDesktop ? 17 : 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: isDesktop ? 14 : 13,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        consultation['date'],
                        style: TextStyle(
                          fontSize: isDesktop ? 13 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '•',
                        style: TextStyle(
                          fontSize: isDesktop ? 13 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        consultation['time'],
                        style: TextStyle(
                          fontSize: isDesktop ? 13 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      consultation['category'],
                      style: TextStyle(
                        fontSize: isDesktop ? 12 : 11,
                        fontWeight: FontWeight.w500,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 14 : 12,
                vertical: isDesktop ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color: _getStatusBadgeColor(consultation['status']),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                consultation['status'],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusTextColor(consultation['status']),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusBadgeColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFFF8DC); // Light yellow
      case 'Accepted':
        return const Color(0xFFE8F5E9); // Light green
      case 'Rejected':
        return const Color(0xFFFFEBEE); // Light red
      case 'Completed':
        return const Color(0xFFE3F2FD); // Light blue
      default:
        return const Color(0xFFF5F5F5); // Gray
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFD4A025); // Dark yellow
      case 'Accepted':
        return const Color(0xFF4CAF50); // Green
      case 'Rejected':
        return const Color(0xFFE53935); // Red
      case 'Completed':
        return const Color(0xFF1976D2); // Blue
      default:
        return Colors.grey;
    }
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
