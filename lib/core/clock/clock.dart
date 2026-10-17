import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Source of "now". Inject this instead of calling `DateTime.now()` so that
/// date-dependent logic (expiry buckets, alert planning) is testable.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// Strips the time component, keeping the local calendar date.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Emits today's local calendar date, and again whenever the day rolls over,
/// so date-dependent providers can `watch` it and refresh at midnight.
final todayProvider = StreamProvider<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  final controller = StreamController<DateTime>();
  Timer? timer;

  void emitAndSchedule() {
    final now = clock.now();
    final today = dateOnly(now);
    controller.add(today);
    // `DateTime(y, m, d + 1)` normalises month ends and DST shifts.
    final nextMidnight = DateTime(today.year, today.month, today.day + 1);
    timer = Timer(
      nextMidnight.difference(now) + const Duration(seconds: 1),
      emitAndSchedule,
    );
  }

  emitAndSchedule();
  // Cancelling the timer (not just the subscription) leaves nothing pending.
  ref.onDispose(() {
    timer?.cancel();
    unawaited(controller.close());
  });
  return controller.stream;
});

/// Today's date as a plain value for widgets: the live [todayProvider] value
/// once it has emitted, otherwise derived from the clock.
final todayDateProvider = Provider<DateTime>((ref) {
  return ref.watch(todayProvider).value ??
      dateOnly(ref.watch(clockProvider).now());
});
