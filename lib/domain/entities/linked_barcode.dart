import 'package:flutter/foundation.dart';

/// A barcode value linked to a medicine (a medicine can have several: one
/// per pack size or manufacturer).
@immutable
class LinkedBarcode {
  const LinkedBarcode({
    required this.id,
    required this.medicineId,
    required this.value,
    this.symbology,
  });

  final String id;
  final String medicineId;
  final String value;

  /// e.g. `ean13`, as reported by the scanner; informational only.
  final String? symbology;
}
