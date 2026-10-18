import 'package:pharmacy_expiry_tracker/domain/alerts/alert_engine.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations_en.dart';

import 'test_env.dart';

/// An [AlertEngine] that only counts passes.
///
/// Widget tests run inside the tester's fake clock. A real pass holds a
/// database transaction that cannot finish until the test pumps, so a test
/// that also reads the database in real time would deadlock. Screens that
/// merely *ask* for a pass use this stub instead.
class StubAlertEngine extends AlertEngine {
  StubAlertEngine(TestEnv env)
    : _env = env,
      super(
        settings: env.settings,
        source: env.alertSource,
        store: env.alertStore,
        scheduler: env.alertScheduler,
        plugin: env.plugin,
        clock: env.clock,
        loadL10n: (_) async => AppLocalizationsEn(),
      );

  final TestEnv _env;
  int replans = 0;

  @override
  Future<ReplanSummary> replan() async {
    replans++;
    return ReplanSummary(at: _env.clock.now(), took: Duration.zero);
  }
}
