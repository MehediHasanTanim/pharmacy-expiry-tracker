import 'dart:async';

import 'package:flutter/foundation.dart';

enum DataChangeKind {
  medicineChanged,
  batchAdded,
  batchEdited,
  stockAdjusted,
  alertStateChanged,
  supplierChanged,
  ledgerChanged,
  reorderChanged,
}

@immutable
class DataChange {
  const DataChange(this.kind, {this.medicineId, this.batchId});

  final DataChangeKind kind;
  final String? medicineId;
  final String? batchId;
}

/// Broadcasts committed data changes. The alert engine (Sprint 3) subscribes
/// to re-plan notifications; search results also refresh from it.
class DataChangeBus {
  final _controller = StreamController<DataChange>.broadcast();

  Stream<DataChange> get changes => _controller.stream;

  void emit(DataChange change) {
    if (!_controller.isClosed) _controller.add(change);
  }

  Future<void> dispose() => _controller.close();
}
