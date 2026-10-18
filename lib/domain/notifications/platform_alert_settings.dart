import 'package:flutter/foundation.dart';

/// What the OS says about conditions that can silently stop alerts.
@immutable
class DeviceAlertConditions {
  const DeviceAlertConditions({
    this.ignoringBatteryOptimizations,
    this.manufacturer,
  });

  /// Android: is the app exempt from battery optimisation? Null where the
  /// platform cannot tell (iOS) or the answer is unavailable.
  final bool? ignoringBatteryOptimizations;

  /// Android device maker (lower-case, e.g. `xiaomi`), used to show the right
  /// advice for aggressive battery managers.
  final String? manufacturer;

  /// Makers whose battery managers are known to stop background work even
  /// when the app is exempt, and so deserve extra guidance.
  bool get hasAggressiveBatteryManager => const {
    'xiaomi',
    'redmi',
    'poco',
    'oppo',
    'realme',
    'oneplus',
    'vivo',
    'huawei',
    'honor',
    'samsung',
    'meizu',
    'tecno',
    'infinix',
    'itel',
  }.contains(manufacturer);
}

/// Small Android-only helpers around notification health, plus opening the
/// right system settings page. iOS can only open the app's settings.
abstract interface class PlatformAlertSettings {
  Future<DeviceAlertConditions> conditions();

  /// The app's notification settings page.
  Future<void> openNotificationSettings();

  /// Android's battery-optimisation list.
  Future<void> openBatterySettings();
}
