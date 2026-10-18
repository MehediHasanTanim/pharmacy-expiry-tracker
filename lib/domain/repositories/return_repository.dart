import 'package:pharmacy_expiry_tracker/domain/entities/supplier_return.dart';

abstract interface class ReturnRepository {
  Future<void> insert(ReturnRecord ret);

  /// A supplier's returns, newest first, with line names and any credit.
  Stream<List<ReturnView>> watchBySupplier(String supplierId);

  Future<ReturnView?> getView(String id);
}
