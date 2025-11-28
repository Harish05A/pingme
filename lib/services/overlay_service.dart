import 'package:flutter_overlay_window/flutter_overlay_window.dart';

class OverlayService {
  static final OverlayService _instance = OverlayService._internal();
  factory OverlayService() => _instance;
  OverlayService._internal();

  int _blockCount = 0;

  // Check and Request Permission
  Future<bool> requestPermission() async {
    final bool status = await FlutterOverlayWindow.isPermissionGranted();
    if (!status) {
      final bool? granted = await FlutterOverlayWindow.requestPermission();
      return granted ?? false;
    }
    return true;
  }

  // Show Overlay
  Future<void> showOverlay({
    required String title,
    required String body,
    String type = 'reminder', // 'reminder' or 'distraction'
  }) async {
    if (await FlutterOverlayWindow.isActive()) return;

    await FlutterOverlayWindow.showOverlay(
      enableDrag: true,
      overlayTitle: title,
      overlayContent: body,
      flag: OverlayFlag.defaultFlag,
      alignment: OverlayAlignment.center,
      visibility: NotificationVisibility.visibilityPublic,
      positionGravity: PositionGravity.auto,
      height: WindowSize.matchParent,
      width: WindowSize.matchParent,
    );

    // Share data with the overlay
    await FlutterOverlayWindow.shareData({
      'title': title,
      'body': body,
      'type': type,
    });
  }

  // Show Blocking Overlay for Distracting Apps
  Future<void> showBlockingOverlay({
    required String appName,
    required String message,
  }) async {
    _blockCount++;

    await showOverlay(
      title: '🚫 App Blocked',
      body: message,
      type: 'distraction',
    );

    // Share additional data for blocking overlay
    await FlutterOverlayWindow.shareData({
      'title': '🚫 App Blocked',
      'body': message,
      'type': 'distraction',
      'appName': appName,
      'blockCount': _blockCount,
    });
  }

  // Show Distraction Warning
  Future<void> showDistractionWarning({
    required String message,
    required int distractionCount,
  }) async {
    await showOverlay(
      title: '⚠️ Stay Focused!',
      body: message,
      type: 'warning',
    );

    await FlutterOverlayWindow.shareData({
      'title': '⚠️ Stay Focused!',
      'body': message,
      'type': 'warning',
      'distractionCount': distractionCount,
    });
  }

  // Close Overlay
  Future<void> closeOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
  }

  // Check if Overlay is Active
  Future<bool> isActive() async {
    return await FlutterOverlayWindow.isActive();
  }

  // Get block count
  int get blockCount => _blockCount;

  // Reset block count
  void resetBlockCount() {
    _blockCount = 0;
  }
}
