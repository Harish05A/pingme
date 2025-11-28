import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _isInitialized = false;

  // Channel IDs
  static const String channelIdHigh = 'pingme_high_importance';
  static const String channelNameHigh = 'High Importance Notifications';
  static const String channelDescHigh = 'Notifications for urgent reminders';

  static const String channelIdSchedule = 'pingme_scheduled';
  static const String channelNameSchedule = 'Scheduled Reminders';
  static const String channelDescSchedule =
      'Notifications for upcoming deadlines';

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Timezone
    tz.initializeTimeZones();

    // Android Initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization (if needed later)
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create Channels (Android)
    await _createNotificationChannels();

    // Request exact alarm permission for Android 12+
    await _requestExactAlarmPermission();

    // Initialize FCM
    await _initializeFCM();

    _isInitialized = true;
    debugPrint('NotificationService initialized');
  }

  Future<void> _createNotificationChannels() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          channelIdHigh,
          channelNameHigh,
          description: channelDescHigh,
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );

      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          channelIdSchedule,
          channelNameSchedule,
          description: channelDescSchedule,
          importance: Importance.high,
          playSound: true,
        ),
      );
    }
  }

  Future<void> _requestExactAlarmPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Check if exact alarms are permitted
      final bool? canScheduleExactAlarms =
          await androidPlugin.canScheduleExactNotifications();

      if (canScheduleExactAlarms == false) {
        // Request permission
        final bool? granted =
            await androidPlugin.requestExactAlarmsPermission();
        debugPrint('Exact alarm permission granted: $granted');
      } else {
        debugPrint('Exact alarm permission already granted');
      }
    }
  }

  Future<void> _initializeFCM() async {
    // Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Get Token
    String? token = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $token');

    // Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
            'Message also contained a notification: ${message.notification}');
        showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'New Reminder',
          body: message.notification!.body ?? '',
          payload: message.data['payload'],
        );
      }
    });
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped with payload: ${response.payload}');
    // Handle navigation based on payload
  }

  // Show Immediate Notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelIdHigh,
          channelNameHigh,
          channelDescription: channelDescHigh,
          importance: Importance.max,
          priority: Priority.high,
          color: const Color(0xFF6C63FF), // Primary Purple
          icon: '@mipmap/ic_launcher',
          styleInformation: BigTextStyleInformation(body),
        ),
      ),
      payload: payload,
    );
  }

  // Schedule Notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      await _localNotifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelIdSchedule,
            channelNameSchedule,
            channelDescription: channelDescSchedule,
            importance: Importance.high,
            priority: Priority.high,
            color: const Color(0xFF6C63FF),
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload,
      );
      debugPrint('Notification scheduled for $scheduledDate');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      // If exact alarms fail, try without exact timing
      try {
        await _localNotifications.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              channelIdSchedule,
              channelNameSchedule,
              channelDescription: channelDescSchedule,
              importance: Importance.high,
              priority: Priority.high,
              color: const Color(0xFF6C63FF),
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexact,
          payload: payload,
        );
        debugPrint('Notification scheduled with inexact timing');
      } catch (e2) {
        debugPrint('Failed to schedule notification: $e2');
      }
    }
  }

  // Cancel Notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  // Cancel All
  Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
  }
}
