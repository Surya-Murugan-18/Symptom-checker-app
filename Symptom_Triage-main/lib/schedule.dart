import 'package:flutter/material.dart';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/models/appointment_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'user_session.dart';
import 'homepage.dart';
import 'message.dart';
import 'profile.dart';
import 'bookingdoctor.dart';
import 'ambulance.dart';
import 'chatdoctor.dart';
import 'doctordetail.dart';
import 'package:symtom_checker/notification.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/widgets/avatar_image.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _selectedTabIndex = 0;
  int _selectedIndex = 3; // Schedule tab active
  List<Appointment> _upcoming = [];
  List<Appointment> _completed = [];
  List<Appointment> _canceled = [];
  bool _isLoading = true;

  // Method to show emergency popup
  void _showEmergencyPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppStrings.s('emergency_contacts', 'Emergency Services'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ambulance Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final Uri phoneUri = Uri(scheme: 'tel', path: '108');
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AmbulancePage()),
                    );
                  },
                  icon: Icon(FontAwesomeIcons.ambulance, size: 20),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      AppStrings.s('call_ambulance', 'Call Ambulance'),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1FA59E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              // Emergency Contact Person Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    final userId = UserSession().userId;
                    if (userId != null) {
                      // Try session first
                      if (UserSession().emergencyContacts != null && UserSession().emergencyContacts!.isNotEmpty) {
                        final phone = UserSession().emergencyContacts![0]['phone'].toString();
                        final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                        if (await canLaunchUrl(phoneUri)) {
                          await launchUrl(phoneUri);
                          return;
                        }
                      }

                      try {
                        final response = await http.get(
                          Uri.parse('${ApiConfig.baseUrl}/users/$userId/emergency'),
                          headers: {"Authorization": "Bearer ${UserSession().token}"},
                        );
                        if (response.statusCode == 200) {
                          final List<dynamic> contacts = json.decode(response.body);
                          if (contacts.isNotEmpty) {
                            final firstContact = contacts[0];
                            final phone = firstContact['phone'].toString();
                            final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                            if (await canLaunchUrl(phoneUri)) {
                              await launchUrl(phoneUri);
                              return;
                            }
                          }
                        }
                      } catch (e) {
                        debugPrint('Error fetching emergency contact: $e');
                      }
                    }
                    final Uri fallbackUri = Uri(scheme: 'tel', path: '112');
                    if (await canLaunchUrl(fallbackUri)) {
                      await launchUrl(fallbackUri);
                    }
                  },
                  icon: Icon(FontAwesomeIcons.userDoctor, size: 20),
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      AppStrings.s('emergency_contact_person', 'Emergency Contact Person'),
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1FA59E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                AppStrings.s('cancel', 'Cancel'),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Sample appointment data
  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    final userId = UserSession().userId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.baseUrl}/appointments/user/$userId"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<Appointment> all = data.map((j) => Appointment.fromJson(j)).toList();
        
        setState(() {
          _upcoming = all.where((a) => 
            a.status == 'UPCOMING' || 
            a.status == 'PENDING' || 
            a.status == 'ACCEPTED' ||
            a.status == 'PAID'
          ).toList();
          _completed = all.where((a) => a.status == 'COMPLETED').toList();
          _canceled = all.where((a) => 
            a.status == 'CANCELED' || 
            a.status == 'REJECTED' || 
            a.status == 'CANCELLED'
          ).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching appointments: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    try {
      final response = await http.put(
        Uri.parse("${ApiConfig.baseUrl}/appointments/$appointmentId/cancel"),
        headers: {"Authorization": "Bearer ${UserSession().token}"},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment canceled successfully')),
        );
        _fetchAppointments();
      }
    } catch (e) {
      debugPrint("Error canceling appointment: $e");
    }
  }

  void _proceedToPayment(Appointment appt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDoctorPage(
          appointmentId: appt.id,
          doctorId: appt.doctor.id,
          doctorName: appt.doctor.fullName,
          specialization: appt.doctor.specialization ?? 'Specialist',
          rating: appt.doctor.rating,
          distanceText: '800m away',
          appointmentDateTime: appt.date,
          photoUrl: appt.doctor.photoUrl,
        ),
      ),
    );
  }

  List<Appointment> get displayedAppointments {
    switch (_selectedTabIndex) {
      case 0:
        return _upcoming;
      case 1:
        return _completed;
      case 2:
        return _canceled;
      default:
        return _upcoming;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final isTablet =
        MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1200;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 24.0,
                vertical: isMobile ? 16.0 : 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.s('schedule', 'Schedule'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 24 : 32,
                        ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                 child: IconButton(
  icon: const Icon(
    Icons.notifications_none,
    color: Color(0xFF333333),
    size: 24,
  ),
  padding: EdgeInsets.zero,
  constraints: const BoxConstraints(),
  onPressed: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
  },
),

                  ),
                ],
              ),
            ),
            // Tab Bar
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16.0 : 24.0,
                vertical: 12.0,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab(
                      label: AppStrings.s('upcoming', 'Upcoming'),
                      index: 0,
                      isActive: _selectedTabIndex == 0,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    _buildTab(
                      label: AppStrings.s('completed', 'Completed'),
                      index: 1,
                      isActive: _selectedTabIndex == 1,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    _buildTab(
                      label: AppStrings.s('canceled', 'Canceled'),
                      index: 2,
                      isActive: _selectedTabIndex == 2,
                    ),
                  ],
                ),
              ),
            ),
            // Appointments List
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : displayedAppointments.isEmpty
                  ? Center(
                      child: Text(
                        AppStrings.s('no_appointments', 'No appointments found'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16.0 : 24.0,
                        vertical: 12.0,
                      ),
                      itemCount: displayedAppointments.length,
                      itemBuilder: (context, index) {
                        final appointment = displayedAppointments[index];
                        return _buildAppointmentCard(
                          appointment: appointment,
                          isMobile: isMobile,
                          isTablet: isTablet,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildTab({
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1FA59E) : const Color(0xFFEBEBEB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : const Color(0xFF666666),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  static String _localizedStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PAID': return AppStrings.s('status_paid', 'Paid');
      case 'PENDING': return AppStrings.s('status_pending', 'Pending');
      case 'ACCEPTED': return AppStrings.s('status_accepted', 'Accepted');
      case 'COMPLETED': return AppStrings.s('status_completed', 'Completed');
      case 'CANCELED': return AppStrings.s('status_canceled', 'Canceled');
      default: return status;
    }
  }

  Widget _buildAppointmentCard({
    required Appointment appointment,
    required bool isMobile,
    required bool isTablet,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
     decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(12),
  border: Border.all(
    color: Colors.grey.shade300, // ✅ grey outline
    width: 1,
  ),
  boxShadow: [
    BoxShadow(
      color: const Color(0xFFF5F5F5),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ],
),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Avatar
              AvatarImage(
                imageUrl: appointment.doctor.photoUrl,
                width: isMobile ? 60 : 80,
                height: isMobile ? 60 : 80,
                borderRadius: isMobile ? 30 : 40,
              ),
              SizedBox(width: isMobile ? 12 : 16),
              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.doctor.fullName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 16 : 18,
                          ),
                    ),
                    SizedBox(height: isMobile ? 4 : 6),
                    Text(
                      appointment.doctor.specialization ?? 'General',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF999999),
                            fontSize: isMobile ? 12 : 14,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          // Date and Time Info
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                color: const Color(0xFF1ABC9C),
                size: 16,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                DateFormat('dd/MM/yyyy').format(appointment.date),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: isMobile ? 14 : 14,
                      color: const Color(0xFF333333),
                    ),
              ),
              SizedBox(width: isMobile ? 12 : 16),
              const Icon(
                Icons.access_time,
                color: const Color(0xFF1ABC9C),
                size: 16,
              ),
              SizedBox(width: isMobile ? 6 : 8),
              Text(
                appointment.time,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: isMobile ? 14 : 14,
                      color: const Color(0xFF333333),
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 238, 248, 247),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _localizedStatus(appointment.status),
                  style: TextStyle(
                    color: Colors.teal,
                    fontSize: isMobile ? 12 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          // Action Buttons
          // PENDING: only Cancel (wait for doctor to accept; no Pay/Reschedule)
          // ACCEPTED: Cancel, Chat (message without payment), Pay Now, optional Reschedule
          // PAID/COMPLETED: Chat (video/voice after payment)
          Row(
            children: [
              if (appointment.status == 'PENDING' || appointment.status == 'ACCEPTED')
                Expanded(
                  child: _buildActionButton(
                    label: AppStrings.s('cancel', 'Cancel'),
                    backgroundColor: const Color(0xFFE0F4F3),
                    textColor: Colors.black,
                    onPressed: () => _cancelAppointment(appointment.id),
                    isMobile: isMobile,
                  ),
                ),
              if (appointment.status == 'PENDING' || appointment.status == 'ACCEPTED')
                const SizedBox(width: 8),

              // Chat: allowed for ACCEPTED (message only), PAID, COMPLETED (message + video/voice)
              if (appointment.status == 'ACCEPTED' || appointment.status == 'PAID' || appointment.status == 'COMPLETED')
                Expanded(
                  child: _buildActionButton(
                    label: AppStrings.s('chat_doctor', 'Chat'),
                    backgroundColor: const Color(0xFF1FA59E),
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDoctorScreen(
                            doctorName: appointment.doctor.fullName,
                            doctorImage: appointment.doctor.photoUrl ?? "assets/D6.jpg",
                            doctorId: appointment.doctor.id,
                            isPaid: appointment.status == 'PAID' || appointment.status == 'COMPLETED',
                            appointmentId: appointment.id,
                          ),
                        ),
                      );
                    },
                    isMobile: isMobile,
                  ),
                ),

              if (appointment.status == 'ACCEPTED')
                const SizedBox(width: 8),

              // Pay Now: only when doctor has ACCEPTED (patient can then pay and unlock video/voice)
              if (appointment.status == 'ACCEPTED')
                Expanded(
                  child: _buildActionButton(
                    label: AppStrings.s('pay_now', 'Pay Now'),
                    backgroundColor: Colors.orange,
                    textColor: Colors.white,
                    onPressed: () => _proceedToPayment(appointment),
                    isMobile: isMobile,
                  ),
                ),

              if (appointment.status == 'ACCEPTED')
                const SizedBox(width: 8),

              // Reschedule: only for already ACCEPTED appointments
              if (appointment.status == 'ACCEPTED')
                Expanded(
                  child: _buildActionButton(
                    label: AppStrings.s('reschedule', 'Reschedule'),
                    backgroundColor: const Color(0xFF1FA59E),
                    textColor: Colors.white,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorDetailPage(
                            doctorId: appointment.doctor.id,
                            doctorName: appointment.doctor.fullName,
                            speciality: appointment.doctor.specialization ?? 'General',
                            rating: appointment.doctor.rating,
                            photoUrl: appointment.doctor.photoUrl,
                            appointmentId: appointment.id,
                            isRescheduling: true,
                          ),
                        ),
                      );
                      if (result == true) _fetchAppointments();
                    },
                    isMobile: isMobile,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onPressed,
    required bool isMobile,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(
          vertical: isMobile ? 20.0 : 20.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: isMobile ? 14 : 14,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
  return BottomNavigationBar(
    backgroundColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    currentIndex: _selectedIndex,
    showSelectedLabels: false,
    showUnselectedLabels: false,

    onTap: (index) {
      if (index == 2) {
        // Phone button - show emergency popup
        _showEmergencyPopup();
        return;
      }

      if (_selectedIndex == index) return;

      setState(() {
        _selectedIndex = index;
      });

      switch (index) {
        case 0:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HealthcareHomePage()),
          );
          break;

        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Message()),
          );
          break;

        case 3:
          // Already on SchedulePage → do nothing
          break;

        case 4:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
          break;
      }
    },

    items: [
      BottomNavigationBarItem(
        icon: _navIcon(FontAwesomeIcons.home, 0),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: _navIcon(FontAwesomeIcons.envelope, 1),
        label: '',
      ),
      BottomNavigationBarItem(
            icon: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _selectedIndex == 2
                    ? const Color(0xFF1FA59E)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 📞 Tilted call icon (TOP)
                  Positioned(
                    top: 8,
                    child: Transform.rotate(
                      angle: 2.4, // 👈 tilt here
                      child: Icon(
                        FontAwesomeIcons.phone,
                        size: 28,
                        color: _selectedIndex == 2 ? Colors.white : Colors.grey,
                      ),
                    ),
                  ),

                  // 🔴 e symbol (BOTTOM)
                  Positioned(
                    bottom: -12,
                    child: Text(
                      'e',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 39,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            label: '',
          ),
      BottomNavigationBarItem(
        icon: _navIcon(FontAwesomeIcons.calendarAlt, 3),
        label: '',
      ),
      BottomNavigationBarItem(
        icon: _navIcon(FontAwesomeIcons.user, 4),
        label: '',
      ),
    ],
  );
}
Widget _navIcon(IconData icon, int index) {
  return Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: _selectedIndex == index
          ? const Color(0xFF1FA59E)
          : Colors.transparent,
      shape: BoxShape.circle,
    ),
    child: Icon(
      icon,
      color: _selectedIndex == index ? Colors.white : Colors.grey,
      size: 24,
    ),
  );
}

}
