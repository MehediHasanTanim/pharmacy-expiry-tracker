import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/diagnostics/diagnostics_report.dart';
import 'package:pharmacy_expiry_tracker/features/expiry/expiry_share.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Writes the diagnostics file and offers it to the share sheet (S6-08).
Future<void> exportDiagnostics(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  try {
    final now = ref.read(clockProvider).now();
    final perms = await ref.read(notificationPluginProvider).permissions();
    final device = await ref.read(platformAlertSettingsProvider).conditions();
    final last = ref.read(alertCoordinatorProvider).last;
    final report = buildDiagnosticsReport(
      DiagnosticsInput(
        now: now,
        appVersion: ref.read(appVersionProvider),
        flavor: appFlavor ?? 'default',
        platform: defaultTargetPlatform.name,
        settings: await ref.read(settingsRepositoryProvider).load(),
        counts: await countRows(ref.read(databaseProvider)),
        pendingAlerts: (await ref.read(alertStoreProvider).all())
            .where((r) => r.isPending)
            .length,
        notificationsAllowed: perms.notifications,
        exactAlarmsAllowed: perms.exactAlarms,
        batteryExempt: device.ignoringBatteryOptimizations,
        manufacturer: device.manufacturer,
        lastReplan: last == null
            ? null
            : '${last.ok ? 'ok' : 'failed (${last.error.runtimeType})'}, '
                  '${last.took.inMilliseconds} ms, planned ${last.planned}, '
                  'scheduled ${last.scheduled}, cancelled ${last.cancelled}',
        recentErrors: recentErrorLines(ref.read(errorLogProvider)),
      ),
    );
    final dir = ref.read(exportDirProvider)..createSync(recursive: true);
    final file = File(p.join(dir.path, 'diagnostics.txt'));
    await file.writeAsString(report, flush: true);
    await ref
        .read(fileExchangeProvider)
        .share(file, subject: l10n.diagnosticsExport);
  } on Object catch (e, st) {
    ref.read(errorLogProvider).record('diagnostics', e, st);
    messenger.showSnackBar(SnackBar(content: Text(l10n.backupErrGeneric)));
  }
}
