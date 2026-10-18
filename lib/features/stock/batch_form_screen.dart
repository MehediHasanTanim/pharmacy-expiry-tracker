import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/batch_usecases.dart';
import 'package:pharmacy_expiry_tracker/features/common/expiry_input.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/stock/stock_providers.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/invoice_form_screen.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Receive a batch ([batchId] null, for [medicineId]) or edit one ([batchId]
/// set). Built for speed: expiry as `MM / YYYY`, remembered received date,
/// and "Save & add another".
class BatchFormScreen extends ConsumerStatefulWidget {
  const BatchFormScreen({this.medicineId, this.batchId, super.key})
    : assert(
        (medicineId == null) != (batchId == null),
        'Pass exactly one of medicineId or batchId',
      );

  final String? medicineId;
  final String? batchId;

  @override
  ConsumerState<BatchFormScreen> createState() => _BatchFormScreenState();
}

class _BatchFormScreenState extends ConsumerState<BatchFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _quantity = TextEditingController();
  final _cost = TextEditingController();
  final _selling = TextEditingController();
  final _numberFocus = FocusNode();

  Batch? _existing;
  bool _loading = false;
  bool _saving = false;
  ExpiryDate? _expiry;
  String? _expiryError;
  DateTime? _received;
  // Bumped to rebuild ExpiryInput with empty fields after "Save & add another".
  int _expiryResetCount = 0;
  String? _supplierId;
  bool _supplierTouched = false;
  // Batches received in this sitting, so one invoice can cover the delivery.
  final _delivery = <_Received>[];

  bool get _isEdit => widget.batchId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loading = true;
      unawaited(_load());
    } else {
      _received = ref.read(lastReceivedDateProvider);
      _supplierId = ref.read(lastSupplierProvider);
      unawaited(_preferredSupplier());
    }
  }

  /// A medicine's preferred supplier is the default for its new batches,
  /// unless the user has already picked one.
  Future<void> _preferredSupplier() async {
    final m = await ref
        .read(medicineRepositoryProvider)
        .getById(widget.medicineId!);
    if (!mounted || _supplierTouched) return;
    final preferred = m?.preferredSupplierId;
    if (preferred != null) setState(() => _supplierId = preferred);
  }

  Future<void> _load() async {
    final b = await ref.read(batchRepositoryProvider).getById(widget.batchId!);
    if (!mounted) return;
    if (b != null) {
      _number.text = b.batchNumber;
      _quantity.text = b.quantityOnHand.toString();
      _cost.text = _moneyText(b.costPrice);
      _selling.text = _moneyText(b.sellingPrice);
      _expiry = b.expiry;
      _received = b.receivedDate;
      _supplierId = b.supplierId;
    }
    setState(() {
      _existing = b;
      _loading = false;
    });
  }

  static String _moneyText(Money? m) => m == null
      ? ''
      : '${m.minor ~/ 100}.${(m.minor % 100).toString().padLeft(2, '0')}';

  @override
  void dispose() {
    for (final c in [_number, _quantity, _cost, _selling]) {
      c.dispose();
    }
    _numberFocus.dispose();
    super.dispose();
  }

  String get _medicineId => widget.medicineId ?? _existing!.medicineId;

  String? _priceValidator(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final m = Money.tryParse(t);
    return m == null || m.isNegative
        ? AppLocalizations.of(context).errPrice
        : null;
  }

  Money? _price(TextEditingController c) {
    final t = c.text.trim();
    return t.isEmpty ? null : Money.tryParse(t);
  }

  Future<void> _pickReceived() async {
    final today = ref.read(todayDateProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: _received ?? today,
      firstDate: DateTime(2000),
      lastDate: today,
    );
    if (picked != null) setState(() => _received = picked);
  }

  Future<void> _save({required bool another}) async {
    final l10n = AppLocalizations.of(context);
    final formOk = _formKey.currentState!.validate();
    setState(
      () => _expiryError = _expiry == null ? l10n.errExpiryRequired : null,
    );
    if (!formOk || _expiry == null || _saving) return;

    final today = ref.read(todayDateProvider);
    final received = _received ?? today;
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await ref
            .read(editBatchProvider)
            .call(
              widget.batchId!,
              BatchEdit(
                batchNumber: _number.text,
                expiry: _expiry!,
                receivedDate: received,
                costPrice: _price(_cost),
                sellingPrice: _price(_selling),
                supplierId: _supplierId,
                notes: _existing?.notes,
              ),
            );
        if (mounted) context.pop();
        return;
      }
      final input = BatchInput(
        medicineId: _medicineId,
        batchNumber: _number.text,
        expiry: _expiry!,
        quantity: int.parse(_quantity.text.trim()),
        receivedDate: received,
        costPrice: _price(_cost),
        sellingPrice: _price(_selling),
        supplierId: _supplierId,
      );
      final result = await _addWithDuplicateHandling(input);
      if (result == null || !mounted) return;
      ref.read(lastReceivedDateProvider.notifier).remember(received);
      ref.read(lastSupplierProvider.notifier).remember(_supplierId);
      if (_supplierId != null && !result.merged) {
        _delivery.add(
          _Received(
            batchId: result.batch.id,
            supplierId: _supplierId!,
            value: input.costPrice?.times(input.quantity),
          ),
        );
      }
      if (result.merged) _snack(l10n.batchMergedInfo);
      if (another) {
        _resetForNext();
        if (!result.merged) _snack(l10n.batchSaved);
      } else {
        await _offerInvoice();
        if (mounted) context.pop();
      }
    } on DuplicateBatchException {
      if (mounted) _snack(l10n.duplicateBatchExact);
    } on ValidationException catch (e) {
      if (mounted) _snack(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Offers to record what the delivery cost as an amount owed (BAT-8 lite):
  /// one prompt per supplier among the batches received in this sitting.
  Future<void> _offerInvoice() async {
    final l10n = AppLocalizations.of(context);
    final groups = <String, List<_Received>>{};
    for (final r in _delivery) {
      groups.putIfAbsent(r.supplierId, () => []).add(r);
    }
    _delivery.clear();
    for (final entry in groups.entries) {
      if (!mounted) return;
      final supplier = await ref
          .read(supplierRepositoryProvider)
          .getById(entry.key);
      if (supplier == null || supplier.isArchived || !mounted) continue;
      final yes = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.dueDialogTitle),
          content: Text(l10n.dueDialogBody(supplier.name)),
          actions: [
            TextButton(
              key: const Key('due-no'),
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.dueDialogNo),
            ),
            FilledButton(
              key: const Key('due-yes'),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.dueDialogYes),
            ),
          ],
        ),
      );
      if (yes != true || !mounted) continue;
      final priced = entry.value.every((r) => r.value != null);
      final total = priced
          ? Money(entry.value.fold<int>(0, (a, r) => a + r.value!.minor))
          : null;
      await context.push(
        '${Routes.suppliers}/${entry.key}/invoice/new',
        extra: InvoiceFormArgs(
          batchIds: [for (final r in entry.value) r.batchId],
          suggestedTotal: total,
        ),
      );
    }
  }

  /// Ends a run of "Save & add another" without adding one more.
  Future<void> _finish() async {
    await _offerInvoice();
    if (mounted) context.pop();
  }

  /// Adds the batch, asking the user how to proceed when the medicine already
  /// has that batch number. Null means the user cancelled.
  Future<AddBatchResult?> _addWithDuplicateHandling(BatchInput input) async {
    final add = ref.read(addBatchProvider);
    try {
      return await add(input);
    } on DuplicateBatchException catch (e) {
      if (!mounted) return null;
      final choice = await _askDuplicate(e);
      if (choice == null) return null;
      if (choice == _DuplicateChoice.separate) {
        return await add(input, onDuplicate: DuplicateResolution.separate);
      }
      final target = e.existing.firstWhere(
        (b) => b.expiry.toIso() == input.expiry.toIso(),
        orElse: () => e.existing.first,
      );
      return await add(
        input,
        onDuplicate: DuplicateResolution.mergeInto(target.id),
      );
    }
  }

  Future<_DuplicateChoice?> _askDuplicate(DuplicateBatchException e) {
    final l10n = AppLocalizations.of(context);
    return showDialog<_DuplicateChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.duplicateBatchTitle),
        content: Text(
          e.exactMatch ? l10n.duplicateBatchExact : l10n.duplicateBatchDiffers,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.actionCancel),
          ),
          // A separate batch needs a different expiry; offer it only then.
          if (!e.exactMatch)
            TextButton(
              key: const Key('duplicate-separate'),
              onPressed: () => Navigator.pop(ctx, _DuplicateChoice.separate),
              child: Text(l10n.duplicateBatchSeparate),
            ),
          FilledButton(
            key: const Key('duplicate-merge'),
            onPressed: () => Navigator.pop(ctx, _DuplicateChoice.merge),
            child: Text(l10n.duplicateBatchAddTo),
          ),
        ],
      ),
    );
  }

  void _resetForNext() {
    _number.clear();
    _quantity.clear();
    setState(() {
      _expiry = null;
      _expiryError = null;
      _expiryResetCount++;
    });
    _formKey.currentState?.reset();
    _numberFocus.requestFocus();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayDateProvider);
    final suppliers = ref.watch(activeSuppliersProvider).value ?? const [];
    final medicineId = _loading ? null : _medicineId;
    final medicine = medicineId == null
        ? null
        : ref.watch(medicineProvider(medicineId)).value;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? l10n.batchEdit : l10n.batchNew)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (medicine != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        medicine.displayName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  TextFormField(
                    key: const Key('field-batch-number'),
                    controller: _number,
                    focusNode: _numberFocus,
                    autofocus: !_isEdit,
                    textCapitalization: TextCapitalization.characters,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.fieldBatchNumber,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l10n.errBatchRequired : null,
                  ),
                  const SizedBox(height: 16),
                  ExpiryInput(
                    key: ValueKey('expiry-$_expiryResetCount'),
                    today: today,
                    initial: _expiry,
                    errorText: _expiryError,
                    onChanged: (v) => setState(() {
                      _expiry = v;
                      if (v != null) _expiryError = null;
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('field-quantity'),
                    controller: _quantity,
                    enabled: !_isEdit,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.fieldQuantity,
                      helperText: _isEdit ? l10n.quantityLockedHint : null,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) {
                      final n = int.tryParse((v ?? '').trim());
                      return n == null || n <= 0
                          ? l10n.errQuantityRequired
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('field-cost'),
                          controller: _cost,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.fieldCostPrice,
                            border: const OutlineInputBorder(),
                          ),
                          validator: _priceValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const Key('field-selling'),
                          controller: _selling,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.fieldSellingPrice,
                            border: const OutlineInputBorder(),
                          ),
                          validator: _priceValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    key: const Key('field-received'),
                    onTap: _pickReceived,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.fieldReceivedDate,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                      ),
                      child: Text(formatDate(context, _received ?? today)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    key: const Key('field-batch-supplier'),
                    child: DropdownButtonFormField<String?>(
                      key: ValueKey(
                        'supplier-$_supplierId-${suppliers.length}',
                      ),
                      initialValue: suppliers.any((s) => s.id == _supplierId)
                          ? _supplierId
                          : null,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.fieldSupplier,
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem<String?>(
                          child: Text(l10n.supplierNone),
                        ),
                        for (final s in suppliers)
                          DropdownMenuItem<String?>(
                            value: s.id,
                            child: Text(
                              s.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() {
                        _supplierId = v;
                        _supplierTouched = true;
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('batch-save'),
                    onPressed: _saving ? null : () => _save(another: false),
                    child: Text(l10n.actionSave),
                  ),
                  if (!_isEdit) ...[
                    const SizedBox(height: 8),
                    OutlinedButton(
                      key: const Key('batch-save-another'),
                      onPressed: _saving ? null : () => _save(another: true),
                      child: Text(l10n.saveAndAddAnother),
                    ),
                    if (_delivery.isNotEmpty)
                      TextButton(
                        key: const Key('batch-done'),
                        onPressed: _saving ? null : _finish,
                        child: Text(l10n.batchDone),
                      ),
                  ],
                ],
              ),
            ),
    );
  }
}

enum _DuplicateChoice { merge, separate }

/// A batch received in this sitting, remembered so one invoice can cover it.
class _Received {
  const _Received({
    required this.batchId,
    required this.supplierId,
    required this.value,
  });

  final String batchId;
  final String supplierId;

  /// Cost of the batch, or null when no cost price was entered.
  final Money? value;
}
