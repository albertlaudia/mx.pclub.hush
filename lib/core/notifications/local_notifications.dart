import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Local notifications wrapper for the daily reminder.
class AppNotifications {
  AppNotifications._();
  static final instance = AppNotifications._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    // Use device local timezone (good enough for the MVP).
    try {
      final localName = DateTime.now().timeZoneName;
      tz.setLocalLocation(tz.getLocation(_mapTimezoneName(localName)));
    } catch (_) {
      // Fallback: keep UTC if mapping fails.
      tz.setLocalLocation(tz.UTC);
    }

    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(iOS: iosInit, android: androidInit),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    await init();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        true;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission() ?? true;
    return iosGranted && androidGranted;
  }

  /// Schedule the daily reminder at the given local hour:minute.
  /// Replaces any previously scheduled daily reminder.
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    await init();
    await _plugin.cancel(_dailyId);
    final now = tz.TZDateTime.now(tz.local);
    var first = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (first.isBefore(now)) {
      first = first.add(const Duration(days: 1));
    }
    const details = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
      android: AndroidNotificationDetails(
        'lock.daily',
        'Daily Prayer',
        channelDescription: 'Reminds you to pray today and keep your streak.',
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
    );
    try {
      await _plugin.zonedSchedule(
        _dailyId,
        'Time to pray',
        'Tap the notification to start your prayer for today.',
        first,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('scheduleDaily failed: $e');
      }
    }
  }

  Future<void> cancelDaily() => _plugin.cancel(_dailyId);

  static const int _dailyId = 1001;

  // Map common IANA / abbreviation forms to a tz database name.
  // For the MVP we default to UTC offset; users with DST shifts can re-set.
  String _mapTimezoneName(String name) {
    final n = name.toUpperCase();
    if (n.contains('SINGAPORE') || n == 'SGT') return 'Asia/Singapore';
    if (n.contains('HONG_KONG') || n == 'HKT') return 'Asia/Hong_Kong';
    if (n.contains('TOKYO') || n == 'JST') return 'Asia/Tokyo';
    if (n.contains('SHANGHAI') || n == 'CST') return 'Asia/Shanghai';
    if (n.contains('KOLKATA') || n == 'IST') return 'Asia/Kolkata';
    if (n.contains('LONDON') || n == 'BST' || n == 'GMT') return 'Europe/London';
    if (n.contains('PARIS') || n == 'CET' || n == 'CEST') return 'Europe/Paris';
    if (n.contains('NEW_YORK') || n == 'EST' || n == 'EDT') return 'America/New_York';
    if (n.contains('CHICAGO') || n == 'CST6') return 'America/Chicago';
    if (n.contains('DENVER') || n == 'MST') return 'America/Denver';
    if (n.contains('LOS_ANGELES') || n == 'PST' || n == 'PDT') return 'America/Los_Angeles';
    return 'UTC';
  }
}
