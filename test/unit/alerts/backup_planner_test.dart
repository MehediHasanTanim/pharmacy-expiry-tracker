import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_planner.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 17, 8);
  const base = AppSettings(digestEnabled: false, alertLeadDays: []);

  List<PlannedAlert> plan({
    DateTime? anchor,
    bool hasData = true,
    AppSettings settings = base,
    DateTime? at,
  }) => planAlerts(
    now: at ?? now,
    settings: settings,
    batches: const [],
    backupAnchor: anchor,
    hasData: hasData,
    l10n: l10n,
  );

  List<String> keys(List<PlannedAlert> a) => a.map((e) => e.key).toList();

  test('14 days after the last backup, then weekly while it stays undone', () {
    final a = plan(
      anchor: DateTime(2026, 10, 10, 15),
      settings: base.copyWith(lastBackupAt: '2026-10-10T15:00:00.000'),
    );
    expect(keys(a), ['backup:2026-10-24', 'backup:2026-10-31']);
    expect(a.first.kind, AlertKind.backup);
    // Daily alert time 09:00 + 20 minutes.
    expect(a.first.fireAt, DateTime(2026, 10, 24, 9, 20));
    expect(
      a.first.body,
      'Your last backup was 14 days ago. Save a fresh copy.',
    );
  });

  test('an overdue backup is reminded at the next daily slot', () {
    final a = plan(
      anchor: DateTime(2026, 9, 1),
      settings: base.copyWith(lastBackupAt: '2026-09-01T10:00:00.000'),
    );
    expect(a.first.key, 'backup:2026-10-17');
    expect(a.first.fireAt, DateTime(2026, 10, 17, 9, 20));
    // Once today's slot has passed, it moves to tomorrow.
    final late = plan(
      anchor: DateTime(2026, 9, 1),
      at: DateTime(2026, 10, 17, 10),
    );
    expect(late.first.key, 'backup:2026-10-18');
  });

  test('with no backup ever, it counts from the first use', () {
    final a = plan(anchor: DateTime(2026, 10, 10));
    expect(a.first.key, 'backup:2026-10-24');
    expect(a.first.body, contains('not made a backup'));
  });

  test('nothing when switched off, without data, or without an anchor', () {
    final old = DateTime(2026, 1, 1);
    expect(
      plan(anchor: old, settings: base.copyWith(backupReminderDays: 0)),
      isEmpty,
    );
    expect(plan(anchor: old, hasData: false), isEmpty);
    expect(plan(), isEmpty);
  });

  test('the interval setting is respected', () {
    final a = plan(
      anchor: DateTime(2026, 10, 15),
      settings: base.copyWith(backupReminderDays: 3),
    );
    expect(a.first.key, 'backup:2026-10-18');
  });

  group('hide details on the lock screen', () {
    const hidden = AppSettings(
      digestEnabled: false,
      alertLeadDays: [0],
      hideDetailsOnLockScreen: true,
    );

    test('keeps titles but replaces the bodies that name things', () {
      final batch = PlanBatch(
        id: 'b1',
        name: 'Napa 500 mg',
        batchNumber: 'A1',
        expiryDay: dayNumber(DateTime(2026, 10, 20)),
        quantity: 5,
        windowDays: 90,
      );
      final shown = planAlerts(
        now: now,
        settings: hidden.copyWith(hideDetailsOnLockScreen: false),
        batches: [batch],
        l10n: l10n,
      );
      final masked = planAlerts(
        now: now,
        settings: hidden,
        batches: [batch],
        l10n: l10n,
      );
      expect(shown.single.body, contains('Napa'));
      expect(masked.single.title, shown.single.title);
      expect(masked.single.body, 'Open the app to see details.');
      expect(masked.single.key, shown.single.key);
    });

    test('the backup reminder names nothing, so it stays as is', () {
      final a = plan(
        anchor: DateTime(2026, 9, 1),
        settings: hidden.copyWith(alertLeadDays: const []),
      );
      expect(a.map((e) => e.kind).toSet(), {AlertKind.backup});
      expect(a.first.body, isNot('Open the app to see details.'));
    });
  });
}
