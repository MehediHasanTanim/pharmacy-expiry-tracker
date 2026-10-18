import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/invoice_rules.dart';

/// Invoices, payments and credits (the supplier ledger). Balances are derived
/// from the rows through the `v_invoice_balance` view, never stored.
abstract interface class LedgerRepository {
  Future<void> insertInvoice(Invoice invoice);

  /// Replaces the editable fields of an existing invoice.
  Future<void> updateInvoice(Invoice invoice);

  Future<void> softDeleteInvoice(String id, DateTime at);

  Future<Invoice?> getInvoice(String id);

  Future<InvoiceBalance?> getInvoiceBalance(
    String id, {
    required DateTime today,
  });

  Stream<InvoiceBalance?> watchInvoiceBalance(
    String id, {
    required DateTime today,
  });

  /// A supplier's invoices, newest first.
  Stream<List<InvoiceBalance>> watchInvoices(
    String supplierId, {
    required DateTime today,
  });

  /// Invoices of the supplier that still owe something.
  Future<List<OpenInvoice>> openInvoices(String supplierId);

  Future<void> setReminderSnooze(
    String invoiceId,
    DateTime? until,
    DateTime at,
  );

  Future<void> insertPayment(Payment payment);

  Future<Payment?> getPayment(String id);

  Future<void> softDeletePayment(String id, DateTime at);

  /// A supplier's payments, newest first.
  Stream<List<Payment>> watchPayments(String supplierId);

  Stream<List<Payment>> watchInvoicePayments(String invoiceId);

  Future<void> insertCredit(Credit credit);

  Future<Credit?> getCredit(String id);

  Future<void> softDeleteCredit(String id, DateTime at);

  Stream<List<Credit>> watchCredits(String supplierId);
}
