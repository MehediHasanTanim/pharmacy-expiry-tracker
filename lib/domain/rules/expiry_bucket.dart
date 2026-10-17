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

/// Date bounds (inclusive, in days from today) of each bucket for ascending
/// [thresholds]; `null` means unbounded. Used to turn a bucket filter into a
/// date range for queries.
({int? minDays, int? maxDays}) bucketDayRange(
  ExpiryBucket bucket, {
  List<int> thresholds = const [30, 60, 90],
}) {
  return switch (bucket) {
    ExpiryBucket.expired => (minDays: null, maxDays: -1),
    ExpiryBucket.d30 => (minDays: 0, maxDays: thresholds[0]),
    ExpiryBucket.d60 => (minDays: thresholds[0] + 1, maxDays: thresholds[1]),
    ExpiryBucket.d90 => (minDays: thresholds[1] + 1, maxDays: thresholds[2]),
    ExpiryBucket.ok => (minDays: thresholds[2] + 1, maxDays: null),
  };
}
