import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_failure.dart';
import 'package:sqlite3/sqlite3.dart' as sql;

/// Name of the database inside the archive.
const backupDbEntry = 'pharmacy_expiry.sqlite';
const backupMetaEntry = 'metadata.json';

/// Bumped only if the container layout itself changes.
const backupFormat = 1;

const _magic = [0x50, 0x58, 0x42, 0x4b]; // "PXBK"
const _headerVersion = 1;
const _saltLength = 16;
const _nonceLength = 12;
const _headerLength = 4 + 1 + 4 + _saltLength + _nonceLength;

/// What a backup says about itself.
@immutable
class BackupMetadata {
  const BackupMetadata({
    required this.appVersion,
    required this.schemaVersion,
    required this.createdAt,
    required this.sha256,
    required this.dbBytes,
    required this.medicines,
    required this.batches,
    required this.suppliers,
    required this.invoices,
    this.encrypted = false,
  });

  factory BackupMetadata.fromJson(
    Map<String, Object?> j, {
    bool encrypted = false,
  }) {
    final counts = (j['counts'] as Map?)?.cast<String, Object?>() ?? const {};
    return BackupMetadata(
      appVersion: j['appVersion']! as String,
      schemaVersion: j['schemaVersion']! as int,
      createdAt: DateTime.parse(j['createdAt']! as String),
      sha256: j['sha256']! as String,
      dbBytes: j['dbBytes']! as int,
      medicines: (counts['medicines'] as int?) ?? 0,
      batches: (counts['batches'] as int?) ?? 0,
      suppliers: (counts['suppliers'] as int?) ?? 0,
      invoices: (counts['invoices'] as int?) ?? 0,
      encrypted: encrypted,
    );
  }

  final String appVersion;
  final int schemaVersion;
  final DateTime createdAt;
  final String sha256;
  final int dbBytes;
  final int medicines;
  final int batches;
  final int suppliers;
  final int invoices;
  final bool encrypted;

  Map<String, Object?> toJson() => {
    'format': backupFormat,
    'app': 'pharmacy_expiry_tracker',
    'appVersion': appVersion,
    'schemaVersion': schemaVersion,
    'createdAt': createdAt.toIso8601String(),
    'sha256': sha256,
    'dbBytes': dbBytes,
    'counts': {
      'medicines': medicines,
      'batches': batches,
      'suppliers': suppliers,
      'invoices': invoices,
    },
  };
}

Future<String> _sha256Hex(List<int> bytes) async {
  final hash = await Sha256().hash(bytes);
  return [for (final b in hash.bytes) b.toRadixString(16).padLeft(2, '0')]
      .join();
}

bool _looksZip(List<int> b) => b.length > 1 && b[0] == 0x50 && b[1] == 0x4b;

/// True if [bytes] starts with the encrypted-backup header.
bool isEncryptedBackup(List<int> bytes) {
  if (bytes.length < _headerLength) return false;
  for (var i = 0; i < _magic.length; i++) {
    if (bytes[i] != _magic[i]) return false;
  }
  return true;
}

Future<SecretKey> _deriveKey(
  String passphrase,
  List<int> salt,
  int iterations,
) {
  return Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: iterations,
    bits: 256,
  ).deriveKeyFromPassword(password: passphrase, nonce: salt);
}

/// Builds the backup container from a database file and writes it to
/// [outPath]. Runs in a background isolate.
///
/// Before archiving, [stampSettings] (key to value) is written into the copy's
/// settings table, so a restored database knows when it was last backed up.
Future<BackupMetadata> buildBackup({
  required String dbPath,
  required String outPath,
  required String appVersion,
  required int schemaVersion,
  required DateTime createdAt,
  Map<String, String> stampSettings = const {},
  String? passphrase,
  int iterations = 150000,
}) async {
  int count(sql.Database db, String table) =>
      db.select('SELECT count(*) AS c FROM $table').first['c']! as int;

  final db = sql.sqlite3.open(dbPath);
  late final int medicines;
  late final int batches;
  late final int suppliers;
  late final int invoices;
  try {
    for (final e in stampSettings.entries) {
      db.execute('INSERT OR REPLACE INTO settings (key, value) VALUES (?, ?)', [
        e.key,
        e.value,
      ]);
    }
    // Fold the stamp into the main file so the copy is a single file.
    db.execute('PRAGMA wal_checkpoint(TRUNCATE)');
    medicines = count(db, 'medicines');
    batches = count(db, 'batches');
    suppliers = count(db, 'suppliers');
    invoices = count(db, 'supplier_invoices');
  } finally {
    db.close();
  }

  final dbBytes = await File(dbPath).readAsBytes();
  final meta = BackupMetadata(
    appVersion: appVersion,
    schemaVersion: schemaVersion,
    createdAt: createdAt,
    sha256: await _sha256Hex(dbBytes),
    dbBytes: dbBytes.length,
    medicines: medicines,
    batches: batches,
    suppliers: suppliers,
    invoices: invoices,
    encrypted: passphrase != null,
  );
  final archive = Archive()
    ..addFile(
      ArchiveFile.bytes(
        backupMetaEntry,
        utf8.encode(jsonEncode(meta.toJson())),
      ),
    )
    ..addFile(ArchiveFile.bytes(backupDbEntry, dbBytes));
  final zip = ZipEncoder().encodeBytes(archive);

  if (passphrase == null) {
    await File(outPath).writeAsBytes(zip, flush: true);
  } else {
    await File(outPath).writeAsBytes(
      await _encrypt(Uint8List.fromList(zip), passphrase, iterations),
      flush: true,
    );
  }
  return meta;
}

Future<Uint8List> _encrypt(
  Uint8List zip,
  String passphrase,
  int iterations,
) async {
  final algo = AesGcm.with256bits();
  final salt = SecretKeyData.random(length: _saltLength).bytes;
  final nonce = algo.newNonce();
  final header = BytesBuilder()
    ..add(_magic)
    ..addByte(_headerVersion)
    ..add((ByteData(4)..setUint32(0, iterations)).buffer.asUint8List())
    ..add(salt)
    ..add(nonce);
  final headerBytes = header.toBytes();
  final key = await _deriveKey(passphrase, salt, iterations);
  final box = await algo.encrypt(
    zip,
    secretKey: key,
    nonce: nonce,
    aad: headerBytes,
  );
  return (BytesBuilder()
        ..add(headerBytes)
        ..add(box.cipherText)
        ..add(box.mac.bytes))
      .toBytes();
}

Future<Uint8List> _decrypt(Uint8List bytes, String passphrase) async {
  final iterations = ByteData.sublistView(bytes, 5, 9).getUint32(0);
  if (iterations < 1 || iterations > 5000000) {
    throw const BackupException(
      BackupFailureKind.corrupt,
      'bad iteration count',
    );
  }
  final salt = bytes.sublist(9, 9 + _saltLength);
  final nonce = bytes.sublist(9 + _saltLength, _headerLength);
  final cipher = bytes.sublist(_headerLength, bytes.length - 16);
  final mac = Mac(bytes.sublist(bytes.length - 16));
  final key = await _deriveKey(passphrase, salt, iterations);
  try {
    final clear = await AesGcm.with256bits().decrypt(
      SecretBox(cipher, nonce: nonce, mac: mac),
      secretKey: key,
      aad: bytes.sublist(0, _headerLength),
    );
    return Uint8List.fromList(clear);
  } on SecretBoxAuthenticationError {
    throw const BackupException(BackupFailureKind.wrongPassphrase);
  }
}

/// Opens, verifies and unpacks a backup. On success the database is at
/// [extractTo]. Every problem is a [BackupException]. Runs in a background
/// isolate.
Future<BackupMetadata> readBackup({
  required String path,
  required String extractTo,
  required int supportedSchema,
  String? passphrase,
}) async {
  Uint8List bytes;
  try {
    bytes = await File(path).readAsBytes();
  } on FileSystemException catch (e) {
    throw BackupException(BackupFailureKind.notABackup, e.message);
  }
  final encrypted = isEncryptedBackup(bytes);
  if (encrypted) {
    if (passphrase == null || passphrase.isEmpty) {
      throw const BackupException(BackupFailureKind.needsPassphrase);
    }
    if (bytes.length < _headerLength + 16 + 22) {
      throw const BackupException(BackupFailureKind.corrupt, 'truncated');
    }
    bytes = await _decrypt(bytes, passphrase);
  }

  Archive archive;
  try {
    archive = ZipDecoder().decodeBytes(bytes);
  } on Object {
    throw BackupException(
      encrypted ? BackupFailureKind.corrupt : BackupFailureKind.notABackup,
      'not a zip',
    );
  }
  final metaFile = archive.findFile(backupMetaEntry);
  final dbFile = archive.findFile(backupDbEntry);
  if (metaFile == null || dbFile == null) {
    // A zip with no entries at all is a truncated one (its index is missing);
    // a zip with other content is simply not ours.
    throw BackupException(
      archive.isEmpty && _looksZip(bytes)
          ? BackupFailureKind.corrupt
          : BackupFailureKind.notABackup,
      'missing entries',
    );
  }
  final BackupMetadata meta;
  try {
    final json =
        jsonDecode(utf8.decode(metaFile.readBytes()!)) as Map<String, Object?>;
    if (json['app'] != 'pharmacy_expiry_tracker') {
      throw const BackupException(BackupFailureKind.notABackup, 'other app');
    }
    meta = BackupMetadata.fromJson(json, encrypted: encrypted);
  } on BackupException {
    rethrow;
  } on Object {
    throw const BackupException(BackupFailureKind.corrupt, 'bad metadata');
  }
  if (meta.schemaVersion > supportedSchema) {
    throw BackupException(
      BackupFailureKind.newerVersion,
      'schema ${meta.schemaVersion} > $supportedSchema',
    );
  }
  final Uint8List? dbBytes;
  try {
    dbBytes = dbFile.readBytes();
  } on Object {
    // The archive's own checksums or sizes did not hold up.
    throw const BackupException(BackupFailureKind.corrupt, 'entry unreadable');
  }
  if (dbBytes == null || await _sha256Hex(dbBytes) != meta.sha256) {
    throw const BackupException(BackupFailureKind.corrupt, 'checksum mismatch');
  }

  await File(extractTo).writeAsBytes(dbBytes, flush: true);
  final db = sql.sqlite3.open(extractTo, mode: sql.OpenMode.readOnly);
  try {
    final check = db.select('PRAGMA integrity_check').first.values.first;
    if (check != 'ok') {
      throw BackupException(BackupFailureKind.corrupt, 'integrity: $check');
    }
    final version = db.select('PRAGMA user_version').first.values.first! as int;
    if (version > supportedSchema) {
      throw const BackupException(
        BackupFailureKind.newerVersion,
        'user_version',
      );
    }
  } on sql.SqliteException catch (e) {
    throw BackupException(BackupFailureKind.corrupt, e.message);
  } finally {
    db.close();
  }
  return meta;
}
