/// Urgency of a batch by days until expiry. Thresholds and the bucketing
/// function arrive in Sprint 2; the enum exists now so the theme can map each
/// level to a colour and icon.
enum ExpiryBucket { expired, d30, d60, d90, ok }
