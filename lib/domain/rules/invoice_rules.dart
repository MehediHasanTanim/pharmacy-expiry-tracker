import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';

/// Status from the amounts and the due date (SUP-6, S4-03).
///
///  * settled (balance ≤ 0) → [InvoiceStatus.paid]
///  * unsettled and past its due date → [InvoiceStatus.overdue], even if part
///    has been paid (the part is still visible from the amounts)
///  * unsettled with something applied → [InvoiceStatus.partial]
///  * otherwise → [InvoiceStatus.unpaid]
///
/// An invoice is overdue from the day *after* its due date.
InvoiceStatus invoiceStatus({
  required Money total,
  required Money paid,
  required Money credited,
  required DateTime? dueDate,
  required DateTime today,
}) {
  final balance = total - paid - credited;
  if (balance.minor <= 0) return InvoiceStatus.paid;
  if (dueDate != null && dateOnly(dueDate).isBefore(dateOnly(today))) {
    return InvoiceStatus.overdue;
  }
  if (paid.minor + credited.minor > 0) return InvoiceStatus.partial;
  return InvoiceStatus.unpaid;
}

/// Due date implied by a supplier's payment terms, or null with no terms.
DateTime? defaultDueDate(DateTime invoiceDate, int? termsDays) {
  if (termsDays == null) return null;
  return DateTime(
    invoiceDate.year,
    invoiceDate.month,
    invoiceDate.day + termsDays,
  );
}

/// An open invoice a payment can be applied to.
@immutable
class OpenInvoice {
  const OpenInvoice({
    required this.id,
    required this.balance,
    required this.invoiceDate,
    this.dueDate,
  });

  final String id;
  final Money balance;
  final DateTime invoiceDate;
  final DateTime? dueDate;
}

@immutable
class Allocation {
  const Allocation(this.invoiceId, this.amount);

  final String invoiceId;
  final Money amount;
}

@immutable
class AllocationResult {
  const AllocationResult(this.allocations, this.leftover);

  final List<Allocation> allocations;

  /// Part of the payment that no invoice could take.
  final Money leftover;
}

/// Spreads [amount] over [invoices], oldest due first (undated invoices come
/// last, in invoice-date order), never giving an invoice more than its balance.
AllocationResult allocatePayment(Money amount, List<OpenInvoice> invoices) {
  final ordered = [...invoices]
    ..sort((a, b) {
      final ad = a.dueDate;
      final bd = b.dueDate;
      if (ad != null && bd != null) {
        final byDue = ad.compareTo(bd);
        if (byDue != 0) return byDue;
      } else if (ad != null) {
        return -1;
      } else if (bd != null) {
        return 1;
      }
      final byDate = a.invoiceDate.compareTo(b.invoiceDate);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
  var remaining = amount.minor;
  final out = <Allocation>[];
  for (final inv in ordered) {
    if (remaining <= 0) break;
    if (inv.balance.minor <= 0) continue;
    final part = remaining < inv.balance.minor ? remaining : inv.balance.minor;
    out.add(Allocation(inv.id, Money(part)));
    remaining -= part;
  }
  return AllocationResult(out, Money(remaining));
}
