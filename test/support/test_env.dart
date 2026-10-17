import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/batch_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/expiry_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/medicine_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/search_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/batch_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/batch_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/expiry_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/medicine_usecases.dart';

import 'fake_clock.dart';

/// In-memory database wired with real repositories and use cases.
class TestEnv {
  TestEnv({BatchRepository Function(BatchRepository real)? wrapBatches})
    : db = AppDatabase.forTesting(),
      clock = FakeClock(DateTime(2026, 10, 17, 9)),
      bus = DataChangeBus() {
    medicines = MedicineRepositoryImpl(db, clock);
    final realBatches = BatchRepositoryImpl(db);
    batches = wrapBatches?.call(realBatches) ?? realBatches;
    tx = DriftTransactionRunner(db);
    search = SearchRepositoryImpl(db);
    expiry = ExpiryRepositoryImpl(db);
    recent = RecentSearchesRepositoryImpl(db);
    saveMedicine = SaveMedicine(medicines, bus);
    setArchived = SetMedicineArchived(medicines, bus);
    addBatch = AddBatch(
      batches: batches,
      medicines: medicines,
      transaction: tx,
      clock: clock,
      bus: bus,
    );
    editBatch = EditBatch(
      batches: batches,
      transaction: tx,
      clock: clock,
      bus: bus,
    );
    adjustStock = AdjustStock(
      batches: batches,
      transaction: tx,
      clock: clock,
      bus: bus,
    );
    alertState = UpdateAlertState(batches: batches, clock: clock, bus: bus);
    discardBatches = DiscardBatches(
      batches: batches,
      adjustStock: adjustStock,
      transaction: tx,
    );
  }

  final AppDatabase db;
  final FakeClock clock;
  final DataChangeBus bus;
  late final MedicineRepositoryImpl medicines;
  late final BatchRepository batches;
  late final DriftTransactionRunner tx;
  late final SearchRepositoryImpl search;
  late final ExpiryRepositoryImpl expiry;
  late final UpdateAlertState alertState;
  late final DiscardBatches discardBatches;
  late final RecentSearchesRepositoryImpl recent;
  late final SaveMedicine saveMedicine;
  late final SetMedicineArchived setArchived;
  late final AddBatch addBatch;
  late final EditBatch editBatch;
  late final AdjustStock adjustStock;

  Future<void> dispose() async {
    await bus.dispose();
    await db.close();
  }

  Future<String> medicine({
    String brand = 'Amoxil',
    String? strength = '500 mg',
    String? generic = 'Amoxicillin',
    DosageForm form = DosageForm.capsule,
    int reorderLevel = 0,
    String? category,
    int? alertWindowDays,
  }) {
    return saveMedicine(
      MedicineInput(
        brandName: brand,
        genericName: generic,
        strength: strength,
        dosageForm: form,
        reorderLevel: reorderLevel,
        category: category,
        alertWindowDays: alertWindowDays,
      ),
    );
  }

  BatchInput batchInput(
    String medicineId, {
    String number = 'A1',
    ExpiryDate? expiry,
    int quantity = 10,
    int? costMinor,
  }) {
    return BatchInput(
      medicineId: medicineId,
      batchNumber: number,
      expiry: expiry ?? ExpiryDate.monthYear(2027, 8),
      quantity: quantity,
      receivedDate: DateTime(2026, 10, 17),
      costPrice: costMinor == null ? null : Money(costMinor),
    );
  }
}
