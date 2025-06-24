import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // Callback to notify provider
  static Function(String title, String body)? onForegroundMessage;

  static Future<void> init(Function(String title, String body) onMessageCallback) async {
    onForegroundMessage = onMessageCallback;

    // Request permission
    await _messaging.requestPermission();

    // Print token for testing
    final token = await _messaging.getToken();
    debugPrint('🔥 FCM Token: $token');

    // Local notification setup
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(settings);

    // Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        final title = notification.title ?? 'iSupply';
        final body = notification.body ?? 'New notification';

        _showLocalNotification(title, body);

        // Notify app state
        if (onForegroundMessage != null) {
          onForegroundMessage!(title, body);
        }
      }
    });
  }

  static void _showLocalNotification(String title, String body) {
    const androidDetails = AndroidNotificationDetails(
      'channelId',
      'iSupply Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    _localNotifications.show(0, title, body, notificationDetails);
  }

  static void showStatusNotification({
    required String oldStatus,
    required String newStatus,
  }) {
    final title = 'Order Status Update - iSupply';
    final body = 'Your order changed from $oldStatus to $newStatus.';
    _showLocalNotification(title, body);
  }
}
