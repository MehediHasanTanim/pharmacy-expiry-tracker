import 'package:flutter/material.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/supplier.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Status as an icon, a word and a colour, never colour alone.
class InvoiceStatusChip extends StatelessWidget {
  const InvoiceStatusChip({required this.status, super.key});

  final InvoiceStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (color, icon) = switch (status) {
      InvoiceStatus.paid => (scheme.primary, Icons.check_circle_outline),
      InvoiceStatus.overdue => (scheme.error, Icons.error_outline),
      InvoiceStatus.partial => (scheme.tertiary, Icons.timelapse),
      InvoiceStatus.unpaid => (scheme.outline, Icons.radio_button_unchecked),
    };
    final text = invoiceStatusLabel(l10n, status);
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Container(
        key: Key('status-${status.name}'),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              text,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
