import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_planner.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_reconciler.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_scheduler.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/alert_store.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/settings_repository.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/first_run.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Outcome of one planning pass.
@immutable
class ReplanSummary {
  const ReplanSummary({
    required this.at,
    required this.took,
    this.planned = 0,
    this.scheduled = 0,
    this.cancelled = 0,
    this.unchanged = 0,
    this.orphansCancelled = 0,
    this.recovered = 0,
    this.error,
  });

  final DateTime at;
  final Duration took;

  /// Alerts the plan wants to exist.
  final int planned;
  final int scheduled;
  final int cancelled;
  final int unchanged;
  final int orphansCancelled;

  /// Past-due alerts moved to history.
  final int recovered;
  final Object? error;

  bool get ok => error == null;

  /// Nothing needed changing.
  bool get isNoop =>
      ok && scheduled == 0 && cancelled == 0 && orphansCancelled == 0;
}

/// One complete "work out the alerts, make the OS match" pass (technical
/// design §6.3-6.5). It never throws: a failure becomes a [ReplanSummary] with
/// an error, and the next pass starts from consistent state.
class AlertEngine {
  AlertEngine({
    required SettingsRepository settings,
    required AlertSource source,
    required AlertStore store,
    required AlertScheduler scheduler,
    required NotificationPlugin plugin,
    required Clock clock,
    required Future<AppLocalizations> Function(AppSettings settings) loadL10n,
  }) : _settings = settings,
       _source = source,
       _store = store,
       _scheduler = scheduler,
       _plugin = plugin,
       _clock = clock,
       _loadL10n = loadL10n;

  final SettingsRepository _settings;
  final AlertSource _source;
  final AlertStore _store;
  final AlertScheduler _scheduler;
  final NotificationPlugin _plugin;
  final Clock _clock;
  final Future<AppLocalizations> Function(AppSettings settings) _loadL10n;

  /// Plans from as few batches as is provably enough: only the earliest
  /// [maxPendingAlerts] alerts are kept, and a batch expiring after
  /// `today + horizon` cannot alert before `today + horizon - maxLead`. So load
  /// a window, and widen it only if the plan is not yet full or reaches into
  /// the part of the timeline an unseen batch could still affect.
  Future<List<PlannedAlert>> _plan(
    DateTime now,
    AppSettings settings,
    AppLocalizations l10n,
  ) async {
    final today = dateOnly(now);
    final maxLead = settings.alertLeadDays.fold<int>(0, math.max);
    final invoices = await _source.loadPlanInvoices();
    final reorders = await _source.loadPlanReorders(today: today);
    final hasData = await _source.hasData();
    final backupAnchor = _backupAnchor(settings);
    for (final horizon in <int?>[maxLead + 120, maxLead + 600, null]) {
      final batches = await _source.loadPlanBatches(
        today: today,
        globalWindowDays: settings.nearExpiryWindowDays,
        horizonDays: horizon,
      );
      final planned = planAlerts(
        now: now,
        settings: settings,
        batches: batches,
        invoices: invoices,
        reorders: reorders,
        backupAnchor: backupAnchor,
        hasData: hasData,
        l10n: l10n,
      );
      if (horizon == null) return planned;
      // Unseen batches cannot alert before this day (minus a day of slack for
      // quiet-hours shifting).
      final safeUntil = DateTime(
        today.year,
        today.month,
        today.day + horizon - maxLead - 1,
      );
      final complete =
          planned.length >= maxPendingAlerts &&
          planned.last.fireAt.isBefore(safeUntil);
      if (complete) return planned;
    }
    return const [];
  }

  /// What the backup reminder counts from: the last backup, or the first use
  /// (recorded by [ensureFirstRunDate] when the app starts).
  DateTime? _backupAnchor(AppSettings s) {
    final text = s.lastBackupAt.isNotEmpty ? s.lastBackupAt : s.firstRunOn;
    return DateTime.tryParse(text);
  }

  /// Forgets what was scheduled and plans again from the data as it is now.
  /// Used after a restore: the old records and the notifications the OS holds
  /// belong to a different database, so every pending notification is
  /// cancelled (the Alert lab's range excepted) and the right ones are set.
  Future<ReplanSummary> resetAndReplan() async {
    try {
      await _store.clearSchedule();
    } on Object catch (e, st) {
      debugPrint('Could not clear the alert schedule: $e\n$st');
    }
    return replan();
  }

  Future<ReplanSummary> replan() async {
    final now = _clock.now();
    final watch = Stopwatch()..start();
    try {
      final settings = await _settings.load();
      final recovered = await _scheduler.recoverPastDue(now);

      final l10n = await _loadL10n(settings);
      final planned = await _plan(now, settings, l10n);

      final records = await _store.all();
      final desired = assignOsIds(
        planned,
        existingByKey: {for (final r in records) r.key: r.osId},
        usedIds: {for (final r in records) r.osId},
      );
      final osPending = {for (final p in await _plugin.pending()) p.id};
      final diff = reconcile(
        desired: desired,
        existingPending: [
          for (final r in records)
            if (r.isPending) r,
        ],
        osPendingIds: osPending,
      );
      final applied = await _scheduler.apply(
        diff,
        snoozeLabel: l10n.alertActionSnooze,
      );

      return ReplanSummary(
        at: now,
        took: watch.elapsed,
        planned: desired.length,
        scheduled: applied.scheduled,
        cancelled: applied.cancelled,
        unchanged: diff.unchanged,
        orphansCancelled: applied.orphansCancelled,
        recovered: recovered,
      );
    } on Object catch (e, st) {
      debugPrint('Alert re-plan failed: $e\n$st');
      return ReplanSummary(at: now, took: watch.elapsed, error: e);
    }
  }
}

/// Decides *when* to re-plan: coalesces bursts of triggers, and never runs two
/// passes at once (single-flight). A trigger that arrives mid-pass causes one
/// more pass afterwards, so late changes are never lost.
class AlertCoordinator {
  AlertCoordinator(
    this._engine, {
    this.debounce = const Duration(milliseconds: 500),
  });

  final AlertEngine _engine;
  final Duration debounce;

  final _results = StreamController<ReplanSummary>.broadcast();
  final _subscriptions = <StreamSubscription<Object?>>[];
  Timer? _timer;
  Future<ReplanSummary?>? _inflight;
  bool _dirty = false;
  bool _disposed = false;
  ReplanSummary? _last;

  /// Every completed pass.
  Stream<ReplanSummary> get results => _results.stream;

  ReplanSummary? get last => _last;

  /// Re-plans whenever [triggers] emit (data changes, settings changes).
  void listenTo(Stream<Object?> triggers) {
    _subscriptions.add(triggers.listen((_) => request()));
  }

  /// Asks for a pass soon; bursts within [debounce] become one.
  void request() {
    if (_disposed) return;
    _timer?.cancel();
    _timer = Timer(debounce, () => unawaited(replanNow()));
  }

  /// Runs a pass now (launch, resume, background task, "check again").
  /// Resolves with the pass that covers this request.
  Future<ReplanSummary?> replanNow() {
    if (_disposed) return Future.value();
    _timer?.cancel();
    final running = _inflight;
    if (running != null) {
      _dirty = true;
      return running;
    }
    return _inflight = _drain();
  }

  Future<ReplanSummary?> _drain() async {
    ReplanSummary? result;
    try {
      do {
        _dirty = false;
        result = await _engine.replan();
        _last = result;
        if (!_results.isClosed) _results.add(result);
      } while (_dirty && !_disposed);
    } finally {
      _inflight = null;
    }
    return result;
  }

  /// Clears the schedule and plans afresh (after a restore).
  Future<ReplanSummary?> resetAndReplan() async {
    if (_disposed) return null;
    _timer?.cancel();
    await _inflight;
    final result = await _engine.resetAndReplan();
    _last = result;
    if (!_results.isClosed) _results.add(result);
    return result;
  }

  Future<void> dispose() async {
    _disposed = true;
    _timer?.cancel();
    for (final s in _subscriptions) {
      await s.cancel();
    }
    await _results.close();
  }
}
