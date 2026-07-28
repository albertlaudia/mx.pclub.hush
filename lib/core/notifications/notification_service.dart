import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../storage/practice_state.dart';

/// Wrapper around `flutter_local_notifications` with brand-aligned
/// copy and the hush. notification flow.
///
/// The notification is opt-in. It fires at the user's chosen window
/// (morning / midday / evening / anytime). Tapping it deep-links to
/// the home screen. The copy is always gentle: "the hush is ready."
/// Never "you missed 3 days!"
///
/// The user can opt in or out at any time via the "deeper practice"
/// toggle in settings. Toggling off cancels all scheduled
/// notifications immediately.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  static const _channelId = 'hush.daily_practice';
  static const _channelName = 'daily practice';
  static const _channelDescription = 'a quiet reminder when the hush is ready';
  static const _notificationId = 1001;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Initialize the plugin. Idempotent. Safe to call multiple times.
  Future<void> initialize() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const init = InitializationSettings(android: android, iOS: ios);

    await _plugin.initialize(
      init,
      onDidReceiveNotificationResponse: (response) {
        // Tapping the notification deep-links to the home screen.
        // The notification payload is the practice window; the home
        // screen reads it from storage. We just log here.
        if (kDebugMode) {
          debugPrint(
            'hush.: notification tapped. payload=${response.payload}',
          );
        }
      },
    );
    _initialized = true;
  }

  /// Request permission. Returns true if granted.
  /// Safe to call multiple times. The user can change their mind at
  /// any time via the system settings.
  Future<bool> requestPermission() async {
    await initialize();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      // Android 12 and below don't require runtime permission.
      return granted ?? true;
    }
    return false;
  }

  /// Schedule the daily notification at the user's chosen window.
  /// Cancels any previously scheduled notification first.
  ///
  /// The window determines the fire time:
  ///   morning  → 7:00 AM
  ///   midday   → 12:00 PM
  ///   evening  → 8:00 PM
  ///   anytime  → 8:00 PM (the default if user hasn't picked a time)
  Future<void> scheduleDaily(PracticeWindow window) async {
    await initialize();
    await cancel();

    final fireTime = _nextFireTime(window);
    if (fireTime == null) return;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.default,
      priority: Priority.default,
      // No sound. The brand is quiet. The notification is a quiet
      // nudge, not an alert. The visual alone is the cue.
      playSound: false,
      enableVibration: false,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: false,
      presentSound: false, // see android note above
    );
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _plugin.zonedSchedule(
      _notificationId,
      _titleFor(window),
      _bodyFor(window),
      fireTime,
      details,
      payload: _payloadFor(window),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Repeat daily. The plugin uses the same fire time every 24h.
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancel the daily notification. Idempotent.
  Future<void> cancel() async {
    await initialize();
    await _plugin.cancel(_notificationId);
  }

  /// True if the user has a daily notification scheduled. Used by
  /// the settings toggle to display the current state.
  Future<bool> isScheduled() async {
    await initialize();
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any((n) => n.id == _notificationId);
  }

  // --- Brand-aligned copy ---

  /// "the hush is ready." — never "you missed 3 days!"
  String _titleFor(PracticeWindow w) {
    switch (w) {
      case PracticeWindow.morning:
        return 'good morning.';
      case PracticeWindow.midday:
        return 'good afternoon.';
      case PracticeWindow.evening:
        return 'good evening.';
      case PracticeWindow.anytime:
        return 'the hush is ready.';
      case PracticeWindow.unknown:
        return 'the hush is ready.';
    }
  }

  /// The notification body. Always an invitation, never a command.
  /// "today's movement is ready." "the verse is waiting."
  String _bodyFor(PracticeWindow w) {
    switch (w) {
      case PracticeWindow.morning:
        return 'a verse is waiting. take a moment when you can.';
      case PracticeWindow.midday:
        return 'a moment of attention, if you have a quiet one.';
      case PracticeWindow.evening:
        return 'a verse for the end of the day. it\'s there when you want it.';
      case PracticeWindow.anytime:
        return 'today\'s practice is ready. open hush. when it fits.';
      case PracticeWindow.unknown:
        return 'today\'s practice is ready. open hush. when it fits.';
    }
  }

  String _payloadFor(PracticeWindow w) => 'window:${w.name}';

  /// Compute the next fire time. The plugin repeats daily at this time.
  /// If the time has already passed today, schedule for tomorrow.
  tz.TZDateTime? _nextFireTime(PracticeWindow w) {
    final now = tz.TZDateTime.now(tz.local);
    int hour;
    int minute = 0;
    switch (w) {
      case PracticeWindow.morning:
        hour = 7;
        break;
      case PracticeWindow.midday:
        hour = 12;
        break;
      case PracticeWindow.evening:
        hour = 20;
        break;
      case PracticeWindow.anytime:
        hour = 20;
        break;
      case PracticeWindow.unknown:
        return null;
    }
    var fire = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!fire.isAfter(now)) {
      fire = fire.add(const Duration(days: 1));
    }
    return fire;
  }
}
