import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';

/// In-memory [NotificationPlugin] that records what was scheduled, for tests
/// of the alert engine that must not touch the OS.
class FakeNotificationPlugin implements NotificationPlugin {
  FakeNotificationPlugin({
    this.notificationsGranted = true,
    this.exactAlarmsGranted = true,
    this.maxPending,
  });

  bool notificationsGranted;
  bool exactAlarmsGranted;

  /// Simulates the iOS cap: scheduling beyond it silently drops the extras.
  final int? maxPending;

  final Map<int, ScheduledNotification> scheduled = {};
  final List<String> calls = [];
  String? launch;
  void Function(String? payload)? onSelected;

  @override
  bool get isSupported => true;

  @override
  Future<void> initialize({
    required void Function(String? payload) onSelected,
  }) async {
    calls.add('initialize');
    this.onSelected = onSelected;
  }

  @override
  Future<NotificationPermissions> permissions() async =>
      NotificationPermissions(
        notifications: notificationsGranted,
        exactAlarms: exactAlarmsGranted,
      );

  @override
  Future<NotificationPermissions> requestPermissions({
    bool exactAlarms = false,
  }) async {
    calls.add('requestPermissions(exact: $exactAlarms)');
    return await permissions();
  }

  @override
  Future<void> schedule(ScheduledNotification notification) async {
    calls.add('schedule(${notification.id})');
    if (!notificationsGranted) return;
    final replacing = scheduled.containsKey(notification.id);
    if (!replacing && maxPending != null && scheduled.length >= maxPending!) {
      return;
    }
    scheduled[notification.id] = notification;
  }

  @override
  Future<void> cancel(int id) async {
    calls.add('cancel($id)');
    scheduled.remove(id);
  }

  @override
  Future<void> cancelAll() async {
    calls.add('cancelAll');
    scheduled.clear();
  }

  @override
  Future<List<PendingNotification>> pending() async => [
    for (final n in scheduled.values)
      PendingNotification(
        id: n.id,
        title: n.title,
        body: n.body,
        payload: n.payload,
      ),
  ];

  @override
  Future<String?> launchPayload() async => launch;

  /// Simulates the user tapping a delivered notification.
  void tap(int id) => onSelected?.call(scheduled[id]?.payload);
}
