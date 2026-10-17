import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/batch.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Shows the "Adjust stock" bottom sheet for [batch]. Completes with true if
/// an adjustment was applied.
Future<bool?> showAdjustStockSheet(
  BuildContext context,
  Batch batch, {
  AdjustmentReason initialReason = AdjustmentReason.sold,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (_) =>
        AdjustStockSheet(batch: batch, initialReason: initialReason),
  );
}

class AdjustStockSheet extends ConsumerStatefulWidget {
  const AdjustStockSheet({
    required this.batch,
    this.initialReason = AdjustmentReason.sold,
    super.key,
  });

  final Batch batch;
  final AdjustmentReason initialReason;

  @override
  ConsumerState<AdjustStockSheet> createState() => _AdjustStockSheetState();
}

class _AdjustStockSheetState extends ConsumerState<AdjustStockSheet> {
  static const _reasons = [
    AdjustmentReason.sold,
    AdjustmentReason.damaged,
    AdjustmentReason.discardedExpired,
    AdjustmentReason.returned,
    AdjustmentReason.correction,
    AdjustmentReason.received,
    AdjustmentReason.other,
  ];

  final _qty = TextEditingController(text: '1');
  final _note = TextEditingController();
  late AdjustmentReason _reason = widget.initialReason;
  // For corrections only: true adds stock, false removes it.
  bool _correctionAdds = false;
  bool _busy = false;

  int get _onHand => widget.batch.quantityOnHand;
  int get _amount => int.tryParse(_qty.text.trim()) ?? 0;

  bool get _adds =>
      _reason == AdjustmentReason.received ||
      (_reason == AdjustmentReason.correction && _correctionAdds);

  int get _delta => _adds ? _amount : -_amount;

  String? _error(AppLocalizations l10n) {
    if (_amount <= 0) return l10n.errQuantityRequired;
    if (!_adds && _amount > _onHand) return l10n.adjustErrTooMany(_onHand);
    return null;
  }

  @override
  void dispose() {
    _qty.dispose();
    _note.dispose();
    super.dispose();
  }

  void _setAmount(int value) {
    final capped = !_adds && value > _onHand ? _onHand : value;
    final next = capped < 1 ? 1 : capped;
    setState(() => _qty.text = next.toString());
  }

  Future<void> _apply() async {
    final l10n = AppLocalizations.of(context);
    if (_error(l10n) != null || _busy) return;
    if (_reason.isDestructive) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.adjustConfirmTitle),
          content: Text(
            l10n.adjustConfirmBody(
              l10n.adjustDelta(_amount),
              widget.batch.batchNumber,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              key: const Key('adjust-confirm'),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.actionConfirm),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(adjustStockProvider)
          .call(
            batchId: widget.batch.id,
            delta: _delta,
            reason: _reason,
            note: _note.text,
          );
      if (mounted) Navigator.pop(context, true);
    } on InsufficientStockException catch (e) {
      if (mounted) {
        _snack(l10n.adjustErrTooMany(e.available));
      }
    } on ValidationException catch (e) {
      if (mounted) _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final error = _error(l10n);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.adjustTitle, style: theme.textTheme.titleLarge),
            Text(
              '${l10n.batchBy(widget.batch.batchNumber)} · ${l10n.stockOnHand(_onHand)}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final r in _reasons)
                  ChoiceChip(
                    key: Key('reason-${r.db}'),
                    label: Text(reasonLabel(l10n, r)),
                    selected: _reason == r,
                    onSelected: (_) {
                      setState(() => _reason = r);
                      // Re-cap the quantity for the new direction.
                      _setAmount(_amount);
                    },
                  ),
              ],
            ),
            if (_reason == AdjustmentReason.correction) ...[
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.adjustCorrectionRemove),
                    icon: const Icon(Icons.remove),
                  ),
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.adjustCorrectionAdd),
                    icon: const Icon(Icons.add),
                  ),
                ],
                selected: {_correctionAdds},
                onSelectionChanged: (s) {
                  setState(() => _correctionAdds = s.first);
                  _setAmount(_amount);
                },
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton.outlined(
                  key: const Key('qty-minus'),
                  icon: const Icon(Icons.remove),
                  onPressed: () => _setAmount(_amount - 1),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    key: const Key('adjust-qty'),
                    controller: _qty,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: l10n.adjustQuantity,
                      errorText: error,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  key: const Key('qty-plus'),
                  icon: const Icon(Icons.add),
                  onPressed: () => _setAmount(_amount + 1),
                ),
                if (!_adds) ...[
                  const SizedBox(width: 8),
                  OutlinedButton(
                    key: const Key('qty-all'),
                    onPressed: () => _setAmount(_onHand),
                    child: Text(l10n.adjustAll),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('adjust-note'),
              controller: _note,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.adjustNote,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('adjust-apply'),
                onPressed: error != null || _busy ? null : _apply,
                child: Text(l10n.adjustApply),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
