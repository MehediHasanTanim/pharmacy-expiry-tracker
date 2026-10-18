import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/repositories/settings_repository.dart';

/// Records the day the app was first used, once. The first backup reminder
/// counts from it when there has never been a backup.
Future<void> ensureFirstRunDate(
  SettingsRepository settings,
  Clock clock,
) async {
  final d = dateOnly(clock.now());
  final today =
      '${d.year}-${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
  await settings.update(
    (s) => s.firstRunOn.isEmpty ? s.copyWith(firstRunOn: today) : s,
  );
}
