import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/core/money/money.dart';
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

/// Payment reminders follow the expiry alerts by a further few minutes.
const paymentAlertOffsetMinutes = 10;

/// Reorder reminders come last.
const reorderAlertOffsetMinutes = 15;

/// Backup reminders come after the other kinds.
const backupAlertOffsetMinutes = 20;

/// A backup that stays overdue is reminded again this often.
const backupRepeatDays = 7;

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
  List<PlanInvoice> invoices = const [],
  List<PlanReorder> reorders = const [],
  DateTime? backupAnchor,
  bool hasData = false,
  int maxPending = maxPendingAlerts,
}) {
  final today = dateOnly(now);
  final out = <PlannedAlert>[
    ..._leadAlerts(now, today, settings, batches, l10n),
    ..._paymentAlerts(now, today, settings, invoices, l10n),
    ..._reorderAlerts(now, today, settings, reorders, l10n),
    if (hasData) ..._backupAlerts(now, today, settings, backupAnchor, l10n),
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

  final capped = shifted.length > maxPending
      ? shifted.sublist(0, maxPending)
      : shifted;
  if (!settings.hideDetailsOnLockScreen) return capped;
  // Lock-screen privacy: keep what happened (the title) but not which
  // medicines or suppliers (the body).
  return [
    for (final a in capped)
      if (a.kind == AlertKind.backup) a else _withBody(a, l10n.alertHiddenBody),
  ];
}

PlannedAlert _withBody(PlannedAlert a, String body) => PlannedAlert(
  key: a.key,
  kind: a.kind,
  fireAt: a.fireAt,
  title: a.title,
  body: body,
  route: a.route,
  refs: a.refs,
);

/// Backup reminders (SEC-4): once the last backup (or, if there never was
/// one, the first use) is [AppSettings.backupReminderDays] old, remind, and
/// then weekly while it stays undone.
List<PlannedAlert> _backupAlerts(
  DateTime now,
  DateTime today,
  AppSettings settings,
  DateTime? anchor,
  AppLocalizations l10n,
) {
  if (settings.backupReminderDays < 1 || anchor == null) return const [];
  final alertMinutes = settings.digestMinutes + backupAlertOffsetMinutes;
  final anchorDay = dayNumber(dateOnly(anchor));
  final todayNumber = dayNumber(today);
  var first = anchorDay + settings.backupReminderDays;
  if (first < todayNumber) first = todayNumber;
  if (first == todayNumber && !_at(today, alertMinutes).isAfter(now)) {
    first = todayNumber + 1;
  }
  final lastDay = todayNumber + digestHorizonDays;
  return [
    for (var day = first; day <= lastDay; day += backupRepeatDays)
      PlannedAlert(
        key: 'backup:${_iso(_fromDayNumber(day))}',
        kind: AlertKind.backup,
        fireAt: _at(_fromDayNumber(day), alertMinutes),
        title: l10n.alertBackupTitle,
        body: settings.lastBackupAt.isEmpty
            ? l10n.alertBackupBodyNever
            : l10n.alertBackupBodyAgo(
                day -
                    dayNumber(dateOnly(DateTime.parse(settings.lastBackupAt))),
              ),
        route: Routes.backup,
      ),
  ];
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
    refs: a.refs,
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

/// A medicine below its reorder level, as reorder reminders need it.
@immutable
class PlanReorder {
  const PlanReorder({
    required this.medicineId,
    required this.name,
    required this.usable,
    this.lastNotifiedDay,
    this.snoozeDay,
    this.orderQuantity,
    this.orderDueDay,
  });

  final String medicineId;
  final String name;

  /// Stock that has not expired.
  final int usable;

  /// Day number of the last reminder that was delivered for it.
  final int? lastNotifiedDay;

  /// Reminders stay silent until this day number.
  final int? snoozeDay;

  /// Quantity on the open order for it, if one was placed (ROR-5).
  final int? orderQuantity;

  /// Day number the open order is due; before then the reorder reminder is
  /// held back, after it the order is chased instead.
  final int? orderDueDay;

  bool get hasOrder => orderDueDay != null;
}

/// An unpaid invoice with a due date, as payment reminders need it.
@immutable
class PlanInvoice {
  const PlanInvoice({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.dueDay,
    required this.balanceMinor,
    this.invoiceNumber,
    this.snoozeDay,
  });

  final String id;
  final String supplierId;
  final String supplierName;
  final String? invoiceNumber;

  /// Due date as a day number (see [dayNumber]).
  final int dueDay;

  /// What is still owed, in minor units.
  final int balanceMinor;

  /// Reminders stay silent until this day number.
  final int? snoozeDay;
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

/// Reminders about unpaid invoices (ALR-14, SUP-9): before the due date, on it,
/// and then every [AppSettings.overdueRepeatDays] days until it is paid. All
/// invoices reminding on the same day share one notification per kind.
List<PlannedAlert> _paymentAlerts(
  DateTime now,
  DateTime today,
  AppSettings settings,
  List<PlanInvoice> invoices,
  AppLocalizations l10n,
) {
  if (invoices.isEmpty) return const [];
  final leads = settings.paymentLeadDays.toSet().where((l) => l >= 0).toList()
    ..sort((a, b) => b.compareTo(a));
  final repeat = settings.overdueRepeatDays;
  final alertMinutes = settings.digestMinutes + paymentAlertOffsetMinutes;
  final todayNumber = dayNumber(today);
  final todayStillAhead = _at(today, alertMinutes).isAfter(now);
  final lastOverdueDay = todayNumber + digestHorizonDays;

  final ahead = <int, _PayGroup>{};
  final due = <int, _PayGroup>{};
  final overdue = <int, _PayGroup>{};

  bool allowed(PlanInvoice inv, int day) {
    if (day < todayNumber) return false;
    if (inv.snoozeDay != null && day < inv.snoozeDay!) return false;
    return day != todayNumber || todayStillAhead;
  }

  for (final inv in invoices) {
    if (inv.balanceMinor <= 0) continue;
    for (final lead in leads) {
      final day = inv.dueDay - lead;
      if (allowed(inv, day)) {
        ((lead == 0 ? due : ahead)[day] ??= _PayGroup()).add(inv, lead);
      }
    }
    if (repeat > 0) {
      // Repeats are anchored on the due date, so the same days come out
      // however often we plan.
      final sinceDue = todayNumber - inv.dueDay;
      var k = sinceDue <= 0 ? 1 : (sinceDue + repeat - 1) ~/ repeat;
      if (k < 1) k = 1;
      for (
        var day = inv.dueDay + k * repeat;
        day <= lastOverdueDay;
        day += repeat
      ) {
        if (allowed(inv, day)) (overdue[day] ??= _PayGroup()).add(inv, 0);
      }
    }
  }

  String money(int minor) => Money(minor)
      .format(locale: settings.languageCode, symbol: settings.currencySymbol);

  PlannedAlert build(String prefix, int day, _PayGroup g, String title) {
    final iso = _iso(_fromDayNumber(day));
    final items = [
      for (final i in g.top)
        l10n.alertPayItem(i.supplierName, money(i.balanceMinor)),
    ].join(', ');
    return PlannedAlert(
      key: '$prefix:$iso',
      kind: AlertKind.payment,
      fireAt: _at(_fromDayNumber(day), alertMinutes),
      title: title,
      body: l10n.alertPayBody(
        g.count,
        items,
        g.count > 3 ? g.count - 3 : 0,
        money(g.totalMinor),
      ),
      route: g.singleSupplier == null
          ? Routes.suppliers
          : '${Routes.suppliers}/${g.singleSupplier}',
    );
  }

  return [
    for (final e in ahead.entries)
      build(
        'pay',
        e.key,
        e.value,
        e.value.mixed || e.value.lead == null
            ? l10n.alertPayMixedTitle
            : l10n.alertPayTitle(e.value.lead!),
      ),
    for (final e in due.entries)
      build('paydue', e.key, e.value, l10n.alertPayTitle(0)),
    for (final e in overdue.entries)
      build('overdue', e.key, e.value, l10n.alertOverdueTitle(e.value.count)),
  ];
}

/// Running summary of the invoices reminding on one day.
class _PayGroup {
  int count = 0;
  int totalMinor = 0;
  int? lead;
  bool mixed = false;
  String? _supplier;
  bool _manySuppliers = false;
  final top = <PlanInvoice>[];

  /// The supplier id when every invoice in the group is theirs.
  String? get singleSupplier => _manySuppliers ? null : _supplier;

  static int _compare(PlanInvoice a, PlanInvoice b) {
    final byDue = a.dueDay.compareTo(b.dueDay);
    if (byDue != 0) return byDue;
    final byName = a.supplierName.compareTo(b.supplierName);
    return byName != 0 ? byName : a.id.compareTo(b.id);
  }

  void add(PlanInvoice inv, int invoiceLead) {
    count++;
    totalMinor += inv.balanceMinor;
    if (lead == null) {
      lead = invoiceLead;
    } else if (lead != invoiceLead) {
      mixed = true;
    }
    if (_supplier == null) {
      _supplier = inv.supplierId;
    } else if (_supplier != inv.supplierId) {
      _manySuppliers = true;
    }
    var i = top.length;
    while (i > 0 && _compare(inv, top[i - 1]) < 0) {
      i--;
    }
    if (i < 3) {
      top.insert(i, inv);
      if (top.length > 3) top.removeLast();
    }
  }
}

/// Reorder reminders (ROR-4, SET-7): for medicines below their level, one
/// notification now and then every [AppSettings.reorderRefireDays] days until
/// they are restocked. A medicine that was reminded recently waits out the
/// interval; a snoozed one stays silent until its snooze ends. Every medicine
/// reminding on the same day shares one notification.
List<PlannedAlert> _reorderAlerts(
  DateTime now,
  DateTime today,
  AppSettings settings,
  List<PlanReorder> items,
  AppLocalizations l10n,
) {
  if (items.isEmpty) return const [];
  final every = settings.reorderRefireDays < 1 ? 1 : settings.reorderRefireDays;
  final alertMinutes = settings.digestMinutes + reorderAlertOffsetMinutes;
  final todayNumber = dayNumber(today);
  final todayStillAhead = _at(today, alertMinutes).isAfter(now);
  final lastDay = todayNumber + digestHorizonDays;

  final groups = <int, _ReorderGroup>{};
  final chase = <int, _ReorderGroup>{};
  for (final item in items) {
    // The first reminder is due `every` days after the last one delivered, or
    // right away if there never was one (or it was long ago).
    var first = item.lastNotifiedDay == null
        ? todayNumber
        : item.lastNotifiedDay! + every;
    // An order that is on its way holds the reminder back; once it is late,
    // the order is chased instead of reordering again (ROR-5).
    final due = item.orderDueDay;
    if (due != null && first <= due) first = due + 1;
    if (first < todayNumber) first = todayNumber;
    if (first == todayNumber && !todayStillAhead) first = todayNumber + 1;
    for (var day = first; day <= lastDay; day += every) {
      if (item.snoozeDay != null && day < item.snoozeDay!) continue;
      final target = due == null ? groups : chase;
      (target[day] ??= _ReorderGroup()).add(item);
    }
  }

  return [
    for (final e in groups.entries)
      PlannedAlert(
        key: 'reorder:${_iso(_fromDayNumber(e.key))}',
        kind: AlertKind.reorder,
        fireAt: _at(_fromDayNumber(e.key), alertMinutes),
        title: l10n.alertReorderTitle(e.value.count),
        body: l10n.alertReorderBody(
          [for (final i in e.value.top) l10n.alertReorderItem(i.name, i.usable)]
              .join(', '),
          e.value.count > 3 ? e.value.count - 3 : 0,
        ),
        route: Routes.reorder,
        refs: e.value.ids..sort(),
      ),
    for (final e in chase.entries)
      PlannedAlert(
        key: 'ordered:${_iso(_fromDayNumber(e.key))}',
        kind: AlertKind.reorder,
        fireAt: _at(_fromDayNumber(e.key), alertMinutes),
        title: l10n.alertOrderLateTitle(e.value.count),
        body: l10n.alertReorderBody(
          [
            for (final i in e.value.top)
              l10n.alertOrderLateItem(i.name, i.orderQuantity ?? 0),
          ].join(', '),
          e.value.count > 3 ? e.value.count - 3 : 0,
        ),
        route: Routes.reorder,
        refs: e.value.ids..sort(),
      ),
  ];
}

class _ReorderGroup {
  int count = 0;
  final ids = <String>[];
  final top = <PlanReorder>[];

  static int _compare(PlanReorder a, PlanReorder b) {
    final byName = a.name.compareTo(b.name);
    return byName != 0 ? byName : a.medicineId.compareTo(b.medicineId);
  }

  void add(PlanReorder item) {
    count++;
    ids.add(item.medicineId);
    var i = top.length;
    while (i > 0 && _compare(item, top[i - 1]) < 0) {
      i--;
    }
    if (i < 3) {
      top.insert(i, item);
      if (top.length > 3) top.removeLast();
    }
  }
}
