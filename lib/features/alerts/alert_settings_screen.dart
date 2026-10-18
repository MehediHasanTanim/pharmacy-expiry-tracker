import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/app/routes.dart';
import 'package:pharmacy_expiry_tracker/domain/entities/app_settings.dart';
import 'package:pharmacy_expiry_tracker/l10n/app_localizations.dart';

/// Lead times, daily digest and quiet hours (SET-3/4/5). Every change is
/// saved at once; the alert coordinator notices and re-plans.
class AlertSettingsScreen extends ConsumerWidget {
  const AlertSettingsScreen({super.key});

  Future<void> _update(
    WidgetRef ref,
    AppSettings Function(AppSettings s) change,
  ) {
    return ref.read(settingsRepositoryProvider).update(change);
  }

  static TimeOfDay _time(int minutes) =>
      TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  static int _minutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> _pickTime(
    BuildContext context,
    WidgetRef ref,
    int current,
    AppSettings Function(AppSettings s, int minutes) apply,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time(current),
    );
    if (picked != null) {
      await _update(ref, (s) => apply(s, _minutes(picked)));
    }
  }

  Future<void> _addLead(BuildContext context, WidgetRef ref) async {
    final days = await showDialog<int>(
      context: context,
      builder: (_) => const _LeadDaysDialog(),
    );
    if (days == null) return;
    await _update(
      ref,
      (s) => s.copyWith(
        alertLeadDays: ({...s.alertLeadDays, days}.toList()
          ..sort((a, b) => b.compareTo(a))),
      ),
    );
  }

  Future<void> _addPaymentLead(BuildContext context, WidgetRef ref) async {
    final days = await showDialog<int>(
      context: context,
      builder: (_) => const _LeadDaysDialog(),
    );
    if (days == null) return;
    await _update(
      ref,
      (s) => s.copyWith(
        paymentLeadDays: ({...s.paymentLeadDays, days}.toList()
          ..sort((a, b) => b.compareTo(a))),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final s = ref.watch(settingsProvider).value ?? const AppSettings();
    final leads = [...s.alertLeadDays]..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.alertSettingsTitle)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.alertSettingsLeadTimes,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              leads.isEmpty
                  ? l10n.alertSettingsNoLeads
                  : l10n.alertSettingsLeadHelp,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final lead in leads)
                  InputChip(
                    key: Key('lead-chip-$lead'),
                    label: Text(l10n.leadChip(lead)),
                    onDeleted: () => unawaited(
                      _update(
                        ref,
                        (s) => s.copyWith(
                          alertLeadDays: [
                            for (final l in s.alertLeadDays)
                              if (l != lead) l,
                          ],
                        ),
                      ),
                    ),
                  ),
                ActionChip(
                  key: const Key('lead-add'),
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(l10n.alertSettingsAddLead),
                  onPressed: () => _addLead(context, ref),
                ),
              ],
            ),
          ),
          const Divider(height: 32),
          ListTile(
            key: const Key('alert-time'),
            title: Text(l10n.alertSettingsDigestTime),
            subtitle: Text(l10n.alertTimeHelp),
            trailing: Text(_time(s.digestMinutes).format(context)),
            onTap: () => _pickTime(
              context,
              ref,
              s.digestMinutes,
              (s, m) => s.copyWith(digestMinutes: m),
            ),
          ),
          SwitchListTile(
            key: const Key('digest-switch'),
            title: Text(l10n.alertSettingsDigest),
            value: s.digestEnabled,
            onChanged: (v) => _update(ref, (s) => s.copyWith(digestEnabled: v)),
          ),
          SwitchListTile(
            key: const Key('skip-empty-switch'),
            title: Text(l10n.alertSettingsSkipEmpty),
            value: s.skipEmptyDigest,
            onChanged: s.digestEnabled
                ? (v) => _update(ref, (s) => s.copyWith(skipEmptyDigest: v))
                : null,
          ),
          const Divider(height: 32),
          SwitchListTile(
            key: const Key('hide-details-switch'),
            title: Text(l10n.settingsHideDetails),
            subtitle: Text(l10n.settingsHideDetailsHelp),
            value: s.hideDetailsOnLockScreen,
            onChanged: (v) =>
                _update(ref, (s) => s.copyWith(hideDetailsOnLockScreen: v)),
          ),
          const Divider(height: 32),
          SwitchListTile(
            key: const Key('quiet-switch'),
            title: Text(l10n.alertSettingsQuiet),
            value: s.quietHoursEnabled,
            onChanged: (v) =>
                _update(ref, (s) => s.copyWith(quietHoursEnabled: v)),
          ),
          ListTile(
            key: const Key('quiet-from'),
            enabled: s.quietHoursEnabled,
            title: Text(l10n.alertSettingsQuietFrom),
            trailing: Text(_time(s.quietStartMinutes).format(context)),
            onTap: () => _pickTime(
              context,
              ref,
              s.quietStartMinutes,
              (s, m) => s.copyWith(quietStartMinutes: m),
            ),
          ),
          ListTile(
            key: const Key('quiet-to'),
            enabled: s.quietHoursEnabled,
            title: Text(l10n.alertSettingsQuietTo),
            trailing: Text(_time(s.quietEndMinutes).format(context)),
            onTap: () => _pickTime(
              context,
              ref,
              s.quietEndMinutes,
              (s, m) => s.copyWith(quietEndMinutes: m),
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              l10n.alertSettingsPayments,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.alertSettingsPayLead,
              style: theme.textTheme.bodySmall,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final lead in ([
                  ...s.paymentLeadDays,
                ]..sort((a, b) => b.compareTo(a))))
                  InputChip(
                    key: Key('pay-lead-chip-$lead'),
                    label: Text(l10n.leadChip(lead)),
                    onDeleted: () => unawaited(
                      _update(
                        ref,
                        (s) => s.copyWith(
                          paymentLeadDays: [
                            for (final l in s.paymentLeadDays)
                              if (l != lead) l,
                          ],
                        ),
                      ),
                    ),
                  ),
                ActionChip(
                  key: const Key('pay-lead-add'),
                  avatar: const Icon(Icons.add, size: 18),
                  label: Text(l10n.alertSettingsAddLead),
                  onPressed: () => _addPaymentLead(context, ref),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(l10n.alertSettingsOverdueEvery),
            trailing: DropdownButton<int>(
              key: const Key('overdue-repeat'),
              value: const [0, 1, 2, 3, 5, 7].contains(s.overdueRepeatDays)
                  ? s.overdueRepeatDays
                  : 3,
              items: [
                for (final n in const [0, 1, 2, 3, 5, 7])
                  DropdownMenuItem(
                    value: n,
                    child: Text(
                      n == 0 ? l10n.overdueEveryOff : l10n.overdueEveryDays(n),
                    ),
                  ),
              ],
              onChanged: (v) {
                if (v != null) {
                  unawaited(
                    _update(ref, (s) => s.copyWith(overdueRepeatDays: v)),
                  );
                }
              },
            ),
          ),
          const Divider(height: 32),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Text(
              l10n.alertSettingsReorder,
              style: theme.textTheme.titleMedium,
            ),
          ),
          ListTile(
            title: Text(l10n.alertSettingsReorderEvery),
            trailing: DropdownButton<int>(
              key: const Key('reorder-every'),
              value: const [1, 2, 3, 5, 7].contains(s.reorderRefireDays)
                  ? s.reorderRefireDays
                  : 3,
              items: [
                for (final n in const [1, 2, 3, 5, 7])
                  DropdownMenuItem(
                    value: n,
                    child: Text(l10n.overdueEveryDays(n)),
                  ),
              ],
              onChanged: (v) {
                if (v != null) {
                  unawaited(
                    _update(ref, (s) => s.copyWith(reorderRefireDays: v)),
                  );
                }
              },
            ),
          ),
          const Divider(height: 32),
          ListTile(
            key: const Key('open-health'),
            leading: const Icon(Icons.health_and_safety_outlined),
            title: Text(l10n.alertSettingsHealth),
            subtitle: Text(l10n.alertSettingsHealthSub),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.alertHealth),
          ),
          ListTile(
            key: const Key('open-history'),
            leading: const Icon(Icons.history),
            title: Text(l10n.alertCenterTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.alertHistory),
          ),
        ],
      ),
    );
  }
}

/// Asks for a number of days. Owns its text controller so it is disposed only
/// after the dialog's closing animation has finished.
class _LeadDaysDialog extends StatefulWidget {
  const _LeadDaysDialog();

  @override
  State<_LeadDaysDialog> createState() => _LeadDaysDialogState();
}

class _LeadDaysDialogState extends State<_LeadDaysDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final n = int.tryParse(_controller.text.trim());
    if (n == null || n < 0 || n > 365) {
      setState(() => _error = l10n.alertSettingsLeadInvalid);
      return;
    }
    Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.alertSettingsLeadDialogTitle),
      content: TextField(
        key: const Key('lead-days-field'),
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(errorText: _error),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          key: const Key('lead-days-add'),
          onPressed: _submit,
          child: Text(l10n.alertSettingsAddLead),
        ),
      ],
    );
  }
}
