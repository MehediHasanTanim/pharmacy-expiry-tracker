import 'package:pharmacy_expiry_tracker/features/scan/barcode_scan_screen.dart';

/// A scanner that "reads" queued values instead of using a camera. A null in
/// the queue is the user backing out.
class FakeScanner {
  final List<String?> queue = <String?>[];
  int calls = 0;

  BarcodeScan get scan => (context) async {
    calls++;
    return queue.isEmpty ? null : queue.removeAt(0);
  };
}
