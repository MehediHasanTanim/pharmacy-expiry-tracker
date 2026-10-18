import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/app_badge.dart';

/// Icon badge through `app_badge_plus`: iOS home-screen badge, and Android
/// launchers that support badge counts.
class PluginAppBadge implements AppBadge {
  const PluginAppBadge();

  @override
  Future<void> setCount(int count) async {
    try {
      if (!await AppBadgePlus.isSupported()) return;
      await AppBadgePlus.updateBadge(count < 0 ? 0 : count);
    } on Object catch (e) {
      // Badges are decoration; never let one break the app.
      debugPrint('Could not set the app badge: $e');
    }
  }
}
