import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/alert_runtime.dart';
import 'package:pharmacy_expiry_tracker/app/onboarding_gate.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/router.dart';
import 'package:pharmacy_expiry_tracker/app/theme.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/features/lock/lock_screen.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      settingsProvider.select(
        (s) => switch (s.value?.themeMode) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system,
        },
      ),
    );
    return AlertRuntime(
      child: MaterialApp.router(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: mode,
        routerConfig: ref.watch(routerProvider),
        builder: (context, child) =>
            ref.watch(onboardingStateProvider) == OnboardingState.unknown
            // Settings are a moment from loading; showing a screen now could
            // flash Home before first-run onboarding.
            ? const ColoredBox(color: Colors.transparent)
            : LockGate(
                child: FormatScope(
                  datePattern: ref.watch(
                    settingsProvider.select((s) => s.value?.dateFormat ?? ''),
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
