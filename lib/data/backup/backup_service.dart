import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_codec.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_failure.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/db/db_encryption.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';

/// A backup file just written, ready to share.
@immutable
class BackupResult {
  const BackupResult({required this.file, required this.metadata});

  final File file;
  final BackupMetadata metadata;
}

/// A backup that was read and verified, but not yet applied.
@immutable
class BackupPreview {
  const BackupPreview({required this.metadata, required this.databaseFile});

  final BackupMetadata metadata;

  /// The verified database, unpacked in the work directory.
  final File databaseFile;
}

/// Safety copies of the live database are kept this long after a restore.
const safetyCopyKeep = Duration(hours: 24);

/// Exports and restores the whole database (SEC-3, SEC-4).
///
/// The heavy work (zip, hashing, key derivation) runs in a background
/// isolate. Closing and reopening the live database is the caller's job, so
/// this class has no opinion about how the app holds it.
class BackupService {
  BackupService({
    required this.workDir,
    required Clock clock,
    required this.appVersion,
    this.iterations = 150000,
  }) : _clock = clock;

  /// Scratch space for exports and unpacked backups.
  final Directory workDir;
  final Clock _clock;
  final String appVersion;

  /// PBKDF2 rounds for new encrypted backups; stored in each file.
  final int iterations;

  /// Writes a backup of [db]. With a [passphrase] the file is AES-256-GCM
  /// encrypted. The copy records the backup time, so a restored database does
  /// not immediately look overdue.
  Future<BackupResult> create(AppDatabase db, {String? passphrase}) async {
    await workDir.create(recursive: true);
    final now = _clock.now();
    final snapshot = p.join(
      workDir.path,
      'snapshot-${now.microsecondsSinceEpoch}.sqlite',
    );
    final day =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final out = p.join(
      workDir.path,
      'pharmacy-expiry-backup-$day.${passphrase == null ? 'zip' : 'pxenc'}',
    );
    try {
      // A consistent snapshot, even while the app keeps writing.
      await exportPlainSnapshot(db, snapshot);
      final stamp = {SettingKey.lastBackupAt: now.toIso8601String()};
      const version = AppDatabase.currentSchemaVersion;
      final iters = iterations;
      final meta = await Isolate.run(
        () => buildBackup(
          dbPath: snapshot,
          outPath: out,
          appVersion: appVersion,
          schemaVersion: version,
          createdAt: now,
          stampSettings: stamp,
          passphrase: passphrase,
          iterations: iters,
        ),
      );
      return BackupResult(file: File(out), metadata: meta);
    } finally {
      await _delete(File(snapshot));
    }
  }

  /// Reads and checks [file] without touching live data.
  Future<BackupPreview> inspect(File file, {String? passphrase}) async {
    await workDir.create(recursive: true);
    final target = p.join(workDir.path, 'restore-candidate.sqlite');
    await _delete(File(target));
    const version = AppDatabase.currentSchemaVersion;
    try {
      final meta = await Isolate.run(
        () => readBackup(
          path: file.path,
          extractTo: target,
          supportedSchema: version,
          passphrase: passphrase,
        ),
      );
      return BackupPreview(metadata: meta, databaseFile: File(target));
    } on BackupException {
      await _delete(File(target));
      rethrow;
    }
  }

  /// Puts the verified database in place of [live].
  ///
  /// [closeDb] must close every connection to [live]. The old files are kept
  /// beside it as `<name>.bak-<time>` for [safetyCopyKeep]; if anything goes
  /// wrong they are moved straight back. Returns the safety copy.
  Future<File> swapIn({
    required File live,
    required BackupPreview preview,
    required Future<void> Function() closeDb,
    String? hexKey,
  }) async {
    await closeDb();
    final stamp = _clock.now().millisecondsSinceEpoch;
    final bak = File('${live.path}.bak-$stamp');
    final moved = <File, File>{};
    try {
      for (final suffix in const ['', '-wal', '-shm']) {
        final src = File('${live.path}$suffix');
        if (src.existsSync()) {
          final dst = File('${bak.path}$suffix');
          await src.rename(dst.path);
          moved[src] = dst;
        }
      }
      // Copy beside the target first, then rename: the swap itself is atomic.
      final staged = File('${live.path}.incoming');
      await preview.databaseFile.copy(staged.path);
      // Backups are plain files; the live database is encrypted.
      if (hexKey != null) encryptInPlace(staged, hexKey);
      await staged.rename(live.path);
    } on Object catch (e) {
      await _delete(File('${live.path}.incoming'));
      await _delete(live);
      for (final e in moved.entries) {
        await e.value.rename(e.key.path);
      }
      throw BackupException(BackupFailureKind.swapFailed, '$e');
    }
    await _delete(preview.databaseFile);
    return bak;
  }

  /// Deletes safety copies older than [safetyCopyKeep]. Returns how many.
  static Future<int> purgeSafetyCopies(
    File live,
    DateTime now, {
    Duration keep = safetyCopyKeep,
  }) async {
    final dir = live.parent;
    if (!dir.existsSync()) return 0;
    final prefix = '${p.basename(live.path)}.bak-';
    var removed = 0;
    await for (final f in dir.list()) {
      if (f is! File) continue;
      final name = p.basename(f.path);
      if (!name.startsWith(prefix)) continue;
      final stampText = name.substring(prefix.length).split('-').first;
      final ms = int.tryParse(stampText);
      if (ms == null) continue;
      if (now.difference(DateTime.fromMillisecondsSinceEpoch(ms)) > keep) {
        await _delete(f);
        removed++;
      }
    }
    return removed;
  }

  /// Removes leftovers in the work directory.
  Future<void> cleanUp() async {
    if (workDir.existsSync()) await workDir.delete(recursive: true);
  }

  static Future<void> _delete(File f) async {
    try {
      if (f.existsSync()) await f.delete();
    } on FileSystemException {
      // Best effort.
    }
  }
}
