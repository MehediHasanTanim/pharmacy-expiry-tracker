import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/supplier_repository.dart';

void validateSupplierInput(SupplierInput i) {
  if (i.name.trim().isEmpty) {
    throw const ValidationException('name', 'Supplier name is required');
  }
  if (i.paymentTermsDays != null && i.paymentTermsDays! < 0) {
    throw const ValidationException(
      'paymentTermsDays',
      'Payment terms cannot be negative',
    );
  }
  final email = i.email?.trim();
  if (email != null && email.isNotEmpty && !_looksLikeEmail(email)) {
    throw const ValidationException('email', 'Enter a valid email address');
  }
}

bool _looksLikeEmail(String s) =>
    RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s);

/// Creates or updates a supplier (SUP-1).
class SaveSupplier {
  SaveSupplier(this._suppliers, this._bus);

  final SupplierRepository _suppliers;
  final DataChangeBus _bus;

  /// Creates when [id] is null, otherwise updates. Returns the supplier id.
  Future<String> call(SupplierInput input, {String? id}) async {
    validateSupplierInput(input);
    final String saved;
    if (id == null) {
      saved = await _suppliers.create(input);
    } else {
      await _suppliers.update(id, input);
      saved = id;
    }
    _bus.emit(const DataChange(DataChangeKind.supplierChanged));
    return saved;
  }
}

/// Archiving hides a supplier from pickers and lists; their ledger stays, and
/// unpaid invoices keep reminding.
class SetSupplierArchived {
  SetSupplierArchived(this._suppliers, this._bus);

  final SupplierRepository _suppliers;
  final DataChangeBus _bus;

  Future<void> call(String id, {required bool archived}) async {
    await _suppliers.setArchived(id, archived: archived);
    _bus.emit(const DataChange(DataChangeKind.supplierChanged));
  }
}
