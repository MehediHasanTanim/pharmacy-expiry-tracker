import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_service.dart';
import 'package:pharmacy_expiry_tracker/data/db/app_database.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/first_run.dart';

import '../support/fake_notification_plugin.dart';
import '../support/test_env.dart';

/// Backup on one phone, restore on another, and the alerts that result
/// (S6-01, S6-02, S6-03; exit criterion "round trip proven including alerts").
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late Directory dir;
  late File live;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('restore_flow');
    live = File(p.join(dir.path, 'live.sqlite'));
  });
  tearDown(() => dir.deleteSync(recursive: true));

  ExpiryDate in_(int days) {
    final d = DateTime(2026, 10, 17 + days);
    return ExpiryDate.day(d.year, d.month, d.day);
  }

  Future<void> seedSource(TestEnv env) async {
    final m = await env.medicine(brand: 'Napa', strength: '500 mg');
    await env.addBatch(
      env.batchInput(m, number: 'N1', quantity: 10, expiry: in_(20)),
    );
    final s = await env.supplier(name: 'ABC Pharma');
    await env.invoice(s, due: DateTime(2026, 10, 25));
    await env.settings.update(
      (x) => x.copyWith(pharmacyName: 'Source Pharmacy'),
    );
  }

  List<(DateTime, String)> shape(FakeNotificationPlugin plugin) =>
      [for (final n in plugin.scheduled.values) (n.fireAt, n.title)]
        ..sort((a, b) => a.$1.compareTo(b.$1));

  test('restoring on another phone brings data, settings and alerts', () async {
    // Phone A: real data and its alerts.
    final a = TestEnv();
    await seedSource(a);
    await ensureFirstRunDate(a.settings, a.clock);
    expect((await a.alertEngine.replan()).error, isNull);
    final expected = shape(a.plugin);
    expect(expected, isNotEmpty);
    final service = BackupService(
      workDir: Directory(p.join(dir.path, 'work')),
      clock: a.clock,
      appVersion: '1.0.0+1',
      iterations: 1000,
    );
    final backup = await service.create(a.db, passphrase: 'secret');
    await a.dispose();

    // Phone B: different data, different (stale) notifications, same OS.
    final osPlugin = FakeNotificationPlugin();
    var b = TestEnv(
      database: AppDatabase(NativeDatabase(live)),
      plugin: osPlugin,
    );
    final other = await b.medicine(brand: 'Other', strength: null);
    await b.addBatch(
      b.batchInput(other, number: 'X', quantity: 3, expiry: in_(5)),
    );
    await b.alertEngine.replan();
    final stale = shape(osPlugin);
    expect(stale, isNotEmpty);
    // A test notification from the Alert lab must survive.
    await osPlugin.schedule(
      ScheduledNotification(
        id: 9000001,
        fireAt: DateTime(2026, 10, 30),
        title: 'lab',
        body: 'lab',
      ),
    );

    // Restore.
    final preview = await service.inspect(backup.file, passphrase: 'secret');
    expect(preview.metadata.medicines, 1);
    final dbToClose = b.db;
    await service.swapIn(
      live: live,
      preview: preview,
      closeDb: () async {
        await b.bus.dispose();
        await dbToClose.close();
      },
    );
    b = TestEnv(database: AppDatabase(NativeDatabase(live)), plugin: osPlugin);
    addTearDown(b.dispose);

    // Data and settings are those of phone A.
    final names = [
      for (final m in await b.db.select(b.db.medicines).get()) m.brandName,
    ];
    expect(names, ['Napa']);
    expect((await b.settings.load()).pharmacyName, 'Source Pharmacy');
    // The restored database carries the time of the backup.
    expect((await b.settings.load()).lastBackupAt, isNotEmpty);

    // Alerts: stale ones go, the restored data's come, the lab one stays.
    final summary = await b.alertEngine.resetAndReplan();
    expect(summary.error, isNull);
    expect(osPlugin.scheduled.containsKey(9000001), isTrue);
    final now = [
      for (final n in osPlugin.scheduled.values)
        if (n.id != 9000001) (n.fireAt, n.title),
    ]..sort((x, y) => x.$1.compareTo(y.$1));
    expect(now, expected);
    for (final s in stale) {
      if (!expected.contains(s)) expect(now, isNot(contains(s)));
    }
    // And re-planning again changes nothing (no duplicates).
    expect((await b.alertEngine.replan()).isNoop, isTrue);
  });

  test('restore does not leave records of the old schedule behind', () async {
    final env = TestEnv();
    addTearDown(env.dispose);
    final m = await env.medicine();
    await env.addBatch(env.batchInput(m, quantity: 5, expiry: in_(10)));
    await env.alertEngine.replan();
    expect(await env.alertStore.all(), isNotEmpty);
    await env.alertStore.clearSchedule();
    expect(await env.alertStore.all(), isEmpty);
    await env.alertEngine.resetAndReplan();
    expect(await env.alertStore.all(), isNotEmpty);
  });

  test('the first-use date is recorded once', () async {
    final env = TestEnv();
    addTearDown(env.dispose);
    expect((await env.settings.load()).firstRunOn, isEmpty);
    await ensureFirstRunDate(env.settings, env.clock);
    expect((await env.settings.load()).firstRunOn, '2026-10-17');
    env.clock.current = DateTime(2026, 11, 20);
    await ensureFirstRunDate(env.settings, env.clock);
    expect((await env.settings.load()).firstRunOn, '2026-10-17');
  });

  test('backup reminders are scheduled once there is data', () async {
    final env = TestEnv();
    addTearDown(env.dispose);
    await env.settings.update(
      (x) => x.copyWith(digestEnabled: false, alertLeadDays: const []),
    );
    await env.alertEngine.replan();
    expect(env.plugin.scheduled, isEmpty, reason: 'no data, no nagging');
    // Before the first-use date is known there is nothing to count from.
    await env.medicine();
    await env.alertEngine.replan();
    expect(env.plugin.scheduled, isEmpty);
    await ensureFirstRunDate(env.settings, env.clock);
    await env.alertEngine.replan();
    final titles = env.plugin.scheduled.values.map((n) => n.title).toSet();
    expect(titles, {'Back up your data'});
    expect(
      env.plugin.scheduled.values.first.fireAt,
      DateTime(2026, 10, 31, 9, 20),
    );
    // A backup pushes it out again.
    await env.settings.update(
      (x) =>
          x.copyWith(lastBackupAt: DateTime(2026, 10, 17, 9).toIso8601String()),
    );
    await env.alertEngine.replan();
    expect(
      env.plugin.scheduled.values.first.fireAt,
      DateTime(2026, 10, 31, 9, 20),
    );
  });
}
