import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pharmacy_expiry_tracker/core/date/expiry_date.dart';
import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/enums.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations_en.dart';

import '../support/test_env.dart';

/// Counts passes and lets a test hold one open.
class GatedEngine extends AlertEngine {
  GatedEngine(TestEnv env)
    : super(
        settings: env.settings,
        source: env.alertSource,
        store: env.alertStore,
        scheduler: env.alertScheduler,
        plugin: env.plugin,
        clock: env.clock,
        loadL10n: (_) async => AppLocalizationsEn(),
      );

  int started = 0;
  int finished = 0;
  int running = 0;
  int maxConcurrent = 0;
  Completer<void>? gate;

  @override
  Future<ReplanSummary> replan() async {
    started++;
    running++;
    if (running > maxConcurrent) maxConcurrent = running;
    final g = gate;
    if (g != null) await g.future;
    await Future<void>.delayed(const Duration(milliseconds: 2));
    running--;
    finished++;
    return ReplanSummary(at: DateTime(2026), took: Duration.zero);
  }
}

void main() {
  late TestEnv env;
  late GatedEngine engine;
  late AlertCoordinator coordinator;

  setUp(() {
    env = TestEnv();
    engine = GatedEngine(env);
    coordinator = AlertCoordinator(
      engine,
      debounce: const Duration(milliseconds: 30),
    );
  });
  tearDown(() async {
    await coordinator.dispose();
    await env.dispose();
  });

  Future<void> pause([int ms = 120]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  group('debounce (S3-08)', () {
    test('a burst of requests becomes one pass', () async {
      for (var i = 0; i < 10; i++) {
        coordinator.request();
        await pause(5);
      }
      expect(engine.started, 0, reason: 'still inside the debounce window');
      await pause();
      expect(engine.started, 1);
    });

    test('requests separated by more than the window run separately', () async {
      coordinator.request();
      await pause();
      coordinator.request();
      await pause();
      expect(engine.started, 2);
    });

    test('replanNow skips the wait and cancels a pending request', () async {
      coordinator.request();
      final r = await coordinator.replanNow();
      expect(r, isNotNull);
      expect(engine.started, 1);
      await pause();
      expect(engine.started, 1, reason: 'the pending timer was cancelled');
    });
  });

  group('single flight', () {
    test('two overlapping requests never run two passes at once', () async {
      engine.gate = Completer<void>();
      final first = coordinator.replanNow();
      final second = coordinator.replanNow();
      await pause(20);
      expect(engine.started, 1);
      engine.gate!.complete();
      await Future.wait([first, second]);
      expect(engine.maxConcurrent, 1);
    });

    test(
      'a request that arrives mid-pass triggers exactly one more pass',
      () async {
        engine.gate = Completer<void>();
        final first = coordinator.replanNow();
        await pause(10);
        // Several late triggers collapse into a single follow-up.
        final late = coordinator.replanNow();
        unawaited(coordinator.replanNow());
        unawaited(coordinator.replanNow());
        engine.gate!.complete();
        await Future.wait([first, late]);
        expect(engine.started, 2);
        expect(engine.maxConcurrent, 1);
      },
    );

    test('every completed pass is announced', () async {
      final seen = <ReplanSummary>[];
      final sub = coordinator.results.listen(seen.add);
      await coordinator.replanNow();
      await coordinator.replanNow();
      await pause(10);
      await sub.cancel();
      expect(seen, hasLength(2));
      expect(coordinator.last, same(seen.last));
    });
  });

  group('triggers', () {
    test('a trigger stream causes a pass', () async {
      final controller = StreamController<int>();
      coordinator.listenTo(controller.stream);
      controller
        ..add(1)
        ..add(2);
      await pause();
      expect(engine.started, 1);
      await controller.close();
    });

    test('nothing runs after dispose', () async {
      coordinator.request();
      await coordinator.dispose();
      await pause();
      expect(engine.started, 0);
      expect(await coordinator.replanNow(), isNull);
    });
  });

  group('end to end: data changes keep the OS in step (S3-18, ALR-4)', () {
    late AlertCoordinator live;
    late String med;

    ExpiryDate in_(int days) {
      final d = DateTime(2026, 10, 17 + days);
      return ExpiryDate.day(d.year, d.month, d.day);
    }

    setUp(() async {
      med = await env.medicine();
      await env.settings.update(
        (s) => s.copyWith(digestEnabled: false, backupReminderDays: 0),
      );
      live =
          AlertCoordinator(
              env.alertEngine,
              debounce: const Duration(milliseconds: 20),
            )
            ..listenTo(env.bus.changes)
            ..listenTo(env.settings.watch().skip(1));
    });
    tearDown(() => live.dispose());

    Future<void> settled() async {
      await pause(80);
      // Wait out any pass still running.
      await live.replanNow();
    }

    test('adding a batch schedules its alerts without being asked', () async {
      await env.addBatch(env.batchInput(med, expiry: in_(40)));
      await settled();
      expect(env.plugin.scheduled, hasLength(5));
    });

    test('discarding it removes them again', () async {
      final b = (await env.addBatch(env.batchInput(med, expiry: in_(40))))
          .batch;
      await settled();
      await env.discardBatches([b.id]);
      await settled();
      expect(env.plugin.scheduled, isEmpty);
    });

    test('snoozing and undoing flow through to the OS', () async {
      final b = (await env.addBatch(env.batchInput(med, expiry: in_(40))))
          .batch;
      await settled();
      final prev = await env.alertState.snooze(b.id, DateTime(2026, 11, 20));
      await settled();
      // Only the alerts on or after Nov 20 remain: the day before and the day.
      expect(env.plugin.scheduled, hasLength(2));
      await env.alertState.restore(b.id, prev);
      await settled();
      expect(env.plugin.scheduled, hasLength(5));
    });

    test('a settings change re-plans', () async {
      await env.addBatch(env.batchInput(med, expiry: in_(40)));
      await settled();
      await env.settings.update((s) => s.copyWith(alertLeadDays: [0]));
      await settled();
      expect(env.plugin.scheduled, hasLength(1));
    });

    test(
      'many rapid edits settle on the right final state, with no duplicates',
      () async {
        for (var i = 1; i <= 8; i++) {
          await env.addBatch(
            env.batchInput(med, number: 'B$i', expiry: in_(10 + i)),
          );
        }
        await settled();
        final ids = env.plugin.scheduled.keys.toList();
        expect(ids.toSet(), hasLength(ids.length));
        // Re-planning again changes nothing.
        final again = await live.replanNow();
        expect(again!.isNoop, isTrue);
        // Cross-check against a from-scratch pass on a clean OS.
        final expected = ids.toSet();
        env.plugin.scheduled.clear();
        await live.replanNow();
        expect(env.plugin.scheduled.keys.toSet(), expected);
      },
    );

    test('adjusting stock that leaves quantity keeps alerts; selling out drops them', () async {
      final b = (await env.addBatch(
        env.batchInput(med, expiry: in_(40), quantity: 5),
      )).batch;
      await settled();
      await env.adjustStock(
        batchId: b.id,
        delta: -2,
        reason: AdjustmentReason.sold,
      );
      await settled();
      expect(env.plugin.scheduled, hasLength(5));
      await env.adjustStock(
        batchId: b.id,
        delta: -3,
        reason: AdjustmentReason.sold,
      );
      await settled();
      expect(env.plugin.scheduled, isEmpty);
    });
  });
}
