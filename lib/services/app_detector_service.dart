import 'dart:async';
// import 'package:usage_stats/usage_stats.dart'; // Temporarily disabled due to Android SDK compatibility

class AppDetectorService {
  static final AppDetectorService _instance = AppDetectorService._internal();
  factory AppDetectorService() => _instance;
  AppDetectorService._internal();

  // Distracting Apps Package Names
  static const List<String> _defaultDistractingApps = [
    'com.instagram.android',
    'com.facebook.katana',
    'com.twitter.android',
    'com.zhiliaoapp.musically', // TikTok
    'com.snapchat.android',
    'com.google.android.youtube',
    'com.netflix.mediaclient',
    'com.disney.disneyplus',
    'com.amazon.avod.thirdpartyclient', // Prime Video
    'tv.twitch.android.app',
    'com.reddit.frontpage',
    'com.discord',
  ];

  // Whitelist for allowed apps during focus
  final List<String> _whitelistedApps = [
    'com.android.settings',
    'com.android.systemui',
    'com.google.android.dialer',
    'com.google.android.contacts',
  ];

  // Custom distracting apps (user can add/remove)
  final List<String> _customDistractingApps = [];

  // Monitoring
  Timer? _monitoringTimer;
  Function(String packageName)? _onDistractingAppDetected;
  bool _isMonitoring = false;

  // Get all distracting apps
  List<String> get distractingApps => [
        ..._defaultDistractingApps,
        ..._customDistractingApps,
      ];

  // Check Permission - STUBBED
  Future<bool> checkPermission() async {
    // TODO: Re-enable when usage_stats is fixed
    return false;
  }

  // Request Permission - STUBBED
  Future<void> requestPermission() async {
    // TODO: Re-enable when usage_stats is fixed
    return;
  }

  // Get Current App - STUBBED
  Future<String?> getCurrentApp() async {
    // TODO: Re-enable when usage_stats is fixed
    return null;
  }

  // Check if app is distracting
  bool isDistracting(String packageName) {
    return distractingApps.contains(packageName) &&
        !_whitelistedApps.contains(packageName);
  }

  // Check if app is whitelisted
  bool isWhitelisted(String packageName) {
    return _whitelistedApps.contains(packageName);
  }

  // Add to whitelist
  void addToWhitelist(String packageName) {
    if (!_whitelistedApps.contains(packageName)) {
      _whitelistedApps.add(packageName);
    }
  }

  // Remove from whitelist
  void removeFromWhitelist(String packageName) {
    _whitelistedApps.remove(packageName);
  }

  // Add custom distracting app
  void addDistractingApp(String packageName) {
    if (!_customDistractingApps.contains(packageName)) {
      _customDistractingApps.add(packageName);
    }
  }

  // Remove custom distracting app
  void removeDistractingApp(String packageName) {
    _customDistractingApps.remove(packageName);
  }

  // Start monitoring for distracting apps - STUBBED
  void startMonitoring({
    required Function(String packageName) onDistractingAppDetected,
    Duration interval = const Duration(seconds: 2),
  }) {
    // TODO: Re-enable when usage_stats is fixed
    if (_isMonitoring) return;

    _onDistractingAppDetected = onDistractingAppDetected;
    _isMonitoring = true;

    // Monitoring disabled - usage_stats not available
    _monitoringTimer = Timer.periodic(interval, (_) async {
      // No-op: usage_stats functionality disabled
    });
  }

  // Stop monitoring
  void stopMonitoring() {
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
    _onDistractingAppDetected = null;
    _isMonitoring = false;
  }

  // Get monitoring status
  bool get isMonitoring => _isMonitoring;

  // Get whitelist
  List<String> get whitelistedApps => List.unmodifiable(_whitelistedApps);

  // Get custom distracting apps
  List<String> get customDistractingApps =>
      List.unmodifiable(_customDistractingApps);
}
