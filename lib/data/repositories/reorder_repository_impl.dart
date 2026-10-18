import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/reorder_sql.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/reorder.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/reorder_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/reorder_rules.dart';

class ReorderRepositoryImpl implements ReorderRepository {
  ReorderRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Stream<List<ReorderItem>> watchBelowLevel({required DateTime today}) {
    return _db
        .customSelect(
          '$belowLevelSql ORDER BY (m.reorder_level - COALESCE(u.usable, 0)) DESC, '
          'lower(m.brand_name)',
          variables: [Variable<String>(dateToIso(today))],
          readsFrom: {
            _db.medicines,
            _db.batches,
            _db.reorderReminderState,
            _db.reorderOrders,
          },
        )
        .watch()
        .map((rows) => [for (final r in rows) _item(r)]);
  }

  ReorderItem _item(QueryRow r) {
    final d = r.data;
    final strength = d['strength'] as String?;
    final brand = d['brand']! as String;
    final level = d['reorder_level']! as int;
    final usable = d['usable']! as int;
    final snooze = d['snoozed_until'] as String?;
    return ReorderItem(
      medicineId: d['id']! as String,
      name: strength == null || strength.isEmpty ? brand : '$brand $strength',
      unit: StockUnit.fromDb(d['unit']! as String),
      reorderLevel: level,
      usable: usable,
      suggested: suggestedOrderQty(usable, level),
      supplierId: d['supplier_id'] as String?,
      snoozedUntil: snooze == null ? null : dateFromIso(snooze),
      order: d['order_id'] == null
          ? null
          : PlacedOrder(
              id: d['order_id']! as String,
              medicineId: d['id']! as String,
              supplierId: d['order_supplier'] as String?,
              quantity: d['order_qty']! as int,
              orderedOn: dateFromIso(d['ordered_on']! as String),
              expectedOn: d['expected_on'] == null
                  ? null
                  : dateFromIso(d['expected_on']! as String),
            ),
    );
  }

  @override
  Future<void> insertOrder(PlacedOrder o, DateTime createdAt) async {
    await _db.transaction(() async {
      // One open order per medicine: a new one replaces the old.
      await (_db.update(_db.reorderOrders)..where(
            (t) =>
                t.medicineId.equals(o.medicineId) & t.status.equals('ORDERED'),
          ))
          .write(const ReorderOrdersCompanion(status: Value('CANCELLED')));
      await _db
          .into(_db.reorderOrders)
          .insert(
            ReorderOrdersCompanion.insert(
              id: o.id,
              medicineId: o.medicineId,
              supplierId: Value(o.supplierId),
              quantity: o.quantity,
              orderedOn: dateToIso(o.orderedOn),
              expectedOn: Value(
                o.expectedOn == null ? null : dateToIso(o.expectedOn!),
              ),
              status: 'ORDERED',
              createdAt: createdAt.millisecondsSinceEpoch,
            ),
          );
    });
  }

  @override
  Future<PlacedOrder?> getOpenOrder(String medicineId) async {
    final row =
        await (_db.select(_db.reorderOrders)
              ..where(
                (t) =>
                    t.medicineId.equals(medicineId) &
                    t.status.equals('ORDERED'),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;
    return PlacedOrder(
      id: row.id,
      medicineId: row.medicineId,
      supplierId: row.supplierId,
      quantity: row.quantity,
      orderedOn: dateFromIso(row.orderedOn),
      expectedOn: row.expectedOn == null ? null : dateFromIso(row.expectedOn!),
    );
  }

  @override
  Future<void> closeOrder(String orderId, {required bool received}) {
    return (_db.update(
      _db.reorderOrders,
    )..where((t) => t.id.equals(orderId))).write(
      ReorderOrdersCompanion(
        status: Value(received ? 'RECEIVED' : 'CANCELLED'),
      ),
    );
  }

  @override
  Future<void> setSnooze(String medicineId, DateTime? until) {
    return _db
        .into(_db.reorderReminderState)
        .insertOnConflictUpdate(
          ReorderReminderStateCompanion(
            medicineId: Value(medicineId),
            snoozedUntil: Value(until == null ? null : dateToIso(until)),
          ),
        );
  }
}
