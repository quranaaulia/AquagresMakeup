import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    
    await _notificationPlugin.initialize(initSettings);
  }

  // Display notification with custom styling
  Future<void> displayNotification({
    required String notificationTitle,
    required String notificationBody,
    String? payload,
  }) async {
    final int uniqueId = _generateUniqueId();
    
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'makeup_store_channel',
      'Makeup Store Notifications',
      channelDescription: 'Notifications for makeup store transactions and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(''),
    );

    const NotificationDetails platformChannelDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _notificationPlugin.show(
      uniqueId,
      notificationTitle,
      notificationBody,
      platformChannelDetails,
      payload: payload,
    );
  }

  // Generate unique notification ID
  int _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  // Cancel specific notification
  Future<void> cancelNotification(int notificationId) async {
    await _notificationPlugin.cancel(notificationId);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationPlugin.cancelAll();
  }
}

// Global function for easy access
Future<void> showNotification({
  required String title,
  required String body,
  String? extraData,
}) async {
  final notificationService = NotificationService();
  await notificationService.displayNotification(
    notificationTitle: title,
    notificationBody: body,
    payload: extraData,
  );
}