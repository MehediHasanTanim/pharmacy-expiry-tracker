import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/core/text/search_text.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/supplier_repository.dart';
import 'package:uuid/uuid.dart';

String? _blank(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}

DateTime _ms(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

extension SupplierRowMapper on SupplierRow {
  Supplier toEntity() => Supplier(
    id: id,
    name: name,
    contactPerson: contactPerson,
    phone: phone,
    email: email,
    address: address,
    taxId: taxId,
    paymentTermsDays: paymentTermsDays,
    notes: notes,
    isArchived: isArchived,
    createdAt: _ms(createdAt),
    updatedAt: _ms(updatedAt),
  );
}

class SupplierRepositoryImpl implements SupplierRepository {
  SupplierRepositoryImpl(this._db, this._clock, {String Function()? newId})
    : _newId = newId ?? (() => const Uuid().v4());

  final AppDatabase _db;
  final Clock _clock;
  final String Function() _newId;

  Set<TableInfo<Table, dynamic>> get _tables => {
    _db.suppliers,
    _db.supplierInvoices,
    _db.supplierPayments,
    _db.supplierCredits,
  };

  /// Suppliers joined to what they are owed. The two sub-selects collapse the
  /// invoice-balance view and unapplied credits to one row per supplier.
  static const _summarySql = '''
    SELECT s.*,
           COALESCE(bal.outstanding, 0) - COALESCE(cr.unlinked, 0)
             AS outstanding,
           COALESCE(bal.overdue, 0) AS overdue,
           COALESCE(bal.overdue_count, 0) AS overdue_count,
           COALESCE(bal.open_count, 0) AS open_count,
           bal.next_due AS next_due
    FROM suppliers s
    LEFT JOIN (
      SELECT supplier_id,
             SUM(balance_minor) AS outstanding,
             SUM(CASE WHEN due_date IS NOT NULL AND due_date < ?
                      THEN balance_minor ELSE 0 END) AS overdue,
             SUM(CASE WHEN due_date IS NOT NULL AND due_date < ?
                      THEN 1 ELSE 0 END) AS overdue_count,
             COUNT(*) AS open_count,
             MIN(due_date) AS next_due
      FROM v_invoice_balance
      WHERE balance_minor > 0
      GROUP BY supplier_id
    ) bal ON bal.supplier_id = s.id
    LEFT JOIN (
      SELECT supplier_id, SUM(amount_minor) AS unlinked
      FROM supplier_credits
      WHERE invoice_id IS NULL AND deleted_at IS NULL
      GROUP BY supplier_id
    ) cr ON cr.supplier_id = s.id
    WHERE s.deleted_at IS NULL
  ''';

  SupplierSummary _summary(QueryRow r) {
    final d = r.data;
    final next = d['next_due'] as String?;
    return SupplierSummary(
      supplier: Supplier(
        id: d['id']! as String,
        name: d['name']! as String,
        contactPerson: d['contact_person'] as String?,
        phone: d['phone'] as String?,
        email: d['email'] as String?,
        address: d['address'] as String?,
        taxId: d['tax_id'] as String?,
        paymentTermsDays: d['payment_terms_days'] as int?,
        notes: d['notes'] as String?,
        isArchived: (d['is_archived']! as int) != 0,
        createdAt: _ms(d['created_at']! as int),
        updatedAt: _ms(d['updated_at']! as int),
      ),
      outstanding: Money(d['outstanding']! as int),
      overdue: Money(d['overdue']! as int),
      overdueCount: d['overdue_count']! as int,
      openInvoiceCount: d['open_count']! as int,
      nextDue: next == null ? null : dateFromIso(next),
    );
  }

  @override
  Stream<List<SupplierSummary>> watchAll({
    required DateTime today,
    String query = '',
    bool includeArchived = false,
    SupplierSort sort = SupplierSort.name,
  }) {
    final iso = dateToIso(today);
    final terms = normalizeSearchText(query)
        .split(' ')
        .where((t) => t.isNotEmpty)
        .toList();
    final where = StringBuffer();
    final vars = <Variable<Object>>[
      Variable<String>(iso),
      Variable<String>(iso),
    ];
    if (!includeArchived) where.write(' AND s.is_archived = 0');
    for (final t in terms) {
      // instr() takes the term literally, unlike LIKE.
      where.write(
        " AND instr(lower(s.name || ' ' || COALESCE(s.contact_person, '')), ?) > 0",
      );
      vars.add(Variable<String>(t));
    }
    final order = switch (sort) {
      SupplierSort.name => 'lower(s.name)',
      SupplierSort.balance => 'outstanding DESC, lower(s.name)',
      SupplierSort.nextDue => 'next_due IS NULL, next_due ASC, lower(s.name)',
    };
    return _db
        .customSelect(
          '$_summarySql$where ORDER BY $order',
          variables: vars,
          readsFrom: _tables,
        )
        .watch()
        .map((rows) => rows.map(_summary).toList());
  }

  @override
  Stream<SupplierSummary?> watchSummary(String id, {required DateTime today}) {
    final iso = dateToIso(today);
    return _db
        .customSelect(
          '$_summarySql AND s.id = ?',
          variables: [
            Variable<String>(iso),
            Variable<String>(iso),
            Variable<String>(id),
          ],
          readsFrom: _tables,
        )
        .watch()
        .map((rows) => rows.isEmpty ? null : _summary(rows.first));
  }

  @override
  Stream<List<Supplier>> watchActive() {
    return (_db.select(_db.suppliers)
          ..where((s) => s.deletedAt.isNull() & s.isArchived.equals(false))
          ..orderBy([(s) => OrderingTerm.asc(s.name.lower())]))
        .watch()
        .map((rows) => rows.map((r) => r.toEntity()).toList());
  }

  @override
  Future<Supplier?> getById(String id) async {
    final row = await (_db.select(
      _db.suppliers,
    )..where((s) => s.id.equals(id) & s.deletedAt.isNull())).getSingleOrNull();
    return row?.toEntity();
  }

  SuppliersCompanion _companion(SupplierInput i, {String? id}) {
    return SuppliersCompanion(
      id: id == null ? const Value.absent() : Value(id),
      name: Value(i.name.trim()),
      contactPerson: Value(_blank(i.contactPerson)),
      phone: Value(_blank(i.phone)),
      email: Value(_blank(i.email)),
      address: Value(_blank(i.address)),
      taxId: Value(_blank(i.taxId)),
      paymentTermsDays: Value(i.paymentTermsDays),
      notes: Value(_blank(i.notes)),
      updatedAt: Value(_clock.now().millisecondsSinceEpoch),
    );
  }

  @override
  Future<String> create(SupplierInput input) async {
    final id = _newId();
    await _db
        .into(_db.suppliers)
        .insert(
          _companion(
            input,
            id: id,
          ).copyWith(createdAt: Value(_clock.now().millisecondsSinceEpoch)),
        );
    return id;
  }

  @override
  Future<void> update(String id, SupplierInput input) async {
    final n =
        await (_db.update(_db.suppliers)
              ..where((s) => s.id.equals(id) & s.deletedAt.isNull()))
            .write(_companion(input));
    if (n == 0) throw NotFoundException('supplier', id);
  }

  @override
  Future<void> setArchived(String id, {required bool archived}) async {
    final n =
        await (_db.update(
          _db.suppliers,
        )..where((s) => s.id.equals(id) & s.deletedAt.isNull())).write(
          SuppliersCompanion(
            isArchived: Value(archived),
            updatedAt: Value(_clock.now().millisecondsSinceEpoch),
          ),
        );
    if (n == 0) throw NotFoundException('supplier', id);
  }

  @override
  Stream<DuesSummary> watchDues({required DateTime today}) {
    final iso = dateToIso(today);
    return _db
        .customSelect(
          '''
          SELECT COALESCE(SUM(b.balance_minor), 0) AS outstanding,
                 COALESCE(SUM(CASE WHEN b.due_date IS NOT NULL AND b.due_date < ?
                                   THEN b.balance_minor ELSE 0 END), 0) AS overdue,
                 COALESCE(SUM(CASE WHEN b.due_date IS NOT NULL AND b.due_date < ?
                                   THEN 1 ELSE 0 END), 0) AS overdue_count,
                 MIN(b.due_date) AS next_due,
                 (SELECT COALESCE(SUM(amount_minor), 0) FROM supplier_credits
                  WHERE invoice_id IS NULL AND deleted_at IS NULL) AS unlinked
          FROM v_invoice_balance b
          JOIN suppliers s ON s.id = b.supplier_id AND s.deleted_at IS NULL
          WHERE b.balance_minor > 0
          ''',
          variables: [Variable<String>(iso), Variable<String>(iso)],
          readsFrom: _tables,
        )
        .watchSingle()
        .map((r) {
          final next = r.data['next_due'] as String?;
          return DuesSummary(
            outstanding: Money(
              (r.data['outstanding']! as int) - (r.data['unlinked']! as int),
            ),
            overdue: Money(r.data['overdue']! as int),
            overdueCount: r.data['overdue_count']! as int,
            nextDue: next == null ? null : dateFromIso(next),
          );
        });
  }
}
