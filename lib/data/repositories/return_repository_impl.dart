import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier_return.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/return_repository.dart';

class ReturnRepositoryImpl implements ReturnRepository {
  ReturnRepositoryImpl(this._db);

  final AppDatabase _db;

  Set<TableInfo<Table, dynamic>> get _tables => {
    _db.supplierReturns,
    _db.supplierReturnLines,
    _db.supplierCredits,
    _db.batches,
    _db.medicines,
    _db.suppliers,
  };

  @override
  Future<void> insert(ReturnRecord ret) async {
    await _db
        .into(_db.supplierReturns)
        .insert(
          SupplierReturnsCompanion.insert(
            id: ret.id,
            supplierId: ret.supplierId,
            returnedOn: dateToIso(ret.returnedOn),
            note: Value(ret.note),
            createdAt: ret.createdAt.millisecondsSinceEpoch,
          ),
        );
    for (final l in ret.lines) {
      await _db
          .into(_db.supplierReturnLines)
          .insert(
            SupplierReturnLinesCompanion.insert(
              id: l.id,
              returnId: ret.id,
              batchId: l.batchId,
              quantity: l.quantity,
              valueMinor: Value(l.value?.minor),
            ),
          );
    }
  }

  static const _select = '''
    SELECT r.id AS id, r.returned_on AS returned_on, r.note AS note,
           s.name AS supplier_name,
           (SELECT SUM(c.amount_minor) FROM supplier_credits c
             WHERE c.return_id = r.id AND c.deleted_at IS NULL) AS credit,
           m.brand_name AS brand, m.strength AS strength,
           b.batch_number AS batch_number,
           l.quantity AS quantity, l.value_minor AS value_minor
    FROM supplier_returns r
    JOIN supplier_return_lines l ON l.return_id = r.id
    JOIN batches b ON b.id = l.batch_id
    JOIN medicines m ON m.id = b.medicine_id
    JOIN suppliers s ON s.id = r.supplier_id
  ''';

  List<ReturnView> _group(List<QueryRow> rows) {
    final byId = <String, List<QueryRow>>{};
    for (final r in rows) {
      (byId[r.read<String>('id')] ??= []).add(r);
    }
    return [
      for (final e in byId.values)
        ReturnView(
          id: e.first.read<String>('id'),
          supplierName: e.first.read<String>('supplier_name'),
          returnedOn: dateFromIso(e.first.read<String>('returned_on')),
          note: e.first.readNullable<String>('note'),
          credit: e.first.readNullable<int>('credit') == null
              ? null
              : Money(e.first.read<int>('credit')),
          lines: [
            for (final r in e)
              ReturnLineView(
                medicineName: _name(
                  r.read<String>('brand'),
                  r.readNullable<String>('strength'),
                ),
                batchNumber: r.read<String>('batch_number'),
                quantity: r.read<int>('quantity'),
                value: r.readNullable<int>('value_minor') == null
                    ? null
                    : Money(r.read<int>('value_minor')),
              ),
          ],
        ),
    ];
  }

  static String _name(String brand, String? strength) =>
      strength == null || strength.isEmpty ? brand : '$brand $strength';

  @override
  Stream<List<ReturnView>> watchBySupplier(String supplierId) {
    return _db
        .customSelect(
          '$_select WHERE r.supplier_id = ? '
          'ORDER BY r.returned_on DESC, r.created_at DESC, m.brand_name',
          variables: [Variable<String>(supplierId)],
          readsFrom: _tables,
        )
        .watch()
        .map(_group);
  }

  @override
  Future<ReturnView?> getView(String id) async {
    final rows = await _db
        .customSelect(
          '$_select WHERE r.id = ? ORDER BY m.brand_name',
          variables: [Variable<String>(id)],
          readsFrom: _tables,
        )
        .get();
    return _group(rows).firstOrNull;
  }
}
