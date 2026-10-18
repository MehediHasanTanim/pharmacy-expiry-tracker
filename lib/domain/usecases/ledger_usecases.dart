import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/data_changes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/batch_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/ledger_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/supplier_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/transaction_runner.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/invoice_rules.dart';
import 'package:uuid/uuid.dart';

/// Shared collaborators for the ledger use cases.
class LedgerDeps {
  LedgerDeps({
    required this.suppliers,
    required this.ledger,
    required this.batches,
    required this.transaction,
    required this.clock,
    required this.bus,
    String Function()? newId,
  }) : newId = newId ?? (() => const Uuid().v4());

  final SupplierRepository suppliers;
  final LedgerRepository ledger;
  final BatchRepository batches;
  final TransactionRunner transaction;
  final Clock clock;
  final DataChangeBus bus;
  final String Function() newId;

  DateTime get today => dateOnly(clock.now());

  void announce() => bus.emit(const DataChange(DataChangeKind.ledgerChanged));
}

String? _blank(String? s) {
  final t = s?.trim();
  return t == null || t.isEmpty ? null : t;
}

void _requirePositive(Money amount, String field) {
  if (amount.minor <= 0) {
    throw ValidationException(field, 'Amount must be above zero');
  }
}

/// Records what a delivery costs as an amount owed to the supplier (SUP-4,
/// S4-04), optionally tying the received batches to it.
class AddInvoice {
  AddInvoice(this._d);

  final LedgerDeps _d;

  /// With `defaultDueFromTerms` and no explicit due date, the supplier's
  /// payment terms set one.
  Future<Invoice> call(
    InvoiceInput input, {
    bool defaultDueFromTerms = true,
  }) async {
    _requirePositive(input.total, 'total');
    final invoiceDate = dateOnly(input.invoiceDate);
    final explicitDue = input.dueDate == null ? null : dateOnly(input.dueDate!);
    if (explicitDue != null && explicitDue.isBefore(invoiceDate)) {
      throw const ValidationException(
        'dueDate',
        'The due date cannot be before the invoice date',
      );
    }

    final invoice = await _d.transaction.run(() async {
      final supplier = await _d.suppliers.getById(input.supplierId);
      if (supplier == null) {
        throw NotFoundException('supplier', input.supplierId);
      }
      if (supplier.isArchived) {
        throw const ValidationException('supplierId', 'Supplier is archived');
      }
      for (final batchId in input.batchIds) {
        final batch = await _d.batches.getById(batchId);
        if (batch == null) throw NotFoundException('batch', batchId);
        if (batch.invoiceId != null) {
          throw const ValidationException(
            'batchIds',
            'A batch is already on another invoice',
          );
        }
        if (batch.supplierId != null && batch.supplierId != input.supplierId) {
          throw const ValidationException(
            'batchIds',
            'A batch came from a different supplier',
          );
        }
      }
      final now = _d.clock.now();
      final created = Invoice(
        id: _d.newId(),
        supplierId: input.supplierId,
        invoiceNumber: _blank(input.invoiceNumber),
        invoiceDate: invoiceDate,
        dueDate:
            explicitDue ??
            (defaultDueFromTerms
                ? defaultDueDate(invoiceDate, supplier.paymentTermsDays)
                : null),
        total: input.total,
        notes: _blank(input.notes),
        createdAt: now,
        updatedAt: now,
      );
      await _d.ledger.insertInvoice(created);
      await _d.batches.linkInvoice(
        input.batchIds,
        created.id,
        input.supplierId,
        now,
      );
      return created;
    });
    _d.announce();
    return invoice;
  }
}

/// Changes an invoice's details (SUP-4). The total may not drop below what has
/// already been paid or credited.
class EditInvoice {
  EditInvoice(this._d);

  final LedgerDeps _d;

  Future<Invoice> call(
    String invoiceId, {
    required DateTime invoiceDate,
    required Money total,
    DateTime? dueDate,
    String? invoiceNumber,
    String? notes,
  }) async {
    _requirePositive(total, 'total');
    final date = dateOnly(invoiceDate);
    final due = dueDate == null ? null : dateOnly(dueDate);
    if (due != null && due.isBefore(date)) {
      throw const ValidationException(
        'dueDate',
        'The due date cannot be before the invoice date',
      );
    }
    final updated = await _d.transaction.run(() async {
      final current = await _d.ledger.getInvoiceBalance(
        invoiceId,
        today: _d.today,
      );
      if (current == null) throw NotFoundException('invoice', invoiceId);
      final settled = current.paid + current.credited;
      if (total.minor < settled.minor) {
        throw const ValidationException(
          'total',
          'The total cannot be less than what is already paid or credited',
        );
      }
      final invoice = Invoice(
        id: invoiceId,
        supplierId: current.invoice.supplierId,
        invoiceNumber: _blank(invoiceNumber),
        invoiceDate: date,
        dueDate: due,
        total: total,
        notes: _blank(notes),
        remindersSnoozedUntil: current.invoice.remindersSnoozedUntil,
        createdAt: current.invoice.createdAt,
        updatedAt: _d.clock.now(),
      );
      await _d.ledger.updateInvoice(invoice);
      return invoice;
    });
    _d.announce();
    return updated;
  }
}

/// Removes an invoice that has no payments or credits on it. Its batches are
/// detached, not deleted.
class DeleteInvoice {
  DeleteInvoice(this._d);

  final LedgerDeps _d;

  Future<void> call(String invoiceId) async {
    await _d.transaction.run(() async {
      final current = await _d.ledger.getInvoiceBalance(
        invoiceId,
        today: _d.today,
      );
      if (current == null) throw NotFoundException('invoice', invoiceId);
      if (current.hasPayments) throw InvoiceHasPaymentsException(invoiceId);
      final now = _d.clock.now();
      await _d.ledger.softDeleteInvoice(invoiceId, now);
      await _d.batches.unlinkInvoice(invoiceId, now);
    });
    _d.announce();
  }
}

/// Records money paid to a supplier (SUP-5, S4-05).
///
/// With `invoiceId` the payment goes to that invoice. Without it, it is spread
/// over the supplier's open invoices, oldest due first, as one payment row per
/// invoice so the ledger stays simple.
class RecordPayment {
  RecordPayment(this._d);

  final LedgerDeps _d;

  /// Throws [OverpaymentException] if more is paid than is owed, unless
  /// `creditExcess` is set, in which case the excess becomes a credit on the
  /// account. Nothing is written when it throws.
  Future<List<Payment>> call({
    required String supplierId,
    required Money amount,
    required DateTime paidOn,
    String? invoiceId,
    PaymentMethod? method,
    String? reference,
    bool creditExcess = false,
  }) async {
    _requirePositive(amount, 'amount');
    final day = dateOnly(paidOn);
    if (day.isAfter(_d.today)) {
      throw const ValidationException(
        'paidOn',
        'A payment cannot be dated in the future',
      );
    }

    final payments = await _d.transaction.run(() async {
      if (await _d.suppliers.getById(supplierId) == null) {
        throw NotFoundException('supplier', supplierId);
      }
      final List<Allocation> allocations;
      var excess = Money.zero;
      if (invoiceId != null) {
        final inv = await _d.ledger.getInvoiceBalance(
          invoiceId,
          today: _d.today,
        );
        if (inv == null) throw NotFoundException('invoice', invoiceId);
        if (inv.invoice.supplierId != supplierId) {
          throw const ValidationException(
            'invoiceId',
            'That invoice belongs to another supplier',
          );
        }
        final owed = inv.balance;
        if (owed.minor <= 0) {
          throw const ValidationException(
            'invoiceId',
            'That invoice is already paid',
          );
        }
        final applied = amount.minor <= owed.minor ? amount : owed;
        excess = amount - applied;
        allocations = [Allocation(invoiceId, applied)];
      } else {
        final result = allocatePayment(
          amount,
          await _d.ledger.openInvoices(supplierId),
        );
        allocations = result.allocations;
        excess = result.leftover;
      }

      if (excess.minor > 0 && !creditExcess) {
        throw OverpaymentException(owed: amount - excess, excess: excess);
      }

      final now = _d.clock.now();
      final created = <Payment>[];
      for (final a in allocations) {
        final p = Payment(
          id: _d.newId(),
          supplierId: supplierId,
          invoiceId: a.invoiceId,
          amount: a.amount,
          paidOn: day,
          method: method,
          reference: _blank(reference),
          createdAt: now,
        );
        await _d.ledger.insertPayment(p);
        created.add(p);
      }
      if (excess.minor > 0) {
        await _d.ledger.insertCredit(
          Credit(
            id: _d.newId(),
            supplierId: supplierId,
            amount: excess,
            issuedOn: day,
            note: 'Overpayment',
            createdAt: now,
          ),
        );
      }
      return created;
    });
    _d.announce();
    return payments;
  }
}

class DeletePayment {
  DeletePayment(this._d);

  final LedgerDeps _d;

  Future<void> call(String paymentId) async {
    await _d.ledger.softDeletePayment(paymentId, _d.clock.now());
    _d.announce();
  }
}

/// Records a credit note or other reduction of what is owed (SUP-10 basics).
class RecordCredit {
  RecordCredit(this._d);

  final LedgerDeps _d;

  /// Linked to `invoiceId` it reduces that invoice (and may not exceed what it
  /// still owes); without one it is a general credit on the account.
  Future<Credit> call({
    required String supplierId,
    required Money amount,
    required DateTime issuedOn,
    String? invoiceId,
    String? note,
  }) async {
    _requirePositive(amount, 'amount');
    final credit = await _d.transaction.run(() async {
      if (await _d.suppliers.getById(supplierId) == null) {
        throw NotFoundException('supplier', supplierId);
      }
      if (invoiceId != null) {
        final inv = await _d.ledger.getInvoiceBalance(
          invoiceId,
          today: _d.today,
        );
        if (inv == null) throw NotFoundException('invoice', invoiceId);
        if (inv.invoice.supplierId != supplierId) {
          throw const ValidationException(
            'invoiceId',
            'That invoice belongs to another supplier',
          );
        }
        if (amount.minor > inv.balance.minor) {
          throw OverpaymentException(
            owed: inv.balance.minor < 0 ? Money.zero : inv.balance,
            excess: amount - (inv.balance.minor < 0 ? Money.zero : inv.balance),
          );
        }
      }
      final created = Credit(
        id: _d.newId(),
        supplierId: supplierId,
        invoiceId: invoiceId,
        amount: amount,
        issuedOn: dateOnly(issuedOn),
        note: _blank(note),
        createdAt: _d.clock.now(),
      );
      await _d.ledger.insertCredit(created);
      return created;
    });
    _d.announce();
    return credit;
  }
}

class DeleteCredit {
  DeleteCredit(this._d);

  final LedgerDeps _d;

  Future<void> call(String creditId) async {
    await _d.ledger.softDeleteCredit(creditId, _d.clock.now());
    _d.announce();
  }
}

/// Silences payment reminders for one invoice (S4-13). Returns the previous
/// snooze date so the change can be undone.
class UpdateReminderSnooze {
  UpdateReminderSnooze(this._d);

  final LedgerDeps _d;

  Future<DateTime?> snooze(String invoiceId, DateTime until) async {
    final day = dateOnly(until);
    if (day.isBefore(_d.today)) {
      throw const ValidationException(
        'until',
        'Snooze date cannot be in the past',
      );
    }
    return _set(invoiceId, day);
  }

  Future<DateTime?> clear(String invoiceId) => _set(invoiceId, null);

  Future<void> restore(String invoiceId, DateTime? previous) async {
    await _set(invoiceId, previous);
  }

  Future<DateTime?> _set(String invoiceId, DateTime? until) async {
    final invoice = await _d.ledger.getInvoice(invoiceId);
    if (invoice == null) throw NotFoundException('invoice', invoiceId);
    await _d.ledger.setReminderSnooze(invoiceId, until, _d.clock.now());
    _d.announce();
    return invoice.remindersSnoozedUntil;
  }
}
