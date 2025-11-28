import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pingme/models/reminder_model.dart';
import 'package:pingme/models/focus_session_model.dart';
import 'package:pingme/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== REMINDER OPERATIONS ====================

  /// Create a new reminder
  Future<String> createReminder(ReminderModel reminder) async {
    try {
      final docRef =
          await _firestore.collection('reminders').add(reminder.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create reminder: $e');
    }
  }

  /// Get reminders for a specific student
  Stream<List<ReminderModel>> getStudentReminders(String studentUid) {
    return _firestore
        .collection('reminders')
        .where('targetStudents', arrayContains: studentUid)
        .orderBy('deadline', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReminderModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get reminders created by a faculty member
  Stream<List<ReminderModel>> getFacultyReminders(String facultyUid) {
    return _firestore
        .collection('reminders')
        .where('createdBy', isEqualTo: facultyUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReminderModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get pending reminders for a student
  Future<List<ReminderModel>> getPendingReminders(String studentUid) async {
    try {
      final snapshot = await _firestore
          .collection('reminders')
          .where('targetStudents', arrayContains: studentUid)
          .where('isCompleted', isEqualTo: false)
          .where('deadline', isGreaterThan: Timestamp.now())
          .orderBy('deadline')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => ReminderModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pending reminders: $e');
    }
  }

  /// Update reminder
  Future<void> updateReminder(
      String reminderId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).update(updates);
    } catch (e) {
      throw Exception('Failed to update reminder: $e');
    }
  }

  /// Mark reminder as completed
  Future<void> markReminderComplete(String reminderId) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).update({
        'isCompleted': true,
        'completedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark reminder as complete: $e');
    }
  }

  /// Delete reminder
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _firestore.collection('reminders').doc(reminderId).delete();
    } catch (e) {
      throw Exception('Failed to delete reminder: $e');
    }
  }

  /// Archive old reminders (past deadline)
  Future<void> archiveOldReminders(String studentUid) async {
    try {
      final snapshot = await _firestore
          .collection('reminders')
          .where('targetStudents', arrayContains: studentUid)
          .where('deadline', isLessThan: Timestamp.now())
          .where('isArchived', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isArchived': true});
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to archive reminders: $e');
    }
  }

  // ==================== FOCUS SESSION OPERATIONS ====================

  /// Save focus session
  Future<void> saveFocusSession(FocusSessionModel session) async {
    try {
      await _firestore
          .collection('focus_sessions')
          .doc(session.id)
          .set(session.toMap());
    } catch (e) {
      throw Exception('Failed to save focus session: $e');
    }
  }

  /// Get focus sessions for a student
  Future<List<FocusSessionModel>> getFocusSessions(String studentUid,
      {int limit = 30}) async {
    try {
      final snapshot = await _firestore
          .collection('focus_sessions')
          .where('userId', isEqualTo: studentUid)
          .orderBy('startTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => FocusSessionModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch focus sessions: $e');
    }
  }

  /// Get focus statistics for a student
  Future<Map<String, dynamic>> getFocusStats(String studentUid) async {
    try {
      final sessions = await getFocusSessions(studentUid);

      int totalSessions = sessions.length;
      int successfulSessions = sessions.where((s) => s.wasSuccessful).length;
      int totalMinutes = sessions.fold(
          0, (sum, session) => sum + session.actualDurationMinutes);
      int totalViolations =
          sessions.fold(0, (sum, session) => sum + session.distractionCount);

      // Calculate streaks
      final streakData = _calculateStreak(sessions);

      // Calculate success rate
      double successRate =
          totalSessions > 0 ? (successfulSessions / totalSessions) * 100 : 0.0;

      return {
        'totalSessions': totalSessions,
        'sessionsCount': totalSessions,
        'totalMinutes': totalMinutes,
        'totalViolations': totalViolations,
        'currentStreak': streakData['currentStreak'],
        'longestStreak': streakData['longestStreak'],
        'successRate': successRate,
        'averageSessionLength':
            totalSessions > 0 ? totalMinutes / totalSessions : 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch focus stats: $e');
    }
  }

  /// Calculate current and longest streak
  Map<String, int> _calculateStreak(List<FocusSessionModel> sessions) {
    if (sessions.isEmpty) {
      return {'currentStreak': 0, 'longestStreak': 0};
    }

    // Group sessions by date
    final sessionsByDate = <String, bool>{};
    for (var session in sessions) {
      final dateKey =
          '${session.startTime.year}-${session.startTime.month}-${session.startTime.day}';
      sessionsByDate[dateKey] = true;
    }

    // Sort dates
    final sortedDates = sessionsByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a)); // Most recent first

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;
    DateTime? lastDate;

    for (var dateStr in sortedDates) {
      final parts = dateStr.split('-');
      final date = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));

      if (lastDate == null) {
        // First date
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final daysDiff = todayDate.difference(date).inDays;

        if (daysDiff <= 1) {
          // Session is today or yesterday
          currentStreak = 1;
          tempStreak = 1;
        }
        lastDate = date;
      } else {
        final daysDiff = lastDate.difference(date).inDays;
        if (daysDiff == 1) {
          // Consecutive day
          tempStreak++;
          if (currentStreak > 0) {
            currentStreak++;
          }
        } else {
          // Streak broken
          if (tempStreak > longestStreak) {
            longestStreak = tempStreak;
          }
          tempStreak = 1;
          currentStreak = 0; // Current streak is broken
        }
        lastDate = date;
      }
    }

    // Check final streak
    if (tempStreak > longestStreak) {
      longestStreak = tempStreak;
    }

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
    };
  }

  // ==================== USER OPERATIONS ====================

  /// Get all students (for faculty to target reminders)
  Future<List<UserModel>> getAllStudents() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw Exception('Failed to fetch students: $e');
    }
  }

  /// Get user by UID
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  /// Update user data
  Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // ==================== ANALYTICS ====================

  /// Get reminder completion rate for a student
  Future<double> getReminderCompletionRate(String studentUid) async {
    try {
      final allReminders = await _firestore
          .collection('reminders')
          .where('targetStudents', arrayContains: studentUid)
          .get();

      if (allReminders.docs.isEmpty) return 0.0;

      final completedCount = allReminders.docs
          .where((doc) => doc.data()['isCompleted'] == true)
          .length;

      return (completedCount / allReminders.docs.length) * 100;
    } catch (e) {
      throw Exception('Failed to calculate completion rate: $e');
    }
  }

  /// Get pending reminders count
  Future<int> getPendingRemindersCount(String studentUid) async {
    try {
      final snapshot = await _firestore
          .collection('reminders')
          .where('targetStudents', arrayContains: studentUid)
          .where('isCompleted', isEqualTo: false)
          .where('deadline', isGreaterThan: Timestamp.now())
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}
