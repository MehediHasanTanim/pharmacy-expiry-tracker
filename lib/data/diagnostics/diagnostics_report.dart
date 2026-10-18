import 'package:pharmacy_expiry_tracker/core/logging/error_log.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';

/// What the diagnostics file says about the device and the app.
class DiagnosticsInput {
  const DiagnosticsInput({
    required this.now,
    required this.appVersion,
    required this.flavor,
    required this.platform,
    required this.settings,
    required this.counts,
    required this.pendingAlerts,
    this.notificationsAllowed,
    this.exactAlarmsAllowed,
    this.batteryExempt,
    this.manufacturer,
    this.lastReplan,
    this.recentErrors = const [],
  });

  final DateTime now;
  final String appVersion;
  final String flavor;
  final String platform;
  final AppSettings settings;

  /// Row counts by table name; counts only, never contents.
  final Map<String, int> counts;
  final int pendingAlerts;
  final bool? notificationsAllowed;
  final bool? exactAlarmsAllowed;
  final bool? batteryExempt;
  final String? manufacturer;

  /// One line about the last planning pass, already free of user data.
  final String? lastReplan;
  final List<String> recentErrors;
}

/// The text of the "export diagnostics" file (S6-08).
///
/// It is built to be safe to send to someone else: there are no medicine,
/// batch, supplier or pharmacy names, no amounts and no dates of individual
/// records. Only versions, switches, numbers and the scrubbed error log.
String buildDiagnosticsReport(DiagnosticsInput d) {
  final s = d.settings;
  final b = StringBuffer()
    ..writeln('Pharmacy expiry tracker - diagnostics')
    ..writeln('Created: ${d.now.toIso8601String()}')
    ..writeln()
    ..writeln('[App]')
    ..writeln('version: ${d.appVersion}')
    ..writeln('flavor: ${d.flavor}')
    ..writeln('platform: ${d.platform}')
    ..writeln('schema: ${AppDatabase.currentSchemaVersion}')
    ..writeln()
    ..writeln('[Data (row counts)]');
  for (final e in d.counts.entries) {
    b.writeln('${e.key}: ${e.value}');
  }
  b
    ..writeln()
    ..writeln('[Alerts]')
    ..writeln('pending: ${d.pendingAlerts}')
    ..writeln('notifications allowed: ${d.notificationsAllowed ?? 'unknown'}')
    ..writeln('exact alarms allowed: ${d.exactAlarmsAllowed ?? 'n/a'}')
    ..writeln('battery exempt: ${d.batteryExempt ?? 'unknown'}')
    ..writeln('device maker: ${d.manufacturer ?? 'unknown'}')
    ..writeln('last pass: ${d.lastReplan ?? 'none yet'}')
    ..writeln('lead days: ${s.alertLeadDays.join(' ')}')
    ..writeln('window days: ${s.nearExpiryWindowDays}')
    ..writeln(
      'digest: ${s.digestEnabled} at ${s.digestMinutes ~/ 60}:'
      '${(s.digestMinutes % 60).toString().padLeft(2, '0')}',
    )
    ..writeln('quiet hours: ${s.quietHoursEnabled}')
    ..writeln('hide details on lock screen: ${s.hideDetailsOnLockScreen}')
    ..writeln()
    ..writeln('[Backup]')
    ..writeln('reminder every (days): ${s.backupReminderDays}')
    ..writeln('last backup: ${_ago(d.now, s.lastBackupAt)}')
    ..writeln()
    ..writeln('[Recent errors]');
  if (d.recentErrors.isEmpty) {
    b.writeln('none');
  } else {
    d.recentErrors.forEach(b.writeln);
  }
  return b.toString();
}

String _ago(DateTime now, String iso) {
  final t = DateTime.tryParse(iso);
  if (t == null) return 'never';
  return '${now.difference(t).inDays} days ago';
}

/// Row counts for the tables worth knowing about.
Future<Map<String, int>> countRows(AppDatabase db) async {
  const tables = [
    'medicines',
    'batches',
    'suppliers',
    'supplier_invoices',
    'supplier_payments',
    'scheduled_alerts',
    'alert_log',
  ];
  final out = <String, int>{};
  for (final t in tables) {
    final row = await db
        .customSelect('SELECT count(*) AS c FROM $t')
        .getSingle();
    out[t] = row.read<int>('c');
  }
  return out;
}

/// Convenience for callers that only have an [ErrorLog].
List<String> recentErrorLines(ErrorLog log) => log.recent(maxLines: 50);
