import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pharmacy_expiry_tracker/data/db/db_encryption.dart';
import 'package:pharmacy_expiry_tracker/data/db/tables/alerts.dart';
import 'package:pharmacy_expiry_tracker/data/db/tables/catalog.dart';
import 'package:pharmacy_expiry_tracker/data/db/tables/stock.dart';
import 'package:pharmacy_expiry_tracker/data/db/tables/suppliers.dart';
import 'package:sqlite3/sqlite3.dart' show Database;

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Medicines,
    MedicineBarcodes,
    Batches,
    StockAdjustments,
    Suppliers,
    SupplierInvoices,
    SupplierPayments,
    SupplierCredits,
    SupplierReturns,
    SupplierReturnLines,
    ReorderOrders,
    ReorderReminderState,
    ScheduledAlerts,
    AlertLog,
    Settings,
  ],
  include: {'indexes.drift'},
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for tests.
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  /// Opens the on-device database in a background isolate.
  ///
  /// With [hexKey] the file is encrypted with SQLCipher (S8-05); without it
  /// the file must be plain SQLite (only while an encryption attempt has
  /// failed, see `prepareDatabase`).
  factory AppDatabase.open({
    String fileName = defaultFileName,
    String? hexKey,
  }) {
    return AppDatabase(
      LazyDatabase(() async {
        final file = await defaultFile(fileName: fileName);
        return NativeDatabase.createInBackground(
          file,
          setup: (db) => _configure(db, hexKey),
        );
      }),
    );
  }

  /// Opens the database at [file] (same rules as [AppDatabase.open]). With
  /// [background] false the database runs in the calling isolate, which is
  /// what tests want.
  factory AppDatabase.forFile(
    File file, {
    String? hexKey,
    bool background = true,
  }) {
    void setup(Database db) => _configure(db, hexKey);
    return AppDatabase(
      background
          ? NativeDatabase.createInBackground(file, setup: setup)
          : NativeDatabase(file, setup: setup),
    );
  }

  /// Bump with every schema change (and add a migration step).
  static const currentSchemaVersion = 1;

  /// The on-device database file.
  static Future<File> defaultFile({String fileName = defaultFileName}) async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, fileName));
  }

  static const defaultFileName = 'pharmacy_expiry.sqlite';

  static void _configure(Database rawDb, String? hexKey) {
    // The key must be the first statement on the connection.
    if (hexKey != null) {
      rawDb
        ..execute(keyPragma(hexKey))
        // Fails here, not later, if the key is wrong.
        ..select('SELECT count(*) FROM sqlite_master');
    }
    rawDb
      ..execute('PRAGMA journal_mode = WAL')
      ..execute('PRAGMA foreign_keys = ON');
  }

  @override
  int get schemaVersion => currentSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
