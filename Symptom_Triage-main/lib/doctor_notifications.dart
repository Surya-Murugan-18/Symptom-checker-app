import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:symtom_checker/doctor-Profile.dart';
import 'package:symtom_checker/doctor_consult.dart';
import 'package:symtom_checker/doctor_dashboard.dart';
import 'package:symtom_checker/doctor_messages_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/doctor_session.dart';

import 'package:symtom_checker/doctor_consult_view_details.dart';

class DoctorNotifications extends StatefulWidget {
  const DoctorNotifications({Key? key}) : super(key: key);

  @override
  State<DoctorNotifications> createState() => _DoctorNotificationsState();
}

class _DoctorNotificationsState extends State<DoctorNotifications> {
  int _selectedIndex = 3;
  final Color _primaryColor = const Color(0xFF199A8E);
  String _selectedFilter = 'All';

  List<Map<String, dynamic>> notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final session = DoctorSession();
    if (session.doctorId == null) return;

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/doctors/${session.doctorId}/notifications"),
        headers: {"Authorization": "Bearer ${session.token}"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            notifications = data.map((n) {
              IconData icon = FontAwesomeIcons.bell;
              Color iconColor = _primaryColor;
              Color bg = _primaryColor.withOpacity(0.1);
              String typeLabel = 'Consultations';

              final type = n['type'];
              if (type == 'BOOKING' || type == 'APPOINTMENT' || type == 'RESCHEDULE' || type == 'CANCELLATION') {
                icon = FontAwesomeIcons.calendarCheck;
                typeLabel = 'Bookings';
              } else if (type == 'MESSAGE') {
                icon = FontAwesomeIcons.envelope;
                typeLabel = 'Messages';
              } else if (type == 'PAYMENT') {
                icon = FontAwesomeIcons.creditCard;
                typeLabel = 'Payments';
              } else if (type == 'EMERGENCY') {
                icon = FontAwesomeIcons.circleXmark;
                iconColor = Colors.red;
                bg = Colors.red.withOpacity(0.1);
                typeLabel = 'Consultations';
              }
              
              return {
                'id': n['id'],
                'type': n['type'], // Keep original type for logic
                'typeLabel': typeLabel,
                'icon': icon,
                'iconBgColor': bg,
                'iconColor': iconColor,
                'title': n['title'] ?? 'Notification',
                'message': n['message'] ?? '',
                'time': _formatTime(n['createdAt']),
                'isRead': n['read'] ?? false,
                'appointmentId': n['appointmentId'],
                'patientId': n['user'] != null ? n['user']['id'] : null,
              };
            }).toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching doctor notifications: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleNotificationTap(Map<String, dynamic> notification) async {
    final session = DoctorSession();
    
    // Mark as read in UI
    setState(() {
      notification['isRead'] = true;
    });

    // Mark as read in Backend
    try {
      await http.put(
        Uri.parse("${ApiConfig.baseUrl}/notifications/${notification['id']}/read"),
        headers: {"Authorization": "Bearer ${session.token}"},
      );
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }

    // Navigate based on type/appointmentId
    if (notification['appointmentId'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorConsultViewDetails(
            appointmentId: notification['appointmentId'],
          ),
        ),
      );
    }
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return "Just now";
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return "${diff.inMinutes} mins ago";
      if (diff.inHours < 24) return "${diff.inHours} hours ago";
      return "${diff.inDays} days ago";
    } catch (_) {
      return "Recently";
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isRead'] = true;
      }
    });
  }

  List<Map<String, dynamic>> get filteredNotifications {
    if (_selectedFilter == 'All') {
      return notifications;
    }
    return notifications
        .where((notification) => notification['type'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.checkDouble,
                  color: _primaryColor,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  'Mark all read',
                  style: TextStyle(
                    color: _primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16,
              vertical: 16,
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Bookings'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Messages'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Payments'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Consultations'),
                ],
              ),
            ),
          ),

          // Notifications List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.bell,
                          size: 64,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No notifications',
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 24 : 16,
                    ),
                    itemCount: filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notification = filteredNotifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primaryColor : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    return GestureDetector(
      onTap: () => _handleNotificationTap(notification),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification['isRead'] ? Colors.white : _primaryColor.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification['isRead'] ? Colors.grey.withOpacity(0.2) : _primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: notification['iconBgColor'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: FaIcon(
                  notification['icon'],
                  color: notification['iconColor'],
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'],
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          Text(
                            notification['time'],
                            style: TextStyle(
                              color: _primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (!notification['isRead']) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification['message'],
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
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
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isSelected ? _primaryColor : Colors.grey.shade400,
                size: 26,
              ),
              if (index == 3 && notifications.any((n) => !n['isRead']))
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
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
