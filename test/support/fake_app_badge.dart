import 'package:pharmacy_expiry_tracker/domain/notifications/app_badge.dart';

class FakeAppBadge implements AppBadge {
  final counts = <int>[];

  int? get current => counts.isEmpty ? null : counts.last;

  @override
  Future<void> setCount(int count) async => counts.add(count);
}
