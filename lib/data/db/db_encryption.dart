import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

/// Thrown when the database on disk is encrypted but its key is unavailable
/// (for example the secure storage was cleared). The data cannot be read.
class DatabaseKeyMissingException implements Exception {
  const DatabaseKeyMissingException();

  @override
  String toString() => 'DatabaseKeyMissingException';
}

/// A 256-bit key as 64 hex characters, from the platform's secure random.
String generateDatabaseKey([Random? random]) {
  final r = random ?? Random.secure();
  return [
    for (var i = 0; i < 32; i++)
      r.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ].join();
}

final _hexKey = RegExp(r'^[0-9a-f]{64}$');

/// SQL that makes SQLCipher use [hexKey] as a raw key (no passphrase
/// derivation). Must be the first statement on a connection.
String keyPragma(String hexKey) {
  if (!_hexKey.hasMatch(hexKey)) {
    throw ArgumentError('The database key must be 64 lowercase hex digits');
  }
  return "PRAGMA key = \"x'$hexKey'\"";
}

/// Opens [path] with [hexKey] and checks the key works, so a wrong key fails
/// here rather than on the first real query.
sql.Database openEncrypted(
  String path,
  String hexKey, {
  bool readOnly = false,
}) {
  final db = sql.sqlite3.open(
    path,
    mode: readOnly ? sql.OpenMode.readOnly : sql.OpenMode.readWrite,
  );
  try {
    db
      ..execute(keyPragma(hexKey))
      ..select('SELECT count(*) FROM sqlite_master');
    return db;
  } on Object {
    db.close();
    rethrow;
  }
}

const _plainMagic = 'SQLite format 3';

/// True if [file] is an unencrypted SQLite database (it starts with the
/// SQLite header; an encrypted one looks like random bytes).
bool isPlainSqlite(File file) {
  if (!file.existsSync()) return false;
  final raf = file.openSync();
  try {
    if (raf.lengthSync() < 16) return false;
    final head = raf.readSync(15);
    return String.fromCharCodes(head) == _plainMagic;
  } finally {
    raf.closeSync();
  }
}

/// True if [file] exists, has content, and is not plain SQLite.
bool isEncryptedFile(File file) =>
    file.existsSync() && file.lengthSync() >= 16 && !isPlainSqlite(file);

Map<String, int> _tableCounts(sql.Database db, String schema) {
  final names = [
    for (final r in db.select(
      'SELECT name FROM $schema.sqlite_master '
      "WHERE type = 'table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    ))
      r['name']! as String,
  ];
  return {
    for (final n in names)
      n: db.select('SELECT count(*) AS c FROM $schema."$n"').first['c']! as int,
  };
}

/// Overwrites then deletes [f]. Best effort: flash storage may keep old
/// blocks, which is why the file-level key, not deletion, is the protection.
void shred(File f) {
  try {
    if (!f.existsSync()) return;
    final len = f.lengthSync();
    final raf = f.openSync(mode: FileMode.write);
    try {
      final zeros = List<int>.filled(64 * 1024, 0);
      var left = len;
      while (left > 0) {
        final n = left < zeros.length ? left : zeros.length;
        raf.writeFromSync(zeros, 0, n);
        left -= n;
      }
      raf.flushSync();
    } finally {
      raf.closeSync();
    }
    f.deleteSync();
  } on FileSystemException {
    // Leave it; it holds nothing the app does not already hold.
  }
}

/// Encrypts a plaintext database in place (S8-05).
///
/// The data is exported into a new encrypted file, which is checked (it opens
/// with the key, passes SQLite's integrity check, and every table has the same
/// number of rows as the original) before anything is swapped. The plaintext
/// original is kept beside it until the encrypted file has been opened once
/// more after the swap; if any step fails, the original is put back and
/// nothing is lost.
///
/// Returns true if the file was converted, false if it was already encrypted
/// or does not exist. [beforeSwap] is for tests that simulate a failure.
bool encryptInPlace(File file, String hexKey, {VoidCallback? beforeSwap}) {
  if (!isPlainSqlite(file)) return false;
  keyPragma(hexKey); // validate early
  final enc = File('${file.path}.enc');
  final old = File('${file.path}.plain');
  final sidecars = ['-wal', '-shm', '-journal'];
  if (enc.existsSync()) enc.deleteSync();
  if (old.existsSync()) {
    // Left by an interrupted earlier attempt; the live file is the source.
    shred(old);
  }

  Map<String, int> expected;
  int version;
  final src = sql.sqlite3.open(file.path);
  try {
    // Fold the write-ahead log into the main file before copying anything.
    src.select('PRAGMA wal_checkpoint(TRUNCATE)');
    version = src.select('PRAGMA user_version').first.values.first! as int;
    expected = _tableCounts(src, 'main');
    src
      ..execute(
        "ATTACH DATABASE '${enc.path.replaceAll("'", "''")}' AS enc KEY \"x'$hexKey'\"",
      )
      ..select("SELECT sqlcipher_export('enc')")
      ..execute('PRAGMA enc.user_version = $version')
      ..execute('DETACH DATABASE enc');
  } on Object {
    src.close();
    if (enc.existsSync()) enc.deleteSync();
    rethrow;
  }
  src.close();

  void verify(File f) {
    final db = openEncrypted(f.path, hexKey, readOnly: true);
    try {
      final check = db.select('PRAGMA integrity_check').first.values.first;
      if (check != 'ok') throw StateError('integrity check failed: $check');
      final v = db.select('PRAGMA user_version').first.values.first;
      if (v != version) throw StateError('schema version changed');
      final got = _tableCounts(db, 'main');
      if (!mapEquals(got, expected)) throw StateError('row counts differ');
    } finally {
      db.close();
    }
  }

  var swapped = false;
  try {
    verify(enc);
    beforeSwap?.call();
    file.renameSync(old.path);
    swapped = true;
    for (final s in sidecars) {
      final f = File('${file.path}$s');
      if (f.existsSync()) f.deleteSync();
    }
    enc.renameSync(file.path);
    verify(file);
  } on Object {
    // Put the original back exactly as it was.
    if (enc.existsSync()) enc.deleteSync();
    if (swapped) {
      if (file.existsSync()) file.deleteSync();
      old.renameSync(file.path);
    }
    rethrow;
  }
  shred(old);
  return true;
}

/// Writes a consistent, **unencrypted** copy of the open database to [path]
/// (the backup container is encrypted separately, with the user's passphrase,
/// and has to be readable by any phone). Works on encrypted and plain
/// connections alike.
Future<void> exportPlainSnapshot(AppDatabase db, String path) async {
  final version = (await db.customSelect('PRAGMA user_version').getSingle())
      .read<int>('user_version');
  await db.customStatement("ATTACH DATABASE ? AS snap KEY ''", [path]);
  try {
    await db.customSelect("SELECT sqlcipher_export('snap')").get();
    await db.customStatement('PRAGMA snap.user_version = $version');
  } finally {
    await db.customStatement('DETACH DATABASE snap');
  }
}
