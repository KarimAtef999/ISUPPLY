import 'package:flutter/material.dart';

class AppNotification {
  final String title;
  final String body;
  final DateTime timestamp;

  AppNotification({
    required this.title,
    required this.body,
    required this.timestamp,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;

  int get count => _notifications.length;

  int get unreadCount => _unreadCount;

  void addNotification(String title, String body) {
    _notifications.add(AppNotification(
      title: title,
      body: body,
      timestamp: DateTime.now(),
    ));
    _unreadCount++; // Increment unread count
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  void resetCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}
