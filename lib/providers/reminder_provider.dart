import 'package:flutter/foundation.dart';
import 'package:pingme/models/reminder_model.dart';
import 'package:pingme/services/firestore_service.dart';
import 'package:pingme/services/notification_service.dart';

class ReminderProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  List<ReminderModel> _reminders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ReminderModel> get reminders => _reminders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filtered getters
  List<ReminderModel> get pendingReminders =>
      _reminders.where((r) => r.isPending && !r.isArchived).toList();

  List<ReminderModel> get completedReminders =>
      _reminders.where((r) => r.isCompleted && !r.isArchived).toList();

  List<ReminderModel> get overdueReminders =>
      _reminders.where((r) => r.isOverdue && !r.isArchived).toList();

  List<ReminderModel> get archivedReminders =>
      _reminders.where((r) => r.isArchived).toList();

  /// Fetch reminders for a student
  Future<void> fetchStudentReminders(String studentUid) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final stream = _firestoreService.getStudentReminders(studentUid);

      stream.listen(
        (reminders) {
          _reminders = reminders;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Failed to load reminders: $error';
          debugPrint(_errorMessage);
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Error fetching reminders: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch reminders created by faculty
  Future<void> fetchFacultyReminders(String facultyUid) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final stream = _firestoreService.getFacultyReminders(facultyUid);

      stream.listen(
        (reminders) {
          _reminders = reminders;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = 'Failed to load reminders: $error';
          debugPrint(_errorMessage);
          notifyListeners();
        },
      );
    } catch (e) {
      _errorMessage = 'Error fetching reminders: $e';
      debugPrint(_errorMessage);
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new reminder (Faculty only)
  Future<bool> createReminder(ReminderModel reminder) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _firestoreService.createReminder(reminder);

      // Schedule notifications for this reminder
      await _scheduleReminderNotifications(reminder);

      debugPrint('Reminder created successfully: ${reminder.id}');
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create reminder: $e';
      debugPrint(_errorMessage);
      _setLoading(false);
      return false;
    }
  }

  /// Update an existing reminder
  Future<bool> updateReminder(
      String reminderId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _firestoreService.updateReminder(reminderId, updates);

      // If deadline changed, reschedule notifications
      if (updates.containsKey('deadline')) {
        final reminder = _reminders.firstWhere((r) => r.id == reminderId);
        await _cancelReminderNotifications(reminder);
        final updatedReminder =
            reminder.copyWith(deadline: updates['deadline']);
        await _scheduleReminderNotifications(updatedReminder);
      }

      debugPrint('Reminder updated successfully: $reminderId');
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update reminder: $e';
      debugPrint(_errorMessage);
      _setLoading(false);
      return false;
    }
  }

  /// Mark reminder as completed
  Future<bool> markReminderComplete(String reminderId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _firestoreService.markReminderComplete(reminderId);

      // Cancel all scheduled notifications for this reminder
      final reminder = _reminders.firstWhere((r) => r.id == reminderId);
      await _cancelReminderNotifications(reminder);

      debugPrint('Reminder marked complete: $reminderId');
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to mark reminder complete: $e';
      debugPrint(_errorMessage);
      _setLoading(false);
      return false;
    }
  }

  /// Toggle reminder completion status
  Future<bool> toggleReminderCompletion(String reminderId) async {
    try {
      final reminder = _reminders.firstWhere((r) => r.id == reminderId);
      if (reminder.isCompleted) {
        // Uncomplete the reminder
        return await updateReminder(reminderId, {
          'isCompleted': false,
          'completedAt': null,
        });
      } else {
        // Complete the reminder
        return await markReminderComplete(reminderId);
      }
    } catch (e) {
      _errorMessage = 'Failed to toggle reminder: $e';
      debugPrint(_errorMessage);
      return false;
    }
  }

  /// Delete a reminder
  Future<bool> deleteReminder(String reminderId) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Cancel notifications first
      final reminder = _reminders.firstWhere((r) => r.id == reminderId);
      await _cancelReminderNotifications(reminder);

      await _firestoreService.deleteReminder(reminderId);

      debugPrint('Reminder deleted: $reminderId');
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete reminder: $e';
      debugPrint(_errorMessage);
      _setLoading(false);
      return false;
    }
  }

  /// Archive old reminders
  Future<void> archiveOldReminders(String studentUid) async {
    try {
      await _firestoreService.archiveOldReminders(studentUid);
      debugPrint('Old reminders archived for student: $studentUid');
    } catch (e) {
      debugPrint('Error archiving reminders: $e');
    }
  }

  /// Schedule notifications for a reminder (24hr, 1hr, 15min before deadline)
  Future<void> _scheduleReminderNotifications(ReminderModel reminder) async {
    final now = DateTime.now();
    final deadline = reminder.deadline;

    // 24 hours before
    final time24hr = deadline.subtract(const Duration(hours: 24));
    if (time24hr.isAfter(now)) {
      await _notificationService.scheduleNotification(
        id: reminder.id.hashCode + 1,
        title: '📅 Reminder: ${reminder.title}',
        body: '24 hours until deadline - ${reminder.typeDisplayName}',
        scheduledDate: time24hr,
        payload: reminder.id,
      );
      debugPrint('Scheduled 24hr notification for: ${reminder.title}');
    }

    // 1 hour before
    final time1hr = deadline.subtract(const Duration(hours: 1));
    if (time1hr.isAfter(now)) {
      await _notificationService.scheduleNotification(
        id: reminder.id.hashCode + 2,
        title: '⏰ Urgent: ${reminder.title}',
        body: '1 hour until deadline - ${reminder.typeDisplayName}',
        scheduledDate: time1hr,
        payload: reminder.id,
      );
      debugPrint('Scheduled 1hr notification for: ${reminder.title}');
    }

    // 15 minutes before
    final time15min = deadline.subtract(const Duration(minutes: 15));
    if (time15min.isAfter(now)) {
      await _notificationService.scheduleNotification(
        id: reminder.id.hashCode + 3,
        title: '🚨 URGENT: ${reminder.title}',
        body: '15 minutes until deadline - ${reminder.typeDisplayName}',
        scheduledDate: time15min,
        payload: reminder.id,
      );
      debugPrint('Scheduled 15min notification for: ${reminder.title}');
    }
  }

  /// Cancel all notifications for a reminder
  Future<void> _cancelReminderNotifications(ReminderModel reminder) async {
    await _notificationService.cancelNotification(reminder.id.hashCode + 1);
    await _notificationService.cancelNotification(reminder.id.hashCode + 2);
    await _notificationService.cancelNotification(reminder.id.hashCode + 3);
    debugPrint('Cancelled notifications for: ${reminder.title}');
  }

  /// Helper to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
