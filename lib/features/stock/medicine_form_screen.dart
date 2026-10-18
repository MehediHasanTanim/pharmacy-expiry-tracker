import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/scan/scan_flow.dart';
import 'package:pharmacy_expiry_tracker/features/suppliers/suppliers_providers.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Create ([medicineId] null) or edit a medicine (MED-1, MED-2, MED-5, MED-6).
/// Pops with the saved medicine's id.
class MedicineFormScreen extends ConsumerStatefulWidget {
  const MedicineFormScreen({this.medicineId, this.barcode, super.key});

  final String? medicineId;

  /// A scanned barcode to link to the medicine once it is saved.
  final String? barcode;

  @override
  ConsumerState<MedicineFormScreen> createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends ConsumerState<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brand = TextEditingController();
  final _generic = TextEditingController();
  final _strength = TextEditingController();
  final _packSize = TextEditingController();
  final _manufacturer = TextEditingController();
  final _category = TextEditingController();
  final _reorder = TextEditingController(text: '0');
  final _window = TextEditingController();
  final _notes = TextEditingController();
  DosageForm _form = DosageForm.tablet;
  StockUnit _unit = StockUnit.strip;
  Medicine? _existing;
  String? _preferredSupplierId;
  // The saved preferred supplier, which may be archived and so not listed.
  Supplier? _preferredSaved;
  bool _loading = false;
  bool _saving = false;

  bool get _isEdit => widget.medicineId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loading = true;
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final m = await ref
        .read(medicineRepositoryProvider)
        .getById(widget.medicineId!);
    if (!mounted) return;
    if (m != null) {
      _brand.text = m.brandName;
      _generic.text = m.genericName ?? '';
      _strength.text = m.strength ?? '';
      _packSize.text = m.packSize?.toString() ?? '';
      _manufacturer.text = m.manufacturer ?? '';
      _category.text = m.category ?? '';
      _reorder.text = m.reorderLevel.toString();
      _window.text = m.alertWindowDays?.toString() ?? '';
      _notes.text = m.notes ?? '';
      _form = m.dosageForm;
      _unit = m.unit;
      _preferredSupplierId = m.preferredSupplierId;
      if (_preferredSupplierId != null) {
        _preferredSaved = await ref
            .read(supplierRepositoryProvider)
            .getById(_preferredSupplierId!);
      }
    }
    setState(() {
      _existing = m;
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _brand,
      _generic,
      _strength,
      _packSize,
      _manufacturer,
      _category,
      _reorder,
      _window,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  MedicineInput _input() {
    final base = _existing?.toInput();
    return MedicineInput(
      brandName: _brand.text,
      genericName: _generic.text,
      strength: _strength.text,
      dosageForm: _form,
      unit: _unit,
      packSize: int.tryParse(_packSize.text.trim()),
      manufacturer: _manufacturer.text,
      category: _category.text,
      reorderLevel: int.tryParse(_reorder.text.trim()) ?? 0,
      // Fields without a form control yet are carried over unchanged.
      preferredSupplierId: _preferredSupplierId,
      alertWindowDays: int.tryParse(_window.text.trim()),
      storageCondition: base?.storageCondition,
      notes: _notes.text,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    final l10n = AppLocalizations.of(context);
    final input = _input();
    setState(() => _saving = true);
    try {
      final dup = await ref
          .read(medicineRepositoryProvider)
          .findDuplicate(
            brandName: input.brandName,
            strength: input.strength,
            dosageForm: input.dosageForm,
            excludeId: widget.medicineId,
          );
      if (dup != null && mounted) {
        final choice = await showDialog<_DuplicateChoice>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.duplicateMedicineTitle),
            content: Text(l10n.duplicateMedicineBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, _DuplicateChoice.cancel),
                child: Text(l10n.actionCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, _DuplicateChoice.view),
                child: Text(l10n.duplicateViewExisting),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(ctx, _DuplicateChoice.saveAnyway),
                child: Text(l10n.duplicateSaveAnyway),
              ),
            ],
          ),
        );
        if (!mounted) return;
        if (choice == _DuplicateChoice.view) {
          await context.push('${Routes.stock}/medicine/${dup.id}');
          return;
        }
        if (choice != _DuplicateChoice.saveAnyway) return;
      }
      final id = await ref
          .read(saveMedicineProvider)
          .call(input, id: widget.medicineId);
      if (widget.barcode != null && mounted) {
        // Best effort: the medicine is saved even if the barcode is refused.
        await linkBarcode(context, ref, id, widget.barcode!);
      }
      if (mounted) context.pop(id);
    } on ValidationException catch (e) {
      if (mounted) _showError(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleArchive() async {
    final l10n = AppLocalizations.of(context);
    final m = _existing!;
    if (!m.isArchived) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.medicineArchiveTitle),
          content: Text(l10n.medicineArchiveBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.actionArchive),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await ref
        .read(setMedicineArchivedProvider)
        .call(m.id, archived: !m.isArchived);
    if (mounted) context.pop(m.id);
  }

  String? _requiredInt(String? v, {required bool allowZero}) {
    final l10n = AppLocalizations.of(context);
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n == null || n < (allowZero ? 0 : 1)) {
      return allowZero ? l10n.errNonNegativeInt : l10n.errPositiveInt;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.medicineEdit : l10n.medicineNew),
        actions: [
          if (_existing != null)
            IconButton(
              key: const Key('medicine-archive'),
              tooltip: _existing!.isArchived
                  ? l10n.actionRestore
                  : l10n.actionArchive,
              icon: Icon(
                _existing!.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
              ),
              onPressed: _toggleArchive,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    key: const Key('field-brand'),
                    controller: _brand,
                    autofocus: !_isEdit,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.fieldBrandName,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v ?? '').trim().isEmpty ? l10n.errBrandRequired : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('field-generic'),
                    controller: _generic,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.fieldGenericName,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('field-strength'),
                    controller: _strength,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.fieldStrength,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<DosageForm>(
                          key: const Key('field-form'),
                          initialValue: _form,
                          decoration: InputDecoration(
                            labelText: l10n.fieldDosageForm,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            for (final f in DosageForm.values)
                              DropdownMenuItem(
                                value: f,
                                child: Text(dosageFormLabel(l10n, f)),
                              ),
                          ],
                          onChanged: (v) => setState(() => _form = v ?? _form),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<StockUnit>(
                          key: const Key('field-unit'),
                          initialValue: _unit,
                          decoration: InputDecoration(
                            labelText: l10n.fieldUnit,
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            for (final u in StockUnit.values)
                              DropdownMenuItem(
                                value: u,
                                child: Text(unitLabel(l10n, u)),
                              ),
                          ],
                          onChanged: (v) => setState(() => _unit = v ?? _unit),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: const Key('field-reorder'),
                          controller: _reorder,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.fieldReorderLevel,
                            helperText: l10n.fieldReorderHelp,
                            helperMaxLines: 2,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => _requiredInt(v, allowZero: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          key: const Key('field-pack-size'),
                          controller: _packSize,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: l10n.fieldPackSize,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) => _requiredInt(v, allowZero: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('field-alert-window'),
                    controller: _window,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: l10n.fieldAlertWindow,
                      helperText: l10n.fieldAlertWindowHelp,
                      helperMaxLines: 3,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => _requiredInt(v, allowZero: false),
                  ),
                  const SizedBox(height: 12),
                  _PreferredSupplierField(
                    selectedId: _preferredSupplierId,
                    saved: _preferredSaved,
                    onChanged: (v) => setState(() => _preferredSupplierId = v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _manufacturer,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.fieldManufacturer,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _category,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.fieldCategory,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _notes,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.fieldNotes,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    key: const Key('medicine-save'),
                    onPressed: _saving ? null : _save,
                    child: Text(l10n.actionSave),
                  ),
                ],
              ),
            ),
    );
  }
}

enum _DuplicateChoice { cancel, view, saveAnyway }

/// Dropdown of suppliers; includes the saved choice even if archived.
class _PreferredSupplierField extends ConsumerWidget {
  const _PreferredSupplierField({
    required this.selectedId,
    required this.saved,
    required this.onChanged,
  });

  final String? selectedId;
  final Supplier? saved;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final active = ref.watch(activeSuppliersProvider).value ?? const [];
    final options = [
      ...active,
      if (saved != null && !active.any((s) => s.id == saved!.id)) saved!,
    ];
    return DropdownButtonFormField<String?>(
      key: ValueKey('preferred-$selectedId-${options.length}'),
      initialValue: options.any((s) => s.id == selectedId) ? selectedId : null,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: l10n.fieldPreferredSupplier,
        border: const OutlineInputBorder(),
      ),
      items: [
        DropdownMenuItem<String?>(child: Text(l10n.supplierNone)),
        for (final s in options)
          DropdownMenuItem<String?>(
            value: s.id,
            child: Text(s.name, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: onChanged,
    );
  }
}
