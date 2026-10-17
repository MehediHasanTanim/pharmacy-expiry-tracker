import 'package:pharmacy_expiry_tracker/core/money/money.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/domain/errors.dart';

/// Status a batch takes after its quantity becomes [quantityOnHand] through an
/// adjustment for [reason].
BatchStatus deriveStatus(int quantityOnHand, AdjustmentReason reason) {
  if (quantityOnHand > 0) return BatchStatus.active;
  return switch (reason) {
    AdjustmentReason.returned => BatchStatus.returned,
    AdjustmentReason.damaged ||
    AdjustmentReason.discardedExpired => BatchStatus.discarded,
    _ => BatchStatus.depleted,
  };
}

/// Checks that [delta] has a sign that fits [reason]. Only RECEIVED adds
/// stock; CORRECTION may go either way; everything else removes stock.
void validateDelta(AdjustmentReason reason, int delta) {
  if (delta == 0) {
    throw const ValidationException('quantity', 'Quantity cannot be zero');
  }
  switch (reason) {
    case AdjustmentReason.received:
      if (delta < 0) {
        throw const ValidationException('quantity', 'Receiving adds stock');
      }
    case AdjustmentReason.correction:
      break;
    case AdjustmentReason.sold ||
        AdjustmentReason.damaged ||
        AdjustmentReason.discardedExpired ||
        AdjustmentReason.returned ||
        AdjustmentReason.other:
      if (delta > 0) {
        throw const ValidationException(
          'quantity',
          'This reason removes stock',
        );
      }
  }
}

/// Cost of the stock written off, for loss reasons with a known cost price.
Money? valueImpact(AdjustmentReason reason, int delta, Money? costPrice) {
  if (!reason.isLoss || costPrice == null) return null;
  return costPrice.times(delta.abs());
}
