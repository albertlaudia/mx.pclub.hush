import 'package:shared_preferences/shared_preferences.dart';
import '../utils/streak_math.dart';

/// The user's chosen practice window. Drives the (future) notification
/// schedule and the (future) time-of-day content shaping.
enum PracticeWindow { unknown, morning, midday, evening, anytime }

/// Minimal local state for `lock.`:
///   - the chosen practice window
///   - whether onboarding is complete
///   - whether today has been practiced
///   - the total number of practices
///
/// No streak counter. No mood. No "best". No week row. The product is
/// the practice, not the score.
class PracticeState {
  final bool onboarded;
  final PracticeWindow window;
  final bool practicedToday;
  final int totalPractices;

  const PracticeState({
    required this.onboarded,
    required this.window,
    required this.practicedToday,
    required this.totalPractices,
  });

  PracticeState copy() => this;
}

class PracticeStateStore {
  PracticeStateStore(this._prefs);
  final SharedPreferences _prefs;

  static Future<PracticeStateStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return PracticeStateStore(prefs);
  }

  static const _kOnboarded = 'lock.onboarded';
  static const _kWindow = 'lock.window';
  static const _kLastDay = 'lock.lastDay';
  static const _kTotal = 'lock.total';

  PracticeState read() {
    final onboarded = _prefs.getBool(_kOnboarded) ?? false;
    final windowIdx = _prefs.getInt(_kWindow) ?? 0;
    final window = PracticeWindow.values[windowIdx.clamp(0, PracticeWindow.values.length - 1)];
    final lastIso = _prefs.getString(_kLastDay);
    final last = lastIso == null ? null : DateTime.tryParse(lastIso);
    final today = StreakMath.today();
    final practiced = last != null && StreakMath.dayKey(last) == today;
    final total = _prefs.getInt(_kTotal) ?? 0;
    return PracticeState(
      onboarded: onboarded,
      window: window,
      practicedToday: practiced,
      totalPractices: total,
    );
  }

  Future<void> setOnboarded(bool v) => _prefs.setBool(_kOnboarded, v);
  Future<void> setWindow(PracticeWindow w) => _prefs.setInt(_kWindow, w.index);
  Future<void> markPracticed() async {
    await _prefs.setString(_kLastDay, StreakMath.iso(StreakMath.today()));
    await _prefs.setInt(_kTotal, (_prefs.getInt(_kTotal) ?? 0) + 1);
  }

  Future<void> reset() async {
    await _prefs.remove(_kOnboarded);
    await _prefs.remove(_kWindow);
    await _prefs.remove(_kLastDay);
    await _prefs.remove(_kTotal);
  }
}
