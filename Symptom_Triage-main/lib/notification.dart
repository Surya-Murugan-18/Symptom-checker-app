import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/models/notification_model.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:symtom_checker/language/app_state.dart';
import 'package:symtom_checker/language/app_strings.dart';
import 'package:symtom_checker/services/appointment_service.dart';
import 'package:symtom_checker/bookingdoctor.dart';

class NotificationPage extends StatefulWidget {
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final Color appColor = Color(0xFF199A8E);
  final Color titleColor = Colors.black;
  final Color backgroundColor = Colors.white;

  // Dynamic notification data
  List<NotificationModel> allNotifications = [];
  List<NotificationModel> filteredNotifications = [];
  bool _isLoading = true;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final userId = UserSession().userId;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse("${ApiConfig.baseUrl}/users/$userId/notifications"));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          allNotifications = data.map((j) => NotificationModel.fromJson(j)).toList();
          filteredNotifications = allNotifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching notifications: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterNotificationsByDate(DateTime date) {
    setState(() {
      selectedDate = date;
      final selectedDay = DateTime(date.year, date.month, date.day);
      
      filteredNotifications = allNotifications.where((notification) {
        final notificationDay = DateTime(
          notification.createdAt.year,
          notification.createdAt.month,
          notification.createdAt.day,
        );
        return notificationDay == selectedDay;
      }).toList();

      // Sort by time - recent first
      filteredNotifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  void _clearDateFilter() {
    setState(() {
      selectedDate = null;
      filteredNotifications = allNotifications;
    });
  }

  void _onNotificationPressed(NotificationModel notification) async {
    if (notification.type == 'ACCEPTANCE' && notification.appointmentId != null) {
      try {
        final appointment = await AppointmentService().getAppointmentById(notification.appointmentId!);
        if (appointment != null && mounted) {
           DateTime combinedDate = appointment.date;
           try {
             if (appointment.time.isNotEmpty) {
               final timeParts = DateFormat("hh:mm a").parse(appointment.time);
               combinedDate = DateTime(
                 appointment.date.year,
                 appointment.date.month,
                 appointment.date.day,
                 timeParts.hour,
                 timeParts.minute,
               );
             }
           } catch (e) {
             debugPrint("Time parse error: $e");
           }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingDoctorPage(
                doctorId: appointment.doctor.id,
                doctorName: appointment.doctor.fullName,
                specialization: appointment.doctor.specialization ?? 'General',
                rating: appointment.doctor.rating,
                distanceText: appointment.doctor.distanceText ?? '800m away',
                appointmentDateTime: combinedDate, 
                appointmentId: appointment.id,
              ),
            ),
          );
        } else if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppStrings.s('could_not_load_appointment', 'Could not load appointment details'))));
        }
      } catch (e) {
        debugPrint("Nav Error: $e");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final padding = isDesktop ? 24.0 : 16.0;
    final fontSize = isDesktop ? 18.0 : 16.0;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Back Arrow and Title
            Padding(
              padding: EdgeInsets.all(padding),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: titleColor,
                      size: isDesktop ? 28 : 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.s('notification_title', 'NOTIFICATION'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: fontSize + 2,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  SizedBox(width: isDesktop ? 28 : 24),
                ],
              ),
            ),
            // Date Filter Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.s('filter_by_date', 'Filter by Date'),
                    style: TextStyle(
                      fontSize: isDesktop ? 18.0 : 18.0,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  SizedBox(height: isDesktop ? 12 : 8),
                  TextButton(
  onPressed: () async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );

    if (pickedDate != null) {
      _filterNotificationsByDate(pickedDate);
    }
  },
  style: TextButton.styleFrom(
    padding: EdgeInsets.zero,
    backgroundColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      border: Border.all(color: appColor.withOpacity(0.3), width: 1.8),
      borderRadius: BorderRadius.circular(8),
      color: Colors.white,
    ),
    child: Row(
      children: [
        Icon(
          FontAwesomeIcons.calendarAlt,
          color: appColor,
          size: isDesktop ? 20 : 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            selectedDate == null
                ? AppStrings.s('select_date_filter', 'Select a date to filter')
                : DateFormat('EEEE, MMMM dd, yyyy').format(selectedDate!),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: selectedDate == null
                  ? Colors.grey[500]
                  : titleColor,
            ),
          ),
        ),
        if (selectedDate != null)
          IconButton(
            onPressed: _clearDateFilter,
            icon: Icon(Icons.close, color: appColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        Icon(
          Icons.arrow_drop_down,
          color: appColor,
          size: isDesktop ? 24 : 24,
        ),
      ],
    ),
  ),
),

                ],
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
                          Icon(
                            Icons.notifications_none,
                            color: appColor.withOpacity(0.5),
                            size: isDesktop ? 64 : 48,
                          ),
                          SizedBox(height: 16),
                          Text(
                            selectedDate == null
                                ? AppStrings.s('no_notifications', 'No notifications')
                                : AppStrings.s('no_notifications_date', 'No notifications for this date'),
                            style: TextStyle(
                              fontSize: isDesktop ? 16.0 : 14.0,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      itemCount: filteredNotifications.length,
                      itemBuilder: (context, index) {
                        return NotificationCard(
                          notification: filteredNotifications[index],
                          appColor: appColor,
                          titleColor: titleColor,
                          backgroundColor: backgroundColor,
                          isDesktop: isDesktop,
                          onPressed: () => _onNotificationPressed(filteredNotifications[index]),
                        );
                      },
                    ),
            ),
            // Action Buttons at Bottom
       
          ],
        ),
      ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final Color appColor;
  final Color titleColor;
  final Color backgroundColor;
  final bool isDesktop;
  final VoidCallback onPressed;

  const NotificationCard({
    required this.notification,
    required this.appColor,
    required this.titleColor,
    required this.backgroundColor,
    required this.isDesktop,
    required this.onPressed,
  });

  String getTimeString(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final notificationDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayString;
    if (notificationDate == today) {
      dayString = AppStrings.s('today_text', 'Today');
    } else if (notificationDate == yesterday) {
      dayString = AppStrings.s('yesterday_text', 'Yesterday');
    } else {
      dayString = DateFormat('EEEE').format(dateTime); // Monday, Tuesday, etc.
    }

    String dateString = DateFormat('MMM dd').format(dateTime); // Jan 18
    String timeString = DateFormat('hh:mm a').format(dateTime); // 12:10 AM

    return "$dayString, $dateString · $timeString";
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'BOOKING':
      case 'APPOINTMENT':
      case 'ACCEPTANCE':
      case 'REJECTION':
      case 'RESCHEDULE':
      case 'CANCELLATION':
      case 'COMPLETION':
        return Icons.event_note;
      case 'MEDICATION':
        return Icons.medication;
      case 'MESSAGE':
        return Icons.chat_bubble_outline;
      case 'PAYMENT':
        return Icons.payments_outlined;
      case 'EMERGENCY':
        return Icons.warning_amber_rounded;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
  final iconSize = isDesktop ? 48.0 : 40.0;
  final titleFontSize = isDesktop ? 16.0 : 16.0;
  final descFontSize = isDesktop ? 13.0 : 13.0;
  final timeFontSize = isDesktop ? 12.0 : 12.0;

  return TextButton(
    onPressed: onPressed, // ✅ onPressed added here
    style: TextButton.styleFrom(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    child: Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 16 : 12),
      padding: EdgeInsets.all(isDesktop ? 16 : 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Container
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: appColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    _getIconForType(notification.type),
                    color: appColor,
                    size: iconSize * 0.55,
                  ),
                ),
              ),
              SizedBox(width: isDesktop ? 16 : 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: descFontSize,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isDesktop ? 12 : 8),

          // Date & Time
          Text(
            getTimeString(notification.createdAt),
            style: TextStyle(
              fontSize: timeFontSize,
              fontWeight: FontWeight.w500,
              color: appColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    ),
  );
}

}
