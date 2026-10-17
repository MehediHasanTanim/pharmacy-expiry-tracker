import 'package:flutter/foundation.dart';

/// All user settings with their defaults (feature spec §4.10, SET-1…SET-13).
@immutable
class AppSettings {
  const AppSettings({
    this.pharmacyName = '',
    this.nearExpiryWindowDays = 90,
    this.bucketThresholds = const [30, 60, 90],
    this.alertLeadDays = const [90, 60, 30, 14, 7, 1, 0],
    this.digestEnabled = true,
    this.digestMinutes = 9 * 60,
    this.skipEmptyDigest = true,
    this.quietHoursEnabled = false,
    this.quietStartMinutes = 22 * 60,
    this.quietEndMinutes = 7 * 60,
    this.paymentLeadDays = const [3, 0],
    this.overdueRepeatDays = 3,
    this.reorderRefireDays = 3,
    this.backupReminderDays = 14,
    this.currencySymbol = '',
    this.dateFormat = '',
    this.languageCode = 'en',
    this.themeMode = 'system',
    this.appLockEnabled = false,
    this.hideDetailsOnLockScreen = false,
    this.expirySort = 'soonest',
    this.expiryCategory = '',
    this.expiryForm = '',
    this.expiryHideHandled = false,
  });

  /// Rebuilds settings from stored key/value rows; missing or malformed values
  /// fall back to defaults.
  factory AppSettings.fromMap(Map<String, String> m) {
    const d = AppSettings();
    return AppSettings(
      pharmacyName: m[SettingKey.pharmacyName] ?? d.pharmacyName,
      nearExpiryWindowDays:
          _int(m[SettingKey.nearExpiryWindowDays]) ?? d.nearExpiryWindowDays,
      bucketThresholds:
          _intList(m[SettingKey.bucketThresholds]) ?? d.bucketThresholds,
      alertLeadDays: _intList(m[SettingKey.alertLeadDays]) ?? d.alertLeadDays,
      digestEnabled: _bool(m[SettingKey.digestEnabled]) ?? d.digestEnabled,
      digestMinutes: _int(m[SettingKey.digestMinutes]) ?? d.digestMinutes,
      skipEmptyDigest:
          _bool(m[SettingKey.skipEmptyDigest]) ?? d.skipEmptyDigest,
      quietHoursEnabled:
          _bool(m[SettingKey.quietHoursEnabled]) ?? d.quietHoursEnabled,
      quietStartMinutes:
          _int(m[SettingKey.quietStartMinutes]) ?? d.quietStartMinutes,
      quietEndMinutes: _int(m[SettingKey.quietEndMinutes]) ?? d.quietEndMinutes,
      paymentLeadDays:
          _intList(m[SettingKey.paymentLeadDays]) ?? d.paymentLeadDays,
      overdueRepeatDays:
          _int(m[SettingKey.overdueRepeatDays]) ?? d.overdueRepeatDays,
      reorderRefireDays:
          _int(m[SettingKey.reorderRefireDays]) ?? d.reorderRefireDays,
      backupReminderDays:
          _int(m[SettingKey.backupReminderDays]) ?? d.backupReminderDays,
      currencySymbol: m[SettingKey.currencySymbol] ?? d.currencySymbol,
      dateFormat: m[SettingKey.dateFormat] ?? d.dateFormat,
      languageCode: m[SettingKey.languageCode] ?? d.languageCode,
      themeMode: m[SettingKey.themeMode] ?? d.themeMode,
      appLockEnabled: _bool(m[SettingKey.appLockEnabled]) ?? d.appLockEnabled,
      hideDetailsOnLockScreen:
          _bool(m[SettingKey.hideDetailsOnLockScreen]) ??
          d.hideDetailsOnLockScreen,
      expirySort: m[SettingKey.expirySort] ?? d.expirySort,
      expiryCategory: m[SettingKey.expiryCategory] ?? d.expiryCategory,
      expiryForm: m[SettingKey.expiryForm] ?? d.expiryForm,
      expiryHideHandled:
          _bool(m[SettingKey.expiryHideHandled]) ?? d.expiryHideHandled,
    );
  }

  final String pharmacyName;

  /// SET-1: global near-expiry window.
  final int nearExpiryWindowDays;

  /// SET-2: urgency bucket thresholds, ascending (days).
  final List<int> bucketThresholds;

  /// SET-3: days before expiry to alert; `0` = on the expiry day.
  final List<int> alertLeadDays;

  /// SET-4: daily digest.
  final bool digestEnabled;
  final int digestMinutes;
  final bool skipEmptyDigest;

  /// SET-5: quiet hours (minutes since midnight).
  final bool quietHoursEnabled;
  final int quietStartMinutes;
  final int quietEndMinutes;

  /// SET-6: supplier payment reminders.
  final List<int> paymentLeadDays;
  final int overdueRepeatDays;

  /// SET-7: minimum days between reorder reminders per medicine.
  final int reorderRefireDays;

  final int backupReminderDays;

  /// SET-8/9: empty string = follow the device locale.
  final String currencySymbol;
  final String dateFormat;

  /// SET-10.
  final String languageCode;

  /// SET-11: `system` | `light` | `dark`.
  final String themeMode;

  /// SET-12.
  final bool appLockEnabled;
  final bool hideDetailsOnLockScreen;

  /// Last-used Expiry tab selections (EXP-4): `soonest` | `value` | `name`;
  /// empty category/form mean "all".
  final String expirySort;
  final String expiryCategory;
  final String expiryForm;
  final bool expiryHideHandled;

  Map<String, String> toMap() => {
    SettingKey.pharmacyName: pharmacyName,
    SettingKey.nearExpiryWindowDays: '$nearExpiryWindowDays',
    SettingKey.bucketThresholds: bucketThresholds.join(','),
    SettingKey.alertLeadDays: alertLeadDays.join(','),
    SettingKey.digestEnabled: '$digestEnabled',
    SettingKey.digestMinutes: '$digestMinutes',
    SettingKey.skipEmptyDigest: '$skipEmptyDigest',
    SettingKey.quietHoursEnabled: '$quietHoursEnabled',
    SettingKey.quietStartMinutes: '$quietStartMinutes',
    SettingKey.quietEndMinutes: '$quietEndMinutes',
    SettingKey.paymentLeadDays: paymentLeadDays.join(','),
    SettingKey.overdueRepeatDays: '$overdueRepeatDays',
    SettingKey.reorderRefireDays: '$reorderRefireDays',
    SettingKey.backupReminderDays: '$backupReminderDays',
    SettingKey.currencySymbol: currencySymbol,
    SettingKey.dateFormat: dateFormat,
    SettingKey.languageCode: languageCode,
    SettingKey.themeMode: themeMode,
    SettingKey.appLockEnabled: '$appLockEnabled',
    SettingKey.hideDetailsOnLockScreen: '$hideDetailsOnLockScreen',
    SettingKey.expirySort: expirySort,
    SettingKey.expiryCategory: expiryCategory,
    SettingKey.expiryForm: expiryForm,
    SettingKey.expiryHideHandled: '$expiryHideHandled',
  };

  AppSettings copyWith({
    String? pharmacyName,
    int? nearExpiryWindowDays,
    List<int>? bucketThresholds,
    List<int>? alertLeadDays,
    bool? digestEnabled,
    int? digestMinutes,
    bool? skipEmptyDigest,
    bool? quietHoursEnabled,
    int? quietStartMinutes,
    int? quietEndMinutes,
    List<int>? paymentLeadDays,
    int? overdueRepeatDays,
    int? reorderRefireDays,
    int? backupReminderDays,
    String? currencySymbol,
    String? dateFormat,
    String? languageCode,
    String? themeMode,
    bool? appLockEnabled,
    bool? hideDetailsOnLockScreen,
    String? expirySort,
    String? expiryCategory,
    String? expiryForm,
    bool? expiryHideHandled,
  }) {
    return AppSettings(
      pharmacyName: pharmacyName ?? this.pharmacyName,
      nearExpiryWindowDays: nearExpiryWindowDays ?? this.nearExpiryWindowDays,
      bucketThresholds: bucketThresholds ?? this.bucketThresholds,
      alertLeadDays: alertLeadDays ?? this.alertLeadDays,
      digestEnabled: digestEnabled ?? this.digestEnabled,
      digestMinutes: digestMinutes ?? this.digestMinutes,
      skipEmptyDigest: skipEmptyDigest ?? this.skipEmptyDigest,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStartMinutes: quietStartMinutes ?? this.quietStartMinutes,
      quietEndMinutes: quietEndMinutes ?? this.quietEndMinutes,
      paymentLeadDays: paymentLeadDays ?? this.paymentLeadDays,
      overdueRepeatDays: overdueRepeatDays ?? this.overdueRepeatDays,
      reorderRefireDays: reorderRefireDays ?? this.reorderRefireDays,
      backupReminderDays: backupReminderDays ?? this.backupReminderDays,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      dateFormat: dateFormat ?? this.dateFormat,
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      hideDetailsOnLockScreen:
          hideDetailsOnLockScreen ?? this.hideDetailsOnLockScreen,
      expirySort: expirySort ?? this.expirySort,
      expiryCategory: expiryCategory ?? this.expiryCategory,
      expiryForm: expiryForm ?? this.expiryForm,
      expiryHideHandled: expiryHideHandled ?? this.expiryHideHandled,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings && mapEquals(other.toMap(), toMap());

  @override
  int get hashCode => Object.hashAll(
    toMap().entries.map((e) => e.key.hashCode ^ e.value.hashCode),
  );

  static int? _int(String? s) => s == null ? null : int.tryParse(s);

  static bool? _bool(String? s) => switch (s) {
    'true' => true,
    'false' => false,
    _ => null,
  };

  static List<int>? _intList(String? s) {
    if (s == null) return null;
    if (s.isEmpty) return const [];
    final parsed = s.split(',').map(int.tryParse).toList();
    return parsed.contains(null) ? null : parsed.cast<int>();
  }
}

/// Storage keys for the `settings` table.
abstract final class SettingKey {
  static const pharmacyName = 'pharmacy_name';
  static const nearExpiryWindowDays = 'near_expiry_window_days';
  static const bucketThresholds = 'bucket_thresholds';
  static const alertLeadDays = 'alert_lead_days';
  static const digestEnabled = 'digest_enabled';
  static const digestMinutes = 'digest_minutes';
  static const skipEmptyDigest = 'skip_empty_digest';
  static const quietHoursEnabled = 'quiet_hours_enabled';
  static const quietStartMinutes = 'quiet_start_minutes';
  static const quietEndMinutes = 'quiet_end_minutes';
  static const paymentLeadDays = 'payment_lead_days';
  static const overdueRepeatDays = 'overdue_repeat_days';
  static const reorderRefireDays = 'reorder_refire_days';
  static const backupReminderDays = 'backup_reminder_days';
  static const currencySymbol = 'currency_symbol';
  static const dateFormat = 'date_format';
  static const languageCode = 'language_code';
  static const themeMode = 'theme_mode';
  static const appLockEnabled = 'app_lock_enabled';
  static const hideDetailsOnLockScreen = 'hide_details_on_lock_screen';
  static const expirySort = 'expiry_sort';
  static const expiryCategory = 'expiry_category';
  static const expiryForm = 'expiry_form';
  static const expiryHideHandled = 'expiry_hide_handled';
}
