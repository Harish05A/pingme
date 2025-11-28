import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:pingme/models/focus_session_model.dart';
import 'package:pingme/services/firestore_service.dart';
import 'package:pingme/services/app_detector_service.dart';
import 'package:pingme/services/overlay_service.dart';

class FocusProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AppDetectorService _appDetectorService = AppDetectorService();
  final OverlayService _overlayService = OverlayService();

  FocusSessionModel? _currentSession;
  List<FocusSessionModel> _sessions = [];
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _sessionTimer;
  bool _isPaused = false;

  FocusSessionModel? get currentSession => _currentSession;
  List<FocusSessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFocusModeActive =>
      _currentSession != null && !_currentSession!.isCompleted && !_isPaused;
  bool get isPaused => _isPaused;

  // Computed getters for UI
  int get totalFocusTime {
    return _sessions
        .where((s) => s.isCompleted)
        .fold(0, (sum, s) => sum + s.actualDurationMinutes);
  }

  int get currentStreak {
    if (_sessions.isEmpty) return 0;

    int streak = 0;
    final sortedSessions = List<FocusSessionModel>.from(_sessions)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    DateTime? lastDate;
    for (var session in sortedSessions) {
      if (!session.wasSuccessful) break;

      final sessionDate = DateTime(
        session.startTime.year,
        session.startTime.month,
        session.startTime.day,
      );

      if (lastDate == null) {
        lastDate = sessionDate;
        streak = 1;
      } else {
        final daysDiff = lastDate.difference(sessionDate).inDays;
        if (daysDiff == 1) {
          streak++;
          lastDate = sessionDate;
        } else if (daysDiff > 1) {
          break;
        }
      }
    }
    return streak;
  }

  int get distractionCount {
    return _currentSession?.distractionCount ?? 0;
  }

  /// Start a new focus session
  Future<bool> startFocusSession({
    required String userId,
    required int durationMinutes,
  }) async {
    if (_currentSession != null && !_currentSession!.isCompleted) {
      _errorMessage = 'A focus session is already active';
      notifyListeners();
      return false;
    }

    try {
      final session = FocusSessionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        startTime: DateTime.now(),
        durationMinutes: durationMinutes,
      );

      _currentSession = session;
      _isPaused = false;

      // Start monitoring for distracting apps with new API
      _appDetectorService.startMonitoring(
        onDistractingAppDetected: _handleDistractingApp,
        interval: const Duration(seconds: 2),
      );

      // Reset overlay block count
      _overlayService.resetBlockCount();

      // Start session timer
      _startSessionTimer();

      debugPrint(
          'Focus session started: ${session.id} for $durationMinutes minutes');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to start focus session: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// Pause the current focus session
  void pauseFocusSession() {
    if (_currentSession == null || _currentSession!.isCompleted) {
      return;
    }

    _isPaused = true;
    _sessionTimer?.cancel();
    _appDetectorService.stopMonitoring();

    debugPrint('Focus session paused: ${_currentSession!.id}');
    notifyListeners();
  }

  /// Resume a paused focus session
  void resumeFocusSession() {
    if (_currentSession == null || _currentSession!.isCompleted || !_isPaused) {
      return;
    }

    _isPaused = false;
    _appDetectorService.startMonitoring(
      onDistractingAppDetected: _handleDistractingApp,
      interval: const Duration(seconds: 2),
    );
    _startSessionTimer();

    debugPrint('Focus session resumed: ${_currentSession!.id}');
    notifyListeners();
  }

  /// End the current focus session
  Future<bool> endFocusSession({bool wasSuccessful = true}) async {
    if (_currentSession == null) {
      return false;
    }

    try {
      _sessionTimer?.cancel();
      _appDetectorService.stopMonitoring();

      final endTime = DateTime.now();
      final actualDuration =
          endTime.difference(_currentSession!.startTime).inMinutes;

      final completedSession = _currentSession!.copyWith(
        endTime: endTime,
        actualDurationMinutes: actualDuration,
        isCompleted: true,
        wasSuccessful: wasSuccessful,
      );

      // Save to Firestore
      await _firestoreService.saveFocusSession(completedSession);

      _sessions.insert(0, completedSession);
      _currentSession = null;
      _isPaused = false;

      debugPrint(
          'Focus session ended: ${completedSession.id}, Duration: $actualDuration min');
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to end focus session: $e';
      debugPrint(_errorMessage);
      notifyListeners();
      return false;
    }
  }

  /// Fetch focus sessions for a user
  Future<void> fetchFocusSessions(String userId, {int limit = 30}) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      final sessions =
          await _firestoreService.getFocusSessions(userId, limit: limit);
      _sessions = sessions;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error fetching focus sessions: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Get focus statistics for a user
  Future<Map<String, dynamic>> getFocusStats(String userId) async {
    try {
      return await _firestoreService.getFocusStats(userId);
    } catch (e) {
      debugPrint('Error fetching focus stats: $e');
      return {
        'totalMinutes': 0,
        'sessionsCount': 0,
        'successRate': 0.0,
        'currentStreak': 0,
        'longestStreak': 0,
      };
    }
  }

  /// Handle distracting app detection
  Future<void> _handleDistractingApp(String packageName) async {
    if (_currentSession == null || _isPaused) return;

    // Increment distraction count
    final updatedSession = _currentSession!.copyWith(
      distractionCount: _currentSession!.distractionCount + 1,
      distractingApps: [
        ..._currentSession!.distractingApps,
        if (!_currentSession!.distractingApps.contains(packageName))
          packageName,
      ],
    );

    _currentSession = updatedSession;

    // Show blocking overlay with app name
    final appName = _getAppName(packageName);
    final remainingTime = getRemainingTime();

    await _overlayService.showBlockingOverlay(
      appName: appName,
      message:
          'Stay focused! You have ${remainingTime.inMinutes} minutes left.\n\nDistractions blocked: ${_overlayService.blockCount}',
    );

    notifyListeners();
  }

  /// Get friendly app name from package name
  String _getAppName(String packageName) {
    final Map<String, String> appNames = {
      'com.instagram.android': 'Instagram',
      'com.facebook.katana': 'Facebook',
      'com.twitter.android': 'Twitter',
      'com.zhiliaoapp.musically': 'TikTok',
      'com.snapchat.android': 'Snapchat',
      'com.google.android.youtube': 'YouTube',
      'com.netflix.mediaclient': 'Netflix',
      'com.discord': 'Discord',
      'com.reddit.frontpage': 'Reddit',
    };
    return appNames[packageName] ?? 'Distracting App';
  }

  /// Start session timer to track completion
  void _startSessionTimer() {
    _sessionTimer?.cancel();

    if (_currentSession == null) return;

    final duration = Duration(minutes: _currentSession!.durationMinutes);

    _sessionTimer = Timer(duration, () async {
      debugPrint('Focus session time completed');
      await endFocusSession(wasSuccessful: true);
    });
  }

  /// Get remaining time for current session
  Duration getRemainingTime() {
    if (_currentSession == null || _currentSession!.isCompleted) {
      return Duration.zero;
    }
    return _currentSession!.remainingTime;
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

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _appDetectorService.stopMonitoring();
    super.dispose();
  }
}
