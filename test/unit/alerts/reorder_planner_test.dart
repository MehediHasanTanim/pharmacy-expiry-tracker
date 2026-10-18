import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_planner.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 17, 8);

  // Only reorder reminders.
  const base = AppSettings(digestEnabled: false, alertLeadDays: []);

  PlanReorder item(
    String id, {
    String name = 'Amoxil 500 mg',
    int usable = 4,
    DateTime? last,
    DateTime? snoozedUntil,
  }) => PlanReorder(
    medicineId: id,
    name: name,
    usable: usable,
    lastNotifiedDay: last == null ? null : dayNumber(last),
    snoozeDay: snoozedUntil == null ? null : dayNumber(snoozedUntil),
  );

  List<PlannedAlert> plan(
    List<PlanReorder> items, {
    AppSettings settings = base,
    DateTime? at,
  }) => planAlerts(
    now: at ?? now,
    settings: settings,
    batches: const [],
    reorders: items,
    l10n: l10n,
  );

  List<String> keys(List<PlannedAlert> a) => a.map((e) => e.key).toList();

  test(
    'a medicine never reminded about is reminded today, then every 3 days',
    () {
      final a = plan([item('m1')]);
      expect(keys(a), [
        'reorder:2026-10-17',
        'reorder:2026-10-20',
        'reorder:2026-10-23',
        'reorder:2026-10-26',
        'reorder:2026-10-29',
      ]);
      expect(a.first.kind, AlertKind.reorder);
      expect(a.first.fireAt, DateTime(2026, 10, 17, 9, 15));
    },
  );

  test('the interval comes from the setting (SET-7)', () {
    final a = plan([item('m1')], settings: base.copyWith(reorderRefireDays: 7));
    expect(keys(a), [
      'reorder:2026-10-17',
      'reorder:2026-10-24',
      'reorder:2026-10-31',
    ]);
  });

  test('after a delivered reminder it waits out the interval', () {
    final a = plan([item('m1', last: DateTime(2026, 10, 16))]);
    // Last reminder yesterday: next one is yesterday + 3 = Oct 19.
    expect(keys(a).first, 'reorder:2026-10-19');
  });

  test('a long-ago reminder means remind now', () {
    final a = plan([item('m1', last: DateTime(2026, 9))]);
    expect(keys(a).first, 'reorder:2026-10-17');
  });

  test("if today's reminder time has passed, start tomorrow", () {
    final a = plan([item('m1')], at: DateTime(2026, 10, 17, 10));
    expect(keys(a).first, 'reorder:2026-10-18');
  });

  test('snooze skips reminders before its date, then resumes', () {
    final a = plan([item('m1', snoozedUntil: DateTime(2026, 10, 23))]);
    expect(keys(a).first, 'reorder:2026-10-23');
  });

  test('text names the medicine and what is left', () {
    final a = plan([item('m1', usable: 4)]);
    expect(a.first.title, '1 medicine to reorder');
    expect(a.first.body, 'Amoxil 500 mg (4 left)');
    expect(a.first.route, '/more/reorder');
  });

  test('several medicines share a notification; long lists are trimmed', () {
    final a = plan([
      for (var i = 0; i < 5; i++) item('m$i', name: 'Med$i', usable: i),
    ]);
    final first = a.first;
    expect(first.title, '5 medicines to reorder');
    expect(
      first.body,
      'Med0 (0 left), Med1 (1 left), Med2 (2 left) and 2 more',
    );
    expect(first.refs, [
      'm0',
      'm1',
      'm2',
      'm3',
      'm4',
    ], reason: 'every medicine is recorded, not just the three named');
  });

  test('medicines on different schedules land on their own days', () {
    final a = plan([
      item('a', name: 'A'),
      item('b', name: 'B', last: DateTime(2026, 10, 16)),
    ]);
    final byKey = {for (final x in a) x.key: x};
    expect(byKey['reorder:2026-10-17']!.refs, ['a']);
    expect(byKey['reorder:2026-10-19']!.refs, ['b']);
    expect(byKey['reorder:2026-10-20']!.refs, ['a']);
  });

  test('nothing below the level means no reminders', () {
    expect(plan(const []), isEmpty);
  });

  test(
    'refs are part of the content hash, so a changed set is rescheduled',
    () {
      final one = plan([item('m1', name: 'Same', usable: 2)]).first;
      final two = plan([
        item('m1', name: 'Same', usable: 2),
        item('m2', name: 'Same', usable: 2),
      ]).first;
      expect(one.contentHash, isNot(two.contentHash));
    },
  );

  test('quiet hours move them like any other alert', () {
    final a = plan(
      [item('m1')],
      settings: base.copyWith(digestMinutes: 23 * 60, quietHoursEnabled: true),
      at: DateTime(2026, 10, 17, 8),
    );
    expect(a.first.fireAt, DateTime(2026, 10, 18, 7));
  });

  test('deterministic and independent of input order', () {
    final items = [
      for (var i = 0; i < 40; i++)
        item(
          'm$i',
          name: 'Med ${i % 7}',
          usable: i % 5,
          last: i.isEven ? DateTime(2026, 10, 10 + i % 6) : null,
          snoozedUntil: i % 9 == 0 ? DateTime(2026, 10, 25) : null,
        ),
    ];
    final shuffled = [...items]..shuffle();
    expect(plan(items), plan(shuffled));
  });
}
