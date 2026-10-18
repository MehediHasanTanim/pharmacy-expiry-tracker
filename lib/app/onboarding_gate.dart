import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';

/// Whether first-run onboarding is shown at all. Tests that exercise other
/// screens switch it off.
final onboardingEnabledProvider = Provider<bool>((ref) => true);

/// Where the user is in first-run setup.
enum OnboardingState {
  /// Settings have not loaded yet; do not redirect anywhere.
  unknown,
  needed,
  done,
}

final onboardingStateProvider = Provider<OnboardingState>((ref) {
  if (!ref.watch(onboardingEnabledProvider)) return OnboardingState.done;
  final settings = ref.watch(settingsProvider);
  if (!settings.hasValue) return OnboardingState.unknown;
  return settings.requireValue.onboardingDone
      ? OnboardingState.done
      : OnboardingState.needed;
});

/// Pokes the router to re-run its redirect when [onboardingStateProvider]
/// changes.
class OnboardingRefresh extends ChangeNotifier {
  void poke() => notifyListeners();
}
