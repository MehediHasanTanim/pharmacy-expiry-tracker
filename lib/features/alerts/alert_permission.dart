import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Shown on Home while notifications are off (ALR-7). Before the system
/// prompt has ever been shown it offers to turn alerts on; afterwards, when
/// the system will not ask again, it sends the user to system settings.
class AlertPermissionBanner extends ConsumerWidget {
  const AlertPermissionBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final plugin = ref.watch(notificationPluginProvider);
    if (!plugin.isSupported) return const SizedBox.shrink();
    final permissions = ref.watch(notificationPermissionsProvider).value;
    if (permissions == null || permissions.notifications) {
      return const SizedBox.shrink();
    }
    final asked = ref.watch(
      settingsProvider.select((s) => s.value?.alertPermissionAsked ?? false),
    );
    final theme = Theme.of(context);

    return Semantics(
      container: true,
      child: Card(
        key: const Key('alert-permission-banner'),
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.notifications_off_outlined,
                color: theme.colorScheme.onErrorContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  asked
                      ? l10n.permissionBannerDenied
                      : l10n.permissionBannerAsk,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                key: const Key('alert-permission-action'),
                onPressed: () => asked
                    ? unawaited(
                        ref
                            .read(platformAlertSettingsProvider)
                            .openNotificationSettings(),
                      )
                    : unawaited(context.push(Routes.alertPermission)),
                child: Text(
                  asked
                      ? l10n.permissionBannerSettings
                      : l10n.permissionBannerAction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Explains why alerts need permission before the system asks (ALR-7).
class AlertPermissionScreen extends ConsumerStatefulWidget {
  const AlertPermissionScreen({super.key});

  @override
  ConsumerState<AlertPermissionScreen> createState() =>
      _AlertPermissionScreenState();
}

class _AlertPermissionScreenState extends ConsumerState<AlertPermissionScreen> {
  bool _busy = false;

  Future<void> _allow() async {
    setState(() => _busy = true);
    try {
      final plugin = ref.read(notificationPluginProvider);
      await plugin.initialize(onSelected: (_) {});
      await plugin.requestPermissions();
      await ref
          .read(settingsRepositoryProvider)
          .update((s) => s.copyWith(alertPermissionAsked: true));
      ref.invalidate(notificationPermissionsProvider);
      // Granting changes what the OS will accept; plan again now.
      unawaited(ref.read(alertCoordinatorProvider).replanNow());
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.permissionTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.notifications_active_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(l10n.permissionTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(l10n.permissionBody, style: theme.textTheme.bodyLarge),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('permission-allow'),
                onPressed: _busy ? null : _allow,
                child: Text(l10n.permissionAllow),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                key: const Key('permission-later'),
                onPressed: _busy ? null : context.pop,
                child: Text(l10n.permissionNotNow),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
