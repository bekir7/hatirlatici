import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationsHelper {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initializeNotification() async {
    tz.initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    const initializeSettings = InitializationSettings(android: androidSettings);
    await flutterLocalNotificationsPlugin.initialize(initializeSettings);
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'reminder_channel',
      "Reminders",
      description: 'Channel for Reminder Notifications',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> scheduleNotification(
      int id, String title, String category, DateTime scheduleTime) async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      "Reminders",
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    final notificationsDetails = NotificationDetails(android: androidDetails);
    if (scheduleTime.isBefore(DateTime.now())) {
      //do nothing
    } else {
      await flutterLocalNotificationsPlugin.zonedSchedule(id, title, category,
          tz.TZDateTime.from(scheduleTime, tz.local), notificationsDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);
    }
  }

  static Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
