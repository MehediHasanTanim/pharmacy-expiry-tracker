import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';

@immutable
class Supplier {
  const Supplier({
    required this.id,
    required this.name,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    this.paymentTermsDays,
    this.notes,
  });

  final String id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;

  /// Days from invoice date to due date; null = no standing terms.
  final int? paymentTermsDays;
  final String? notes;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  SupplierInput toInput() => SupplierInput(
    name: name,
    contactPerson: contactPerson,
    phone: phone,
    email: email,
    address: address,
    taxId: taxId,
    paymentTermsDays: paymentTermsDays,
    notes: notes,
  );
}

@immutable
class SupplierInput {
  const SupplierInput({
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.taxId,
    this.paymentTermsDays,
    this.notes,
  });

  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? taxId;
  final int? paymentTermsDays;
  final String? notes;
}

enum SupplierSort { name, balance, nextDue }

/// A supplier with what is owed to them (SUP-7).
@immutable
class SupplierSummary {
  const SupplierSummary({
    required this.supplier,
    this.outstanding = Money.zero,
    this.overdue = Money.zero,
    this.overdueCount = 0,
    this.openInvoiceCount = 0,
    this.nextDue,
  });

  final Supplier supplier;

  /// Unpaid invoice balances, less credits not tied to an invoice. Can be
  /// negative when the supplier owes the pharmacy.
  final Money outstanding;

  /// Part of the unpaid balances whose due date has passed.
  final Money overdue;
  final int overdueCount;
  final int openInvoiceCount;

  /// Earliest due date among unpaid invoices that have one.
  final DateTime? nextDue;

  bool get hasOverdue => overdueCount > 0;
}

/// All suppliers combined, for the dashboard (SUP-8).
@immutable
class DuesSummary {
  const DuesSummary({
    this.outstanding = Money.zero,
    this.overdue = Money.zero,
    this.overdueCount = 0,
    this.nextDue,
  });

  final Money outstanding;
  final Money overdue;
  final int overdueCount;
  final DateTime? nextDue;

  @override
  bool operator ==(Object other) =>
      other is DuesSummary &&
      other.outstanding == outstanding &&
      other.overdue == overdue &&
      other.overdueCount == overdueCount &&
      other.nextDue == nextDue;

  @override
  int get hashCode => Object.hash(outstanding, overdue, overdueCount, nextDue);
}

enum PaymentMethod {
  cash('CASH'),
  bank('BANK'),
  mobile('MOBILE'),
  cheque('CHEQUE'),
  other('OTHER');

  PaymentMethod(this.db);
  final String db;

  static PaymentMethod? fromDb(String? v) {
    for (final m in PaymentMethod.values) {
      if (m.db == v) return m;
    }
    return null;
  }
}

/// Where an invoice stands (SUP-6). Overdue takes precedence over partial.
enum InvoiceStatus { unpaid, partial, paid, overdue }

@immutable
class Invoice {
  const Invoice({
    required this.id,
    required this.supplierId,
    required this.invoiceDate,
    required this.total,
    required this.createdAt,
    required this.updatedAt,
    this.invoiceNumber,
    this.dueDate,
    this.notes,
    this.remindersSnoozedUntil,
  });

  final String id;
  final String supplierId;
  final String? invoiceNumber;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final Money total;
  final String? notes;

  /// Payment reminders stay silent until this date.
  final DateTime? remindersSnoozedUntil;
  final DateTime createdAt;
  final DateTime updatedAt;
}

@immutable
class InvoiceInput {
  const InvoiceInput({
    required this.supplierId,
    required this.invoiceDate,
    required this.total,
    this.invoiceNumber,
    this.dueDate,
    this.notes,
    this.batchIds = const [],
  });

  final String supplierId;
  final String? invoiceNumber;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final Money total;
  final String? notes;

  /// Received batches this invoice pays for.
  final List<String> batchIds;
}

/// An invoice with what has been settled against it.
@immutable
class InvoiceBalance {
  const InvoiceBalance({
    required this.invoice,
    required this.paid,
    required this.credited,
    required this.status,
  });

  final Invoice invoice;
  final Money paid;
  final Money credited;
  final InvoiceStatus status;

  Money get balance => invoice.total - paid - credited;
  bool get isSettled => balance.minor <= 0;
  bool get hasPayments => paid.minor > 0 || credited.minor > 0;
}

@immutable
class Payment {
  const Payment({
    required this.id,
    required this.supplierId,
    required this.invoiceId,
    required this.amount,
    required this.paidOn,
    required this.createdAt,
    this.method,
    this.reference,
  });

  final String id;
  final String supplierId;
  final String invoiceId;
  final Money amount;
  final DateTime paidOn;
  final PaymentMethod? method;
  final String? reference;
  final DateTime createdAt;
}

@immutable
class Credit {
  const Credit({
    required this.id,
    required this.supplierId,
    required this.amount,
    required this.issuedOn,
    required this.createdAt,
    this.invoiceId,
    this.returnId,
    this.note,
  });

  final String id;
  final String supplierId;

  /// The invoice it reduces, or null for a general credit on the account.
  final String? invoiceId;

  /// The return of goods this credit came from, if any.
  final String? returnId;
  final Money amount;
  final DateTime issuedOn;
  final String? note;
  final DateTime createdAt;
}
