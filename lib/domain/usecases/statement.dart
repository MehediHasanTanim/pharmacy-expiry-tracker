import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';

enum StatementKind { invoice, payment, credit }

/// One line of a supplier statement. [amount] is signed from the pharmacy's
/// point of view: invoices add to what is owed, payments and credits reduce it.
@immutable
class StatementEntry {
  const StatementEntry({
    required this.on,
    required this.kind,
    required this.amount,
    required this.balance,
    this.reference,
    this.note,
  });

  final DateTime on;
  final StatementKind kind;
  final String? reference;
  final String? note;
  final Money amount;

  /// Owed after this line.
  final Money balance;
}

/// An account statement for reconciling with a supplier (SUP-11).
@immutable
class SupplierStatement {
  const SupplierStatement({
    required this.supplierName,
    required this.from,
    required this.to,
    required this.opening,
    required this.entries,
    required this.closing,
    required this.totalInvoiced,
    required this.totalPaid,
    required this.totalCredited,
  });

  final String supplierName;
  final DateTime from;
  final DateTime to;

  /// Owed at the start of [from].
  final Money opening;
  final List<StatementEntry> entries;

  /// Owed at the end of [to].
  final Money closing;
  final Money totalInvoiced;
  final Money totalPaid;
  final Money totalCredited;
}

/// Works out the statement for [from]..[to] (both days included) from a
/// supplier's invoices, payments and credits. Everything before [from] folds
/// into the opening balance; lines are in date order with a running balance.
/// Money is integer minor units, so the lines always add up exactly.
SupplierStatement buildStatement({
  required String supplierName,
  required DateTime from,
  required DateTime to,
  required List<Invoice> invoices,
  required List<Payment> payments,
  required List<Credit> credits,
}) {
  final start = dateOnly(from);
  final end = dateOnly(to);
  final raw =
      <
          ({
            DateTime on,
            int order,
            DateTime created,
            StatementKind kind,
            int signed,
            String? ref,
            String? note,
          })
        >[
          for (final i in invoices)
            (
              on: dateOnly(i.invoiceDate),
              order: 0,
              created: i.createdAt,
              kind: StatementKind.invoice,
              signed: i.total.minor,
              ref: i.invoiceNumber,
              note: i.notes,
            ),
          for (final c in credits)
            (
              on: dateOnly(c.issuedOn),
              order: 1,
              created: c.createdAt,
              kind: StatementKind.credit,
              signed: -c.amount.minor,
              ref: null,
              note: c.note,
            ),
          for (final p in payments)
            (
              on: dateOnly(p.paidOn),
              order: 2,
              created: p.createdAt,
              kind: StatementKind.payment,
              signed: -p.amount.minor,
              ref: p.reference,
              note: null,
            ),
        ]
        ..sort((a, b) {
          final byDate = a.on.compareTo(b.on);
          if (byDate != 0) return byDate;
          final byKind = a.order.compareTo(b.order);
          return byKind != 0 ? byKind : a.created.compareTo(b.created);
        });

  var balance = 0;
  var opening = 0;
  var invoiced = 0;
  var paid = 0;
  var credited = 0;
  final entries = <StatementEntry>[];
  for (final r in raw) {
    if (r.on.isAfter(end)) break;
    balance += r.signed;
    if (r.on.isBefore(start)) {
      opening = balance;
      continue;
    }
    switch (r.kind) {
      case StatementKind.invoice:
        invoiced += r.signed;
      case StatementKind.payment:
        paid -= r.signed;
      case StatementKind.credit:
        credited -= r.signed;
    }
    entries.add(
      StatementEntry(
        on: r.on,
        kind: r.kind,
        amount: Money(r.signed),
        balance: Money(balance),
        reference: r.ref,
        note: r.note,
      ),
    );
  }
  return SupplierStatement(
    supplierName: supplierName,
    from: start,
    to: end,
    opening: Money(opening),
    entries: entries,
    closing: Money(balance),
    totalInvoiced: Money(invoiced),
    totalPaid: Money(paid),
    totalCredited: Money(credited),
  );
}
