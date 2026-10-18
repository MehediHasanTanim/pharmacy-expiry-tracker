import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/db/db_encryption.dart';
import 'package:pharmacy_expiry_tracker/data/db/migration_guard.dart';
import 'package:pharmacy_expiry_tracker/data/security/db_key_store.dart';

/// Gets the on-device database ready and returns the key to open it with.
///
///  * a new install gets an encrypted database;
///  * a plaintext database from an earlier version is encrypted in place
///    (S8-05), after a verified copy; if that fails, the plaintext file is left
///    exactly as it was, null is returned (open it unencrypted) and the next
///    start tries again;
///  * an encrypted database with no key throws
///    [DatabaseKeyMissingException]: the data cannot be read.
///
/// Then the schema is brought to the current version with a safety copy around
/// the upgrade (S6-05); [MigrationFailedException] means the old data was put
/// back. Call before the first normal use in any isolate.
Future<String?> prepareDatabase({
  required DatabaseKeyStore keys,
  File? file,
}) async {
  final target = file ?? await AppDatabase.defaultFile();
  String? key;
  if (isEncryptedFile(target)) {
    key = await keys.read();
    if (key == null) throw const DatabaseKeyMissingException();
  } else if (!target.existsSync()) {
    key = await getOrCreateDatabaseKey(keys);
  } else if (isPlainSqlite(target)) {
    try {
      final candidate = await getOrCreateDatabaseKey(keys);
      encryptInPlace(target, candidate);
      key = candidate;
    } on Object catch (e, st) {
      debugPrint('Database encryption failed, staying unencrypted: $e\n$st');
      key = null;
    }
  }
  await guardedMigrate(
    file: target,
    targetVersion: AppDatabase.currentSchemaVersion,
    hexKey: key,
    migrate: () async {
      final db = AppDatabase.forFile(target, hexKey: key);
      try {
        // Any query makes Drift open the file and run the upgrade.
        await db.customSelect('SELECT 1').get();
      } finally {
        await db.close();
      }
    },
  );
  return key;
}
