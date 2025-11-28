import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pingme/config/firebase_options.dart';
import 'package:pingme/services/notification_service.dart';

// Background Task Names
const String taskCheckReminders = 'check_reminders';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    debugPrint("Native called background task: $task");

    try {
      // Initialize Firebase if needed
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }

      switch (task) {
        case taskCheckReminders:
          await _checkReminders();
          break;
      }

      return Future.value(true);
    } catch (e) {
      debugPrint("Error in background task: $e");
      return Future.value(false);
    }
  });
}

Future<void> _checkReminders() async {
  try {
    debugPrint("Checking for reminders in background...");

    // Initialize notification service
    final notificationService = NotificationService();
    await notificationService.initialize();

    // Get current time
    final now = DateTime.now();
    final in24Hours = now.add(const Duration(hours: 24));

    // Query Firestore for upcoming reminders
    final firestore = FirebaseFirestore.instance;

    // Check for reminders in the next 24 hours
    final upcomingReminders = await firestore
        .collection('reminders')
        .where('isCompleted', isEqualTo: false)
        .where('deadline', isGreaterThan: Timestamp.fromDate(now))
        .where('deadline', isLessThan: Timestamp.fromDate(in24Hours))
        .get();

    debugPrint("Found ${upcomingReminders.docs.length} upcoming reminders");

    for (var doc in upcomingReminders.docs) {
      final data = doc.data();
      final deadline = (data['deadline'] as Timestamp).toDate();
      final title = data['title'] as String;
      final type = data['type'] as String;
      final reminderId = data['id'] as String;

      final timeUntilDeadline = deadline.difference(now);

      // Schedule notification based on time remaining
      if (timeUntilDeadline.inMinutes <= 15 &&
          timeUntilDeadline.inMinutes > 0) {
        // Urgent: 15 minutes or less
        await notificationService.showNotification(
          id: reminderId.hashCode + 3,
          title: '🚨 URGENT: $title',
          body: '${timeUntilDeadline.inMinutes} minutes until deadline - $type',
          payload: reminderId,
        );
        debugPrint('Sent urgent notification for: $title');
      } else if (timeUntilDeadline.inHours <= 1 &&
          timeUntilDeadline.inHours > 0) {
        // 1 hour reminder
        await notificationService.scheduleNotification(
          id: reminderId.hashCode + 2,
          title: '⏰ Urgent: $title',
          body: '1 hour until deadline - $type',
          scheduledDate: deadline.subtract(const Duration(hours: 1)),
          payload: reminderId,
        );
        debugPrint('Scheduled 1hr notification for: $title');
      } else if (timeUntilDeadline.inHours <= 24) {
        // 24 hour reminder
        await notificationService.scheduleNotification(
          id: reminderId.hashCode + 1,
          title: '📅 Reminder: $title',
          body: '24 hours until deadline - $type',
          scheduledDate: deadline.subtract(const Duration(hours: 24)),
          payload: reminderId,
        );
        debugPrint('Scheduled 24hr notification for: $title');
      }
    }

    debugPrint("Background reminder check completed successfully");
  } catch (e) {
    debugPrint("Error checking reminders: $e");
  }
}

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    debugPrint("Background Service Initialized");
  }

  Future<void> registerPeriodicTask() async {
    await Workmanager().registerPeriodicTask(
      "pingme_periodic_check",
      taskCheckReminders,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
  }
}
