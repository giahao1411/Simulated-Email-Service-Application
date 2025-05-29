import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationUtils {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'email_channel',
      'Email Notifications',
      channelDescription: 'Thông báo cho email mới',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      0, // notification ID
      title, // notification title
      body, // notification body
      platformDetails, // platform-specific details
    );
  }
}
