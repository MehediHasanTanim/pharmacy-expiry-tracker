import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';

typedef SupplierListArgs = ({
  String query,
  bool includeArchived,
  SupplierSort sort,
});

final supplierListProvider = StreamProvider.autoDispose
    .family<List<SupplierSummary>, SupplierListArgs>(
      (ref, a) => ref
          .watch(supplierRepositoryProvider)
          .watchAll(
            today: ref.watch(todayDateProvider),
            query: a.query,
            includeArchived: a.includeArchived,
            sort: a.sort,
          ),
    );

final supplierSummaryProvider = StreamProvider.autoDispose
    .family<SupplierSummary?, String>(
      (ref, id) => ref
          .watch(supplierRepositoryProvider)
          .watchSummary(id, today: ref.watch(todayDateProvider)),
    );

/// Non-archived suppliers, for pickers.
final activeSuppliersProvider = StreamProvider.autoDispose<List<Supplier>>(
  (ref) => ref.watch(supplierRepositoryProvider).watchActive(),
);

/// Everything owed, for the Suppliers tab and (Sprint 5) the dashboard.
final duesSummaryProvider = StreamProvider.autoDispose<DuesSummary>(
  (ref) => ref
      .watch(supplierRepositoryProvider)
      .watchDues(today: ref.watch(todayDateProvider)),
);

final supplierInvoicesProvider = StreamProvider.autoDispose
    .family<List<InvoiceBalance>, String>(
      (ref, supplierId) => ref
          .watch(ledgerRepositoryProvider)
          .watchInvoices(supplierId, today: ref.watch(todayDateProvider)),
    );

final invoiceBalanceProvider = StreamProvider.autoDispose
    .family<InvoiceBalance?, String>(
      (ref, id) => ref
          .watch(ledgerRepositoryProvider)
          .watchInvoiceBalance(id, today: ref.watch(todayDateProvider)),
    );

final supplierPaymentsProvider = StreamProvider.autoDispose
    .family<List<Payment>, String>(
      (ref, supplierId) =>
          ref.watch(ledgerRepositoryProvider).watchPayments(supplierId),
    );

final invoicePaymentsProvider = StreamProvider.autoDispose
    .family<List<Payment>, String>(
      (ref, invoiceId) =>
          ref.watch(ledgerRepositoryProvider).watchInvoicePayments(invoiceId),
    );

final supplierCreditsProvider = StreamProvider.autoDispose
    .family<List<Credit>, String>(
      (ref, supplierId) =>
          ref.watch(ledgerRepositoryProvider).watchCredits(supplierId),
    );

/// How the Suppliers tab is sorted (kept for the session).
class SupplierSortChoice extends Notifier<SupplierSort> {
  @override
  SupplierSort build() => SupplierSort.name;

  void set(SupplierSort sort) => state = sort;
}

final supplierSortProvider = NotifierProvider<SupplierSortChoice, SupplierSort>(
  SupplierSortChoice.new,
);
