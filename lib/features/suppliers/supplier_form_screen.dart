import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Create or edit a supplier (SUP-1). Pops with the saved supplier's id.
class SupplierFormScreen extends ConsumerStatefulWidget {
  const SupplierFormScreen({this.supplierId, super.key});

  final String? supplierId;

  @override
  ConsumerState<SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _taxId = TextEditingController();
  final _terms = TextEditingController();
  final _notes = TextEditingController();
  Supplier? _existing;
  bool _loading = false;
  bool _saving = false;

  bool get _isEdit => widget.supplierId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _loading = true;
      unawaited(_load());
    }
  }

  Future<void> _load() async {
    final s = await ref
        .read(supplierRepositoryProvider)
        .getById(widget.supplierId!);
    if (!mounted) return;
    if (s != null) {
      _name.text = s.name;
      _contact.text = s.contactPerson ?? '';
      _phone.text = s.phone ?? '';
      _email.text = s.email ?? '';
      _address.text = s.address ?? '';
      _taxId.text = s.taxId ?? '';
      _terms.text = s.paymentTermsDays?.toString() ?? '';
      _notes.text = s.notes ?? '';
    }
    setState(() {
      _existing = s;
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _contact,
      _phone,
      _email,
      _address,
      _taxId,
      _terms,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      final id = await ref
          .read(saveSupplierProvider)
          .call(
            SupplierInput(
              name: _name.text,
              contactPerson: _contact.text,
              phone: _phone.text,
              email: _email.text,
              address: _address.text,
              taxId: _taxId.text,
              paymentTermsDays: int.tryParse(_terms.text.trim()),
              notes: _notes.text,
            ),
            id: widget.supplierId,
          );
      if (mounted) context.pop(id);
    } on ValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleArchive() async {
    final l10n = AppLocalizations.of(context);
    final s = _existing!;
    if (!s.isArchived) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.supplierArchiveTitle),
          content: Text(l10n.supplierArchiveBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              key: const Key('supplier-archive-confirm'),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.actionArchive),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await ref
        .read(setSupplierArchivedProvider)
        .call(s.id, archived: !s.isArchived);
    if (mounted) context.pop(s.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget field(
      String key,
      TextEditingController c,
      String label, {
      TextInputType? type,
      String? Function(String?)? validator,
      String? helper,
      List<TextInputFormatter>? formatters,
      int maxLines = 1,
      TextCapitalization caps = TextCapitalization.words,
    }) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          key: Key(key),
          controller: c,
          keyboardType: type,
          maxLines: maxLines,
          inputFormatters: formatters,
          textCapitalization: caps,
          textInputAction: maxLines == 1 ? TextInputAction.next : null,
          decoration: InputDecoration(
            labelText: label,
            helperText: helper,
            helperMaxLines: 2,
            border: const OutlineInputBorder(),
          ),
          validator: validator,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? l10n.supplierEdit : l10n.supplierNew),
        actions: [
          if (_existing != null)
            IconButton(
              key: const Key('supplier-archive'),
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
                    key: const Key('field-supplier-name'),
                    controller: _name,
                    autofocus: !_isEdit,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: l10n.fieldSupplierName,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (v) => (v ?? '').trim().isEmpty
                        ? l10n.errSupplierRequired
                        : null,
                  ),
                  const SizedBox(height: 12),
                  field('field-contact', _contact, l10n.fieldContactPerson),
                  field(
                    'field-phone',
                    _phone,
                    l10n.fieldPhone,
                    type: TextInputType.phone,
                    caps: TextCapitalization.none,
                  ),
                  field(
                    'field-email',
                    _email,
                    l10n.fieldEmail,
                    type: TextInputType.emailAddress,
                    caps: TextCapitalization.none,
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return null;
                      return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)
                          ? null
                          : l10n.errEmailInvalid;
                    },
                  ),
                  field(
                    'field-address',
                    _address,
                    l10n.fieldAddress,
                    maxLines: 2,
                  ),
                  field(
                    'field-tax-id',
                    _taxId,
                    l10n.fieldTaxId,
                    caps: TextCapitalization.characters,
                  ),
                  field(
                    'field-terms',
                    _terms,
                    l10n.fieldPaymentTerms,
                    helper: l10n.fieldPaymentTermsHelp,
                    type: TextInputType.number,
                    formatters: [FilteringTextInputFormatter.digitsOnly],
                    caps: TextCapitalization.none,
                    validator: (v) {
                      final t = (v ?? '').trim();
                      if (t.isEmpty) return null;
                      final n = int.tryParse(t);
                      return n == null || n < 0 ? l10n.errTermsInvalid : null;
                    },
                  ),
                  field(
                    'field-supplier-notes',
                    _notes,
                    l10n.fieldNotes,
                    maxLines: 3,
                    caps: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    key: const Key('supplier-save'),
                    onPressed: _saving ? null : _save,
                    child: Text(l10n.actionSave),
                  ),
                ],
              ),
            ),
    );
  }
}
