import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/deep_links.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';

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
    if (ref.read(alertEngineEnabledProvider)) unawaited(_start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _start() async {
    final plugin = ref.read(notificationPluginProvider);
    await plugin.initialize(
      onSelected: (payload) => ref.read(deepLinksProvider).handle(payload),
    );
    if (!mounted) return;
    _started = true;
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
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
