// Developer-only diagnostics, so strings are not localised.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_expiry_tracker/app/providers.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';

/// Alert lab (Sprint 2 spike, dev flavor only). Schedules real OS
/// notifications so delivery can be checked on physical devices: with the app
/// force-closed, in airplane mode, across a reboot, under Doze, and on
/// OEM-customised Android. Results go in `docs/qa-alert-matrix.md`.
class AlertLabScreen extends ConsumerStatefulWidget {
  const AlertLabScreen({super.key});

  @override
  ConsumerState<AlertLabScreen> createState() => _AlertLabScreenState();
}

class _AlertLabScreenState extends ConsumerState<AlertLabScreen> {
  // Ids in a range the real engine will never use.
  static const _baseId = 9000000;

  NotificationPermissions? _permissions;
  List<PendingNotification> _pending = const [];
  String? _launchPayload;
  String? _lastTapped;
  bool _ready = false;
  final _log = <String>[];

  NotificationPlugin get _plugin => ref.read(notificationPluginProvider);

  @override
  void initState() {
    super.initState();
    unawaited(_init());
  }

  Future<void> _init() async {
    await _plugin.initialize(
      onSelected: (payload) {
        if (!mounted) return;
        setState(() => _lastTapped = payload);
        _note('Tapped notification (app running), payload=$payload');
      },
    );
    _launchPayload = await _plugin.launchPayload();
    if (_launchPayload != null) {
      _note('App was launched by a notification, payload=$_launchPayload');
    }
    _ready = true;
    await _refresh();
  }

  Future<void> _refresh() async {
    final permissions = await _plugin.permissions();
    final pending = await _plugin.pending();
    if (!mounted) return;
    setState(() {
      _permissions = permissions;
      _pending = pending;
    });
  }

  void _note(String text) {
    final t = DateTime.now();
    final stamp =
        '${t.hour.toString().padLeft(2, '0')}:'
        '${t.minute.toString().padLeft(2, '0')}:'
        '${t.second.toString().padLeft(2, '0')}';
    setState(() => _log.insert(0, '$stamp  $text'));
  }

  Future<void> _request({required bool exact}) async {
    final p = await _plugin.requestPermissions(exactAlarms: exact);
    _note('Permissions: $p');
    await _refresh();
  }

  Future<void> _scheduleIn(
    Duration delay, {
    required bool exact,
    int slot = 0,
  }) async {
    final when = DateTime.now().add(delay);
    await _plugin.schedule(
      ScheduledNotification(
        id: _baseId + slot,
        fireAt: when,
        title: 'Alert lab ${exact ? 'exact' : 'inexact'}',
        body: 'Scheduled for ${_hms(when)}',
        payload: '/expiry?bucket=d30',
        preferExact: exact,
      ),
    );
    _note('Scheduled ${exact ? 'exact' : 'inexact'} for ${_hms(when)}');
    await _refresh();
  }

  /// Schedules [count] notifications one minute apart, starting an hour out,
  /// to see where the OS stops accepting them (iOS keeps 64).
  Future<void> _scheduleMany(int count) async {
    final start = DateTime.now().add(const Duration(hours: 1));
    for (var i = 0; i < count; i++) {
      await _plugin.schedule(
        ScheduledNotification(
          id: _baseId + 100 + i,
          fireAt: start.add(Duration(minutes: i)),
          title: 'Cap test ${i + 1}',
          body: 'Bulk notification ${i + 1} of $count',
          preferExact: false,
        ),
      );
    }
    final pending = await _plugin.pending();
    _note('Scheduled $count; OS reports ${pending.length} pending');
    await _refresh();
  }

  Future<void> _cancelAll() async {
    await _plugin.cancelAll();
    _note('Cancelled all');
    await _refresh();
  }

  static String _hms(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}:'
      '${t.second.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = _permissions;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert lab'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status', style: theme.textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text('Supported: ${_plugin.isSupported}'),
                        Text('Notifications allowed: ${p?.notifications}'),
                        Text(
                          'Exact alarms allowed: ${p?.exactAlarms ?? 'n/a'}',
                        ),
                        Text('Pending in OS: ${_pending.length}'),
                        Text(
                          'Launched by notification: ${_launchPayload ?? 'no'}',
                        ),
                        Text('Last tapped payload: ${_lastTapped ?? '-'}'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: () => _request(exact: false),
                      child: const Text('Request notifications'),
                    ),
                    OutlinedButton(
                      onPressed: () => _request(exact: true),
                      child: const Text('Request + exact alarms'),
                    ),
                    FilledButton.tonal(
                      key: const Key('lab-10s'),
                      onPressed: () => _scheduleIn(
                        const Duration(seconds: 10),
                        exact: true,
                        slot: 1,
                      ),
                      child: const Text('In 10 s'),
                    ),
                    FilledButton.tonal(
                      key: const Key('lab-2m-exact'),
                      onPressed: () => _scheduleIn(
                        const Duration(minutes: 2),
                        exact: true,
                        slot: 2,
                      ),
                      child: const Text('In 2 min (exact)'),
                    ),
                    FilledButton.tonal(
                      key: const Key('lab-2m-inexact'),
                      onPressed: () => _scheduleIn(
                        const Duration(minutes: 2),
                        exact: false,
                        slot: 3,
                      ),
                      child: const Text('In 2 min (inexact)'),
                    ),
                    OutlinedButton(
                      key: const Key('lab-70'),
                      onPressed: () => _scheduleMany(70),
                      child: const Text('Schedule 70 (cap test)'),
                    ),
                    TextButton(
                      onPressed: _cancelAll,
                      child: const Text('Cancel all'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Log', style: theme.textTheme.titleMedium),
                for (final line in _log)
                  Text(line, style: theme.textTheme.bodySmall),
                const SizedBox(height: 16),
                Text('Pending', style: theme.textTheme.titleMedium),
                for (final n in _pending.take(20))
                  Text(
                    '${n.id}  ${n.title ?? ''}  ${n.body ?? ''}',
                    style: theme.textTheme.bodySmall,
                  ),
                if (_pending.length > 20)
                  Text('… and ${_pending.length - 20} more'),
              ],
            ),
    );
  }
}
