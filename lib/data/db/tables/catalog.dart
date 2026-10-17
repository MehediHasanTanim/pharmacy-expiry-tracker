import 'package:drift/drift.dart';
import 'package:pharmacy_expiry_tracker/data/db/tables/suppliers.dart';

@TableIndex(name: 'idx_med_search', columns: {#searchText})
class Medicines extends Table {
  TextColumn get id => text()();
  TextColumn get brandName => text()();
  TextColumn get genericName => text().nullable()();
  TextColumn get strength => text().nullable()();
  TextColumn get dosageForm => text().withDefault(const Constant('other'))();
  TextColumn get unit => text().withDefault(const Constant('piece'))();
  IntColumn get packSize => integer().nullable()();
  TextColumn get manufacturer => text().nullable()();
  TextColumn get category => text().nullable()();
  IntColumn get reorderLevel => integer().withDefault(const Constant(0))();
  TextColumn get preferredSupplierId =>
      text().nullable().references(Suppliers, #id)();

  /// Null means "use the global near-expiry window".
  IntColumn get alertWindowDays => integer().nullable()();
  TextColumn get storageCondition => text().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// Normalised brand + generic name used for search.
  TextColumn get searchText => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MedicineBarcodes extends Table {
  TextColumn get id => text()();
  TextColumn get medicineId => text().references(Medicines, #id)();
  TextColumn get value => text().unique()();
  TextColumn get symbology => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
