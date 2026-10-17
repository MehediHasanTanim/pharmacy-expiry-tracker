import 'package:drift/drift.dart';

class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get contactPerson => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get taxId => text().nullable()();
  IntColumn get paymentTermsDays => integer().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_inv_due', columns: {#dueDate})
class SupplierInvoices extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId => text().references(Suppliers, #id)();
  TextColumn get invoiceNumber => text().nullable()();
  TextColumn get invoiceDate => text()();
  TextColumn get dueDate => text().nullable()();
  IntColumn get totalMinor => integer()();
  TextColumn get notes => text().nullable()();
  TextColumn get remindersSnoozedUntil => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SupplierReturns extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId => text().references(Suppliers, #id)();
  TextColumn get returnedOn => text()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class SupplierPayments extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId => text().references(Suppliers, #id)();
  TextColumn get invoiceId =>
      text().nullable().references(SupplierInvoices, #id)();
  IntColumn get amountMinor => integer()();
  TextColumn get paidOn => text()();
  TextColumn get method => text().nullable()();
  TextColumn get reference => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SupplierCredits extends Table {
  TextColumn get id => text()();
  TextColumn get supplierId => text().references(Suppliers, #id)();
  TextColumn get invoiceId =>
      text().nullable().references(SupplierInvoices, #id)();
  TextColumn get returnId =>
      text().nullable().references(SupplierReturns, #id)();
  IntColumn get amountMinor => integer()();
  TextColumn get issuedOn => text()();
  TextColumn get note => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
