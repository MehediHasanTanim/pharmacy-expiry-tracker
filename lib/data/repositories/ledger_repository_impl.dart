import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/ledger_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/invoice_rules.dart';

DateTime _ms(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

String? _blank(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}

class LedgerRepositoryImpl implements LedgerRepository {
  LedgerRepositoryImpl(this._db);

  final AppDatabase _db;

  Set<TableInfo<Table, dynamic>> get _tables => {
    _db.supplierInvoices,
    _db.supplierPayments,
    _db.supplierCredits,
  };

  // --- invoices -----------------------------------------------------------

  Invoice _invoiceFrom(SupplierInvoice r) => Invoice(
    id: r.id,
    supplierId: r.supplierId,
    invoiceNumber: r.invoiceNumber,
    invoiceDate: dateFromIso(r.invoiceDate),
    dueDate: r.dueDate == null ? null : dateFromIso(r.dueDate!),
    total: Money(r.totalMinor),
    notes: r.notes,
    remindersSnoozedUntil: r.remindersSnoozedUntil == null
        ? null
        : dateFromIso(r.remindersSnoozedUntil!),
    createdAt: _ms(r.createdAt),
    updatedAt: _ms(r.updatedAt),
  );

  SupplierInvoicesCompanion _invoiceCompanion(Invoice i) {
    return SupplierInvoicesCompanion(
      id: Value(i.id),
      supplierId: Value(i.supplierId),
      invoiceNumber: Value(_blank(i.invoiceNumber)),
      invoiceDate: Value(dateToIso(i.invoiceDate)),
      dueDate: Value(i.dueDate == null ? null : dateToIso(i.dueDate!)),
      totalMinor: Value(i.total.minor),
      notes: Value(_blank(i.notes)),
      remindersSnoozedUntil: Value(
        i.remindersSnoozedUntil == null
            ? null
            : dateToIso(i.remindersSnoozedUntil!),
      ),
      createdAt: Value(i.createdAt.millisecondsSinceEpoch),
      updatedAt: Value(i.updatedAt.millisecondsSinceEpoch),
    );
  }

  @override
  Future<void> insertInvoice(Invoice invoice) =>
      _db.into(_db.supplierInvoices).insert(_invoiceCompanion(invoice));

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    final n =
        await (_db.update(
          _db.supplierInvoices,
        )..where((i) => i.id.equals(invoice.id) & i.deletedAt.isNull())).write(
          _invoiceCompanion(invoice).copyWith(createdAt: const Value.absent()),
        );
    if (n == 0) throw NotFoundException('invoice', invoice.id);
  }

  @override
  Future<void> softDeleteInvoice(String id, DateTime at) async {
    final n =
        await (_db.update(
          _db.supplierInvoices,
        )..where((i) => i.id.equals(id) & i.deletedAt.isNull())).write(
          SupplierInvoicesCompanion(
            deletedAt: Value(at.millisecondsSinceEpoch),
            updatedAt: Value(at.millisecondsSinceEpoch),
          ),
        );
    if (n == 0) throw NotFoundException('invoice', id);
  }

  @override
  Future<Invoice?> getInvoice(String id) async {
    final row = await (_db.select(
      _db.supplierInvoices,
    )..where((i) => i.id.equals(id) & i.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : _invoiceFrom(row);
  }

  static const _balanceSql = '''
    SELECT i.*, v.paid_minor AS paid_minor, v.credit_minor AS credit_minor
    FROM supplier_invoices i
    JOIN v_invoice_balance v ON v.invoice_id = i.id
    WHERE i.deleted_at IS NULL
  ''';

  InvoiceBalance _balanceFrom(QueryRow r, DateTime today) {
    final d = r.data;
    final invoice = Invoice(
      id: d['id']! as String,
      supplierId: d['supplier_id']! as String,
      invoiceNumber: d['invoice_number'] as String?,
      invoiceDate: dateFromIso(d['invoice_date']! as String),
      dueDate: d['due_date'] == null
          ? null
          : dateFromIso(d['due_date']! as String),
      total: Money(d['total_minor']! as int),
      notes: d['notes'] as String?,
      remindersSnoozedUntil: d['reminders_snoozed_until'] == null
          ? null
          : dateFromIso(d['reminders_snoozed_until']! as String),
      createdAt: _ms(d['created_at']! as int),
      updatedAt: _ms(d['updated_at']! as int),
    );
    final paid = Money(d['paid_minor']! as int);
    final credited = Money(d['credit_minor']! as int);
    return InvoiceBalance(
      invoice: invoice,
      paid: paid,
      credited: credited,
      status: invoiceStatus(
        total: invoice.total,
        paid: paid,
        credited: credited,
        dueDate: invoice.dueDate,
        today: today,
      ),
    );
  }

  @override
  Future<InvoiceBalance?> getInvoiceBalance(
    String id, {
    required DateTime today,
  }) async {
    final rows = await _db
        .customSelect(
          '$_balanceSql AND i.id = ?',
          variables: [Variable<String>(id)],
          readsFrom: _tables,
        )
        .get();
    return rows.isEmpty ? null : _balanceFrom(rows.first, today);
  }

  @override
  Stream<InvoiceBalance?> watchInvoiceBalance(
    String id, {
    required DateTime today,
  }) {
    return _db
        .customSelect(
          '$_balanceSql AND i.id = ?',
          variables: [Variable<String>(id)],
          readsFrom: _tables,
        )
        .watch()
        .map((rows) => rows.isEmpty ? null : _balanceFrom(rows.first, today));
  }

  @override
  Stream<List<InvoiceBalance>> watchInvoices(
    String supplierId, {
    required DateTime today,
  }) {
    return _db
        .customSelect(
          '$_balanceSql AND i.supplier_id = ? '
          'ORDER BY i.invoice_date DESC, i.created_at DESC, i.id DESC',
          variables: [Variable<String>(supplierId)],
          readsFrom: _tables,
        )
        .watch()
        .map((rows) => [for (final r in rows) _balanceFrom(r, today)]);
  }

  @override
  Future<List<OpenInvoice>> openInvoices(String supplierId) async {
    final rows = await _db
        .customSelect(
          '''
      SELECT invoice_id, balance_minor, invoice_date, due_date
      FROM v_invoice_balance
      WHERE supplier_id = ? AND balance_minor > 0
      ''',
          variables: [Variable<String>(supplierId)],
          readsFrom: _tables,
        )
        .get();
    return [
      for (final r in rows)
        OpenInvoice(
          id: r.data['invoice_id']! as String,
          balance: Money(r.data['balance_minor']! as int),
          invoiceDate: dateFromIso(r.data['invoice_date']! as String),
          dueDate: r.data['due_date'] == null
              ? null
              : dateFromIso(r.data['due_date']! as String),
        ),
    ];
  }

  @override
  Future<void> setReminderSnooze(
    String invoiceId,
    DateTime? until,
    DateTime at,
  ) async {
    final n =
        await (_db.update(
          _db.supplierInvoices,
        )..where((i) => i.id.equals(invoiceId) & i.deletedAt.isNull())).write(
          SupplierInvoicesCompanion(
            remindersSnoozedUntil: Value(
              until == null ? null : dateToIso(until),
            ),
            updatedAt: Value(at.millisecondsSinceEpoch),
          ),
        );
    if (n == 0) throw NotFoundException('invoice', invoiceId);
  }

  // --- payments -----------------------------------------------------------

  Payment _paymentFrom(SupplierPayment r) => Payment(
    id: r.id,
    supplierId: r.supplierId,
    invoiceId: r.invoiceId!,
    amount: Money(r.amountMinor),
    paidOn: dateFromIso(r.paidOn),
    method: PaymentMethod.fromDb(r.method),
    reference: r.reference,
    createdAt: _ms(r.createdAt),
  );

  @override
  Future<void> insertPayment(Payment p) {
    return _db
        .into(_db.supplierPayments)
        .insert(
          SupplierPaymentsCompanion.insert(
            id: p.id,
            supplierId: p.supplierId,
            invoiceId: Value(p.invoiceId),
            amountMinor: p.amount.minor,
            paidOn: dateToIso(p.paidOn),
            method: Value(p.method?.db),
            reference: Value(_blank(p.reference)),
            createdAt: p.createdAt.millisecondsSinceEpoch,
          ),
        );
  }

  @override
  Future<Payment?> getPayment(String id) async {
    final row = await (_db.select(
      _db.supplierPayments,
    )..where((p) => p.id.equals(id) & p.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : _paymentFrom(row);
  }

  @override
  Future<void> softDeletePayment(String id, DateTime at) async {
    final n =
        await (_db.update(
          _db.supplierPayments,
        )..where((p) => p.id.equals(id) & p.deletedAt.isNull())).write(
          SupplierPaymentsCompanion(
            deletedAt: Value(at.millisecondsSinceEpoch),
          ),
        );
    if (n == 0) throw NotFoundException('payment', id);
  }

  @override
  Stream<List<Payment>> watchPayments(String supplierId) {
    return (_db.select(_db.supplierPayments)
          ..where((p) => p.supplierId.equals(supplierId) & p.deletedAt.isNull())
          ..orderBy([
            (p) => OrderingTerm.desc(p.paidOn),
            (p) => OrderingTerm.desc(p.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_paymentFrom).toList());
  }

  @override
  Stream<List<Payment>> watchInvoicePayments(String invoiceId) {
    return (_db.select(_db.supplierPayments)
          ..where((p) => p.invoiceId.equals(invoiceId) & p.deletedAt.isNull())
          ..orderBy([
            (p) => OrderingTerm.desc(p.paidOn),
            (p) => OrderingTerm.desc(p.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_paymentFrom).toList());
  }

  // --- credits ------------------------------------------------------------

  Credit _creditFrom(SupplierCredit r) => Credit(
    id: r.id,
    supplierId: r.supplierId,
    invoiceId: r.invoiceId,
    returnId: r.returnId,
    amount: Money(r.amountMinor),
    issuedOn: dateFromIso(r.issuedOn),
    note: r.note,
    createdAt: _ms(r.createdAt),
  );

  @override
  Future<void> insertCredit(Credit c) {
    return _db
        .into(_db.supplierCredits)
        .insert(
          SupplierCreditsCompanion.insert(
            id: c.id,
            supplierId: c.supplierId,
            invoiceId: Value(c.invoiceId),
            returnId: Value(c.returnId),
            amountMinor: c.amount.minor,
            issuedOn: dateToIso(c.issuedOn),
            note: Value(_blank(c.note)),
            createdAt: c.createdAt.millisecondsSinceEpoch,
          ),
        );
  }

  @override
  Future<Credit?> getCredit(String id) async {
    final row = await (_db.select(
      _db.supplierCredits,
    )..where((c) => c.id.equals(id) & c.deletedAt.isNull())).getSingleOrNull();
    return row == null ? null : _creditFrom(row);
  }

  @override
  Future<void> softDeleteCredit(String id, DateTime at) async {
    final n =
        await (_db.update(
          _db.supplierCredits,
        )..where((c) => c.id.equals(id) & c.deletedAt.isNull())).write(
          SupplierCreditsCompanion(deletedAt: Value(at.millisecondsSinceEpoch)),
        );
    if (n == 0) throw NotFoundException('credit', id);
  }

  @override
  Stream<List<Credit>> watchCredits(String supplierId) {
    return (_db.select(_db.supplierCredits)
          ..where((c) => c.supplierId.equals(supplierId) & c.deletedAt.isNull())
          ..orderBy([
            (c) => OrderingTerm.desc(c.issuedOn),
            (c) => OrderingTerm.desc(c.createdAt),
          ]))
        .watch()
        .map((rows) => rows.map(_creditFrom).toList());
  }
}
