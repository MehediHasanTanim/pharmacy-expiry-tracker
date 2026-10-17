import 'package:drift/drift.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';

/// Medicines left-joined to the batches that still hold stock, grouped to give
/// each medicine's on-hand total and nearest expiry. Callers add `where` and
/// ordering.
class MedicineSummaryQuery {
  MedicineSummaryQuery(this._db)
    : _onHand = _db.batches.quantityOnHand.sum(),
      _nearest = _db.batches.expiryDate.min() {
    statement =
        _db.select(_db.medicines).join([
            leftOuterJoin(
              _db.batches,
              _db.batches.medicineId.equalsExp(_db.medicines.id) &
                  _db.batches.quantityOnHand.isBiggerThanValue(0) &
                  _db.batches.status.equals('ACTIVE') &
                  _db.batches.deletedAt.isNull(),
            ),
          ])
          ..addColumns([_onHand, _nearest])
          ..groupBy([_db.medicines.id]);
  }

  final AppDatabase _db;
  final Expression<int> _onHand;
  final Expression<String> _nearest;
  late final JoinedSelectStatement<HasResultSet, dynamic> statement;

  MedicineSummary map(TypedResult row) {
    final nearest = row.read(_nearest);
    return MedicineSummary(
      medicine: row.readTable(_db.medicines).toEntity(),
      onHand: row.read(_onHand) ?? 0,
      nearestExpiry: nearest == null ? null : ExpiryDate.parse(nearest),
    );
  }
}
