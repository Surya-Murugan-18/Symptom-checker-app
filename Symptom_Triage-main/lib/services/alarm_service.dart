import 'package:alarm/alarm.dart';
import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  Future<void> init() async {
    if (kIsWeb) return;
    try {
      await Alarm.init();
    } catch (e) {
      debugPrint("Alarm initialization failed: $e");
    }
  }

  Future<void> setAlarm({
    required int id,
    required DateTime dateTime,
    required String assetPath,
    required String title,
    required String body,
  }) async {
    final alarmSettings = AlarmSettings(
      id: id,
      dateTime: dateTime,
      assetAudioPath: assetPath,
      loopAudio: true,
      vibrate: true,
      volume: 0.8,
      fadeDuration: 3.0,
      notificationSettings: NotificationSettings(
        title: title,
        body: body,
        stopButton: 'Stop',
        icon: 'notification_icon',
      ),
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> stopAlarm(int id) async {
    await Alarm.stop(id);
  }

  Future<void> stopAll() async {
    try {
      final alarms = await Alarm.getAlarms();
      for (var alarm in alarms) {
        await Alarm.stop(alarm.id);
      }
    } catch (e) {
      debugPrint("Alarm stopAll failed: $e");
    }
  }
}
