import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/alert_store_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/batch_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/expiry_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/ledger_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/medicine_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/search_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/settings_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/supplier_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_scheduler.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/batch_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/batch_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/expiry_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/ledger_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/medicine_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/supplier_usecases.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations_en.dart';

import 'fake_clock.dart';
import 'fake_notification_plugin.dart';

/// In-memory database wired with real repositories and use cases.
class TestEnv {
  TestEnv({
    BatchRepository Function(BatchRepository real)? wrapBatches,
    FakeNotificationPlugin? plugin,
    LedgerRepositoryImpl Function(AppDatabase db)? ledgerFactory,
    AppDatabase? database,
  }) : db = database ?? AppDatabase.forTesting(),
       clock = FakeClock(DateTime(2026, 10, 17, 9)),
       plugin = plugin ?? FakeNotificationPlugin(),
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
    settings = SettingsRepositoryImpl(db);
    suppliers = SupplierRepositoryImpl(db, clock);
    ledger = ledgerFactory?.call(db) ?? LedgerRepositoryImpl(db);
    final deps = LedgerDeps(
      suppliers: suppliers,
      ledger: ledger,
      batches: batches,
      transaction: tx,
      clock: clock,
      bus: bus,
    );
    saveSupplier = SaveSupplier(suppliers, bus);
    setSupplierArchived = SetSupplierArchived(suppliers, bus);
    addInvoice = AddInvoice(deps);
    editInvoice = EditInvoice(deps);
    deleteInvoice = DeleteInvoice(deps);
    recordPayment = RecordPayment(deps);
    deletePayment = DeletePayment(deps);
    recordCredit = RecordCredit(deps);
    deleteCredit = DeleteCredit(deps);
    reminderSnooze = UpdateReminderSnooze(deps);
    alertStore = AlertStoreImpl(db);
    alertSource = AlertSourceImpl(db);
    alertScheduler = AlertScheduler(
      plugin: this.plugin,
      store: alertStore,
      transaction: tx,
    );
    alertEngine = AlertEngine(
      settings: settings,
      source: alertSource,
      store: alertStore,
      scheduler: alertScheduler,
      plugin: this.plugin,
      clock: clock,
      loadL10n: (_) async => AppLocalizationsEn(),
    );
    alertState = UpdateAlertState(batches: batches, clock: clock, bus: bus);
    discardBatches = DiscardBatches(
      batches: batches,
      adjustStock: adjustStock,
      transaction: tx,
    );
  }

  final AppDatabase db;
  final FakeNotificationPlugin plugin;
  final FakeClock clock;
  final DataChangeBus bus;
  late final MedicineRepositoryImpl medicines;
  late final BatchRepository batches;
  late final DriftTransactionRunner tx;
  late final SearchRepositoryImpl search;
  late final ExpiryRepositoryImpl expiry;
  late final SettingsRepositoryImpl settings;
  late final SupplierRepositoryImpl suppliers;
  late final LedgerRepositoryImpl ledger;
  late final SaveSupplier saveSupplier;
  late final SetSupplierArchived setSupplierArchived;
  late final AddInvoice addInvoice;
  late final EditInvoice editInvoice;
  late final DeleteInvoice deleteInvoice;
  late final RecordPayment recordPayment;
  late final DeletePayment deletePayment;
  late final RecordCredit recordCredit;
  late final DeleteCredit deleteCredit;
  late final UpdateReminderSnooze reminderSnooze;
  late final AlertStoreImpl alertStore;
  late final AlertSourceImpl alertSource;
  late final AlertScheduler alertScheduler;
  late final AlertEngine alertEngine;
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

  /// Creates a supplier and returns its id.
  Future<String> supplier({
    String name = 'ABC Pharma',
    int? terms,
    String? phone,
  }) {
    return saveSupplier(
      SupplierInput(name: name, paymentTermsDays: terms, phone: phone),
    );
  }

  /// Adds an invoice of [totalMinor] for [supplierId].
  Future<Invoice> invoice(
    String supplierId, {
    int totalMinor = 10000,
    DateTime? date,
    DateTime? due,
    String? number,
    List<String> batchIds = const [],
  }) {
    return addInvoice(
      InvoiceInput(
        supplierId: supplierId,
        invoiceDate: date ?? DateTime(2026, 10, 1),
        dueDate: due,
        total: Money(totalMinor),
        invoiceNumber: number,
        batchIds: batchIds,
      ),
    );
  }

  /// Like [batchInput] but received from [supplierId].
  BatchInput batchInputFrom(
    String medicineId,
    String number,
    String supplierId,
  ) {
    return BatchInput(
      medicineId: medicineId,
      batchNumber: number,
      expiry: ExpiryDate.monthYear(2027, 8),
      quantity: 10,
      receivedDate: DateTime(2026, 10, 17),
      supplierId: supplierId,
    );
  }
}
