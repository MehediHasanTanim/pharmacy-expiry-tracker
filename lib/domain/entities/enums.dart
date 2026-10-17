enum DosageForm {
  tablet,
  capsule,
  syrup,
  injection,
  ointment,
  drops,
  other;

  static DosageForm fromDb(String v) => DosageForm.values.firstWhere(
    (e) => e.name == v,
    orElse: () => DosageForm.other,
  );
}

enum StockUnit {
  strip,
  box,
  bottle,
  vial,
  piece;

  static StockUnit fromDb(String v) => StockUnit.values.firstWhere(
    (e) => e.name == v,
    orElse: () => StockUnit.piece,
  );
}

enum BatchStatus {
  active('ACTIVE'),
  depleted('DEPLETED'),
  returned('RETURNED'),
  discarded('DISCARDED');

  BatchStatus(this.db);
  final String db;

  static BatchStatus fromDb(String v) => BatchStatus.values.firstWhere(
    (e) => e.db == v,
    orElse: () => BatchStatus.active,
  );
}

enum AdjustmentReason {
  received('RECEIVED'),
  sold('SOLD'),
  damaged('DAMAGED'),
  discardedExpired('DISCARDED_EXPIRED'),
  returned('RETURNED'),
  correction('CORRECTION'),
  other('OTHER');

  AdjustmentReason(this.db);
  final String db;

  static AdjustmentReason fromDb(String v) => AdjustmentReason.values
      .firstWhere((e) => e.db == v, orElse: () => AdjustmentReason.other);

  /// Reasons that write stock off as a loss (value impact is recorded).
  bool get isLoss => this == damaged || this == discardedExpired;

  /// Reasons that need a confirmation step in the UI.
  bool get isDestructive => isLoss;
}
