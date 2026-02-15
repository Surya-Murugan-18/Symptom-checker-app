import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:symtom_checker/api_config.dart';
import 'package:symtom_checker/user_session.dart';
import 'package:symtom_checker/doctor_session.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  
  static final Set<int> _notifiedIds = {};
  Timer? _timer;

  // Constructor
  NotificationService();

  Future<void> init() async {
    tz.initializeTimeZones();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
  }

  static Future<void> showNotification(String title, String body) async {
    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'high_importance_channel',
        'High Importance Notifications',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      DateTime.now().hashCode,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Medication Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _checkNotifications();
    });
    // Immediate check
    _checkNotifications();
  }

  void stopPolling() {
    _timer?.cancel();
  }

  Future<void> _checkNotifications() async {
    final userId = UserSession().userId;
    final doctorId = DoctorSession().doctorId;
    final token = UserSession().token ?? DoctorSession().token;

    if (token == null) return;

    String url = "";
    if (doctorId != null) {
      url = "${ApiConfig.baseUrl}/doctors/$doctorId/notifications";
    } else if (userId != null) {
      url = "${ApiConfig.baseUrl}/users/$userId/notifications";
    }

    if (url.isEmpty) return;

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        for (var n in data) {
          final int id = n['id'];
          final bool isRead = n['isRead'] ?? false;
          
          if (!isRead && !_notifiedIds.contains(id)) {
            showNotification(
              n['title'] ?? "Notification",
              n['message'] ?? "",
            );
            _notifiedIds.add(id);
          }
        }
      }
    } catch (e) {
      // Periodic poll, silent error
    }
  }
}
