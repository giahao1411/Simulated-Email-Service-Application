import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_application/core/constants/app_functions.dart';
import 'package:email_application/features/notification/utils/notification_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    // config local notifications
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);

    // require permission for notifications
    final settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppFunctions.debugPrint('Quyền thông báo đã được cấp');
    }

    // get the FCM token for the device
    final token = await _messaging.getToken();
    if (token != null && FirebaseAuth.instance.currentUser != null) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userEmail = FirebaseAuth.instance.currentUser!.email ?? 'unknown';
      await _firestore.collection('user_tokens').doc(userId).set({
        'token': token,
        'email': userEmail,
        'timestamp': Timestamp.now(),
      }, SetOptions(merge: true));
      AppFunctions.debugPrint('FCM token saved: $token');
    } else {
      AppFunctions.debugPrint('Failed to get device token');
    }

    // handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        AppFunctions.debugPrint(
          'Received message in foreground: ${notification.title}',
        );
        NotificationUtils.showNotification(
          notification.title ?? 'Email mới',
          notification.body ?? 'Bạn có một email mới',
        );
      }
    });

    // handle onClicked messages
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppFunctions.debugPrint(
        'Message clicked: ${message.notification?.title}',
      );
      // Navigate to the email screen or perform any action
      // For example, you can use a navigator key to navigate to a specific screen
    });
  }
}
