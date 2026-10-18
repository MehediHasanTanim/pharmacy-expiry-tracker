import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';

/// Whether the app can show a deep-linked screen yet. Stays true until a
/// feature that blocks the UI (onboarding, app lock) sets it false.
class DeepLinkReady extends Notifier<bool> {
  @override
  bool build() => true;

  void set({required bool ready}) => state = ready;
}

final deepLinkReadyProvider = NotifierProvider<DeepLinkReady, bool>(
  DeepLinkReady.new,
);

/// Route held back while [deepLinkReadyProvider] is false.
class PendingDeepLink extends Notifier<String?> {
  @override
  String? build() => null;

  void hold(String route) => state = route;

  void clear() => state = null;
}

final pendingDeepLinkProvider = NotifierProvider<PendingDeepLink, String?>(
  PendingDeepLink.new,
);

/// Routes a tapped notification's payload to a screen.
class DeepLinks {
  DeepLinks(this._ref);

  final Ref _ref;

  static const _allowed = [
    Routes.home,
    Routes.stock,
    Routes.expiry,
    Routes.suppliers,
    Routes.more,
  ];

  /// Only in-app routes are followed; anything else in a payload is ignored.
  static bool isValid(String? payload) {
    if (payload == null || !payload.startsWith('/')) return false;
    final uri = Uri.tryParse(payload);
    if (uri == null) return false;
    return _allowed.any((p) => uri.path == p || uri.path.startsWith('$p/'));
  }

  /// Opens [payload], or holds it until the app is ready (e.g. unlocked).
  void handle(String? payload) {
    if (!isValid(payload)) {
      if (payload != null) {
        debugPrint('Ignoring notification payload: $payload');
      }
      return;
    }
    if (!_ref.read(deepLinkReadyProvider)) {
      _ref.read(pendingDeepLinkProvider.notifier).hold(payload!);
      return;
    }
    _ref.read(routerProvider).go(payload!);
  }

  /// Opens a route that was held back; call when the app becomes ready.
  void flush() {
    final pending = _ref.read(pendingDeepLinkProvider);
    if (pending == null) return;
    _ref.read(pendingDeepLinkProvider.notifier).clear();
    handle(pending);
  }
}

final deepLinksProvider = Provider<DeepLinks>(DeepLinks.new);
