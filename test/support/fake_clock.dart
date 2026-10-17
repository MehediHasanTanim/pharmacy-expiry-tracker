import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';

class FakeClock implements Clock {
  FakeClock(this.current);

  DateTime current;

  @override
  DateTime now() => current;

  void advance(Duration d) => current = current.add(d);
}
