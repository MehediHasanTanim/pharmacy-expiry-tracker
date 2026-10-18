import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/features/alerts/alert_permission.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Tells the user on Home when alerts may not reach them (HOM-2): blocked
/// notifications first, then a failed planning pass, then battery saving that
/// is known to stop alerts on some phones. Nothing shows when all is well.
class AlertStatusBanner extends ConsumerWidget {
  const AlertStatusBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugin = ref.watch(notificationPluginProvider);
    if (!plugin.isSupported) return const SizedBox.shrink();
    final permissions = ref.watch(notificationPermissionsProvider).value;
    // Blocked notifications get their own, more specific banner.
    if (permissions != null && !permissions.notifications) {
      return const AlertPermissionBanner();
    }

    final l10n = AppLocalizations.of(context);
    final last = ref.watch(replanResultsProvider).value;
    final conditions = ref.watch(deviceAlertConditionsProvider).value;
    final theme = Theme.of(context);

    String? text;
    VoidCallback? action;
    var actionLabel = l10n.bannerCheck;
    if (last != null && !last.ok) {
      text = l10n.bannerReplanFailed;
      action = () => unawaited(ref.read(alertCoordinatorProvider).replanNow());
    } else if (conditions != null &&
        conditions.ignoringBatteryOptimizations == false &&
        conditions.hasAggressiveBatteryManager) {
      text = l10n.bannerBattery;
      actionLabel = l10n.healthOpenBattery;
      action = () => unawaited(context.push(Routes.alertHealth));
    }
    if (text == null) return const SizedBox.shrink();

    return Card(
      key: const Key('alert-status-banner'),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: theme.colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: theme.colorScheme.onTertiaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonal(
              key: const Key('alert-status-action'),
              onPressed: action,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
