import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Id in the Alert lab range, so the engine never cancels a test alert.
const _testAlertId = 9000900;

/// Next pending alert; refreshes after every planning pass.
final nextAlertProvider = FutureProvider.autoDispose<DateTime?>((ref) {
  ref
    ..watch(replanResultsProvider)
    ..watch(pendingAlertCountProvider);
  return ref
      .watch(alertStoreProvider)
      .nextPendingFireAt(ref.watch(clockProvider).now());
});

/// Alerts the OS reports as queued, read straight from the scheduler.
final osPendingCountProvider = FutureProvider.autoDispose<int>((ref) async {
  ref.watch(replanResultsProvider);
  return (await ref.watch(notificationPluginProvider).pending()).length;
});

/// The most recent alert that was delivered (from the alert history).
final lastFiredAlertProvider = StreamProvider.autoDispose<AlertLogEntry?>(
  (ref) => ref
      .watch(alertStoreProvider)
      .watchLog(limit: 1)
      .map((l) => l.isEmpty ? null : l.first),
);

/// Groups phone makers that share a battery manager, for the right steps.
String oemFamily(String? maker) => switch (maker) {
  'xiaomi' || 'redmi' || 'poco' => 'xiaomi',
  'samsung' => 'samsung',
  'oppo' || 'realme' || 'oneplus' => 'oppo',
  'vivo' || 'iqoo' => 'vivo',
  'huawei' || 'honor' => 'huawei',
  _ => 'other',
};

/// Shows whether alerts can reach the user and lets them test the real path
/// (ALR-7, ALR-8).
class AlertHealthScreen extends ConsumerWidget {
  const AlertHealthScreen({super.key});

  Future<void> _sendTest(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final plugin = ref.read(notificationPluginProvider);
    await plugin.initialize(onSelected: (_) {});
    await plugin.schedule(
      ScheduledNotification(
        id: _testAlertId,
        fireAt: ref.read(clockProvider).now().add(const Duration(seconds: 10)),
        title: l10n.alertTestTitle,
        body: l10n.alertTestBody,
        channel: NotificationChannel.diagnostics,
        payload: '/more/alerts/health',
      ),
    );
    messenger.showSnackBar(SnackBar(content: Text(l10n.healthTestScheduled)));
    ref.invalidate(osPendingCountProvider);
  }

  Future<void> _checkAgain(WidgetRef ref) async {
    ref
      ..invalidate(notificationPermissionsProvider)
      ..invalidate(deviceAlertConditionsProvider);
    await ref.read(alertCoordinatorProvider).replanNow();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final permissions = ref.watch(notificationPermissionsProvider).value;
    final conditions = ref.watch(deviceAlertConditionsProvider).value;
    final next = ref.watch(nextAlertProvider).value;
    final pending = ref.watch(pendingAlertCountProvider).value;
    final osPending = ref.watch(osPendingCountProvider).value;
    final last =
        ref.watch(replanResultsProvider).value ??
        ref.watch(alertCoordinatorProvider).last;
    final platform = ref.watch(platformAlertSettingsProvider);
    final lastFired = ref.watch(lastFiredAlertProvider).value;

    Widget row({
      required String label,
      required String value,
      required bool? ok,
      Widget? action,
      String? note,
      Key? key,
    }) {
      final color = ok == null
          ? theme.colorScheme.outline
          : ok
          ? theme.colorScheme.primary
          : theme.colorScheme.error;
      return ListTile(
        key: key,
        leading: Icon(
          ok == null
              ? Icons.remove_circle_outline
              : ok
              ? Icons.check_circle_outline
              : Icons.error_outline,
          color: color,
        ),
        title: Text(label),
        subtitle: Text(note == null ? value : '$value\n$note'),
        isThreeLine: note != null,
        trailing: action,
      );
    }

    final notificationsOk = permissions?.notifications;
    final batteryOk = conditions?.ignoringBatteryOptimizations;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.healthTitle)),
      body: ListView(
        children: [
          row(
            key: const Key('health-notifications'),
            label: l10n.healthNotifications,
            value: notificationsOk == null
                ? '…'
                : notificationsOk
                ? l10n.healthAllowed
                : l10n.healthBlocked,
            ok: notificationsOk,
            action: notificationsOk == false
                ? TextButton(
                    key: const Key('health-open-settings'),
                    onPressed: () =>
                        unawaited(platform.openNotificationSettings()),
                    child: Text(l10n.healthOpenSettings),
                  )
                : null,
          ),
          row(
            key: const Key('health-exact'),
            label: l10n.healthExactAlarms,
            // Alerts use inexact delivery, so this is informational.
            value: permissions?.exactAlarms == null
                ? l10n.healthNotApplicable
                : permissions!.exactAlarms!
                ? l10n.healthAllowed
                : l10n.healthBlocked,
            ok: null,
          ),
          if (batteryOk != null)
            row(
              key: const Key('health-battery'),
              label: l10n.healthBattery,
              value: batteryOk
                  ? l10n.healthUnrestricted
                  : l10n.healthRestricted,
              ok: batteryOk,
              note: conditions!.hasAggressiveBatteryManager
                  ? '${l10n.healthOemTip(conditions.manufacturer ?? '')}\n'
                        '${l10n.healthOemSteps(oemFamily(conditions.manufacturer))}'
                  : null,
              action: batteryOk
                  ? null
                  : TextButton(
                      key: const Key('health-open-battery'),
                      onPressed: () =>
                          unawaited(platform.openBatterySettings()),
                      child: Text(l10n.healthOpenBattery),
                    ),
            ),
          const Divider(),
          row(
            key: const Key('health-next'),
            label: l10n.healthNextAlert,
            value: next == null
                ? l10n.healthNone
                : formatDateTime(context, next),
            ok: null,
          ),
          row(
            key: const Key('health-pending'),
            label: l10n.healthPending,
            value:
                '${pending ?? 0}'
                '${osPending == null ? '' : ' · ${l10n.healthOsPending(osPending)}'}',
            ok: pending == null || osPending == null
                ? null
                : osPending >= pending,
          ),
          row(
            key: const Key('health-last'),
            label: l10n.healthLastPlanned,
            value: last == null
                ? l10n.healthNever
                : formatDateTime(context, last.at),
            ok: last?.ok,
            note: last != null && !last.ok ? l10n.healthLastError : null,
          ),
          row(
            key: const Key('health-last-fired'),
            label: l10n.healthLastFired,
            value: lastFired == null
                ? l10n.healthLastFiredNone
                : l10n.healthLastFiredValue(
                    formatDateTime(context, lastFired.firedAt),
                    lastFired.title,
                  ),
            ok: null,
            action: TextButton(
              key: const Key('health-history'),
              onPressed: () => unawaited(context.push(Routes.alertHistory)),
              child: Text(l10n.healthHistoryLink),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  key: const Key('health-test'),
                  onPressed: () => _sendTest(context, ref),
                  icon: const Icon(Icons.notifications_active_outlined),
                  label: Text(l10n.healthSendTest),
                ),
                OutlinedButton.icon(
                  key: const Key('health-refresh'),
                  onPressed: () => _checkAgain(ref),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.healthRefresh),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
