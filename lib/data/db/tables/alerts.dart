import 'package:drift/drift.dart';
import 'package:pharmacy_expiry_tracker/data/db/tables/catalog.dart';
import 'package:pharmacy_expiry_tracker/data/db/tables/suppliers.dart';

class ReorderOrders extends Table {
  TextColumn get id => text()();
  TextColumn get medicineId => text().references(Medicines, #id)();
  TextColumn get supplierId => text().nullable().references(Suppliers, #id)();
  IntColumn get quantity => integer()();
  TextColumn get orderedOn => text()();
  TextColumn get expectedOn => text().nullable()();

  /// `ORDERED` | `RECEIVED` | `CANCELLED`.
  TextColumn get status => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class ReorderReminderState extends Table {
  TextColumn get medicineId => text().references(Medicines, #id)();
  TextColumn get lastNotifiedOn => text().nullable()();
  TextColumn get snoozedUntil => text().nullable()();

  @override
  Set<Column> get primaryKey => {medicineId};
}

@TableIndex(name: 'idx_alert_fire', columns: {#fireAt})
class ScheduledAlerts extends Table {
  /// Deterministic logical key, e.g. `lead:2026-11-17`.
  TextColumn get id => text()();

  /// EXPIRY_LEAD | EXPIRY_DAY | DIGEST | PAYMENT | REORDER | BACKUP.
  TextColumn get kind => text()();

  /// UTC epoch milliseconds.
  IntColumn get fireAt => integer()();

  /// 31-bit id handed to the OS scheduler.
  IntColumn get osId => integer().unique()();
  TextColumn get payload => text()();
  TextColumn get contentHash => text()();

  /// `PENDING` | `FIRED` | `CANCELLED`.
  TextColumn get state => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class AlertLog extends Table {
  TextColumn get id => text()();
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  TextColumn get route => text().nullable()();
  IntColumn get firedAt => integer()();
  IntColumn get openedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
