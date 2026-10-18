import 'package:flutter/foundation.dart';

/// Android notification channels / iOS categories the app posts to.
enum NotificationChannel {
  expiryCritical('expiry_critical', 'Expiry alerts'),
  expiryDigest('expiry_digest', 'Daily expiry digest'),
  payments('payments', 'Supplier payments'),
  reorder('reorder', 'Reorder reminders'),
  backup('backup', 'Backup reminders'),
  diagnostics('diagnostics', 'Alert diagnostics');

  NotificationChannel(this.id, this.label);

  final String id;
  final String label;
}

/// A local notification to deliver at [fireAt] (device-local wall-clock time).
@immutable
class ScheduledNotification {
  const ScheduledNotification({
    required this.id,
    required this.fireAt,
    required this.title,
    required this.body,
    this.channel = NotificationChannel.expiryCritical,
    this.payload,
    this.preferExact = true,
    this.snoozeLabel,
  });

  /// 31-bit id; scheduling the same id again replaces the earlier one.
  final int id;
  final DateTime fireAt;
  final String title;
  final String body;
  final NotificationChannel channel;

  /// Route opened when the user taps the notification.
  final String? payload;

  /// When set, the notification offers a button with this label that shows it
  /// again a day later (ALR-11).
  final String? snoozeLabel;

  /// Ask for exact delivery (Android exact alarms) where permitted; falls
  /// back to inexact delivery otherwise.
  final bool preferExact;
}

@immutable
class PendingNotification {
  const PendingNotification({
    required this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

@immutable
class NotificationPermissions {
  const NotificationPermissions({
    required this.notifications,
    this.exactAlarms,
  });

  /// May the app post notifications at all?
  final bool notifications;

  /// Android 12+: may it schedule exact alarms? Null where not applicable.
  final bool? exactAlarms;

  @override
  bool operator ==(Object other) =>
      other is NotificationPermissions &&
      other.notifications == notifications &&
      other.exactAlarms == exactAlarms;

  @override
  int get hashCode => Object.hash(notifications, exactAlarms);

  @override
  String toString() =>
      'NotificationPermissions(notifications: $notifications, '
      'exactAlarms: $exactAlarms)';
}

/// Thin seam over the OS local-notification scheduler (technical design §6).
/// Everything above it — the planner, reconciler and coordinator in Sprint 3 —
/// is testable against a fake.
abstract interface class NotificationPlugin {
  /// Whether this platform can schedule local notifications at all.
  bool get isSupported;

  /// Prepares channels and time zones. [onSelected] receives the tapped
  /// notification's payload while the app is running.
  Future<void> initialize({required void Function(String? payload) onSelected});

  Future<NotificationPermissions> permissions();

  /// Prompts for notification permission (and, on Android 12+, sends the user
  /// to the exact-alarm setting when [exactAlarms] is true).
  Future<NotificationPermissions> requestPermissions({
    bool exactAlarms = false,
  });

  /// Schedules, or replaces, the notification with the same id.
  Future<void> schedule(ScheduledNotification notification);

  Future<void> cancel(int id);

  Future<void> cancelAll();

  /// Notifications the OS still has queued.
  Future<List<PendingNotification>> pending();

  /// Payload of the notification that launched the app, if any.
  Future<String?> launchPayload();
}
