import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/logging/error_log.dart';
import 'package:pharmacy_expiry_tracker/data/background/alert_background.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/alert_store_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/barcode_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/batch_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/draft_store_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/expiry_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/ledger_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/medicine_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/reorder_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/return_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/search_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/settings_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/supplier_repository_impl.dart';
import 'package:pharmacy_expiry_tracker/data/services/alert_engine_factory.dart';
import 'package:pharmacy_expiry_tracker/data/services/app_badge_impl.dart';
import 'package:pharmacy_expiry_tracker/data/services/local_notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/data/services/platform_alert_settings_impl.dart';
import 'package:pharmacy_expiry_tracker/data/services/share_file_exchange.dart';
import 'package:pharmacy_expiry_tracker/data/services/url_contact_launcher.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/contact_launcher.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/linked_barcode.dart';
import 'package:pharmacy_expiry_tracker/domain/file_exchange.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/app_badge.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/platform_alert_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/alert_store.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/barcode_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/batch_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/draft_store.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/expiry_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/ledger_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/medicine_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/reorder_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/return_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/search_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/settings_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/supplier_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/transaction_runner.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/barcode_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/batch_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/delivery_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/expiry_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/ledger_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/medicine_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/reorder_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/return_usecases.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/supplier_usecases.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(databaseProvider)),
);

final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Currency symbol from settings; empty means "show the bare amount".
final currencySymbolProvider = Provider<String>(
  (ref) =>
      ref.watch(settingsProvider.select((s) => s.value?.currencySymbol ?? '')),
);

/// Committed data changes, for components that react to them (search refresh
/// now, the alert engine from Sprint 3).
final dataChangeBusProvider = Provider<DataChangeBus>((ref) {
  final bus = DataChangeBus();
  ref.onDispose(bus.dispose);
  return bus;
});

final dataChangesProvider = StreamProvider<DataChange>(
  (ref) => ref.watch(dataChangeBusProvider).changes,
);

final medicineRepositoryProvider = Provider<MedicineRepository>(
  (ref) => MedicineRepositoryImpl(
    ref.watch(databaseProvider),
    ref.watch(clockProvider),
  ),
);

final batchRepositoryProvider = Provider<BatchRepository>(
  (ref) => BatchRepositoryImpl(ref.watch(databaseProvider)),
);

final transactionRunnerProvider = Provider<TransactionRunner>(
  (ref) => DriftTransactionRunner(ref.watch(databaseProvider)),
);

final searchRepositoryProvider = Provider<SearchRepository>(
  (ref) => SearchRepositoryImpl(ref.watch(databaseProvider)),
);

final recentSearchesRepositoryProvider = Provider<RecentSearchesRepository>(
  (ref) => RecentSearchesRepositoryImpl(ref.watch(databaseProvider)),
);

final saveMedicineProvider = Provider<SaveMedicine>(
  (ref) => SaveMedicine(
    ref.watch(medicineRepositoryProvider),
    ref.watch(dataChangeBusProvider),
  ),
);

final setMedicineArchivedProvider = Provider<SetMedicineArchived>(
  (ref) => SetMedicineArchived(
    ref.watch(medicineRepositoryProvider),
    ref.watch(dataChangeBusProvider),
  ),
);

final addBatchProvider = Provider<AddBatch>(
  (ref) => AddBatch(
    batches: ref.watch(batchRepositoryProvider),
    medicines: ref.watch(medicineRepositoryProvider),
    transaction: ref.watch(transactionRunnerProvider),
    clock: ref.watch(clockProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final editBatchProvider = Provider<EditBatch>(
  (ref) => EditBatch(
    batches: ref.watch(batchRepositoryProvider),
    transaction: ref.watch(transactionRunnerProvider),
    clock: ref.watch(clockProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final adjustStockProvider = Provider<AdjustStock>(
  (ref) => AdjustStock(
    batches: ref.watch(batchRepositoryProvider),
    transaction: ref.watch(transactionRunnerProvider),
    clock: ref.watch(clockProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final expiryRepositoryProvider = Provider<ExpiryRepository>(
  (ref) => ExpiryRepositoryImpl(ref.watch(databaseProvider)),
);

final updateAlertStateProvider = Provider<UpdateAlertState>(
  (ref) => UpdateAlertState(
    batches: ref.watch(batchRepositoryProvider),
    clock: ref.watch(clockProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final discardBatchesProvider = Provider<DiscardBatches>(
  (ref) => DiscardBatches(
    batches: ref.watch(batchRepositoryProvider),
    adjustStock: ref.watch(adjustStockProvider),
    transaction: ref.watch(transactionRunnerProvider),
  ),
);

/// The OS notification scheduler. Overridden with a fake in tests.
final notificationPluginProvider = Provider<NotificationPlugin>(
  (ref) => LocalNotificationPlugin(),
);

final platformAlertSettingsProvider = Provider<PlatformAlertSettings>(
  (ref) => MethodChannelPlatformAlertSettings(),
);

final alertStoreProvider = Provider<AlertStore>(
  (ref) => AlertStoreImpl(ref.watch(databaseProvider)),
);

final alertSourceProvider = Provider<AlertSource>(
  (ref) => AlertSourceImpl(ref.watch(databaseProvider)),
);

/// Whether the alert engine runs at all. Tests that exercise screens, not
/// alerts, switch it off.
final alertEngineEnabledProvider = Provider<bool>((ref) => true);

final alertEngineProvider = Provider<AlertEngine>(
  (ref) => createAlertEngine(
    db: ref.watch(databaseProvider),
    plugin: ref.watch(notificationPluginProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Registers the periodic background re-plan. Replaced in tests.
final backgroundReplanRegistrarProvider = Provider<Future<void> Function()>(
  (ref) => AlertBackground.register,
);

/// Re-plans alerts when data or settings change. Reading this provider starts
/// listening.
final alertCoordinatorProvider = Provider<AlertCoordinator>((ref) {
  final coordinator = AlertCoordinator(ref.watch(alertEngineProvider))
    ..listenTo(ref.watch(dataChangeBusProvider).changes)
    ..listenTo(ref.watch(settingsRepositoryProvider).watch());
  ref.onDispose(() => unawaited(coordinator.dispose()));
  return coordinator;
});

/// Result of each completed alert pass, newest last.
final replanResultsProvider = StreamProvider<ReplanSummary>(
  (ref) => ref.watch(alertCoordinatorProvider).results,
);

/// Current notification / exact-alarm permission. Invalidate to re-check
/// (the app does when it returns to the foreground).
final notificationPermissionsProvider =
    FutureProvider.autoDispose<NotificationPermissions>(
      (ref) => ref.watch(notificationPluginProvider).permissions(),
    );

final deviceAlertConditionsProvider =
    FutureProvider.autoDispose<DeviceAlertConditions>(
      (ref) => ref.watch(platformAlertSettingsProvider).conditions(),
    );

final alertLogProvider = StreamProvider.autoDispose<List<AlertLogEntry>>(
  (ref) => ref.watch(alertStoreProvider).watchLog(),
);

final pendingAlertCountProvider = StreamProvider.autoDispose<int>(
  (ref) => ref.watch(alertStoreProvider).watchPendingCount(),
);

final supplierRepositoryProvider = Provider<SupplierRepository>(
  (ref) => SupplierRepositoryImpl(
    ref.watch(databaseProvider),
    ref.watch(clockProvider),
  ),
);

final ledgerRepositoryProvider = Provider<LedgerRepository>(
  (ref) => LedgerRepositoryImpl(ref.watch(databaseProvider)),
);

final ledgerDepsProvider = Provider<LedgerDeps>(
  (ref) => LedgerDeps(
    suppliers: ref.watch(supplierRepositoryProvider),
    ledger: ref.watch(ledgerRepositoryProvider),
    batches: ref.watch(batchRepositoryProvider),
    transaction: ref.watch(transactionRunnerProvider),
    clock: ref.watch(clockProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final saveSupplierProvider = Provider<SaveSupplier>(
  (ref) => SaveSupplier(
    ref.watch(supplierRepositoryProvider),
    ref.watch(dataChangeBusProvider),
  ),
);

final setSupplierArchivedProvider = Provider<SetSupplierArchived>(
  (ref) => SetSupplierArchived(
    ref.watch(supplierRepositoryProvider),
    ref.watch(dataChangeBusProvider),
  ),
);

final addInvoiceProvider = Provider<AddInvoice>(
  (ref) => AddInvoice(ref.watch(ledgerDepsProvider)),
);
final editInvoiceProvider = Provider<EditInvoice>(
  (ref) => EditInvoice(ref.watch(ledgerDepsProvider)),
);
final deleteInvoiceProvider = Provider<DeleteInvoice>(
  (ref) => DeleteInvoice(ref.watch(ledgerDepsProvider)),
);
final recordPaymentProvider = Provider<RecordPayment>(
  (ref) => RecordPayment(ref.watch(ledgerDepsProvider)),
);
final deletePaymentProvider = Provider<DeletePayment>(
  (ref) => DeletePayment(ref.watch(ledgerDepsProvider)),
);
final recordCreditProvider = Provider<RecordCredit>(
  (ref) => RecordCredit(ref.watch(ledgerDepsProvider)),
);
final deleteCreditProvider = Provider<DeleteCredit>(
  (ref) => DeleteCredit(ref.watch(ledgerDepsProvider)),
);
final reminderSnoozeProvider = Provider<UpdateReminderSnooze>(
  (ref) => UpdateReminderSnooze(ref.watch(ledgerDepsProvider)),
);

/// Opens phone, messaging and mail apps. Replaced in tests.
final contactLauncherProvider = Provider<ContactLauncher>(
  (ref) => const UrlContactLauncher(),
);

final reorderRepositoryProvider = Provider<ReorderRepository>(
  (ref) => ReorderRepositoryImpl(ref.watch(databaseProvider)),
);

final reorderSnoozeProvider = Provider<UpdateReorderSnooze>(
  (ref) => UpdateReorderSnooze(
    reorder: ref.watch(reorderRepositoryProvider),
    clock: ref.watch(clockProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

/// The app-icon badge. Replaced in tests.
final appBadgeProvider = Provider<AppBadge>((ref) => const PluginAppBadge());

/// The version shown in diagnostics and written into backups. Set in `main`.
final appVersionProvider = Provider<String>((ref) => '0.0.0');

/// The on-device database file; backup and restore swap it. Set in `main`.
final databaseFileProvider = Provider<File>(
  (ref) => throw UnimplementedError('databaseFileProvider is set in main'),
);

/// The bounded local error log (S6-08). Set in `main`; tests get a throwaway.
final errorLogProvider = Provider<ErrorLog>((ref) {
  final dir = Directory.systemTemp.createTempSync('pharmacy_expiry_log');
  ref.onDispose(() {
    try {
      dir.deleteSync(recursive: true);
    } on FileSystemException {
      // Best effort.
    }
  });
  return ErrorLog(File(p.join(dir.path, 'errors.log')));
});

/// Share sheet and file picker. Replaced in tests.
final fileExchangeProvider = Provider<FileExchange>(
  (ref) => const ShareFileExchange(),
);

final returnRepositoryProvider = Provider<ReturnRepository>(
  (ref) => ReturnRepositoryImpl(ref.watch(databaseProvider)),
);

final returnToSupplierProvider = Provider<ReturnToSupplier>(
  (ref) => ReturnToSupplier(
    deps: ref.watch(ledgerDepsProvider),
    returns: ref.watch(returnRepositoryProvider),
    adjustStock: ref.watch(adjustStockProvider),
    recordCredit: ref.watch(recordCreditProvider),
  ),
);

final barcodeServiceProvider = Provider<BarcodeService>(
  (ref) => BarcodeService(
    barcodes: BarcodeRepositoryImpl(ref.watch(databaseProvider)),
    medicines: ref.watch(medicineRepositoryProvider),
    transaction: ref.watch(transactionRunnerProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final barcodeRepositoryProvider = Provider<BarcodeRepository>(
  (ref) => BarcodeRepositoryImpl(ref.watch(databaseProvider)),
);

final orderTrackerProvider = Provider<OrderTracker>(
  (ref) => OrderTracker(
    reorder: ref.watch(reorderRepositoryProvider),
    medicines: ref.watch(medicineRepositoryProvider),
    clock: ref.watch(clockProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final receiveDeliveryProvider = Provider<ReceiveDelivery>(
  (ref) => ReceiveDelivery(
    addBatch: ref.watch(addBatchProvider),
    addInvoice: ref.watch(addInvoiceProvider),
    transaction: ref.watch(transactionRunnerProvider),
    bus: ref.watch(dataChangeBusProvider),
  ),
);

final draftStoreProvider = Provider<DraftStore>(
  (ref) => DraftStoreImpl(ref.watch(databaseProvider)),
);

final medicineBarcodesProvider = StreamProvider.autoDispose
    .family<List<LinkedBarcode>, String>(
      (ref, medicineId) =>
          ref.watch(barcodeRepositoryProvider).watchForMedicine(medicineId),
    );
