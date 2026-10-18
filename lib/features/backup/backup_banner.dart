import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/features/backup/backup_controller.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Home banner: the data has not been backed up for a while (SEC-4).
class BackupBanner extends ConsumerWidget {
  const BackupBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final due = ref.watch(backupDueProvider);
    if (due == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final text = due.daysSince == null
        ? l10n.homeBackupNever
        : l10n.homeBackupStale(due.daysSince!);
    return Card(
      key: const Key('backup-banner'),
      color: scheme.tertiaryContainer,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            Icon(Icons.backup_outlined, color: scheme.onTertiaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: scheme.onTertiaryContainer),
              ),
            ),
            TextButton(
              key: const Key('backup-banner-action'),
              onPressed: () => context.push(Routes.backup),
              child: Text(l10n.homeBackupAction),
            ),
          ],
        ),
      ),
    );
  }
}
