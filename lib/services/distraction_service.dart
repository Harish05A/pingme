import 'package:flutter/material.dart';
import 'package:pingme/services/app_detector_service.dart';
import 'package:pingme/services/live_update_service.dart';

/// DistractionService - Orchestrates distraction detection and popup display
/// Integrates AppDetectorService with LiveUpdateService
/// Implements cooldown logic to prevent popup spam
class DistractionService {
  static final DistractionService instance = DistractionService._internal();
  factory DistractionService() => instance;
  DistractionService._internal();

  // Services
  final AppDetectorService _appDetector = AppDetectorService();
  final LiveUpdateService _liveUpdate = LiveUpdateService.instance;

  // State
  bool _isActive = false;
  DateTime? _lastPopupTime;
  String? _lastDetectedApp;

  // Configuration
  static const Duration cooldownDuration = Duration(minutes: 5);
  static const Duration detectionInterval = Duration(seconds: 2);

  // Callback for popup display
  Function(BuildContext context, String appName)? _onShowPopup;

  /// Check if service is currently active
  bool get isActive => _isActive;

  /// Get time until next popup can be shown
  Duration? get timeUntilNextPopup {
    if (_lastPopupTime == null) return null;

    final elapsed = DateTime.now().difference(_lastPopupTime!);
    final remaining = cooldownDuration - elapsed;

    return remaining.isNegative ? null : remaining;
  }

  /// Check if popup can be shown (cooldown expired)
  bool get canShowPopup {
    if (_lastPopupTime == null) return true;

    final elapsed = DateTime.now().difference(_lastPopupTime!);
    return elapsed >= cooldownDuration;
  }

  /// Start monitoring for distracting apps
  /// Requires a callback to show the popup with context
  void startMonitoring({
    required Function(BuildContext context, String appName) onShowPopup,
  }) {
    if (_isActive) {
      debugPrint('DistractionService: Already monitoring');
      return;
    }

    debugPrint('DistractionService: Starting monitoring');
    _isActive = true;
    _onShowPopup = onShowPopup;

    // Start app detection
    _appDetector.startMonitoring(
      onDistractingAppDetected: _onDistractingAppDetected,
      interval: detectionInterval,
    );
  }

  /// Stop monitoring
  void stopMonitoring() {
    if (!_isActive) return;

    debugPrint('DistractionService: Stopping monitoring');
    _isActive = false;
    _appDetector.stopMonitoring();
    _onShowPopup = null;
  }

  /// Handle distraction app detection
  void _onDistractingAppDetected(String packageName) {
    // Avoid duplicate triggers for same app
    if (_lastDetectedApp == packageName && !canShowPopup) {
      return;
    }

    debugPrint('DistractionService: Detected distracting app: $packageName');

    // Check cooldown
    if (!canShowPopup) {
      final remaining = timeUntilNextPopup;
      debugPrint(
          'DistractionService: Cooldown active. ${remaining?.inMinutes} min remaining');
      return;
    }

    // Check if there's anything to show
    if (!_shouldShowPopup()) {
      debugPrint('DistractionService: No high priority tasks, skipping popup');
      return;
    }

    _lastDetectedApp = packageName;
    _triggerPopup(packageName);
  }

  /// Check if popup should be shown based on available data
  bool _shouldShowPopup() {
    // Show popup if there are high priority tasks
    return _liveUpdate.highPriorityCount > 0;
  }

  /// Trigger popup display
  void _triggerPopup(String packageName) {
    // Get app name from package
    final appName = _getAppNameFromPackage(packageName);

    debugPrint('DistractionService: Triggering popup for $appName');

    // Update last popup time
    _lastPopupTime = DateTime.now();

    // Call the popup callback (will be handled by main app)
    // Note: This requires a BuildContext, which will be provided by the app
    // The actual popup display is handled externally
    debugPrint('DistractionService: Popup callback registered for $appName');
  }

  /// Show popup with context (called from app)
  void showPopupWithContext(BuildContext context, String appName) {
    _onShowPopup?.call(context, appName);
  }

  /// Get user-friendly app name from package name
  String _getAppNameFromPackage(String packageName) {
    const appNames = {
      'com.instagram.android': 'Instagram',
      'com.facebook.katana': 'Facebook',
      'com.twitter.android': 'Twitter',
      'com.zhiliaoapp.musically': 'TikTok',
      'com.snapchat.android': 'Snapchat',
      'com.google.android.youtube': 'YouTube',
      'com.netflix.mediaclient': 'Netflix',
      'com.disney.disneyplus': 'Disney+',
      'com.amazon.avod.thirdpartyclient': 'Prime Video',
      'tv.twitch.android.app': 'Twitch',
      'com.reddit.frontpage': 'Reddit',
      'com.discord': 'Discord',
    };

    return appNames[packageName] ?? 'Distracting App';
  }

  /// Reset cooldown (for testing or manual override)
  void resetCooldown() {
    _lastPopupTime = null;
    _lastDetectedApp = null;
    debugPrint('DistractionService: Cooldown reset');
  }

  /// Get statistics
  Map<String, dynamic> getStats() {
    return {
      'isActive': _isActive,
      'canShowPopup': canShowPopup,
      'lastPopupTime': _lastPopupTime?.toIso8601String(),
      'lastDetectedApp': _lastDetectedApp,
      'timeUntilNextPopup': timeUntilNextPopup?.inMinutes,
      'highPriorityTaskCount': _liveUpdate.highPriorityCount,
    };
  }

  /// Dispose and cleanup
  void dispose() {
    debugPrint('DistractionService: Disposing');
    stopMonitoring();
    _lastPopupTime = null;
    _lastDetectedApp = null;
  }
}
