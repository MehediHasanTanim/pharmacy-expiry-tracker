import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/core/text/search_text.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/db/sql_helpers.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/expiry_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';

/// Near-expiry queries (technical design §4.3).
///
/// Rows are ordered by a single ascending text key plus the batch id, which
/// makes keyset pagination uniform across sort orders:
///  * soonest: `expiry_date`
///  * value at risk: zero-padded inverted value, then `expiry_date`
///  * name: medicine search text, then `expiry_date`
class ExpiryRepositoryImpl implements ExpiryRepository {
  ExpiryRepositoryImpl(this._db);

  final AppDatabase _db;

  $BatchesTable get _b => _db.batches;
  $MedicinesTable get _m => _db.medicines;

  static String _iso(DateTime d) => dateToIso(d);

  static DateTime _plusDays(DateTime d, int days) =>
      DateTime(d.year, d.month, d.day + days);

  /// Value of the stock on hand; null when the batch has no cost price.
  Expression<int> get _valueExpr => _b.quantityOnHand * _b.costPriceMinor;

  Expression<String> _keyFor(ExpirySort sort) {
    switch (sort) {
      case ExpirySort.soonest:
        return const CustomExpression<String>('batches.expiry_date');
      case ExpirySort.valueAtRisk:
        // Larger value sorts first: invert into a fixed-width number.
        return const CustomExpression<String>(
          "printf('%015d', 999999999999999 - "
          '(batches.quantity_on_hand * coalesce(batches.cost_price_minor, 0))) '
          "|| '|' || batches.expiry_date",
        );
      case ExpirySort.name:
        return const CustomExpression<String>(
          "medicines.search_text || '|' || batches.expiry_date",
        );
    }
  }

  /// Conditions shared by every expiry query. The bucket filter is applied
  /// separately because the summary ignores it.
  Expression<bool> _base(ExpiryQuery q) {
    final f = q.filter;
    final today = _iso(q.today);
    var e =
        _b.deletedAt.isNull() &
        _b.status.equals(BatchStatus.active.db) &
        _b.quantityOnHand.isBiggerThanValue(0) &
        _m.deletedAt.isNull() &
        _m.isArchived.equals(false) &
        // Inside the medicine's own window, or the global one.
        // `today` is formatted by us from a DateTime and the window is an int,
        // so inlining them is injection-safe.
        CustomExpression<bool>(
          "(julianday(batches.expiry_date) - julianday('$today')) <= "
          'coalesce(medicines.alert_window_days, ${q.globalWindowDays})',
        );
    if (f.category != null) e = e & _m.category.equals(f.category!);
    if (f.form != null) e = e & _m.dosageForm.equals(f.form!.name);
    if (f.supplierId != null) e = e & _b.supplierId.equals(f.supplierId!);
    if (f.fromDays != null) {
      e =
          e &
          _b.expiryDate.isBiggerOrEqualValue(
            _iso(_plusDays(q.today, f.fromDays!)),
          );
    }
    if (f.toDays != null) {
      e =
          e &
          _b.expiryDate.isSmallerOrEqualValue(
            _iso(_plusDays(q.today, f.toDays!)),
          );
    }
    if (f.hideHandled) {
      // Expired stock stays visible until it is actually dealt with.
      e = e & (_b.handledAt.isNull() | _b.expiryDate.isSmallerThanValue(today));
    }
    final terms = normalizeSearchText(f.query)
        .split(' ')
        .where((t) => t.isNotEmpty);
    for (final t in terms) {
      e =
          e &
          (containsLiteral(_m.searchText, t) |
              containsLiteral(_b.batchNumber, t.toUpperCase()));
    }
    return e;
  }

  Expression<bool> _bucketFilter(ExpiryQuery q, ExpiryBucket bucket) {
    final r = bucketDayRange(bucket, thresholds: q.thresholds);
    Expression<bool> e = const Constant(true);
    if (r.minDays != null) {
      e =
          e &
          _b.expiryDate.isBiggerOrEqualValue(
            _iso(_plusDays(q.today, r.minDays!)),
          );
    }
    if (r.maxDays != null) {
      e =
          e &
          _b.expiryDate.isSmallerOrEqualValue(
            _iso(_plusDays(q.today, r.maxDays!)),
          );
    }
    return e;
  }

  @override
  Future<ExpiryPage> fetchPage(
    ExpiryQuery query, {
    ExpiryCursor? after,
    int limit = 50,
  }) async {
    final key = _keyFor(query.sort);
    var where = _base(query);
    final bucket = query.filter.bucket;
    if (bucket != null) where = where & _bucketFilter(query, bucket);
    if (after != null) {
      where =
          where &
          (key.isBiggerThanValue(after.key) |
              (key.equals(after.key) & _b.id.isBiggerThanValue(after.id)));
    }

    final stmt =
        _db.select(_b).join([innerJoin(_m, _m.id.equalsExp(_b.medicineId))])
          ..addColumns([key])
          ..where(where)
          ..orderBy([OrderingTerm.asc(key), OrderingTerm.asc(_b.id)])
          ..limit(limit);
    final rows = await stmt.get();

    final items = [
      for (final r in rows)
        _item(r.readTable(_b).toEntity(), r.readTable(_m).toEntity(), query),
    ];
    final next = rows.length == limit
        ? ExpiryCursor(rows.last.read(key)!, rows.last.readTable(_b).id)
        : null;
    return ExpiryPage(items, next: next);
  }

  ExpiryItem _item(Batch batch, Medicine medicine, ExpiryQuery q) {
    final days = batch.expiry.daysUntil(q.today);
    return ExpiryItem(
      batch: batch,
      medicine: medicine,
      daysLeft: days,
      bucket: bucketFor(days, thresholds: q.thresholds),
    );
  }

  @override
  Stream<ExpirySummary> watchSummary(ExpiryQuery query) {
    final today = query.today;
    final t = query.thresholds;
    String at(int days) => _iso(_plusDays(today, days));

    final inBucket = <ExpiryBucket, Expression<bool>>{
      ExpiryBucket.expired: _b.expiryDate.isSmallerThanValue(_iso(today)),
      ExpiryBucket.d30:
          _b.expiryDate.isBiggerOrEqualValue(_iso(today)) &
          _b.expiryDate.isSmallerOrEqualValue(at(t[0])),
      ExpiryBucket.d60:
          _b.expiryDate.isBiggerThanValue(at(t[0])) &
          _b.expiryDate.isSmallerOrEqualValue(at(t[1])),
      ExpiryBucket.d90:
          _b.expiryDate.isBiggerThanValue(at(t[1])) &
          _b.expiryDate.isSmallerOrEqualValue(at(t[2])),
      ExpiryBucket.ok: _b.expiryDate.isBiggerThanValue(at(t[2])),
    };
    // Per bucket: how many batches, what they are worth, how many have no
    // price. One pass over the rows computes all of it.
    final counts = {
      for (final e in inBucket.entries) e.key: _b.id.count(filter: e.value),
    };
    final values = {
      for (final e in inBucket.entries) e.key: _valueExpr.sum(filter: e.value),
    };
    final missing = {
      for (final e in inBucket.entries)
        e.key: _b.id.count(filter: e.value & _b.costPriceMinor.isNull()),
    };

    final stmt =
        _db.selectOnly(_b).join([innerJoin(_m, _m.id.equalsExp(_b.medicineId))])
          ..addColumns([...counts.values, ...values.values, ...missing.values])
          ..where(_base(query));

    return stmt.watchSingle().map((r) {
      final perBucket = {
        for (final k in inBucket.keys)
          k: ValueAtRisk(
            total: Money(r.read(values[k]!) ?? 0),
            missingCost: r.read(missing[k]!) ?? 0,
          ),
      };
      return ExpirySummary(
        counts: {for (final k in inBucket.keys) k: r.read(counts[k]!) ?? 0},
        value: ValueAtRisk(
          total: Money(perBucket.values.fold(0, (a, v) => a + v.total.minor)),
          missingCost: perBucket.values.fold(0, (a, v) => a + v.missingCost),
        ),
        values: perBucket,
      );
    });
  }

  @override
  Stream<void> watchChanges() {
    return _db.tableUpdates(TableUpdateQuery.onAllTables([_b, _m])).map((_) {});
  }

  @override
  Future<List<String>> categories() async {
    final rows =
        await (_db.selectOnly(_m, distinct: true)
              ..addColumns([_m.category])
              ..where(
                _m.category.isNotNull() &
                    _m.deletedAt.isNull() &
                    _m.isArchived.equals(false),
              )
              ..orderBy([OrderingTerm.asc(_m.category)]))
            .map((r) => r.read(_m.category)!)
            .get();
    return rows;
  }
}
