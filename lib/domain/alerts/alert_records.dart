import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';

/// Lifecycle of a row in `scheduled_alerts`.
enum ScheduledState {
  pending('PENDING'),
  fired('FIRED'),
  cancelled('CANCELLED');

  ScheduledState(this.db);
  final String db;

  static ScheduledState fromDb(String v) => ScheduledState.values.firstWhere(
    (s) => s.db == v,
    orElse: () => ScheduledState.pending,
  );
}

/// What the engine believes it has asked the OS to deliver.
@immutable
class ScheduledAlertRecord {
  const ScheduledAlertRecord({
    required this.key,
    required this.kind,
    required this.fireAt,
    required this.osId,
    required this.title,
    required this.body,
    required this.route,
    required this.contentHash,
    required this.state,
  });

  final String key;
  final AlertKind kind;
  final DateTime fireAt;
  final int osId;
  final String title;
  final String body;
  final String route;
  final String contentHash;
  final ScheduledState state;

  bool get isPending => state == ScheduledState.pending;
}

/// An alert that has been (or should have been) delivered, for the Alert
/// history screen.
@immutable
class AlertLogEntry {
  const AlertLogEntry({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.firedAt,
    this.route,
    this.openedAt,
  });

  final String id;
  final AlertKind kind;
  final String title;
  final String body;
  final String? route;
  final DateTime firedAt;
  final DateTime? openedAt;

  bool get isOpened => openedAt != null;
}
