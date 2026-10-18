import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/report.dart';

/// Ready-made periods for reports and statements.
enum RangePreset { month, days90, year }

DateRange presetRange(RangePreset p, DateTime today) {
  final t = dateOnly(today);
  return switch (p) {
    RangePreset.month => DateRange(DateTime(t.year, t.month), t),
    RangePreset.days90 => DateRange(DateTime(t.year, t.month, t.day - 89), t),
    RangePreset.year => DateRange(DateTime(t.year), t),
  };
}

/// Ticks whenever stored data changes, so reports on screen stay current.
final dataVersionProvider = StreamProvider.autoDispose<int>((ref) async* {
  var n = 0;
  yield n;
  await for (final _ in ref.watch(dataChangeBusProvider).changes) {
    yield ++n;
  }
});

class _RangeNotifier extends Notifier<DateRange> {
  @override
  DateRange build() =>
      presetRange(RangePreset.month, ref.read(todayDateProvider));

  void set(DateRange r) => state = r;
}

final reportRangeProvider = NotifierProvider<_RangeNotifier, DateRange>(
  _RangeNotifier.new,
);

class _LossGroupNotifier extends Notifier<LossGroup> {
  @override
  LossGroup build() => LossGroup.month;

  void set(LossGroup g) => state = g;
}

final lossGroupProvider = NotifierProvider<_LossGroupNotifier, LossGroup>(
  _LossGroupNotifier.new,
);

class _FlagNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set({required bool value}) => state = value;
}

final includeDamagedProvider = NotifierProvider<_FlagNotifier, bool>(
  _FlagNotifier.new,
);

class _ValuationGroupNotifier extends Notifier<ValuationGroup> {
  @override
  ValuationGroup build() => ValuationGroup.medicine;

  void set(ValuationGroup g) => state = g;
}

final valuationGroupProvider =
    NotifierProvider<_ValuationGroupNotifier, ValuationGroup>(
      _ValuationGroupNotifier.new,
    );

final lossReportProvider = FutureProvider.autoDispose<GroupedReport>((ref) {
  ref.watch(dataVersionProvider);
  return ref
      .watch(reportRepositoryProvider)
      .expiryLoss(
        ref.watch(reportRangeProvider),
        ref.watch(lossGroupProvider),
        includeDamaged: ref.watch(includeDamagedProvider),
      );
});

final stockReportProvider = FutureProvider.autoDispose<GroupedReport>((ref) {
  ref.watch(dataVersionProvider);
  return ref
      .watch(reportRepositoryProvider)
      .stockValuation(ref.watch(valuationGroupProvider));
});

final duesReportProvider = FutureProvider.autoDispose<AgingReport>((ref) {
  ref.watch(dataVersionProvider);
  return ref
      .watch(reportRepositoryProvider)
      .duesAging(ref.watch(todayDateProvider));
});
