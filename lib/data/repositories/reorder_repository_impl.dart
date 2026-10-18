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
          readsFrom: {_db.medicines, _db.batches, _db.reorderReminderState},
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
