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
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/delivery_usecases.dart';
import 'package:pharmacy_expiry_tracker/features/common/expiry_input.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

const _draftKey = 'bulk_receive';

String _encodeExpiry(ExpiryDate e) =>
    '${e.toIso()}|${e.precision == ExpiryPrecision.month ? 'm' : 'd'}';

ExpiryDate? _decodeExpiry(String s) {
  if (s.isEmpty) return null;
  try {
    final parts = s.split('|');
    return ExpiryDate.parse(
      parts[0],
      precision: parts.length > 1 && parts[1] == 'm'
          ? ExpiryPrecision.month
          : ExpiryPrecision.day,
    );
  } on FormatException {
    return null;
  }
}

class _Line {
  _Line(this.id, {DraftLine? from})
    : medicineId = from?.medicineId,
      medicineName = from?.medicineName ?? '',
      expiry = _decodeExpiry(from?.expiry ?? ''),
      batch = TextEditingController(text: from?.batchNumber ?? ''),
      qty = TextEditingController(text: from?.quantity ?? ''),
      cost = TextEditingController(text: from?.cost ?? '');

  final int id;
  String? medicineId;
  String medicineName;
  ExpiryDate? expiry;
  final TextEditingController batch;
  final TextEditingController qty;
  final TextEditingController cost;
  String? error;

  DraftLine toDraft() => DraftLine(
    medicineId: medicineId,
    medicineName: medicineName,
    batchNumber: batch.text,
    expiry: expiry == null ? '' : _encodeExpiry(expiry!),
    quantity: qty.text,
    cost: cost.text,
  );

  void dispose() {
    batch.dispose();
    qty.dispose();
    cost.dispose();
  }
}

/// Receive a whole delivery at once (BAT-8): many batches from one supplier,
/// optionally one invoice for the total. Saved atomically, and kept as a draft
/// while it is being typed so an interrupted session can be resumed.
class ReceiveDeliveryScreen extends ConsumerStatefulWidget {
  const ReceiveDeliveryScreen({super.key});

  @override
  ConsumerState<ReceiveDeliveryScreen> createState() =>
      _ReceiveDeliveryScreenState();
}

class _ReceiveDeliveryScreenState extends ConsumerState<ReceiveDeliveryScreen> {
  final _number = TextEditingController();
  final _total = TextEditingController();
  final _lines = <_Line>[];
  int _nextId = 0;
  String? _supplierId;
  DateTime? _received;
  Timer? _saveTimer;
  bool _resumed = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    unawaited(_loadDraft());
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _number.dispose();
    _total.dispose();
    for (final l in _lines) {
      l.dispose();
    }
    super.dispose();
  }

  Future<void> _loadDraft() async {
    final raw = await ref.read(draftStoreProvider).load(_draftKey);
    DeliveryDraft? draft;
    if (raw != null) {
      try {
        draft = DeliveryDraft.fromJson(raw);
      } on Object {
        draft = null; // A damaged draft is dropped, not shown.
      }
    }
    if (!mounted) return;
    setState(() {
      if (draft != null && !draft.isEmpty) {
        _resumed = true;
        _supplierId = draft.supplierId;
        _number.text = draft.invoiceNumber;
        _total.text = draft.invoiceTotal;
        _received = draft.receivedDate;
        for (final l in draft.lines) {
          _lines.add(_Line(_nextId++, from: l));
        }
      }
      if (_lines.isEmpty) _lines.add(_Line(_nextId++));
      _loading = false;
    });
  }

  /// Saves the form as typed, shortly after the last change.
  void _changed() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), () {
      final draft = DeliveryDraft(
        supplierId: _supplierId,
        invoiceNumber: _number.text,
        invoiceTotal: _total.text,
        receivedDate: _received,
        lines: [for (final l in _lines) l.toDraft()],
      );
      final store = ref.read(draftStoreProvider);
      unawaited(
        draft.isEmpty || _onlyBlankLines(draft)
            ? store.clear(_draftKey)
            : store.save(_draftKey, draft.toJson()),
      );
    });
  }

  bool _onlyBlankLines(DeliveryDraft d) =>
      d.supplierId == null &&
      d.invoiceNumber.isEmpty &&
      d.invoiceTotal.isEmpty &&
      d.lines.every(
        (l) =>
            l.medicineId == null &&
            l.batchNumber.isEmpty &&
            l.quantity.isEmpty &&
            l.cost.isEmpty &&
            l.expiry.isEmpty,
      );

  Future<void> _startOver() async {
    _saveTimer?.cancel();
    await ref.read(draftStoreProvider).clear(_draftKey);
    if (!mounted) return;
    setState(() {
      for (final l in _lines) {
        l.dispose();
      }
      _lines
        ..clear()
        ..add(_Line(_nextId++));
      _supplierId = null;
      _number.clear();
      _total.clear();
      _received = null;
      _resumed = false;
      _error = null;
    });
  }

  Future<void> _chooseMedicine(_Line line) async {
    final id = await context.push<String>('${Routes.stock}/pick?choose=1');
    if (id == null || !mounted) return;
    final m = await ref.read(medicineRepositoryProvider).getById(id);
    if (m == null || !mounted) return;
    setState(() {
      line
        ..medicineId = id
        ..medicineName = m.displayName
        ..error = null;
    });
    _changed();
  }

  /// Turns the form into a delivery, marking lines that cannot be read.
  DeliveryInput _build() {
    final l10n = AppLocalizations.of(context);
    var ok = true;
    final lines = <DeliveryLine>[];
    final index = <int>[]; // delivery line -> form line
    for (var i = 0; i < _lines.length; i++) {
      final l = _lines[i]..error = null;
      final blank =
          l.medicineId == null &&
          l.batch.text.trim().isEmpty &&
          l.qty.text.trim().isEmpty &&
          l.expiry == null;
      if (blank && _lines.length > 1) continue; // an untouched spare line
      final qty = int.tryParse(l.qty.text.trim());
      final cost = l.cost.text.trim().isEmpty
          ? null
          : Money.tryParse(l.cost.text);
      if (l.medicineId == null) {
        l.error = l10n.receiveNeedMedicine;
      } else if (l.expiry == null) {
        l.error = l10n.receiveNeedExpiry;
      } else if (qty == null) {
        l.error = l10n.errPositiveInt;
      } else if (l.cost.text.trim().isNotEmpty && cost == null) {
        l.error = l10n.errAmountInvalid;
      }
      if (l.error != null) {
        ok = false;
        continue;
      }
      lines.add(
        DeliveryLine(
          medicineId: l.medicineId!,
          batchNumber: l.batch.text,
          expiry: l.expiry!,
          quantity: qty!,
          costPrice: cost,
        ),
      );
      index.add(i);
    }
    Money? total;
    if (_total.text.trim().isNotEmpty) {
      total = Money.tryParse(_total.text);
      if (total == null || total.minor <= 0) {
        _error = l10n.receiveBadTotal;
        ok = false;
      }
    }
    _lineIndex = index;
    _localErrors = !ok;
    return DeliveryInput(
      receivedDate: _received ?? ref.read(todayDateProvider),
      supplierId: _supplierId,
      invoiceTotal: total,
      invoiceNumber: _number.text,
      lines: lines,
    );
  }

  List<int> _lineIndex = const [];
  bool _localErrors = false;

  Future<void> _save() async {
    if (_saving) return;
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);
    final input = _build();
    // Check everything we can without writing, so the user sees all problems
    // at once, including those on lines that are otherwise complete.
    final problems = input.lines.isEmpty && _localErrors
        ? <LineProblem>[]
        : validateDelivery(input);
    if (problems.isNotEmpty || _localErrors) {
      setState(() => _showProblems(problems, l10n));
      return;
    }
    setState(() => _saving = true);
    try {
      final result = await ref.read(receiveDeliveryProvider).call(input);
      _saveTimer?.cancel();
      await ref.read(draftStoreProvider).clear(_draftKey);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.receiveSaved(result.batches.length))),
      );
      context.pop(true);
    } on DeliveryInvalidException catch (e) {
      if (mounted) setState(() => _showProblems(e.problems, l10n));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showProblems(List<LineProblem> problems, AppLocalizations l10n) {
    for (final p in problems) {
      if (p.index < 0) {
        _error = switch (p.field) {
          'lines' => l10n.receiveNeedLines,
          'supplier' => l10n.receiveNeedSupplier,
          'total' => l10n.receiveBadTotal,
          _ => p.message,
        };
      } else if (p.index < _lineIndex.length) {
        _lines[_lineIndex[p.index]].error = p.message;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final today = ref.watch(todayDateProvider);
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
      appBar: AppBar(title: Text(l10n.receiveDeliveryTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_resumed)
                  Card(
                    key: const Key('receive-draft-banner'),
                    color: theme.colorScheme.secondaryContainer,
                    child: ListTile(
                      leading: const Icon(Icons.edit_note),
                      title: Text(l10n.receiveDraftBanner),
                      trailing: TextButton(
                        key: const Key('receive-start-over'),
                        onPressed: _startOver,
                        child: Text(l10n.receiveDiscardDraft),
                      ),
                    ),
                  ),
                DropdownButtonFormField<String?>(
                  key: const Key('receive-supplier'),
                  initialValue:
                      suppliers.any((s) => s.supplier.id == _supplierId)
                      ? _supplierId
                      : null,
                  decoration: InputDecoration(
                    labelText: l10n.receiveSupplier,
                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(child: Text(l10n.receiveNoSupplier)),
                    for (final s in suppliers)
                      DropdownMenuItem(
                        value: s.supplier.id,
                        child: Text(s.supplier.name),
                      ),
                  ],
                  onChanged: (v) {
                    setState(() => _supplierId = v);
                    _changed();
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('receive-number'),
                        controller: _number,
                        onChanged: (_) => _changed(),
                        decoration: InputDecoration(
                          labelText: l10n.receiveInvoiceNumber,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        key: const Key('receive-total'),
                        controller: _total,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                        ],
                        onChanged: (_) => _changed(),
                        decoration: InputDecoration(
                          labelText: l10n.receiveInvoiceTotal,
                          prefixText: currency.isEmpty ? null : '$currency ',
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Text(
                    l10n.receiveInvoiceHelp,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                ListTile(
                  key: const Key('receive-date'),
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event),
                  title: Text(l10n.receiveDate),
                  subtitle: Text(formatDate(context, _received ?? today)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _received ?? today,
                      firstDate: DateTime(today.year - 1),
                      lastDate: today,
                    );
                    if (picked != null) {
                      setState(() => _received = picked);
                      _changed();
                    }
                  },
                ),
                const Divider(),
                for (var i = 0; i < _lines.length; i++)
                  _lineCard(context, i, today, l10n),
                TextButton.icon(
                  key: const Key('receive-add-line'),
                  onPressed: () {
                    setState(() => _lines.add(_Line(_nextId++)));
                    _changed();
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l10n.receiveAddLine),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _error!,
                      key: const Key('receive-error'),
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('receive-save'),
                  onPressed: _saving ? null : _save,
                  child: Text(l10n.receiveSave),
                ),
              ],
            ),
    );
  }

  Widget _lineCard(
    BuildContext context,
    int i,
    DateTime today,
    AppLocalizations l10n,
  ) {
    final l = _lines[i];
    final theme = Theme.of(context);
    return Card(
      key: ValueKey('receive-line-${l.id}'),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.receiveLineNumber(i + 1),
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                if (_lines.length > 1)
                  IconButton(
                    key: Key('receive-remove-$i'),
                    tooltip: l10n.receiveLineRemove,
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() => _lines.removeAt(i).dispose());
                      _changed();
                    },
                  ),
              ],
            ),
            OutlinedButton(
              key: Key('receive-medicine-$i'),
              onPressed: () => _chooseMedicine(l),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l.medicineId == null
                      ? l10n.receiveLineChoose
                      : l.medicineName,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: Key('receive-batch-$i'),
              controller: l.batch,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) => _changed(),
              decoration: InputDecoration(
                labelText: l10n.receiveLineBatch,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            ExpiryInput(
              key: ValueKey('receive-expiry-${l.id}'),
              today: today,
              initial: l.expiry,
              onChanged: (v) {
                l.expiry = v;
                _changed();
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: Key('receive-qty-$i'),
                    controller: l.qty,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => _changed(),
                    decoration: InputDecoration(
                      labelText: l10n.receiveLineQuantity,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    key: Key('receive-cost-$i'),
                    controller: l.cost,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.,]')),
                    ],
                    onChanged: (_) => _changed(),
                    decoration: InputDecoration(
                      labelText: l10n.receiveLineCost,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            if (l.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l.error!,
                  key: Key('receive-line-error-$i'),
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
