import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/data/db/db_encryption.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

/// A schema upgrade failed; the database was put back as it was before.
class MigrationFailedException implements Exception {
  const MigrationFailedException(this.cause);

  final Object cause;

  @override
  String toString() => 'MigrationFailedException($cause)';
}

/// Safety copy around schema upgrades (S6-05): before the first upgrade
/// step, the database is copied; if the upgrade throws, the copy replaces the
/// half-migrated file so the user's data is exactly as it was.
///
/// [migrate] is whatever forces the upgrade to run (opening the Drift
/// database and issuing a query). Nothing happens when the file is missing
/// (fresh install) or already at [targetVersion]. With [hexKey] the file is
/// an encrypted database (its copy is encrypted too).
Future<bool> guardedMigrate({
  required File file,
  required int targetVersion,
  required Future<void> Function() migrate,
  String? hexKey,
}) async {
  final copy = File('${file.path}.premigrate');
  final stored = _storedVersion(file, hexKey);
  final needsCopy = stored != null && stored > 0 && stored < targetVersion;
  if (needsCopy) {
    if (copy.existsSync()) copy.deleteSync();
    _makeCopy(file, copy, hexKey);
  }
  try {
    await migrate();
  } on Object catch (e, st) {
    debugPrint('Schema upgrade failed: $e\n$st');
    if (needsCopy) _rollback(file, copy);
    throw MigrationFailedException(e);
  }
  if (needsCopy && copy.existsSync()) copy.deleteSync();
  return needsCopy;
}

sql.Database _open(File file, String? hexKey, {bool readOnly = false}) {
  if (hexKey != null) {
    return openEncrypted(file.path, hexKey, readOnly: readOnly);
  }
  return sql.sqlite3.open(
    file.path,
    mode: readOnly ? sql.OpenMode.readOnly : sql.OpenMode.readWrite,
  );
}

void _makeCopy(File file, File copy, String? hexKey) {
  final db = _open(file, hexKey);
  try {
    if (hexKey == null) {
      // VACUUM INTO gives a consistent copy even with a write-ahead log.
      db.execute('VACUUM INTO ?', [copy.path]);
    } else {
      // Fold the log into the file, then copy the encrypted bytes as they are.
      db.select('PRAGMA wal_checkpoint(TRUNCATE)');
    }
  } finally {
    db.close();
  }
  if (hexKey != null) file.copySync(copy.path);
}

/// Version stored in the file, or null if there is no file.
int? _storedVersion(File file, String? hexKey) {
  if (!file.existsSync()) return null;
  final db = _open(file, hexKey, readOnly: true);
  try {
    return db.select('PRAGMA user_version').first.values.first! as int;
  } finally {
    db.close();
  }
}

void _rollback(File file, File copy) {
  for (final suffix in const ['', '-wal', '-shm']) {
    final f = File('${file.path}$suffix');
    if (f.existsSync()) f.deleteSync();
  }
  copy.renameSync(file.path);
}
