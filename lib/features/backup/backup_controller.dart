import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_failure.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_service.dart';

/// Where unpacked and exported backups are staged.
final backupWorkDirProvider = Provider<Directory>(
  (ref) => Directory(p.join(Directory.systemTemp.path, 'pharmacy_backup')),
);

/// PBKDF2 rounds for new encrypted backups. Tests lower it.
final backupIterationsProvider = Provider<int>((ref) => 150000);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    workDir: ref.watch(backupWorkDirProvider),
    clock: ref.watch(clockProvider),
    appVersion: ref.watch(appVersionProvider),
    iterations: ref.watch(backupIterationsProvider),
  ),
);

/// The steps of backing up and restoring, in the order the screens use them.
class BackupController {
  BackupController(Ref ref) : _ref = ref;

  final Ref _ref;

  BackupService get _service => _ref.read(backupServiceProvider);

  /// Writes a backup and offers it to the share sheet. When the user saves or
  /// sends it, the time is recorded (which also moves the next reminder out).
  /// Returns false if they dismissed the sheet.
  Future<bool> exportAndShare({String? passphrase}) async {
    final result = await _service.create(
      _ref.read(databaseProvider),
      passphrase: passphrase,
    );
    // The staged file is left in the cache for the receiving app to read (a
    // mail or chat upload may still be running); it is cleared at next launch.
    final shared = await _ref
        .read(fileExchangeProvider)
        .share(result.file, subject: p.basename(result.file.path));
    if (shared) {
      final stamp = _ref.read(clockProvider).now().toIso8601String();
      await _ref
          .read(settingsRepositoryProvider)
          .update((s) => s.copyWith(lastBackupAt: stamp));
    }
    return shared;
  }

  /// Reads and checks a backup; see [BackupService.inspect].
  Future<BackupPreview> inspect(File file, {String? passphrase}) =>
      _service.inspect(file, passphrase: passphrase);

  /// Replaces all data with [preview] and rebuilds everything that depended
  /// on the database. The previous data is kept for 24 hours beside the new
  /// file. Alerts are cancelled and planned afresh for the restored data.
  Future<void> restore(BackupPreview preview) async {
    final live = _ref.read(databaseFileProvider);
    try {
      await _service.swapIn(
        live: live,
        preview: preview,
        closeDb: () => _ref.read(databaseProvider).close(),
      );
    } on BackupException {
      // The old data was put back; reopen it.
      _ref.invalidate(databaseProvider);
      rethrow;
    }
    _ref.invalidate(databaseProvider);
    try {
      await _ref.read(alertCoordinatorProvider).resetAndReplan();
    } on Object catch (e, st) {
      // The data is restored; alerts are advisory and the next launch or
      // resume plans them again.
      debugPrint('Re-plan after restore failed: $e\n$st');
    }
    unawaited(_service.cleanUp());
  }
}

/// Replaced in tests to avoid swapping real files.
final backupControllerProvider = Provider<BackupController>(
  BackupController.new,
);

/// How overdue the backup is, for the Home banner. Null when no banner is due.
class BackupDue {
  const BackupDue(this.daysSince);

  /// Days since the last backup; null if there never was one.
  final int? daysSince;
}

/// A banner is due when the last backup (or, with none, the first use) is at
/// least `backupReminderDays` old and the reminder is not switched off.
final backupDueProvider = Provider<BackupDue?>((ref) {
  final s = ref.watch(settingsProvider).value;
  if (s == null || s.backupReminderDays < 1) return null;
  final today = ref.watch(todayDateProvider);
  final last = DateTime.tryParse(s.lastBackupAt);
  final anchor = last ?? DateTime.tryParse(s.firstRunOn);
  if (anchor == null) return null;
  final age = today.difference(dateOnly(anchor)).inDays;
  if (age < s.backupReminderDays) return null;
  return BackupDue(last == null ? null : age);
});
