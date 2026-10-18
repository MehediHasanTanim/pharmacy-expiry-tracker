import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/core/clock/clock.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_failure.dart';
import 'package:pharmacy_expiry_tracker/data/backup/backup_service.dart';
import 'package:pharmacy_expiry_tracker/features/backup/backup_controller.dart';
import 'package:pharmacy_expiry_tracker/features/common/labels.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Back up to a file, restore from one (SEC-3, SEC-4).
class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _busy = false;

  String _message(AppLocalizations l10n, Object error) {
    if (error is BackupException) {
      return switch (error.kind) {
        BackupFailureKind.notABackup => l10n.backupErrNotABackup,
        BackupFailureKind.corrupt => l10n.backupErrCorrupt,
        BackupFailureKind.newerVersion => l10n.backupErrNewer,
        BackupFailureKind.swapFailed => l10n.backupErrSwap,
        BackupFailureKind.needsPassphrase ||
        BackupFailureKind.wrongPassphrase => l10n.backupWrongPassphrase,
      };
    }
    return l10n.backupErrGeneric;
  }

  Future<void> _backup() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final choice = await showDialog<_Passphrase>(
      context: context,
      builder: (_) => const _NewPassphraseDialog(),
    );
    if (choice == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final shared = await ref
          .read(backupControllerProvider)
          .exportAndShare(passphrase: choice.value);
      messenger.showSnackBar(
        SnackBar(
          content: Text(shared ? l10n.backupDone : l10n.backupNotShared),
        ),
      );
    } on Object catch (e, st) {
      ref.read(errorLogProvider).record('backup', e, st);
      messenger.showSnackBar(SnackBar(content: Text(_message(l10n, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Reads the chosen file, asking for a passphrase if it needs one.
  Future<BackupPreview?> _open(File file) async {
    final controller = ref.read(backupControllerProvider);
    String? passphrase;
    var wrong = false;
    while (true) {
      try {
        return await controller.inspect(file, passphrase: passphrase);
      } on BackupException catch (e) {
        final retry =
            e.kind == BackupFailureKind.needsPassphrase ||
            e.kind == BackupFailureKind.wrongPassphrase;
        if (!retry) rethrow;
        if (!mounted) return null;
        wrong = e.kind == BackupFailureKind.wrongPassphrase;
        passphrase = await showDialog<String>(
          context: context,
          builder: (_) => _AskPassphraseDialog(wrong: wrong),
        );
        if (passphrase == null) return null;
      }
    }
  }

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    setState(() => _busy = true);
    try {
      final file = await ref.read(fileExchangeProvider).pick();
      if (file == null || !mounted) return;
      final preview = await _open(file);
      if (preview == null || !mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => _PreviewDialog(preview: preview),
      );
      if (confirmed != true) return;
      await ref.read(backupControllerProvider).restore(preview);
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupRestored)));
      router.go(Routes.home);
    } on Object catch (e, st) {
      ref.read(errorLogProvider).record('restore', e, st);
      messenger.showSnackBar(SnackBar(content: Text(_message(l10n, e))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider).value;
    final due = ref.watch(backupDueProvider);
    final last = DateTime.tryParse(settings?.lastBackupAt ?? '');
    final days = last == null
        ? null
        : ref.watch(todayDateProvider).difference(dateOnly(last)).inDays;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.backupTitle)),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: due == null ? null : theme.colorScheme.tertiaryContainer,
                child: ListTile(
                  key: const Key('backup-status'),
                  leading: Icon(
                    due == null
                        ? Icons.verified_outlined
                        : Icons.backup_outlined,
                  ),
                  title: Text(
                    days == null
                        ? l10n.backupLastNever
                        : l10n.backupLastAgo(days),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.backupExplain),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('backup-now'),
                onPressed: _busy ? null : _backup,
                icon: const Icon(Icons.ios_share),
                label: Text(l10n.backupNow),
              ),
              const SizedBox(height: 24),
              Text(l10n.backupRestoreHint),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('backup-restore'),
                onPressed: _busy ? null : _restore,
                icon: const Icon(Icons.restore),
                label: Text(l10n.backupRestore),
              ),
              const SizedBox(height: 24),
              if (settings != null)
                DropdownButtonFormField<int>(
                  key: const Key('backup-reminder'),
                  initialValue:
                      _reminderChoices.contains(settings.backupReminderDays)
                      ? settings.backupReminderDays
                      : 14,
                  decoration: InputDecoration(
                    labelText: l10n.backupReminderLabel,
                  ),
                  items: [
                    for (final d in _reminderChoices)
                      DropdownMenuItem(
                        value: d,
                        child: Text(
                          d == 0
                              ? l10n.backupReminderOff
                              : l10n.backupReminderEvery(d),
                        ),
                      ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    unawaited(
                      ref
                          .read(settingsRepositoryProvider)
                          .update((s) => s.copyWith(backupReminderDays: v)),
                    );
                  },
                ),
            ],
          ),
          if (_busy)
            Positioned.fill(
              child: ColoredBox(
                color: theme.colorScheme.scrim.withValues(alpha: 0.25),
                child: Center(
                  child: Semantics(
                    liveRegion: true,
                    label: l10n.backupWorking,
                    child: const CircularProgressIndicator(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static const _reminderChoices = [0, 7, 14, 30];
}

/// A passphrase choice: [value] is null for an unprotected backup.
class _Passphrase {
  const _Passphrase(this.value);

  final String? value;
}

class _NewPassphraseDialog extends StatefulWidget {
  const _NewPassphraseDialog();

  @override
  State<_NewPassphraseDialog> createState() => _NewPassphraseDialogState();
}

class _NewPassphraseDialogState extends State<_NewPassphraseDialog> {
  final _a = TextEditingController();
  final _b = TextEditingController();
  bool _protect = false;
  String? _error;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    super.dispose();
  }

  void _submit(AppLocalizations l10n) {
    if (!_protect) {
      Navigator.pop(context, const _Passphrase(null));
      return;
    }
    if (_a.text.length < 8) {
      setState(() => _error = l10n.backupPassphraseShort);
    } else if (_a.text != _b.text) {
      setState(() => _error = l10n.backupPassphraseMismatch);
    } else {
      Navigator.pop(context, _Passphrase(_a.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.backupNow),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              key: const Key('backup-protect'),
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.backupEncryptTitle),
              value: _protect,
              onChanged: (v) => setState(() => _protect = v),
            ),
            if (_protect) ...[
              Text(l10n.backupEncryptHint),
              TextField(
                key: const Key('backup-pass'),
                controller: _a,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.backupPassphrase),
              ),
              TextField(
                key: const Key('backup-pass2'),
                controller: _b,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.backupPassphraseConfirm,
                  errorText: _error,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('backup-go'),
          onPressed: () => _submit(l10n),
          child: Text(l10n.backupNow),
        ),
      ],
    );
  }
}

class _AskPassphraseDialog extends StatefulWidget {
  const _AskPassphraseDialog({required this.wrong});

  final bool wrong;

  @override
  State<_AskPassphraseDialog> createState() => _AskPassphraseDialogState();
}

class _AskPassphraseDialogState extends State<_AskPassphraseDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.backupAskPassphraseTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.backupAskPassphraseBody),
          TextField(
            key: const Key('restore-pass'),
            controller: _c,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.backupPassphrase,
              errorText: widget.wrong ? l10n.backupWrongPassphrase : null,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('restore-pass-ok'),
          onPressed: () => Navigator.pop(context, _c.text),
          child: Text(l10n.actionConfirm),
        ),
      ],
    );
  }
}

class _PreviewDialog extends StatelessWidget {
  const _PreviewDialog({required this.preview});

  final BackupPreview preview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final m = preview.metadata;
    return AlertDialog(
      title: Text(l10n.backupPreviewTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.backupPreviewMade(formatDate(context, m.createdAt)),
              key: const Key('restore-made'),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.backupPreviewCounts(
                m.medicines,
                m.batches,
                m.suppliers,
                m.invoices,
              ),
              key: const Key('restore-counts'),
            ),
            const SizedBox(height: 12),
            Text(l10n.backupPreviewReplace),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('restore-cancel'),
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('restore-confirm'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.backupRestoreAction),
        ),
      ],
    );
  }
}
