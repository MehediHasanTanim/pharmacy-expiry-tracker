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
final todayProvider = StreamProvider<DateTime>((ref) async* {
  final clock = ref.watch(clockProvider);
  while (true) {
    final now = clock.now();
    final today = dateOnly(now);
    yield today;
    // `DateTime(y, m, d + 1)` normalises month ends and DST shifts.
    final nextMidnight = DateTime(today.year, today.month, today.day + 1);
    await Future<void>.delayed(
      nextMidnight.difference(now) + const Duration(seconds: 1),
    );
  }
});
