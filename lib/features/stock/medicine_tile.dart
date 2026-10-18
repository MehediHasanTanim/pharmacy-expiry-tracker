import 'package:flutter/material.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/medicine.dart';
import 'package:pharmacy_expiry_tracker/features/common/expiry_chip.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// One medicine row: name, form/generic, on-hand total, nearest-expiry chip.
class MedicineTile extends StatelessWidget {
  const MedicineTile({required this.summary, required this.onTap, super.key});

  final MedicineSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final m = summary.medicine;
    final subtitle = [
      dosageFormLabel(l10n, m.dosageForm),
      if (m.genericName != null) m.genericName!,
    ].join(' · ');
    final stock = summary.onHand > 0
        ? l10n.stockOnHand(summary.onHand)
        : l10n.noStock;
    return Opacity(
      opacity: m.isArchived ? 0.6 : 1,
      child: ListTile(
        key: Key('medicine-${m.id}'),
        title: Text(m.displayName),
        isThreeLine: summary.nearestExpiry != null,
        // Everything sits in the subtitle so large text can wrap; a trailing
        // column would be squeezed into the tile's fixed height.
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.isArchived ? '$subtitle · ${l10n.archivedBadge}' : subtitle),
            Text(stock, style: Theme.of(context).textTheme.labelLarge),
            if (summary.nearestExpiry != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ExpiryChip(expiry: summary.nearestExpiry!),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
