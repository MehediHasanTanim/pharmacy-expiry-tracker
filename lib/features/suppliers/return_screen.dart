import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier_return.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/invoice_rules.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/common/share_text.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// What the return screen opens with.
class ReturnArgs {
  const ReturnArgs({this.supplierId, this.batchIds = const []});

  final String? supplierId;

  /// Batches already chosen (from the Expiry tab); empty to pick from the
  /// supplier's stock.
  final List<String> batchIds;
}

class _Line {
  _Line(this.item, {required bool selected, required int quantity})
    : selected = selected,
      qty = TextEditingController(text: '$quantity');

  final BatchWithMedicine item;
  bool selected;
  final TextEditingController qty;

  int get stock => item.batch.quantityOnHand;
  int? get quantity => int.tryParse(qty.text.trim());
  bool get valid => quantity != null && quantity! > 0 && quantity! <= stock;
}

/// Send stock back to a supplier, with an optional credit (SUP-10).
class ReturnScreen extends ConsumerStatefulWidget {
  const ReturnScreen({this.args = const ReturnArgs(), super.key});

  final ReturnArgs args;

  @override
  ConsumerState<ReturnScreen> createState() => _ReturnScreenState();
}

class _ReturnScreenState extends ConsumerState<ReturnScreen> {
  final _credit = TextEditingController();
  final _note = TextEditingController();
  final _lines = <_Line>[];
  String? _supplierId;
  String? _creditInvoiceId;
  List<OpenInvoice> _openInvoices = const [];
  bool _creditEdited = false;
  bool _loading = true;
  bool _saving = false;
  bool _mismatch = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _supplierId = widget.args.supplierId;
    unawaited(_load());
  }

  @override
  void dispose() {
    _credit.dispose();
    _note.dispose();
    for (final l in _lines) {
      l.qty.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final batches = ref.read(batchRepositoryProvider);
    final medicines = ref.read(medicineRepositoryProvider);
    final picked = <BatchWithMedicine>[];
    for (final id in widget.args.batchIds) {
      final b = await batches.getById(id);
      if (b == null || b.quantityOnHand == 0) continue;
      final m = await medicines.getById(b.medicineId);
      if (m != null) picked.add(BatchWithMedicine(batch: b, medicine: m));
    }
    if (_supplierId == null && picked.isNotEmpty) {
      // One clear supplier among the chosen batches is the default.
      final ids = picked.map((p) => p.batch.supplierId).whereType<String>();
      final distinct = ids.toSet();
      if (distinct.length == 1) _supplierId = distinct.single;
    }
    if (!mounted) return;
    _preselected = picked;
    await _applySupplier();
  }

  List<BatchWithMedicine> _preselected = const [];

  /// Rebuilds the lines for the current supplier.
  Future<void> _applySupplier() async {
    final id = _supplierId;
    final items = <BatchWithMedicine>[];
    var mismatch = false;
    var preselect = false;
    if (_preselected.isNotEmpty) {
      preselect = true;
      for (final p in _preselected) {
        final from = p.batch.supplierId;
        if (id == null || from == null || from == id) {
          items.add(p);
        } else {
          mismatch = true;
        }
      }
    } else if (id != null) {
      final all = await ref
          .read(batchRepositoryProvider)
          .watchAllActive()
          .first;
      items.addAll(
        all.where(
          (b) => b.batch.supplierId == id && b.batch.quantityOnHand > 0,
        ),
      );
    }
    final invoices = id == null
        ? const <OpenInvoice>[]
        : await ref.read(ledgerRepositoryProvider).openInvoices(id);
    if (!mounted) return;
    setState(() {
      for (final l in _lines) {
        l.qty.dispose();
      }
      _lines
        ..clear()
        ..addAll([
          for (final i in items)
            _Line(i, selected: preselect, quantity: i.batch.quantityOnHand),
        ]);
      _openInvoices = invoices;
      _creditInvoiceId = null;
      _mismatch = mismatch;
      _loading = false;
    });
    _prefillCredit();
  }

  /// The cost of what is being returned, as the default credit.
  void _prefillCredit() {
    if (_creditEdited) return;
    var total = 0;
    var any = false;
    for (final l in _lines) {
      final cost = l.item.batch.costPrice;
      if (l.selected && l.valid && cost != null) {
        total += cost.times(l.quantity!).minor;
        any = true;
      }
    }
    _credit.text = any ? Money(total).format() : '';
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final currency = ref.read(currencySymbolProvider);
    final chosen = _lines.where((l) => l.selected).toList();
    if (_supplierId == null || chosen.isEmpty) {
      setState(() => _error = l10n.returnNeedLines);
      return;
    }
    if (chosen.any((l) => !l.valid)) {
      setState(() => _error = l10n.returnBadQuantity);
      return;
    }
    Money? credit;
    if (_credit.text.trim().isNotEmpty) {
      credit = Money.tryParse(_credit.text);
      if (credit == null || credit.minor <= 0) {
        setState(() => _error = l10n.returnBadCredit);
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await ref
          .read(returnToSupplierProvider)
          .call(
            supplierId: _supplierId!,
            returnedOn: ref.read(todayDateProvider),
            note: _note.text,
            credit: credit,
            creditInvoiceId: credit == null ? null : _creditInvoiceId,
            lines: [
              for (final l in chosen)
                ReturnLineInput(l.item.batch.id, l.quantity!),
            ],
          );
      if (!mounted) return;
      await _done(result.ret.id);
    } on OverpaymentException catch (e) {
      if (mounted) {
        setState(
          () => _error = l10n.creditTooMuch(e.owed.format(symbol: currency)),
        );
      }
    } on InsufficientStockException {
      if (mounted) setState(() => _error = l10n.returnBadQuantity);
    } on ValidationException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _done(String returnId) async {
    final l10n = AppLocalizations.of(context);
    final share = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.returnDone),
        actions: [
          TextButton(
            key: const Key('return-finish'),
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.actionClose),
          ),
          FilledButton.icon(
            key: const Key('return-share'),
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.ios_share),
            label: Text(l10n.returnShare),
          ),
        ],
      ),
    );
    if ((share ?? false) && mounted) {
      await shareReturn(ref, l10n, returnId, context);
    }
    if (mounted) context.pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final suppliers =
        ref
            .watch(
              supplierListProvider((
                query: '',
                includeArchived: false,
                sort: SupplierSort.name,
              )),
            )
            .value ??
        const [];
    final currency = ref.watch(currencySymbolProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.returnTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  key: const Key('return-supplier'),
                  initialValue:
                      suppliers.any((s) => s.supplier.id == _supplierId)
                      ? _supplierId
                      : null,
                  decoration: InputDecoration(
                    labelText: l10n.returnSupplier,
                    border: const OutlineInputBorder(),
                  ),
                  hint: Text(l10n.returnPickSupplier),
                  items: [
                    for (final s in suppliers)
                      DropdownMenuItem(
                        value: s.supplier.id,
                        child: Text(s.supplier.name),
                      ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _supplierId = v;
                      _creditEdited = false;
                    });
                    unawaited(_applySupplier());
                  },
                ),
                if (_mismatch)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.returnSupplierMismatch,
                      key: const Key('return-mismatch'),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(l10n.returnLinesTitle, style: theme.textTheme.titleMedium),
                if (_lines.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      _supplierId == null
                          ? l10n.returnPickSupplier
                          : l10n.returnNoLines,
                      key: const Key('return-empty'),
                    ),
                  ),
                for (final l in _lines) _lineTile(context, l, l10n),
                const SizedBox(height: 16),
                TextField(
                  key: const Key('return-credit'),
                  controller: _credit,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                  ],
                  onChanged: (_) => _creditEdited = true,
                  decoration: InputDecoration(
                    labelText: l10n.returnCredit,
                    helperText: l10n.returnCreditHelp,
                    prefixText: currency.isEmpty ? null : '$currency ',
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_openInvoices.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String?>(
                    key: const Key('return-credit-invoice'),
                    initialValue: _creditInvoiceId,
                    decoration: InputDecoration(
                      labelText: l10n.returnCreditInvoice,
                      border: const OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem(child: Text(l10n.returnCreditAccount)),
                      for (final i in _openInvoices)
                        DropdownMenuItem(
                          value: i.id,
                          child: Text(
                            '${formatDate(context, i.invoiceDate)} · '
                            '${i.balance.format(symbol: currency)}',
                          ),
                        ),
                    ],
                    onChanged: (v) => setState(() => _creditInvoiceId = v),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  key: const Key('return-note'),
                  controller: _note,
                  decoration: InputDecoration(
                    labelText: l10n.returnNote,
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _error!,
                      key: const Key('return-error'),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('return-save'),
                  onPressed: _saving ? null : _save,
                  child: Text(l10n.returnSave),
                ),
              ],
            ),
    );
  }

  Widget _lineTile(BuildContext context, _Line l, AppLocalizations l10n) {
    final b = l.item.batch;
    return Card(
      key: Key('return-line-${b.batchNumber}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
        child: Row(
          children: [
            Checkbox(
              key: Key('return-check-${b.batchNumber}'),
              value: l.selected,
              onChanged: (v) => setState(() {
                l.selected = v ?? false;
                _prefillCredit();
              }),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.item.medicine.displayName),
                  Text(
                    '${l10n.batchBy(b.batchNumber)} · '
                    '${formatDate(context, b.expiry.date)} · '
                    '${l10n.returnLineLeft(l.stock)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 80,
              child: TextField(
                key: Key('return-qty-${b.batchNumber}'),
                controller: l.qty,
                enabled: l.selected,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(_prefillCredit),
                decoration: InputDecoration(
                  labelText: l10n.returnQuantity,
                  errorText: l.selected && !l.valid ? '' : null,
                  errorStyle: const TextStyle(height: 0),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Builds and shares the return list for [returnId] (SUP-10).
Future<void> shareReturn(
  WidgetRef ref,
  AppLocalizations l10n,
  String returnId,
  BuildContext context,
) async {
  final view = await ref.read(returnRepositoryProvider).getView(returnId);
  if (view == null || !context.mounted) return;
  final currency = ref.read(currencySymbolProvider);
  if (!context.mounted) return;
  final text = buildReturnText(
    l10n,
    supplierName: view.supplierName,
    date: formatDate(context, view.returnedOn),
    view: view,
    money: (minor) => Money(minor).format(symbol: currency),
  );
  await ref
      .read(fileExchangeProvider)
      .shareText(text, subject: l10n.returnShareSubject(view.supplierName));
}
