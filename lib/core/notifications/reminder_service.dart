import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/calendar/domain/vrat.dart';
import '../../shared/models/jap_settings.dart';
import 'reminder_planner.dart';

/// Local jap/vrat reminders. Soft-fails on web/tests so chanting never waits.
class ReminderService {
  ReminderService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static final ReminderService instance = ReminderService();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  Future<void> init() async {
    if (_ready) {
      return;
    }
    try {
      tzdata.initializeTimeZones();
      try {
        final info = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(info.identifier));
      } catch (_) {
        // Stay on the package default rather than blocking the app.
      }

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
          macOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
    } catch (error) {
      debugPrint('ReminderService.init failed: $error');
    }
  }

  Future<bool> requestPermission() async {
    await init();
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
      return true;
    } catch (error) {
      debugPrint('ReminderService.requestPermission failed: $error');
      return false;
    }
  }

  Future<void> apply({
    required JapSettings settings,
    required String deityName,
    required List<Vrat> vrats,
  }) async {
    await init();
    if (!_ready) {
      return;
    }

    try {
      await _plugin.cancelAll();
      if (!settings.reminderEnabled) {
        return;
      }

      final planned = ReminderPlanner.plan(
        now: DateTime.now(),
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
        vrats: vrats,
        vratReminderEnabled: settings.vratReminderEnabled,
        deityName: deityName,
      );

      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'bhakti_sadhana',
          'साधना स्मरण',
          channelDescription: 'दैनिक जप और व्रत का स्मरण',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      );

      for (final reminder in planned) {
        await _plugin.zonedSchedule(
          id: reminder.id,
          title: reminder.title,
          body: reminder.body,
          scheduledDate: tz.TZDateTime(
            tz.local,
            reminder.fireAt.year,
            reminder.fireAt.month,
            reminder.fireAt.day,
            reminder.fireAt.hour,
            reminder.fireAt.minute,
          ),
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (error) {
      debugPrint('ReminderService.apply failed: $error');
    }
  }
}
