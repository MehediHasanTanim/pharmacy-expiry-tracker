import 'package:drift/drift.dart';
import 'package:pharmacy_expiry_tracker/data/db/tables/catalog.dart';
import 'package:pharmacy_expiry_tracker/data/db/tables/suppliers.dart';

// `idx_batch_expiry` is a partial index (`WHERE quantity_on_hand > 0`), which
// @TableIndex cannot express; it lives in `indexes.drift`.
@TableIndex(name: 'idx_batch_med', columns: {#medicineId})
@TableIndex(name: 'idx_batch_supplier', columns: {#supplierId})
@DataClassName('BatchRow')
class Batches extends Table {
  TextColumn get id => text()();
  TextColumn get medicineId => text().references(Medicines, #id)();
  TextColumn get batchNumber => text()();

  /// `YYYY-MM-DD`; last day of the month when [expiryPrecision] is `MONTH`.
  TextColumn get expiryDate => text()();

  /// `MONTH` | `DAY`.
  TextColumn get expiryPrecision => text()();
  IntColumn get quantityReceived => integer()();
  IntColumn get quantityOnHand => integer()();
  IntColumn get costPriceMinor => integer().nullable()();
  IntColumn get sellingPriceMinor => integer().nullable()();
  TextColumn get receivedDate => text()();
  TextColumn get supplierId => text().nullable().references(Suppliers, #id)();
  TextColumn get invoiceId =>
      text().nullable().references(SupplierInvoices, #id)();

  /// `ACTIVE` | `DEPLETED` | `RETURNED` | `DISCARDED`.
  TextColumn get status => text().withDefault(const Constant('ACTIVE'))();
  TextColumn get snoozedUntil => text().nullable()();
  IntColumn get handledAt => integer().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {medicineId, batchNumber, expiryDate},
  ];
}

@DataClassName('StockAdjustmentRow')
class StockAdjustments extends Table {
  TextColumn get id => text()();
  TextColumn get batchId => text().references(Batches, #id)();
  IntColumn get deltaQty => integer()();

  /// RECEIVED | SOLD | DAMAGED | DISCARDED_EXPIRED | RETURNED | CORRECTION
  /// | OTHER.
  TextColumn get reason => text()();
  TextColumn get note => text().nullable()();
  IntColumn get valueImpactMinor => integer().nullable()();
  TextColumn get returnId =>
      text().nullable().references(SupplierReturns, #id)();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class SupplierReturnLines extends Table {
  TextColumn get id => text()();
  TextColumn get returnId => text().references(SupplierReturns, #id)();
  TextColumn get batchId => text().references(Batches, #id)();
  IntColumn get quantity => integer()();
  IntColumn get valueMinor => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
