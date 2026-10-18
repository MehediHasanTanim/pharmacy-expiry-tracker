import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/services/local_notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/action_payload.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';

/// Id of the "Snooze 1 day" button on a notification.
const snoozeActionId = 'snooze_1d';

/// Snoozed copies use ids inside the Alert lab's reserved range
/// (9 000 000 to 9 000 999), which re-planning never cancels, so a snoozed
/// alert is not swept away as an orphan. This slice is for snoozes only.
const snoozedIdBase = 9000600;
const snoozedIdCount = 300;

int snoozedIdFor(int originalId) => snoozedIdBase + originalId % snoozedIdCount;

/// Entry point for the button when the app is not running.
@pragma('vm:entry-point')
Future<void> notificationActionBackground(NotificationResponse response) =>
    handleNotificationAction(response);

/// Shows the notification again in 24 hours when "Snooze 1 day" was pressed.
/// It works from the payload alone, so it needs neither the app nor the
/// database. Pressing it twice just replaces the same snoozed copy.
Future<void> handleNotificationAction(
  NotificationResponse response, {
  NotificationPlugin? plugin,
  Clock clock = const SystemClock(),
}) async {
  if (response.actionId != snoozeActionId) return;
  final data = decodeActionPayload(response.payload);
  if (data == null) return;
  final target = plugin ?? LocalNotificationPlugin();
  await target.initialize(onSelected: (_) {});
  await target.schedule(
    ScheduledNotification(
      id: snoozedIdFor(response.id ?? 0),
      fireAt: clock.now().add(const Duration(days: 1)),
      title: data.title,
      body: data.body,
      payload: data.route,
      snoozeLabel: data.snoozeLabel,
      preferExact: false,
    ),
  );
}
