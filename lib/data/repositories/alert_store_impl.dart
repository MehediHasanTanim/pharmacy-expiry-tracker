import 'dart:convert';

import 'package:drift/drift.dart' hide Batch;
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/data/mappers/mappers.dart';
import 'package:pharmacy_expiry_tracker/data/repositories/reorder_sql.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_planner.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_records.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/alert_store.dart';

DateTime _ms(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

class AlertStoreImpl implements AlertStore {
  AlertStoreImpl(this._db);

  final AppDatabase _db;

  $ScheduledAlertsTable get _s => _db.scheduledAlerts;

  ScheduledAlertRecord _record(ScheduledAlert r) {
    final payload = jsonDecode(r.payload) as Map<String, dynamic>;
    return ScheduledAlertRecord(
      key: r.id,
      kind: AlertKind.fromDb(r.kind),
      fireAt: _ms(r.fireAt),
      osId: r.osId,
      title: payload['title'] as String? ?? '',
      body: payload['body'] as String? ?? '',
      route: payload['route'] as String? ?? '',
      contentHash: r.contentHash,
      state: ScheduledState.fromDb(r.state),
      refs: [
        for (final id in (payload['refs'] as List<dynamic>? ?? const []))
          id as String,
      ],
    );
  }

  @override
  Future<List<ScheduledAlertRecord>> all() async {
    final rows = await (_db.select(
      _s,
    )..orderBy([(r) => OrderingTerm.asc(r.fireAt)])).get();
    return rows.map(_record).toList();
  }

  @override
  Future<void> upsertPending(PlannedAlert a) {
    return _db
        .into(_s)
        .insertOnConflictUpdate(
          ScheduledAlertsCompanion.insert(
            id: a.key,
            kind: a.kind.db,
            fireAt: a.fireAt.millisecondsSinceEpoch,
            osId: a.osId,
            payload: jsonEncode({
              'title': a.title,
              'body': a.body,
              'route': a.route,
              'refs': a.refs,
            }),
            contentHash: a.contentHash,
            state: ScheduledState.pending.db,
          ),
        );
  }

  @override
  Future<void> markState(List<String> keys, ScheduledState state) async {
    if (keys.isEmpty) return;
    await (_db.update(_s)..where((r) => r.id.isIn(keys))).write(
      ScheduledAlertsCompanion(state: Value(state.db)),
    );
  }

  @override
  Future<List<ScheduledAlertRecord>> markPastDueFired(DateTime now) async {
    final due =
        await (_db.select(_s)
              ..where(
                (r) =>
                    r.state.equals(ScheduledState.pending.db) &
                    r.fireAt.isSmallerOrEqualValue(now.millisecondsSinceEpoch),
              )
              ..orderBy([(r) => OrderingTerm.asc(r.fireAt)]))
            .get();
    if (due.isEmpty) return const [];
    await markState([for (final r in due) r.id], ScheduledState.fired);
    return due.map(_record).toList();
  }

  @override
  Future<void> prune({required DateTime rows, required DateTime log}) async {
    await (_db.delete(_s)..where(
          (r) =>
              r.state.equals(ScheduledState.pending.db).not() &
              r.fireAt.isSmallerThanValue(rows.millisecondsSinceEpoch),
        ))
        .go();
    await (_db.delete(_db.alertLog)..where(
          (l) => l.firedAt.isSmallerThanValue(log.millisecondsSinceEpoch),
        ))
        .go();
  }

  @override
  Future<void> addLog(AlertLogEntry e) {
    return _db
        .into(_db.alertLog)
        .insertOnConflictUpdate(
          AlertLogCompanion.insert(
            id: e.id,
            kind: e.kind.db,
            title: e.title,
            body: e.body,
            route: Value(e.route),
            firedAt: e.firedAt.millisecondsSinceEpoch,
            openedAt: Value(e.openedAt?.millisecondsSinceEpoch),
          ),
        );
  }

  @override
  Stream<List<AlertLogEntry>> watchLog({int limit = 100}) {
    return (_db.select(_db.alertLog)
          ..orderBy([(l) => OrderingTerm.desc(l.firedAt)])
          ..limit(limit))
        .watch()
        .map(
          (rows) => [
            for (final l in rows)
              AlertLogEntry(
                id: l.id,
                kind: AlertKind.fromDb(l.kind),
                title: l.title,
                body: l.body,
                route: l.route,
                firedAt: _ms(l.firedAt),
                openedAt: l.openedAt == null ? null : _ms(l.openedAt!),
              ),
          ],
        );
  }

  @override
  Future<void> markLogOpened(String id, DateTime at) async {
    await (_db.update(_db.alertLog)..where((l) => l.id.equals(id))).write(
      AlertLogCompanion(openedAt: Value(at.millisecondsSinceEpoch)),
    );
  }

  @override
  Future<DateTime?> nextPendingFireAt(DateTime now) async {
    final next = _s.fireAt.min();
    final row =
        await (_db.selectOnly(_s)
              ..addColumns([next])
              ..where(
                _s.state.equals(ScheduledState.pending.db) &
                    _s.fireAt.isBiggerThanValue(now.millisecondsSinceEpoch),
              ))
            .getSingle();
    final ms = row.read(next);
    return ms == null ? null : _ms(ms);
  }

  @override
  Future<void> markReorderNotified(
    List<String> medicineIds,
    DateTime day,
  ) async {
    final iso = dateToIso(day);
    for (final id in medicineIds) {
      // Only the notified date changes; an existing snooze is kept.
      await _db
          .into(_db.reorderReminderState)
          .insertOnConflictUpdate(
            ReorderReminderStateCompanion(
              medicineId: Value(id),
              lastNotifiedOn: Value(iso),
            ),
          );
    }
  }

  @override
  Future<void> clearSchedule() => _db.delete(_db.scheduledAlerts).go();

  @override
  Stream<int> watchPendingCount() {
    final count = _s.id.count();
    return (_db.selectOnly(_s)
          ..addColumns([count])
          ..where(_s.state.equals(ScheduledState.pending.db)))
        .watchSingle()
        .map((r) => r.read(count) ?? 0);
  }
}

class AlertSourceImpl implements AlertSource {
  AlertSourceImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<PlanBatch>> loadPlanBatches({
    required DateTime today,
    required int globalWindowDays,
    int? horizonDays,
  }) async {
    final horizon = horizonDays == null
        ? null
        : dateToIso(DateTime(today.year, today.month, today.day + horizonDays));
    // Raw SQL, with dates already turned into day numbers: this runs over tens
    // of thousands of rows and building a Dart date for each would dominate.
    final rows = await _db
        .customSelect(
          """
      SELECT b.id AS id,
             b.batch_number AS batch_number,
             CAST(strftime('%s', b.expiry_date) AS INTEGER) / 86400 AS expiry_day,
             b.quantity_on_hand AS qty,
             CASE WHEN b.snoozed_until IS NULL THEN NULL
                  ELSE CAST(strftime('%s', b.snoozed_until) AS INTEGER) / 86400
             END AS snooze_day,
             m.brand_name AS brand,
             m.strength AS strength,
             coalesce(m.alert_window_days, ?) AS window_days
      FROM batches b
      JOIN medicines m ON m.id = b.medicine_id
      WHERE b.deleted_at IS NULL
        AND b.status = 'ACTIVE'
        AND b.quantity_on_hand > 0
        AND b.handled_at IS NULL
        AND m.deleted_at IS NULL
        AND m.is_archived = 0
        AND (? IS NULL OR b.expiry_date <= ?)
      """,
          variables: [
            Variable<int>(globalWindowDays),
            Variable<String>(horizon),
            Variable<String>(horizon),
          ],
          readsFrom: {_db.batches, _db.medicines},
        )
        .get();

    return [
      for (final r in rows)
        PlanBatch(
          id: r.data['id']! as String,
          name: _name(
            r.data['brand']! as String,
            r.data['strength'] as String?,
          ),
          batchNumber: r.data['batch_number']! as String,
          expiryDay: r.data['expiry_day']! as int,
          quantity: r.data['qty']! as int,
          windowDays: r.data['window_days']! as int,
          snoozeDay: r.data['snooze_day'] as int?,
        ),
    ];
  }

  @override
  Future<bool> hasData() async {
    final row = await _db
        .customSelect('SELECT EXISTS(SELECT 1 FROM medicines) AS e')
        .getSingle();
    return row.read<int>('e') == 1;
  }

  @override
  Future<List<PlanReorder>> loadPlanReorders({required DateTime today}) async {
    final rows = await _db
        .customSelect(
          belowLevelSql,
          variables: [Variable<String>(dateToIso(today))],
          readsFrom: {_db.medicines, _db.batches, _db.reorderReminderState},
        )
        .get();
    int? day(Object? iso) =>
        iso == null ? null : dayNumber(dateFromIso(iso as String));
    return [
      for (final r in rows)
        PlanReorder(
          medicineId: r.data['id']! as String,
          name: _name(
            r.data['brand']! as String,
            r.data['strength'] as String?,
          ),
          usable: r.data['usable']! as int,
          lastNotifiedDay: day(r.data['last_notified_on']),
          snoozeDay: day(r.data['snoozed_until']),
        ),
    ];
  }

  @override
  Future<List<PlanInvoice>> loadPlanInvoices() async {
    final rows = await _db
        .customSelect(
          '''
      SELECT i.id AS id, i.supplier_id AS supplier_id,
             i.invoice_number AS invoice_number,
             s.name AS supplier_name,
             CAST(strftime('%s', v.due_date) AS INTEGER) / 86400 AS due_day,
             v.balance_minor AS balance,
             CASE WHEN i.reminders_snoozed_until IS NULL THEN NULL
                  ELSE CAST(strftime('%s', i.reminders_snoozed_until) AS INTEGER) / 86400
             END AS snooze_day
      FROM v_invoice_balance v
      JOIN supplier_invoices i ON i.id = v.invoice_id
      JOIN suppliers s ON s.id = v.supplier_id AND s.deleted_at IS NULL
      WHERE v.balance_minor > 0 AND v.due_date IS NOT NULL
      ''',
          readsFrom: {
            _db.supplierInvoices,
            _db.supplierPayments,
            _db.supplierCredits,
          },
        )
        .get();
    return [
      for (final r in rows)
        PlanInvoice(
          id: r.data['id']! as String,
          supplierId: r.data['supplier_id']! as String,
          supplierName: r.data['supplier_name']! as String,
          invoiceNumber: r.data['invoice_number'] as String?,
          dueDay: r.data['due_day']! as int,
          balanceMinor: r.data['balance']! as int,
          snoozeDay: r.data['snooze_day'] as int?,
        ),
    ];
  }

  static String _name(String brand, String? strength) =>
      strength == null || strength.isEmpty ? brand : '$brand $strength';
}
