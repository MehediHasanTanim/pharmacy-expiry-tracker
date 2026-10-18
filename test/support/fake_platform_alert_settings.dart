import 'package:pharmacy_expiry_tracker/domain/notifications/platform_alert_settings.dart';

class FakePlatformAlertSettings implements PlatformAlertSettings {
  FakePlatformAlertSettings({
    this.battery = true,
    this.manufacturer = 'google',
  });

  bool? battery;
  String? manufacturer;
  final opened = <String>[];

  @override
  Future<DeviceAlertConditions> conditions() async => DeviceAlertConditions(
    ignoringBatteryOptimizations: battery,
    manufacturer: manufacturer,
  );

  @override
  Future<void> openBatterySettings() async => opened.add('battery');

  @override
  Future<void> openNotificationSettings() async => opened.add('notifications');
}
