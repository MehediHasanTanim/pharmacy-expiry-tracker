import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/dev/seed_data.dart';
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
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(child: Text(l10n.emptyMore)),
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
