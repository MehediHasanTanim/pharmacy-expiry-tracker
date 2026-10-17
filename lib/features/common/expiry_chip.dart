import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/theme.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// "12 days left" / "Expired 3 days ago", coloured and iconed by urgency so
/// colour is never the only signal.
class ExpiryChip extends ConsumerWidget {
  const ExpiryChip({required this.expiry, super.key});

  final ExpiryDate expiry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = ref.watch(todayDateProvider);
    final thresholds = ref.watch(
      settingsProvider.select((s) => s.value?.bucketThresholds),
    );
    final days = expiry.daysUntil(today);
    final bucket = bucketFor(
      days,
      thresholds: thresholds ?? const [30, 60, 90],
    );
    final style = Theme.of(context).extension<UrgencyColors>()!.of(bucket);
    final text = days < 0 ? l10n.expiredAgo(-days) : l10n.daysLeft(days);
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: style.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: style.color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, size: 16, color: style.color),
            const SizedBox(width: 4),
            Text(
              text,
              style: Theme.of(context).textTheme.labelMedium
                  ?.copyWith(color: style.color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
