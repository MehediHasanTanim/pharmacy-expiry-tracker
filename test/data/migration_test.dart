import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';

import '../generated_migrations/schema.dart';

/// Guards against changing a shipped schema without a migration: the live
/// schema must equal the committed snapshot in `drift_schemas/`.
///
/// When bumping `schemaVersion`:
///   dart run drift_dev schema dump lib/data/db/app_database.dart drift_schemas/
///   dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
/// then add a stepwise upgrade test here.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  test('current schema matches the committed v1 snapshot', () async {
    final connection = await verifier.startAt(1);
    final db = AppDatabase(connection);
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 1);
  });
}
