import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/deep_links.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Alerts that have come due, newest first, so one dismissed from the shade
/// can still be found and opened (ALR-12).
class AlertHistoryScreen extends ConsumerWidget {
  const AlertHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final log = ref.watch(alertLogProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.alertCenterTitle)),
      body: log.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(l10n.errorGeneric)),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Text(
                l10n.alertCenterEmpty,
                key: const Key('history-empty'),
              ),
            );
          }
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  l10n.alertCenterMissed,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              for (final e in entries) _Entry(entry: e),
            ],
          );
        },
      ),
    );
  }
}

class _Entry extends ConsumerWidget {
  const _Entry({required this.entry});

  final AlertLogEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unread = !entry.isOpened;
    final icon = switch (entry.kind) {
      AlertKind.digest => Icons.today_outlined,
      AlertKind.expiryDay => Icons.event_busy_outlined,
      _ => Icons.hourglass_bottom,
    };
    return ListTile(
      key: Key('history-${entry.id}'),
      leading: Icon(icon, color: unread ? theme.colorScheme.primary : null),
      title: Text(
        entry.title,
        style: TextStyle(fontWeight: unread ? FontWeight.w700 : null),
      ),
      subtitle: Text(
        '${entry.body}\n${formatDateTime(context, entry.firedAt)}',
      ),
      isThreeLine: true,
      trailing: unread
          ? Icon(Icons.circle, size: 10, color: theme.colorScheme.primary)
          : null,
      onTap: () async {
        await ref
            .read(alertStoreProvider)
            .markLogOpened(entry.id, ref.read(clockProvider).now());
        if (context.mounted) ref.read(deepLinksProvider).handle(entry.route);
      },
    );
  }
}
