import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pingme/models/reminder_model.dart';
import 'package:pingme/services/firestore_service.dart';

/// LiveUpdateService - Real-time Firestore listener for student updates
/// Maintains two critical lists: unreadMessages and highPriorityTasks
/// Uses Firestore streams for efficient, battery-friendly updates
class LiveUpdateService {
  static final LiveUpdateService instance = LiveUpdateService._internal();
  factory LiveUpdateService() => instance;
  LiveUpdateService._internal();

  // State
  final FirestoreService _firestoreService = FirestoreService();
  String? _currentStudentUid;

  // Data lists (exposed via getters)
  List<ReminderModel> _highPriorityTasks = [];
  List<ReminderModel> _allReminders = [];

  // Stream subscriptions
  StreamSubscription<List<ReminderModel>>? _remindersSubscription;

  // Getters
  List<ReminderModel> get highPriorityTasks =>
      List.unmodifiable(_highPriorityTasks);
  List<ReminderModel> get allReminders => List.unmodifiable(_allReminders);
  bool get isInitialized => _currentStudentUid != null;

  /// Initialize the service for a specific student
  /// Starts real-time Firestore listeners
  void initialize(String studentUid) {
    if (_currentStudentUid == studentUid) {
      debugPrint('LiveUpdateService: Already initialized for $studentUid');
      return;
    }

    debugPrint('LiveUpdateService: Initializing for student $studentUid');
    _currentStudentUid = studentUid;

    // Start listening to reminders
    _startRemindersListener(studentUid);
  }

  /// Start listening to reminders stream
  void _startRemindersListener(String studentUid) {
    _remindersSubscription?.cancel();

    _remindersSubscription =
        _firestoreService.getStudentReminders(studentUid).listen(
      (reminders) {
        _allReminders = reminders;
        _updateHighPriorityTasks();
        debugPrint('LiveUpdateService: Updated ${reminders.length} reminders');
      },
      onError: (error) {
        debugPrint('LiveUpdateService: Error listening to reminders: $error');
      },
    );
  }

  /// Update high priority tasks based on current reminders
  void _updateHighPriorityTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    // Filter incomplete reminders
    final incompleteTasks =
        _allReminders.where((r) => !r.isCompleted && !r.isArchived).toList();

    // Sort by priority rules
    _highPriorityTasks =
        _sortTasksByPriority(incompleteTasks, now, today, tomorrow);

    debugPrint(
        'LiveUpdateService: ${_highPriorityTasks.length} high priority tasks');
  }

  /// Sort tasks by priority:
  /// 1. Overdue tasks (deadline < now)
  /// 2. Today-due tasks (deadline.day == today.day)
  /// 3. High-priority tasks (priority == high)
  /// 4. Upcoming tasks (sorted by deadline ascending)
  List<ReminderModel> _sortTasksByPriority(
    List<ReminderModel> tasks,
    DateTime now,
    DateTime today,
    DateTime tomorrow,
  ) {
    // Categorize tasks
    final overdue = <ReminderModel>[];
    final dueToday = <ReminderModel>[];
    final highPriority = <ReminderModel>[];
    final upcoming = <ReminderModel>[];

    for (final task in tasks) {
      if (task.deadline.isBefore(now)) {
        overdue.add(task);
      } else if (task.deadline.isBefore(tomorrow)) {
        dueToday.add(task);
      } else if (task.priority == ReminderPriority.high) {
        highPriority.add(task);
      } else {
        upcoming.add(task);
      }
    }

    // Sort each category by deadline
    overdue.sort((a, b) => a.deadline.compareTo(b.deadline));
    dueToday.sort((a, b) => a.deadline.compareTo(b.deadline));
    highPriority.sort((a, b) => a.deadline.compareTo(b.deadline));
    upcoming.sort((a, b) => a.deadline.compareTo(b.deadline));

    // Combine in priority order
    return [
      ...overdue,
      ...dueToday,
      ...highPriority,
      ...upcoming.take(5), // Limit upcoming to 5 items
    ];
  }

  /// Get top N high priority tasks for display
  List<ReminderModel> getTopPriorityTasks({int limit = 3}) {
    return _highPriorityTasks.take(limit).toList();
  }

  /// Check if there are any overdue tasks
  bool get hasOverdueTasks {
    final now = DateTime.now();
    return _allReminders.any(
        (r) => !r.isCompleted && !r.isArchived && r.deadline.isBefore(now));
  }

  /// Check if there are tasks due today
  bool get hasTasksDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    return _allReminders.any((r) =>
        !r.isCompleted &&
        !r.isArchived &&
        r.deadline.isAfter(now) &&
        r.deadline.isBefore(tomorrow));
  }

  /// Get count of high priority incomplete tasks
  int get highPriorityCount => _highPriorityTasks.length;

  /// Refresh data manually (useful for pull-to-refresh)
  Future<void> refresh() async {
    if (_currentStudentUid == null) return;

    try {
      // The stream will automatically update when Firestore changes
      // This method is here for explicit refresh if needed
      debugPrint('LiveUpdateService: Manual refresh triggered');
    } catch (e) {
      debugPrint('LiveUpdateService: Error during refresh: $e');
    }
  }

  /// Dispose and cleanup all listeners
  void dispose() {
    debugPrint('LiveUpdateService: Disposing');
    _remindersSubscription?.cancel();
    _remindersSubscription = null;
    _currentStudentUid = null;
    _highPriorityTasks = [];
    _allReminders = [];
  }
}
