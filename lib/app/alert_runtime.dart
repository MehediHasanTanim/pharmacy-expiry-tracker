import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/deep_links.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/expiry.dart';
import 'package:pharmacy_expiry_tracker/domain/usecases/first_run.dart';
import 'package:pharmacy_expiry_tracker/features/home/home_providers.dart';

/// Starts the alert engine with the app and keeps it fresh: initialises the
/// OS scheduler, opens a notification that launched the app, re-plans at
/// launch and whenever the app returns to the foreground.
class AlertRuntime extends ConsumerStatefulWidget {
  const AlertRuntime({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AlertRuntime> createState() => _AlertRuntimeState();
}

class _AlertRuntimeState extends ConsumerState<AlertRuntime>
    with WidgetsBindingObserver {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (ref.read(alertEngineEnabledProvider)) {
      unawaited(_start());
      // Keep the icon badge equal to the number of batches needing action.
      ref.listenManual(
        homeExpirySummaryProvider,
        (_, next) => _updateBadge(next.value),
        fireImmediately: true,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _updateBadge(ExpirySummary? summary) {
    if (summary == null) return;
    unawaited(ref.read(appBadgeProvider).setCount(needsActionCount(summary)));
  }

  Future<void> _start() async {
    final plugin = ref.read(notificationPluginProvider);
    await plugin.initialize(
      onSelected: (payload) => ref.read(deepLinksProvider).handle(payload),
    );
    if (!mounted) return;
    _started = true;
    await ensureFirstRunDate(
      ref.read(settingsRepositoryProvider),
      ref.read(clockProvider),
    );
    if (!mounted) return;
    final launched = await plugin.launchPayload();
    if (!mounted) return;
    if (launched != null) ref.read(deepLinksProvider).handle(launched);
    // Keep alerts fresh while the app stays closed (Android).
    unawaited(ref.read(backgroundReplanRegistrarProvider)());
    // Reading the coordinator starts its listeners (data and settings).
    await ref.read(alertCoordinatorProvider).replanNow();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_started) return;
    // Permission may have changed in system settings while away.
    ref
      ..invalidate(notificationPermissionsProvider)
      ..invalidate(deviceAlertConditionsProvider);
    unawaited(ref.read(alertCoordinatorProvider).replanNow());
    _updateBadge(ref.read(homeExpirySummaryProvider).value);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
