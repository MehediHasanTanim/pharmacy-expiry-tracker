import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_planner.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/planned_alert.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations_en.dart';

void main() {
  final l10n = AppLocalizationsEn();
  final now = DateTime(2026, 10, 17, 8);

  // Digest off by default so lead-time behaviour is tested on its own.
  const noDigest = AppSettings(digestEnabled: false);

  PlanBatch batch(
    String id,
    DateTime expires, {
    String name = 'Amoxil 500 mg',
    String number = 'A1',
    int qty = 10,
    int window = 90,
    DateTime? snoozedUntil,
    DateTime? handledAt,
  }) => PlanBatch(
    id: id,
    name: name,
    batchNumber: number,
    expiryDay: dayNumber(expires),
    quantity: qty,
    windowDays: window,
    snoozeDay: snoozedUntil == null ? null : dayNumber(snoozedUntil),
    handled: handledAt != null,
  );

  List<PlannedAlert> plan(
    List<PlanBatch> batches, {
    AppSettings settings = noDigest,
    DateTime? at,
    int maxPending = maxPendingAlerts,
  }) => planAlerts(
    now: at ?? now,
    settings: settings,
    batches: batches,
    l10n: l10n,
    maxPending: maxPending,
  );

  List<String> keys(List<PlannedAlert> a) => a.map((e) => e.key).toList();

  group('lead-time alerts (ALR-1)', () {
    test(
      'one batch gets an alert at each future lead time, plus expiry day',
      () {
        final a = plan([batch('1', DateTime(2026, 11, 17))]);
        // Leads 90 and 60 are already in the past; 30,14,7,1 and day-of remain.
        expect(keys(a), [
          'lead:2026-10-18',
          'lead:2026-11-03',
          'lead:2026-11-10',
          'lead:2026-11-16',
          'day:2026-11-17',
        ]);
        expect(a.first.kind, AlertKind.expiryLead);
        expect(a.last.kind, AlertKind.expiryDay);
      },
    );

    test('alerts arrive five minutes after the daily alert time', () {
      final a = plan([batch('1', DateTime(2026, 11, 17))]);
      expect(a.first.fireAt, DateTime(2026, 10, 18, 9, 5));
      expect(a.last.fireAt, DateTime(2026, 11, 17, 9, 5));
    });

    test('titles say how far away expiry is', () {
      final a = plan([batch('1', DateTime(2026, 11, 17))]);
      final byKey = {for (final x in a) x.key: x};
      expect(byKey['lead:2026-10-18']!.title, 'Expiry in 30 days');
      expect(byKey['lead:2026-11-16']!.title, 'Expires tomorrow');
      expect(byKey['day:2026-11-17']!.title, 'Expires today');
      expect(byKey['lead:2026-10-18']!.body, '1 batch: Amoxil 500 mg (A1)');
    });

    test(
      'batches reaching a lead time the same day share one notification',
      () {
        final a = plan([
          batch('1', DateTime(2026, 11, 17), name: 'Alpha', number: 'A'),
          batch('2', DateTime(2026, 11, 17), name: 'Beta', number: 'B'),
        ]);
        final lead = a.firstWhere((x) => x.key == 'lead:2026-10-18');
        expect(a.where((x) => x.key == lead.key), hasLength(1));
        expect(lead.body, '2 batches: Alpha (A), Beta (B)');
      },
    );

    test('long groups list three batches then "and N more"', () {
      final a = plan([
        for (var i = 0; i < 5; i++)
          batch('$i', DateTime(2026, 11, 17), name: 'Med$i', number: 'N$i'),
      ]);
      final lead = a.firstWhere((x) => x.key == 'lead:2026-10-18');
      expect(
        lead.body,
        '5 batches: Med0 (N0), Med1 (N1), Med2 (N2) and 2 more',
      );
    });

    test('mixed lead times on one day use a general title', () {
      final a = plan([
        batch('1', DateTime(2026, 11, 17)), // lead 30 on Oct 18
        batch('2', DateTime(2026, 10, 25), name: 'Soon'), // lead 7 on Oct 18
      ]);
      final lead = a.firstWhere((x) => x.key == 'lead:2026-10-18');
      expect(lead.title, 'Batches nearing expiry');
      expect(lead.route, '/expiry?date=2026-10-18');
    });

    test('a uniform group deep-links to its urgency bucket', () {
      final a = plan([batch('1', DateTime(2026, 11, 17))]);
      expect(
        a.firstWhere((x) => x.key == 'lead:2026-10-18').route,
        '/expiry?bucket=d30&date=2026-10-18',
      );
      expect(
        a.firstWhere((x) => x.key == 'day:2026-11-17').route,
        '/expiry?bucket=d30&date=2026-11-17',
      );
    });

    test('expiry-day alerts are separate from lead alerts on the same day', () {
      final a = plan([
        batch('1', DateTime(2026, 10, 25), name: 'Today'), // day-of Oct 25
        batch('2', DateTime(2026, 11, 1), name: 'Later'), // lead 7 on Oct 25
      ]);
      expect(keys(a), containsAll(['day:2026-10-25', 'lead:2026-10-25']));
    });
  });

  group('what is skipped', () {
    test('lead dates already past, and times earlier today', () {
      // Expires tomorrow: the 1-day lead is today at 09:05 (still ahead at
      // 08:00), then the expiry day.
      final b = batch('1', DateTime(2026, 10, 18));
      expect(keys(plan([b])), ['lead:2026-10-17', 'day:2026-10-18']);
      // By 10:00 today's slot is gone; only the expiry day remains.
      expect(keys(plan([b], at: DateTime(2026, 10, 17, 10))), [
        'day:2026-10-18',
      ]);
    });

    test(
      'expiring today: alert at 09:05 still ahead at 08:00, gone at 10:00',
      () {
        final b = batch('1', DateTime(2026, 10, 17));
        expect(keys(plan([b])), ['day:2026-10-17']);
        expect(plan([b], at: DateTime(2026, 10, 17, 10)), isEmpty);
        expect(
          plan([b], at: DateTime(2026, 10, 17, 9, 5)),
          isEmpty,
          reason: 'not strictly after now',
        );
      },
    );

    test('already expired batches have no future lead alerts', () {
      expect(plan([batch('1', DateTime(2026, 10, 1))]), isEmpty);
    });

    test('handled and empty batches never alert', () {
      final a = plan([
        batch('1', DateTime(2026, 11, 17), handledAt: DateTime(2026, 10, 16)),
        batch('2', DateTime(2026, 11, 17), qty: 0),
      ]);
      expect(a, isEmpty);
    });

    test('snoozed: silent until the snooze date, then alerts resume', () {
      final b = batch(
        '1',
        DateTime(2026, 11, 17),
        snoozedUntil: DateTime(2026, 11, 10),
      );
      expect(keys(plan([b])), [
        'lead:2026-11-10', // the snooze date itself resumes
        'lead:2026-11-16',
        'day:2026-11-17',
      ]);
    });

    test('a snooze that ends after expiry silences everything', () {
      final b = batch(
        '1',
        DateTime(2026, 11, 17),
        snoozedUntil: DateTime(2026, 12),
      );
      expect(plan([b]), isEmpty);
    });

    test('a short per-medicine window skips long lead times', () {
      final a = plan([batch('1', DateTime(2026, 12, 20), window: 14)]);
      // Leads 90/60/30 exceed the 14-day window.
      expect(keys(a), [
        'lead:2026-12-06',
        'lead:2026-12-13',
        'lead:2026-12-19',
        'day:2026-12-20',
      ]);
    });

    test('custom lead times replace the defaults', () {
      final a = plan(
        [batch('1', DateTime(2026, 11, 17))],
        settings: const AppSettings(
          digestEnabled: false,
          alertLeadDays: [14, 0],
        ),
      );
      expect(keys(a), ['lead:2026-11-03', 'day:2026-11-17']);
    });

    test('duplicate and negative lead times are ignored', () {
      final a = plan(
        [batch('1', DateTime(2026, 11, 17))],
        settings: const AppSettings(
          digestEnabled: false,
          alertLeadDays: [14, 14, -3, 0],
        ),
      );
      expect(keys(a), ['lead:2026-11-03', 'day:2026-11-17']);
    });
  });

  group('calendar edge cases (S3-05)', () {
    test('leap day: one day before 1 March 2028 is 29 February', () {
      final a = plan(
        [batch('1', DateTime(2028, 3))],
        at: DateTime(2028, 2, 20, 8),
        settings: const AppSettings(
          digestEnabled: false,
          alertLeadDays: [1, 0],
        ),
      );
      expect(keys(a), ['lead:2028-02-29', 'day:2028-03-01']);
    });

    test('no leap day in 2027', () {
      final a = plan(
        [batch('1', DateTime(2027, 3))],
        at: DateTime(2027, 2, 20, 8),
        settings: const AppSettings(digestEnabled: false, alertLeadDays: [1]),
      );
      expect(keys(a), ['lead:2027-02-28']);
    });

    test('month and year boundaries', () {
      final a = plan(
        [batch('1', DateTime(2027, 1, 5))],
        at: DateTime(2026, 12, 20, 8),
        settings: const AppSettings(
          digestEnabled: false,
          alertLeadDays: [7, 5, 0],
        ),
      );
      expect(keys(a), ['lead:2026-12-29', 'lead:2026-12-31', 'day:2027-01-05']);
    });

    test('the alert time of day is constant across every date of a year', () {
      // Covers both daylight-saving transitions in whatever zone the test
      // machine uses: a 09:05 alert must stay at 09:05 local time.
      final alerts = plan(
        [
          for (var d = 0; d < 400; d++)
            batch('$d', DateTime(2026, 10, 18 + d), name: 'M$d', number: 'B$d'),
        ],
        settings: const AppSettings(digestEnabled: false, alertLeadDays: [0]),
        maxPending: 1000,
      );
      expect(alerts, hasLength(400));
      for (final a in alerts) {
        expect(a.fireAt.hour, 9, reason: a.key);
        expect(a.fireAt.minute, 5, reason: a.key);
      }
      for (var i = 1; i < alerts.length; i++) {
        expect(alerts[i].fireAt.isAfter(alerts[i - 1].fireAt), isTrue);
      }
    });

    test('a different "now" changes only what is still ahead', () {
      final b = batch('1', DateTime(2026, 11, 17));
      final later = keys(plan([b], at: DateTime(2026, 11, 5, 8)));
      expect(later, ['lead:2026-11-10', 'lead:2026-11-16', 'day:2026-11-17']);
    });
  });

  group('quiet hours (ALR-10)', () {
    AppSettings quiet(
      int digestMinutes, {
      int start = 22 * 60,
      int end = 7 * 60,
    }) => AppSettings(
      digestEnabled: false,
      alertLeadDays: const [0],
      digestMinutes: digestMinutes,
      quietHoursEnabled: true,
      quietStartMinutes: start,
      quietEndMinutes: end,
    );

    DateTime fire(AppSettings s) =>
        plan([batch('1', DateTime(2026, 11, 17))], settings: s).single.fireAt;

    test('early-morning alert inside an overnight window moves to its end', () {
      // 06:30 + 5 min = 06:35, inside 22:00-07:00.
      expect(fire(quiet(6 * 60 + 30)), DateTime(2026, 11, 17, 7));
    });

    test('late-evening alert inside an overnight window moves to next day', () {
      expect(fire(quiet(23 * 60)), DateTime(2026, 11, 18, 7));
    });

    test('daytime window', () {
      expect(
        fire(quiet(13 * 60, start: 12 * 60, end: 14 * 60)),
        DateTime(2026, 11, 17, 14),
      );
    });

    test(
      'outside the window nothing moves; the end time itself is allowed',
      () {
        expect(fire(quiet(9 * 60)), DateTime(2026, 11, 17, 9, 5));
        expect(fire(quiet(6 * 60 + 55)), DateTime(2026, 11, 17, 7));
      },
    );

    test('equal start and end means no quiet period', () {
      expect(
        fire(quiet(23 * 60, start: 22 * 60, end: 22 * 60)),
        DateTime(2026, 11, 17, 23, 5),
      );
    });

    test('quiet hours off leaves times alone', () {
      final s = quiet(23 * 60).copyWith(quietHoursEnabled: false);
      expect(fire(s), DateTime(2026, 11, 17, 23, 5));
    });
  });

  group('daily digest (ALR-2)', () {
    AppSettings digest({bool skipEmpty = true, int hh = 9}) => AppSettings(
      alertLeadDays: const [],
      skipEmptyDigest: skipEmpty,
      digestMinutes: hh * 60,
    );

    test('nothing to report: skipped, or sent anyway when asked', () {
      expect(plan(const [], settings: digest()), isEmpty);
      final a = plan(const [], settings: digest(skipEmpty: false));
      expect(a, hasLength(14));
      expect(a.first.key, 'digest:2026-10-17');
      expect(a.last.key, 'digest:2026-10-30');
    });

    test('disabled digest produces none', () {
      expect(
        plan(
          [batch('1', DateTime(2026, 10, 20))],
          settings: const AppSettings(alertLeadDays: [], digestEnabled: false),
        ),
        isEmpty,
      );
    });

    test('a digest about to land states exact counts', () {
      final a = plan([
        batch('1', DateTime(2026, 10, 20)), // near
        batch('2', DateTime(2026, 11, 10), number: 'B'), // near (24 days)
        batch('3', DateTime(2026, 11, 20), number: 'C'), // not near
        batch('4', DateTime(2026, 10, 1), number: 'D'), // expired
      ], settings: digest());
      final today = a.firstWhere((x) => x.key == 'digest:2026-10-17');
      expect(today.body, '2 batches expiring soon · 1 expired on the shelf');
      expect(today.route, '/expiry');
      expect(today.title, 'Expiry digest');
    });

    test('digests more than a day out never claim counts', () {
      final a = plan([batch('1', DateTime(2026, 10, 20))], settings: digest());
      final later = a.firstWhere((x) => x.key == 'digest:2026-10-19');
      expect(later.body, "Open the app to review today's expiry actions.");
    });

    test('skip-empty uses projected counts: stops once nothing is due', () {
      // Expires Oct 20; "near" counts only while within 30 days and not past.
      // After it expires the batch counts as expired, so digests continue.
      final a = plan([batch('1', DateTime(2026, 10, 20))], settings: digest());
      expect(a, hasLength(14));
    });

    test(
      'a batch far in the future starts appearing when it comes in range',
      () {
        final a = plan([
          batch('1', DateTime(2026, 11, 20)),
        ], settings: digest());
        // Near from 30 days before Nov 20 = Oct 21.
        expect(a.first.key, 'digest:2026-10-21');
      },
    );

    test('handled batches are left out of the counts', () {
      final a = plan([
        batch('1', DateTime(2026, 10, 20), handledAt: DateTime(2026, 10, 1)),
      ], settings: digest());
      expect(a, isEmpty);
    });

    test('the digest time follows the setting', () {
      final a = plan([
        batch('1', DateTime(2026, 10, 20)),
      ], settings: digest(hh: 18));
      expect(a.first.fireAt, DateTime(2026, 10, 17, 18));
    });
  });

  group('cap and ordering (ALR-5)', () {
    test('keeps only the earliest alerts, in time order', () {
      final batches = [
        for (var d = 1; d <= 100; d++)
          batch('$d', DateTime(2026, 10, 17 + d), name: 'M$d', number: 'B$d'),
      ];
      final a = plan(
        batches,
        settings: const AppSettings(digestEnabled: false, alertLeadDays: [0]),
      );
      expect(a, hasLength(maxPendingAlerts));
      expect(a.first.key, 'day:2026-10-18');
      expect(a.last.key, 'day:2026-12-16');
      for (var i = 1; i < a.length; i++) {
        expect(a[i].fireAt.isAfter(a[i - 1].fireAt), isTrue);
      }
    });

    test('ties are broken by key so ordering is stable', () {
      final a = plan(
        [batch('1', DateTime(2026, 10, 25))],
        settings: const AppSettings(
          alertLeadDays: [0],
          digestMinutes: 9 * 60,
          skipEmptyDigest: false,
        ),
      );
      final sorted = [...a]
        ..sort((x, y) {
          final t = x.fireAt.compareTo(y.fireAt);
          return t != 0 ? t : x.key.compareTo(y.key);
        });
      expect(a, sorted);
    });

    test('digests and lead alerts compete for the same slots', () {
      final a = plan(
        [batch('1', DateTime(2026, 11, 17))],
        settings: const AppSettings(skipEmptyDigest: false),
        maxPending: 6,
      );
      expect(a, hasLength(6));
      expect(a.map((x) => x.kind).toSet(), contains(AlertKind.digest));
    });
  });

  group('determinism (S3-05 property tests)', () {
    List<PlanBatch> randomBatches(Random r, int n) => [
      for (var i = 0; i < n; i++)
        batch(
          'b$i',
          DateTime(2026, 10, 17 + r.nextInt(200) - 20),
          name: 'Med ${r.nextInt(40)}',
          number: 'L$i',
          qty: r.nextInt(5),
          window: [30, 60, 90, 180][r.nextInt(4)],
          snoozedUntil: r.nextInt(5) == 0
              ? DateTime(2026, 10, 17 + r.nextInt(60))
              : null,
          handledAt: r.nextInt(7) == 0 ? DateTime(2026, 10, 1) : null,
        ),
    ];

    test('planning twice gives identical results', () {
      for (var seed = 0; seed < 25; seed++) {
        final batches = randomBatches(Random(seed), 300);
        final s = AppSettings(
          digestMinutes: (seed * 37) % (24 * 60),
          quietHoursEnabled: seed.isEven,
          skipEmptyDigest: seed % 3 == 0,
        );
        expect(
          plan(batches, settings: s),
          plan(batches, settings: s),
          reason: 'seed $seed',
        );
      }
    });

    test('input order does not matter', () {
      final r = Random(7);
      final batches = randomBatches(r, 400);
      final shuffled = [...batches]..shuffle(Random(99));
      expect(
        plan(shuffled, settings: const AppSettings()),
        plan(batches, settings: const AppSettings()),
      );
    });

    test('alerts are unique by key and never in the past', () {
      for (var seed = 0; seed < 25; seed++) {
        final a = plan(
          randomBatches(Random(seed), 300),
          settings: const AppSettings(),
        );
        expect(a.map((x) => x.key).toSet(), hasLength(a.length));
        for (final x in a) {
          expect(x.fireAt.isAfter(now), isTrue, reason: x.key);
        }
      }
    });

    test('content hash is stable, and changes with content or time', () {
      final a = plan([batch('1', DateTime(2026, 11, 17))]).first;
      final same = plan([batch('1', DateTime(2026, 11, 17))]).first;
      expect(a.contentHash, same.contentHash);
      final other = plan([batch('1', DateTime(2026, 11, 17), name: 'Other')])
          .first;
      expect(other.contentHash, isNot(a.contentHash));
      final shifted = plan(
        [batch('1', DateTime(2026, 11, 17))],
        settings: const AppSettings(digestEnabled: false, digestMinutes: 600),
      ).first;
      expect(shifted.contentHash, isNot(a.contentHash));
    });
  });

  test('planning 50 000 batches takes well under a second', () {
    final r = Random(1);
    final batches = [
      for (var i = 0; i < 50000; i++)
        batch(
          'b$i',
          DateTime(2026, 10, 17 + r.nextInt(120) - 10),
          name: 'Med ${i % 5000}',
          number: 'L$i',
        ),
    ];
    final sw = Stopwatch()..start();
    final a = plan(batches, settings: const AppSettings());
    final ms = sw.elapsedMilliseconds;
    // Timings are the point of this test; print them for the log.
    // ignore: avoid_print
    print('plan of 50k batches: ${ms}ms -> ${a.length} alerts');
    expect(a, hasLength(maxPendingAlerts));
    expect(ms, lessThan(1000));
  });

  group('os ids (S3-01)', () {
    PlannedAlert alert(String key) => PlannedAlert(
      key: key,
      kind: AlertKind.digest,
      fireAt: DateTime(2030),
      title: 't',
      body: 'b',
      route: '/expiry',
    );

    test('ids are positive 31-bit and stable across calls', () {
      final a = assignOsIds([alert('lead:2026-11-01')], existingByKey: {});
      final b = assignOsIds([alert('lead:2026-11-01')], existingByKey: {});
      expect(a.single.osId, b.single.osId);
      expect(a.single.osId, inInclusiveRange(1, 0x7fffffff));
    });

    test('a known key keeps its id', () {
      final a = assignOsIds(
        [alert('lead:2026-11-01')],
        existingByKey: {'lead:2026-11-01': 42},
      );
      expect(a.single.osId, 42);
    });

    test('collisions probe forward to a free id', () {
      final first = assignOsIds([alert('k')], existingByKey: {}).single.osId;
      final probed = assignOsIds(
        [alert('k')],
        existingByKey: {},
        usedIds: {first, first + 1},
      ).single.osId;
      expect(probed, first + 2);
    });

    test('two new keys never share an id even if their hashes would clash', () {
      final ids = assignOsIds([
        for (var i = 0; i < 2000; i++) alert('digest:$i'),
      ], existingByKey: {}).map((a) => a.osId);
      expect(ids.toSet(), hasLength(2000));
    });

    test('the Alert lab id range is never used', () {
      for (var i = 0; i < 5000; i++) {
        final id = assignOsIds([alert('x$i')], existingByKey: {}).single.osId;
        expect(isLabNotificationId(id), isFalse);
      }
      // Force a probe into the reserved range.
      final base = assignOsIds([alert('y')], existingByKey: {}).single.osId;
      expect(base, isNot(0));
    });

    test('stableHash is the documented FNV-1a', () {
      expect(stableHash(''), 0x811c9dc5);
      expect(stableHash('a'), 0xe40c292c);
      expect(stableHash('foobar'), 0xbf9cf968);
    });
  });
}
