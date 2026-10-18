import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/dev/seed_data.dart';
import 'package:pharmacy_expiry_tracker/features/home/home_providers.dart';
import 'package:pharmacy_expiry_tracker/features/more/diagnostics_action.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  /// Developer tools are available in the `dev` flavor only.
  static bool get showDevTools => appFlavor == 'dev';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabMore)),
      body: ListView(
        children: [
          _Section(l10n.moreSectionStock),
          ListTile(
            key: const Key('more-reorder'),
            leading: const Icon(Icons.shopping_cart_outlined),
            title: Text(l10n.moreReorderTile),
            trailing: _CountBadge(
              count: ref.watch(reorderItemsProvider).value?.length ?? 0,
            ),
            onTap: () => context.push(Routes.reorder),
          ),
          _Section(l10n.moreSectionAlerts),
          ListTile(
            key: const Key('more-alerts'),
            leading: const Icon(Icons.notifications_outlined),
            title: Text(l10n.alertSettingsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.alertSettings),
          ),
          ListTile(
            key: const Key('more-alert-health'),
            leading: const Icon(Icons.health_and_safety_outlined),
            title: Text(l10n.healthTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.alertHealth),
          ),
          ListTile(
            key: const Key('more-alert-history'),
            leading: const Icon(Icons.history),
            title: Text(l10n.alertCenterTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.alertHistory),
          ),
          _Section(l10n.moreSectionData),
          ListTile(
            key: const Key('more-backup'),
            leading: const Icon(Icons.backup_outlined),
            title: Text(l10n.moreBackupTile),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.backup),
          ),
          ListTile(
            key: const Key('more-diagnostics'),
            leading: const Icon(Icons.bug_report_outlined),
            title: Text(l10n.diagnosticsExport),
            subtitle: Text(l10n.diagnosticsHelp),
            onTap: () => unawaited(exportDiagnostics(context, ref)),
          ),
          _Section(l10n.moreSectionApp),
          ListTile(
            key: const Key('more-settings'),
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.moreSettingsTile),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.settings),
          ),
          if (showDevTools) ...[
            const Divider(),
            ListTile(
              key: const Key('dev-seed'),
              leading: const Icon(Icons.science_outlined),
              title: Text(l10n.devSeed),
              subtitle: Text(l10n.devTools),
              onTap: () => _seed(context, ref),
            ),
            ListTile(
              key: const Key('dev-alert-lab'),
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Alert lab'),
              subtitle: const Text('Schedule real notifications on a device'),
              onTap: () => context.push(Routes.alertLab),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _seed(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.devSeed),
        content: Text(l10n.devSeedBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.actionConfirm),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await SeedDataGenerator(ref.read(databaseProvider)).generate(
      today: dateOnly(ref.read(clockProvider).now()),
      medicines: 5000,
      batches: 10000,
    );
    messenger.showSnackBar(SnackBar(content: Text(l10n.devSeedDone)));
  }
}

class _Section extends StatelessWidget {
  const _Section(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Semantics(
      header: true,
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    ),
  );
}

/// A small count, with the number spelled out for screen readers.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const Icon(Icons.chevron_right);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('more-reorder-count'),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
