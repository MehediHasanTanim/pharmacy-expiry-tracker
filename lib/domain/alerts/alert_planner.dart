import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/rules/expiry_bucket.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// At most this many notifications are kept scheduled (iOS allows 64).
const maxPendingAlerts = 60;

/// How many days ahead daily digests are scheduled; later days are added when
/// the plan is refreshed.
const digestHorizonDays = 14;

/// Lead-time alerts are sent a few minutes after the digest so the two never
/// arrive at the same instant.
const leadAlertOffsetMinutes = 5;

/// Calendar day as a whole number (days since 1970-01-01), immune to
/// daylight-saving shifts. Planning does its arithmetic on these so scanning
/// tens of thousands of batches stays fast.
int dayNumber(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 86400000;

DateTime _fromDayNumber(int n) {
  final u = DateTime.fromMillisecondsSinceEpoch(n * 86400000, isUtc: true);
  return DateTime(u.year, u.month, u.day);
}

/// The facts about one batch that alert planning needs. Dates are day numbers
/// (see [dayNumber]) so loading and planning avoid building date objects.
@immutable
class PlanBatch {
  const PlanBatch({
    required this.id,
    required this.name,
    required this.batchNumber,
    required this.expiryDay,
    required this.quantity,
    required this.windowDays,
    this.snoozeDay,
    this.handled = false,
  });

  final String id;

  /// Medicine display name, e.g. "Amoxil 500 mg".
  final String name;
  final String batchNumber;

  /// Expiry date as a day number.
  final int expiryDay;
  final int quantity;

  /// The medicine's near-expiry window; lead times beyond it are not alerted.
  final int windowDays;

  /// Alerts stay silent until this day number.
  final int? snoozeDay;
  final bool handled;
}

DateTime _at(DateTime day, int minutes) =>
    DateTime(day.year, day.month, day.day, minutes ~/ 60, minutes % 60);

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

/// Works out which notifications should exist right now (technical design
/// §6.3). Pure: the same inputs always give the same plan, which is what makes
/// re-planning safe to run as often as needed.
///
///  * one **lead-time** notification per fire date, grouping every batch that
///    reaches a lead time that day, and one **expiry-day** notification for
///    batches expiring that day;
///  * a **daily digest** for the next [digestHorizonDays] days;
///  * quiet hours shift anything inside them to the end of the quiet window;
///  * only the earliest [maxPending] are kept.
List<PlannedAlert> planAlerts({
  required DateTime now,
  required AppSettings settings,
  required List<PlanBatch> batches,
  required AppLocalizations l10n,
  int maxPending = maxPendingAlerts,
}) {
  final today = dateOnly(now);
  final out = <PlannedAlert>[
    ..._leadAlerts(now, today, settings, batches, l10n),
    if (settings.digestEnabled)
      ..._digests(now, today, settings, batches, l10n),
  ];

  final shifted =
      [
        for (final a in out)
          if (settings.quietHoursEnabled)
            _withTime(a, _applyQuietHours(a.fireAt, settings))
          else
            a,
      ]..sort((a, b) {
        final byTime = a.fireAt.compareTo(b.fireAt);
        return byTime != 0 ? byTime : a.key.compareTo(b.key);
      });

  return shifted.length > maxPending ? shifted.sublist(0, maxPending) : shifted;
}

PlannedAlert _withTime(PlannedAlert a, DateTime fireAt) {
  if (fireAt == a.fireAt) return a;
  return PlannedAlert(
    key: a.key,
    kind: a.kind,
    fireAt: fireAt,
    title: a.title,
    body: a.body,
    route: a.route,
  );
}

/// Moves [t] to the end of the quiet window if it falls inside it.
DateTime _applyQuietHours(DateTime t, AppSettings s) {
  final start = s.quietStartMinutes;
  final end = s.quietEndMinutes;
  if (start == end) return t;
  final minute = t.hour * 60 + t.minute;
  final overnight = start > end;
  final inQuiet = overnight
      ? (minute >= start || minute < end)
      : (minute >= start && minute < end);
  if (!inQuiet) return t;
  final sameDay = !overnight || minute < end;
  final day = sameDay ? dateOnly(t) : DateTime(t.year, t.month, t.day + 1);
  return _at(day, end);
}

/// Running summary of the batches reaching an alert on one day: how many, the
/// three most urgent (for the text), and whether they share one lead time.
class _Group {
  int count = 0;
  int? lead;
  bool mixed = false;
  final top = <PlanBatch>[];

  static int _compare(PlanBatch a, PlanBatch b) {
    final byExpiry = a.expiryDay.compareTo(b.expiryDay);
    if (byExpiry != 0) return byExpiry;
    final byName = a.name.compareTo(b.name);
    return byName != 0 ? byName : a.id.compareTo(b.id);
  }

  void add(PlanBatch b, int batchLead) {
    count++;
    if (lead == null) {
      lead = batchLead;
    } else if (lead != batchLead) {
      mixed = true;
    }
    // Keep the three smallest in a tiny sorted list: O(1) per batch and
    // independent of input order.
    var i = top.length;
    while (i > 0 && _compare(b, top[i - 1]) < 0) {
      i--;
    }
    if (i < 3) {
      top.insert(i, b);
      if (top.length > 3) top.removeLast();
    }
  }
}

List<PlannedAlert> _leadAlerts(
  DateTime now,
  DateTime today,
  AppSettings settings,
  List<PlanBatch> batches,
  AppLocalizations l10n,
) {
  final leads = settings.alertLeadDays.toSet().where((l) => l >= 0).toList()
    ..sort((a, b) => b.compareTo(a));
  final alertMinutes = settings.digestMinutes + leadAlertOffsetMinutes;
  final todayNumber = dayNumber(today);
  final todayStillAhead = _at(today, alertMinutes).isAfter(now);

  final ahead = <int, _Group>{};
  final expiring = <int, _Group>{};
  for (final b in batches) {
    if (b.handled || b.quantity <= 0) continue;
    final expiryDay = b.expiryDay;
    final snoozeDay = b.snoozeDay;
    for (final lead in leads) {
      // A medicine with a short window is not alerted at long lead times.
      if (lead > b.windowDays) continue;
      final day = expiryDay - lead;
      if (day < todayNumber) continue;
      // Snoozed: silent until the snooze date, resuming on it.
      if (snoozeDay != null && day < snoozeDay) continue;
      if (day == todayNumber && !todayStillAhead) continue;
      final groups = lead == 0 ? expiring : ahead;
      (groups[day] ??= _Group()).add(b, lead);
    }
  }

  return [
    for (final e in ahead.entries)
      _leadAlert(
        AlertKind.expiryLead,
        'lead',
        e.key,
        alertMinutes,
        e.value,
        settings,
        l10n,
      ),
    for (final e in expiring.entries)
      _leadAlert(
        AlertKind.expiryDay,
        'day',
        e.key,
        alertMinutes,
        e.value,
        settings,
        l10n,
      ),
  ];
}

PlannedAlert _leadAlert(
  AlertKind kind,
  String keyPrefix,
  int dayNumber,
  int alertMinutes,
  _Group g,
  AppSettings settings,
  AppLocalizations l10n,
) {
  final day = _fromDayNumber(dayNumber);
  final uniform = g.mixed ? null : g.lead;
  final items = [for (final b in g.top) l10n.alertItem(b.name, b.batchNumber)]
      .join(', ');
  final iso = _iso(day);
  final bucket = uniform == null
      ? null
      : bucketFor(uniform, thresholds: settings.bucketThresholds).name;
  return PlannedAlert(
    key: '$keyPrefix:$iso',
    kind: kind,
    fireAt: _at(day, alertMinutes),
    title: uniform == null
        ? l10n.alertMixedTitle
        : l10n.alertLeadTitle(uniform),
    body: l10n.alertBody(g.count, items, g.count > 3 ? g.count - 3 : 0),
    route: Routes.expiryFiltered(bucket: bucket, date: iso),
  );
}

List<PlannedAlert> _digests(
  DateTime now,
  DateTime today,
  AppSettings settings,
  List<PlanBatch> batches,
  AppLocalizations l10n,
) {
  final nearLimit = settings.bucketThresholds.first;
  final todayNumber = dayNumber(today);
  final expiryDays = <int>[
    for (final b in batches)
      if (!b.handled && b.quantity > 0) b.expiryDay,
  ];

  final alerts = <PlannedAlert>[];
  for (var i = 0; i < digestHorizonDays; i++) {
    final dn = todayNumber + i;
    final day = _fromDayNumber(dn);
    final fireAt = _at(day, settings.digestMinutes);
    if (!fireAt.isAfter(now)) continue;

    // Projected counts as of that day (batches keep ageing).
    var near = 0;
    var expired = 0;
    for (final e in expiryDays) {
      final left = e - dn;
      if (left < 0) {
        expired++;
      } else if (left <= nearLimit) {
        near++;
      }
    }
    if (settings.skipEmptyDigest && near + expired == 0) continue;

    // Exact counts only for a digest about to land; further out the data may
    // change before it is delivered, so say nothing that could be wrong.
    final soon = fireAt.difference(now) <= const Duration(hours: 24);
    alerts.add(
      PlannedAlert(
        key: 'digest:${_iso(day)}',
        kind: AlertKind.digest,
        fireAt: fireAt,
        title: l10n.alertDigestTitle,
        body: soon
            ? l10n.alertDigestBody(near, expired)
            : l10n.alertDigestGeneric,
        route: Routes.expiry,
      ),
    );
  }
  return alerts;
}
