import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/platform_alert_settings.dart';
import 'package:url_launcher/url_launcher.dart';

/// Android answers through a tiny method channel in `MainActivity`; iOS only
/// supports opening the app's settings page (`app-settings:`).
class MethodChannelPlatformAlertSettings implements PlatformAlertSettings {
  MethodChannelPlatformAlertSettings([
    MethodChannel channel = const MethodChannel(channelName),
  ]) : _channel = channel;

  static const channelName = 'com.pharmacytracker/alert_settings';
  final MethodChannel _channel;

  @override
  Future<DeviceAlertConditions> conditions() async {
    if (!Platform.isAndroid) return const DeviceAlertConditions();
    try {
      final result = await _channel.invokeMapMethod<String, Object?>(
        'conditions',
      );
      return DeviceAlertConditions(
        ignoringBatteryOptimizations:
            result?['ignoringBatteryOptimizations'] as bool?,
        manufacturer: (result?['manufacturer'] as String?)?.toLowerCase(),
      );
    } on PlatformException catch (e) {
      debugPrint('Could not read device alert conditions: $e');
      return const DeviceAlertConditions();
    } on MissingPluginException {
      return const DeviceAlertConditions();
    }
  }

  @override
  Future<void> openNotificationSettings() async {
    if (Platform.isAndroid) {
      await _invoke('openNotificationSettings');
    } else if (Platform.isIOS) {
      await launchUrl(Uri.parse('app-settings:'));
    }
  }

  @override
  Future<void> openBatterySettings() async {
    if (Platform.isAndroid) await _invoke('openBatterySettings');
  }

  Future<void> _invoke(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on PlatformException catch (e) {
      debugPrint('$method failed: $e');
    } on MissingPluginException {
      debugPrint('$method is not available on this platform');
    }
  }
}
