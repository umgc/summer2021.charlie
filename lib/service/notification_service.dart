import 'dart:async';
import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '/model/notification_payload.dart';

///flutter local notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

///Notification Service
class NotificationService {
  ///Method for zonedScheduledNotification
  Future<void> zonedScheduleNotification(
      DateTime scheduledDateTime, NotificationPayload payload) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Mnemosyne: Reminder',
        payload.note,
        scheduledDateTime,
        const NotificationDetails(
            android: AndroidNotificationDetails('your channel id',
                'your channel name', 'your channel description')),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: json.encode(payload));
  }
}
