/// Urgency of a batch by days until expiry.
enum ExpiryBucket { expired, d30, d60, d90, ok }

/// Buckets [daysLeft] by ascending [thresholds] (default 30/60/90 days).
/// Negative days are expired; a threshold value itself belongs to its bucket.
ExpiryBucket bucketFor(
  int daysLeft, {
  List<int> thresholds = const [30, 60, 90],
}) {
  if (daysLeft < 0) return ExpiryBucket.expired;
  if (daysLeft <= thresholds[0]) return ExpiryBucket.d30;
  if (daysLeft <= thresholds[1]) return ExpiryBucket.d60;
  if (daysLeft <= thresholds[2]) return ExpiryBucket.d90;
  return ExpiryBucket.ok;
}
