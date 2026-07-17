import 'package:intl/intl.dart';

/// Pure-function date math for the streak counter.
/// All times are in the user's local timezone.
class StreakMath {
  /// Normalize a DateTime to midnight in the local timezone.
  static DateTime dayKey(DateTime t) {
    final local = t.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// The day key for "today" in the local timezone.
  static DateTime today() => dayKey(DateTime.now());

  /// Number of whole days between two day-keys (b - a).
  /// Always returns a non-negative integer; if b < a, returns 0.
  static int daysBetween(DateTime a, DateTime b) {
    final aKey = dayKey(a);
    final bKey = dayKey(b);
    return bKey.difference(aKey).inDays.clamp(0, 1 << 30);
  }

  /// The Monday of the week containing the given date (ISO week starts Monday).
  static DateTime startOfWeek(DateTime t) {
    final d = dayKey(t);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// "yyyy-MM-dd" — used as the day-key in storage and notification ids.
  static String iso(DateTime t) {
    return DateFormat('yyyy-MM-dd').format(dayKey(t));
  }

  /// Friendly short day label, e.g. "Mon".
  static String dayAbbrev(DateTime t) {
    return DateFormat('E').format(dayKey(t));
  }

  /// Short date label, e.g. "Jul 14".
  static String shortDate(DateTime t) {
    return DateFormat('MMM d').format(dayKey(t));
  }
}
