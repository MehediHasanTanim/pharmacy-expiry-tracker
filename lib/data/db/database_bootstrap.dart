import 'dart:io';

import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/db/migration_guard.dart';

/// Brings the on-device database to the current schema, with a safety copy
/// around the upgrade (S6-05). Throws [MigrationFailedException] after putting
/// the old data back. Call before the first normal use in any isolate.
Future<void> prepareDatabase([File? file]) async {
  final target = file ?? await AppDatabase.defaultFile();
  await guardedMigrate(
    file: target,
    targetVersion: AppDatabase.currentSchemaVersion,
    migrate: () async {
      final db = AppDatabase.open();
      try {
        // Any query makes Drift open the file and run the upgrade.
        await db.customSelect('SELECT 1').get();
      } finally {
        await db.close();
      }
    },
  );
}
