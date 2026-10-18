import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/report_repository.dart';

String _name(String brand, String? strength) =>
    strength == null || strength.isEmpty ? brand : '$brand $strength';

/// Report queries (S8-01): plain SQL aggregates, so they stay fast on large
/// stores and every figure can be checked against the rows behind it.
class ReportRepositoryImpl implements ReportRepository {
  ReportRepositoryImpl(this._db);

  final AppDatabase _db;

  static const _nameSql =
      'm.brand_name || CASE WHEN m.strength IS NULL OR '
      "m.strength = '' THEN '' ELSE ' ' || m.strength END";

  String _reasons(bool includeDamaged) => includeDamaged
      ? "('DISCARDED_EXPIRED', 'DAMAGED')"
      : "('DISCARDED_EXPIRED')";

  // The group key and label for each way of grouping write-offs.
  (String key, String label) _lossColumns(LossGroup g) => switch (g) {
    LossGroup.month => (
      "strftime('%Y-%m', a.created_at / 1000, 'unixepoch', 'localtime')",
      "strftime('%Y-%m', a.created_at / 1000, 'unixepoch', 'localtime')",
    ),
    LossGroup.supplier => (
      "COALESCE(b.supplier_id, '')",
      "COALESCE(s.name, '')",
    ),
    LossGroup.medicine => ('m.id', _nameSql),
  };

  static const _lossFrom = '''
    FROM stock_adjustments a
    JOIN batches b ON b.id = a.batch_id
    JOIN medicines m ON m.id = b.medicine_id
    LEFT JOIN suppliers s ON s.id = b.supplier_id
  ''';

  @override
  Future<GroupedReport> expiryLoss(
    DateRange range,
    LossGroup group, {
    bool includeDamaged = false,
  }) async {
    final (key, label) = _lossColumns(group);
    final rows = await _db
        .customSelect(
          'SELECT $key AS k, MIN($label) AS label, '
          'SUM(-a.delta_qty) AS qty, '
          'COALESCE(SUM(a.value_impact_minor), 0) AS value, '
          'COUNT(DISTINCT a.batch_id) AS batches, '
          'COUNT(DISTINCT CASE WHEN a.value_impact_minor IS NULL '
          'THEN a.batch_id END) AS unpriced '
          '$_lossFrom '
          'WHERE a.reason IN ${_reasons(includeDamaged)} '
          'AND a.created_at >= ? AND a.created_at < ? '
          'GROUP BY k '
          '${group == LossGroup.month ? 'ORDER BY k DESC' : 'ORDER BY value DESC, label'}',
          variables: [
            Variable<int>(range.fromMs),
            Variable<int>(range.toMsExclusive),
          ],
          readsFrom: {_db.stockAdjustments, _db.batches, _db.medicines},
        )
        .get();
    return GroupedReport([
      for (final r in rows)
        ReportRow(
          key: r.read<String>('k'),
          label: r.read<String>('label'),
          quantity: r.read<int>('qty'),
          value: Money(r.read<int>('value')),
          batches: r.read<int>('batches'),
          unpriced: r.read<int>('unpriced'),
        ),
    ]);
  }

  @override
  Future<List<LossDetail>> expiryLossDetails(
    DateRange range,
    LossGroup group,
    String key, {
    bool includeDamaged = false,
  }) async {
    final (keySql, _) = _lossColumns(group);
    final rows = await _db
        .customSelect(
          'SELECT a.created_at AS at, m.brand_name AS brand, '
          'm.strength AS strength, b.batch_number AS number, '
          '-a.delta_qty AS qty, a.value_impact_minor AS value, '
          's.name AS supplier '
          '$_lossFrom '
          'WHERE a.reason IN ${_reasons(includeDamaged)} '
          'AND a.created_at >= ? AND a.created_at < ? AND $keySql = ? '
          'ORDER BY a.created_at DESC, m.brand_name',
          variables: [
            Variable<int>(range.fromMs),
            Variable<int>(range.toMsExclusive),
            Variable<String>(key),
          ],
          readsFrom: {_db.stockAdjustments, _db.batches, _db.medicines},
        )
        .get();
    return [
      for (final r in rows)
        LossDetail(
          on: DateTime.fromMillisecondsSinceEpoch(r.read<int>('at')),
          medicineName: _name(
            r.read<String>('brand'),
            r.readNullable<String>('strength'),
          ),
          batchNumber: r.read<String>('number'),
          quantity: r.read<int>('qty'),
          value: r.readNullable<int>('value') == null
              ? null
              : Money(r.read<int>('value')),
          supplierName: r.readNullable<String>('supplier'),
        ),
    ];
  }

  (String key, String label) _valuationColumns(ValuationGroup g) => switch (g) {
    ValuationGroup.medicine => ('m.id', _nameSql),
    ValuationGroup.supplier => (
      "COALESCE(b.supplier_id, '')",
      "COALESCE(s.name, '')",
    ),
    ValuationGroup.category => (
      "COALESCE(m.category, '')",
      "COALESCE(m.category, '')",
    ),
  };

  static const _stockFrom = '''
    FROM batches b
    JOIN medicines m ON m.id = b.medicine_id
    LEFT JOIN suppliers s ON s.id = b.supplier_id
    WHERE b.deleted_at IS NULL AND b.status = 'ACTIVE'
      AND b.quantity_on_hand > 0 AND m.deleted_at IS NULL
  ''';

  @override
  Future<GroupedReport> stockValuation(ValuationGroup group) async {
    final (key, label) = _valuationColumns(group);
    final rows = await _db
        .customSelect(
          'SELECT $key AS k, MIN($label) AS label, '
          'SUM(b.quantity_on_hand) AS qty, '
          'COALESCE(SUM(b.cost_price_minor * b.quantity_on_hand), 0) '
          'AS value, COUNT(*) AS batches, '
          'SUM(CASE WHEN b.cost_price_minor IS NULL THEN 1 ELSE 0 END) '
          'AS unpriced '
          '$_stockFrom GROUP BY k ORDER BY value DESC, label',
          readsFrom: {_db.batches, _db.medicines},
        )
        .get();
    return GroupedReport([
      for (final r in rows)
        ReportRow(
          key: r.read<String>('k'),
          label: r.read<String>('label'),
          quantity: r.read<int>('qty'),
          value: Money(r.read<int>('value')),
          batches: r.read<int>('batches'),
          unpriced: r.read<int>('unpriced'),
        ),
    ]);
  }

  @override
  Future<List<StockDetail>> stockDetails(
    ValuationGroup group,
    String key,
  ) async {
    final (keySql, _) = _valuationColumns(group);
    final rows = await _db
        .customSelect(
          'SELECT m.brand_name AS brand, m.strength AS strength, '
          'b.batch_number AS number, b.expiry_date AS expiry, '
          'b.quantity_on_hand AS qty, b.cost_price_minor AS cost '
          '$_stockFrom AND $keySql = ? '
          'ORDER BY b.expiry_date, m.brand_name',
          variables: [Variable<String>(key)],
          readsFrom: {_db.batches, _db.medicines},
        )
        .get();
    return [
      for (final r in rows)
        StockDetail(
          medicineName: _name(
            r.read<String>('brand'),
            r.readNullable<String>('strength'),
          ),
          batchNumber: r.read<String>('number'),
          expiry: dateFromIso(r.read<String>('expiry')),
          quantity: r.read<int>('qty'),
          value: r.readNullable<int>('cost') == null
              ? null
              : Money(r.read<int>('cost') * r.read<int>('qty')),
        ),
    ];
  }

  @override
  Future<AgingReport> duesAging(DateTime today) async {
    final iso = dateToIso(today);
    final rows = await _db
        .customSelect(
          'SELECT v.supplier_id AS sid, s.name AS name, '
          'v.balance_minor AS balance, '
          'CASE WHEN v.due_date IS NULL THEN 0 '
          'ELSE CAST(julianday(?) - julianday(v.due_date) AS INTEGER) END '
          'AS overdue '
          'FROM v_invoice_balance v '
          'JOIN suppliers s ON s.id = v.supplier_id '
          'WHERE v.balance_minor > 0',
          variables: [Variable<String>(iso)],
          readsFrom: {
            _db.supplierInvoices,
            _db.supplierPayments,
            _db.supplierCredits,
            _db.suppliers,
          },
        )
        .get();
    final bySupplier = <String, ({String name, Map<AgingBucket, int> sums})>{};
    for (final r in rows) {
      final entry = bySupplier.putIfAbsent(
        r.read<String>('sid'),
        () => (name: r.read<String>('name'), sums: <AgingBucket, int>{}),
      );
      final bucket = agingBucketFor(daysOverdue: r.read<int>('overdue'));
      entry.sums[bucket] = (entry.sums[bucket] ?? 0) + r.read<int>('balance');
    }
    final out =
        [
          for (final e in bySupplier.entries)
            AgingRow(
              supplierId: e.key,
              supplierName: e.value.name,
              buckets: {
                for (final b in e.value.sums.entries) b.key: Money(b.value),
              },
            ),
        ]..sort((a, b) {
          final byTotal = b.total.minor.compareTo(a.total.minor);
          return byTotal != 0
              ? byTotal
              : a.supplierName.compareTo(b.supplierName);
        });
    return AgingReport(out);
  }
}
