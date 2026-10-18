import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:pharmacy_expiry_tracker/data/services/notification_actions.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/action_payload.dart';
import 'package:pharmacy_expiry_tracker/domain/notifications/notification_plugin.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// [NotificationPlugin] backed by `flutter_local_notifications`: OS-native
/// scheduled notifications that fire with no network, with the app closed, and
/// (after the plugin's boot receiver) across reboots.
class LocalNotificationPlugin implements NotificationPlugin {
  LocalNotificationPlugin([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialised = false;

  @override
  bool get isSupported => Platform.isAndroid || Platform.isIOS;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  @override
  Future<void> initialize({
    required void Function(String? payload) onSelected,
  }) async {
    if (!isSupported || _initialised) return;
    await _initialiseTimeZone();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        // Permission is requested explicitly (with an explanation first), not
        // on first launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) {
        if (r.actionId == snoozeActionId) {
          unawaited(handleNotificationAction(r, plugin: this));
        } else {
          onSelected(routeOf(r.payload));
        }
      },
      // The "Snooze 1 day" button works with the app closed.
      onDidReceiveBackgroundNotificationResponse: notificationActionBackground,
    );
    final android = _android;
    if (android != null) {
      for (final c in NotificationChannel.values) {
        await android.createNotificationChannel(
          AndroidNotificationChannel(
            c.id,
            c.label,
            importance: switch (c) {
              NotificationChannel.expiryCritical => Importance.high,
              NotificationChannel.payments => Importance.high,
              _ => Importance.defaultImportance,
            },
          ),
        );
      }
    }
    _initialised = true;
  }

  Future<void> _initialiseTimeZone() async {
    tz_data.initializeTimeZones();
    try {
      final name = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(name));
    } on Object catch (e) {
      // Unknown zone: fall back to UTC rather than failing to schedule.
      debugPrint('Could not resolve the local time zone ($e); using UTC.');
      tz.setLocalLocation(tz.UTC);
    }
  }

  @override
  Future<NotificationPermissions> permissions() async {
    if (!isSupported) {
      return const NotificationPermissions(notifications: false);
    }
    if (Platform.isAndroid) {
      final android = _android;
      return NotificationPermissions(
        notifications: await android?.areNotificationsEnabled() ?? false,
        exactAlarms: await android?.canScheduleExactNotifications(),
      );
    }
    final options = await _ios?.checkPermissions();
    return NotificationPermissions(notifications: options?.isEnabled ?? false);
  }

  @override
  Future<NotificationPermissions> requestPermissions({
    bool exactAlarms = false,
  }) async {
    if (!isSupported) {
      return const NotificationPermissions(notifications: false);
    }
    if (Platform.isAndroid) {
      final android = _android;
      await android?.requestNotificationsPermission();
      if (exactAlarms) {
        await android?.requestExactAlarmsPermission();
      }
    } else {
      await _ios?.requestPermissions(alert: true, badge: true, sound: true);
    }
    return await permissions();
  }

  @override
  Future<void> schedule(ScheduledNotification n) async {
    if (!isSupported) return;
    // Exact alarms need a permission the user may not have granted; ask the OS
    // rather than assuming, and degrade to inexact (a few minutes' drift).
    var mode = AndroidScheduleMode.inexactAllowWhileIdle;
    if (n.preferExact && Platform.isAndroid) {
      final canExact = await _android?.canScheduleExactNotifications() ?? false;
      if (canExact) {
        mode = AndroidScheduleMode.exactAllowWhileIdle;
      }
    }
    await _plugin.zonedSchedule(
      id: n.id,
      title: n.title,
      body: n.body,
      scheduledDate: tz.TZDateTime.from(n.fireAt, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          n.channel.id,
          n.channel.label,
          importance: switch (n.channel) {
            NotificationChannel.expiryCritical ||
            NotificationChannel.payments => Importance.high,
            _ => Importance.defaultImportance,
          },
          priority: Priority.high,
          actions: [
            if (n.snoozeLabel != null)
              AndroidNotificationAction(snoozeActionId, n.snoozeLabel!),
          ],
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: mode,
      payload: n.snoozeLabel == null
          ? n.payload
          : encodeActionPayload(
              route: n.payload,
              title: n.title,
              body: n.body,
              snoozeLabel: n.snoozeLabel!,
            ),
    );
  }

  @override
  Future<void> cancel(int id) async {
    if (isSupported) await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    if (isSupported) await _plugin.cancelAll();
  }

  @override
  Future<List<PendingNotification>> pending() async {
    if (!isSupported) return const [];
    final requests = await _plugin.pendingNotificationRequests();
    return [
      for (final r in requests)
        PendingNotification(
          id: r.id,
          title: r.title,
          body: r.body,
          payload: r.payload,
        ),
    ];
  }

  @override
  Future<String?> launchPayload() async {
    if (!isSupported) return null;
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return routeOf(details.notificationResponse?.payload);
  }
}
