import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';

/// What a scheduled alert is about. Stored as text in `scheduled_alerts`.
enum AlertKind {
  expiryLead('EXPIRY_LEAD'),
  expiryDay('EXPIRY_DAY'),
  digest('DIGEST'),
  payment('PAYMENT'),
  reorder('REORDER'),
  backup('BACKUP');

  AlertKind(this.db);
  final String db;

  static AlertKind fromDb(String v) => AlertKind.values.firstWhere(
    (k) => k.db == v,
    orElse: () => AlertKind.expiryLead,
  );

  NotificationChannel get channel => switch (this) {
    AlertKind.expiryLead ||
    AlertKind.expiryDay => NotificationChannel.expiryCritical,
    AlertKind.digest => NotificationChannel.expiryDigest,
    AlertKind.payment => NotificationChannel.payments,
    AlertKind.reorder => NotificationChannel.reorder,
    AlertKind.backup => NotificationChannel.backup,
  };
}

/// One notification the engine wants to exist (technical design §6.2).
///
/// The [key] is deterministic — the same logical alert always has the same
/// key — so planning twice yields the same set, and reconciling against what
/// is already scheduled only touches what changed.
@immutable
class PlannedAlert {
  const PlannedAlert({
    required this.key,
    required this.kind,
    required this.fireAt,
    required this.title,
    required this.body,
    required this.route,
    this.osId = 0,
  });

  /// e.g. `lead:2026-11-17`, `day:2026-11-17`, `digest:2026-10-18`.
  final String key;
  final AlertKind kind;

  /// Device-local wall-clock delivery time.
  final DateTime fireAt;
  final String title;
  final String body;

  /// In-app route opened when the notification is tapped.
  final String route;

  /// 31-bit id handed to the OS scheduler; assigned by [assignOsIds].
  final int osId;

  /// Changes whenever anything the user would see or rely on changes.
  String get contentHash =>
      stableHash('$title|$body|$route|${fireAt.millisecondsSinceEpoch}')
          .toRadixString(16);

  PlannedAlert withOsId(int id) => PlannedAlert(
    key: key,
    kind: kind,
    fireAt: fireAt,
    title: title,
    body: body,
    route: route,
    osId: id,
  );

  ScheduledNotification toNotification() => ScheduledNotification(
    id: osId,
    fireAt: fireAt,
    title: title,
    body: body,
    channel: kind.channel,
    payload: route,
    // Date-level alerts do not need minute precision (spike decision).
    preferExact: false,
  );

  @override
  bool operator ==(Object other) =>
      other is PlannedAlert &&
      other.key == key &&
      other.kind == kind &&
      other.fireAt == fireAt &&
      other.title == title &&
      other.body == body &&
      other.route == route &&
      other.osId == osId;

  @override
  int get hashCode => Object.hash(key, kind, fireAt, title, body, route, osId);

  @override
  String toString() => 'PlannedAlert($key @ $fireAt)';
}

/// FNV-1a over UTF-16 code units, 32-bit. Stable across runs and platforms,
/// unlike `String.hashCode`, so ids and hashes can be persisted.
int stableHash(String input) {
  var h = 0x811c9dc5;
  for (final unit in input.codeUnits) {
    h ^= unit;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h;
}

/// Ids at or above this belong to the developer Alert lab and are never
/// assigned to, or cancelled by, the engine.
const labIdStart = 9000000;
const labIdEnd = 9001000;

bool isLabNotificationId(int id) => id >= labIdStart && id < labIdEnd;

/// Gives each alert a stable 31-bit OS id.
///
/// A key that already has an id keeps it (so rescheduling replaces rather than
/// duplicates). New keys start from their hash and probe forward past any id
/// in [usedIds] — which must include ids of fired and cancelled rows too,
/// because the id column is unique — and past reserved ids.
List<PlannedAlert> assignOsIds(
  List<PlannedAlert> alerts, {
  required Map<String, int> existingByKey,
  Set<int> usedIds = const {},
}) {
  final used = {...usedIds, ...existingByKey.values};
  final result = <PlannedAlert>[];
  for (final a in alerts) {
    final existing = existingByKey[a.key];
    if (existing != null) {
      result.add(a.withOsId(existing));
      continue;
    }
    var id = stableHash(a.key) & 0x7fffffff;
    while (id == 0 || used.contains(id) || isLabNotificationId(id)) {
      id = (id + 1) & 0x7fffffff;
    }
    used.add(id);
    result.add(a.withOsId(id));
  }
  return result;
}
