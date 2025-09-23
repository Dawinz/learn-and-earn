import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance =>
      _instance ??= NotificationService._();
  NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Getters
  bool get isInitialized => _isInitialized;

  // Initialize notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure timezone
      await _configureLocalTimeZone();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permissions
      await _requestPermissions();

      _isInitialized = true;

      if (kDebugMode) {
        print('Notification service initialized successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize notification service: $e');
      }
    }
  }

  // Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );
  }

  // Request notification permissions
  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.notification.request();
      return status.isGranted;
    }
    return false;
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.status;
      return status.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.notification.status;
      return status.isGranted;
    }
    return false;
  }

  // Show local notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'learn_earn_channel',
          'Learn & Earn Notifications',
          channelDescription: 'Notifications for Learn & Earn app',
          importance: Importance.max,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'learn_earn_channel',
          'Learn & Earn Notifications',
          channelDescription: 'Notifications for Learn & Earn app',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Handle notification tap
  void _onSelectNotification(NotificationResponse response) {
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
    // Handle notification tap logic here
  }

  // Configure local timezone
  Future<void> _configureLocalTimeZone() async {
    // Initialize timezones
    tz.initializeTimeZones();
    // Use system timezone as fallback
    tz.setLocalLocation(tz.local);
  }
}
