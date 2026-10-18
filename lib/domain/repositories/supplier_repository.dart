import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';

abstract interface class SupplierRepository {
  /// Suppliers with what is owed to each, as of [today] (for overdue).
  Stream<List<SupplierSummary>> watchAll({
    required DateTime today,
    String query = '',
    bool includeArchived = false,
    SupplierSort sort = SupplierSort.name,
  });

  Stream<SupplierSummary?> watchSummary(String id, {required DateTime today});

  /// Non-archived suppliers by name, for pickers.
  Stream<List<Supplier>> watchActive();

  Future<Supplier?> getById(String id);

  /// Returns the new supplier's id.
  Future<String> create(SupplierInput input);

  Future<void> update(String id, SupplierInput input);

  Future<void> setArchived(String id, {required bool archived});

  /// Everything owed, across all suppliers (SUP-8).
  Stream<DuesSummary> watchDues({required DateTime today});
}
