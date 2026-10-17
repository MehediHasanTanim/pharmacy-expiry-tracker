import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// In-memory database for tests.
  AppDatabase.forTesting() : super(NativeDatabase.memory());

  /// Opens the on-device database in a background isolate.
  factory AppDatabase.open({String fileName = 'pharmacy_expiry.sqlite'}) {
    return AppDatabase(
      LazyDatabase(() async {
        final dir = await getApplicationDocumentsDirectory();
        final file = File(p.join(dir.path, fileName));
        return NativeDatabase.createInBackground(file, setup: _configure);
      }),
    );
  }

  static void _configure(Database rawDb) {
    rawDb
      ..execute('PRAGMA journal_mode = WAL')
      ..execute('PRAGMA foreign_keys = ON');
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
