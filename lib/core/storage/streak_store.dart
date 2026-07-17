import 'package:shared_preferences/shared_preferences.dart';
import '../utils/streak_math.dart';

/// Local persistence for the day-streak, mood, and last-practiced state.
///
/// Storage keys (all under `lock.*` namespace):
///   - lock.streak.current   int   — the current day-streak
///   - lock.streak.best      int   — the best streak ever achieved
///   - lock.streak.lastDay   ISO   — the day-key of the most recent practice
///   - lock.mood.godDay      int   — most recent "relationship with God" check-in (1-10)
///   - lock.mood.feelingDay  int   — most recent "how are you feeling" check-in (1-10)
///   - lock.mood.godAt       ISO   — day-key of the most recent god-mood check-in
///   - lock.mood.feelingAt   ISO   — day-key of the most recent feeling-mood check-in
///   - lock.prayerCount      int   — total number of prayers completed
///   - lock.installedAt      ISO   — day-key of first install
///   - lock.onboarded        bool  — has the user finished onboarding?
class StreakStore {
  StreakStore(this._prefs);
  final SharedPreferences _prefs;

  static Future<StreakStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return StreakStore(prefs);
  }

  static const _kCurrent = 'lock.streak.current';
  static const _kBest = 'lock.streak.best';
  static const _kLastDay = 'lock.streak.lastDay';
  static const _kGodDay = 'lock.mood.godDay';
  static const _kGodAt = 'lock.mood.godAt';
  static const _kFeelingDay = 'lock.mood.feelingDay';
  static const _kFeelingAt = 'lock.mood.feelingAt';
  static const _kPrayerCount = 'lock.prayerCount';
  static const _kInstalledAt = 'lock.installedAt';
  static const _kOnboarded = 'lock.onboarded';

  // ---- streak ----

  int get current => _prefs.getInt(_kCurrent) ?? 0;
  int get best => _prefs.getInt(_kBest) ?? 0;
  DateTime? get lastDay {
    final s = _prefs.getString(_kLastDay);
    return s == null ? null : DateTime.parse(s);
  }

  /// Mark today as practiced. Returns the new streak value.
  /// Idempotent: tapping "done" twice in one day is a no-op.
  Future<int> markPrayedToday() async {
    final today = StreakMath.today();
    final last = lastDay;
    if (last != null && StreakMath.dayKey(last) == today) {
      return current; // already counted today
    }
    int next;
    if (last == null) {
      next = 1;
    } else {
      final gap = StreakMath.daysBetween(last, today);
      if (gap == 1) {
        next = current + 1; // consecutive
      } else {
        next = 1; // broke the streak
      }
    }
    await _prefs.setInt(_kCurrent, next);
    await _prefs.setString(_kLastDay, StreakMath.iso(today));
    if (next > best) await _prefs.setInt(_kBest, next);
    await _prefs.setInt(_kPrayerCount, prayerCount + 1);
    if (installedAt == null) {
      await _prefs.setString(_kInstalledAt, StreakMath.iso(today));
    }
    return next;
  }

  int get prayerCount => _prefs.getInt(_kPrayerCount) ?? 0;
  DateTime? get installedAt {
    final s = _prefs.getString(_kInstalledAt);
    return s == null ? null : DateTime.parse(s);
  }

  // ---- mood: relationship with God ----

  int? get godMood => _prefs.getInt(_kGodDay);
  DateTime? get godMoodAt {
    final s = _prefs.getString(_kGodAt);
    return s == null ? null : DateTime.parse(s);
  }
  Future<void> setGodMood(int value) async {
    await _prefs.setInt(_kGodDay, value);
    await _prefs.setString(_kGodAt, StreakMath.iso(StreakMath.today()));
  }

  // ---- mood: how are you feeling ----

  int? get feelingMood => _prefs.getInt(_kFeelingDay);
  DateTime? get feelingMoodAt {
    final s = _prefs.getString(_kFeelingAt);
    return s == null ? null : DateTime.parse(s);
  }
  Future<void> setFeelingMood(int value) async {
    await _prefs.setInt(_kFeelingDay, value);
    await _prefs.setString(_kFeelingAt, StreakMath.iso(StreakMath.today()));
  }

  // ---- onboarding ----

  bool get onboarded => _prefs.getBool(_kOnboarded) ?? false;
  Future<void> setOnboarded(bool v) => _prefs.setBool(_kOnboarded, v);

  // ---- for tests / dev ----

  Future<void> reset() async {
    for (final k in [
      _kCurrent, _kBest, _kLastDay, _kGodDay, _kGodAt, _kFeelingDay,
      _kFeelingAt, _kPrayerCount, _kInstalledAt,
    ]) {
      await _prefs.remove(k);
    }
  }
}
