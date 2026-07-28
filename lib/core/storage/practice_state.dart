import 'package:shared_preferences/shared_preferences.dart';
import '../utils/streak_math.dart';

/// The user's chosen practice window. Drives the (future) notification
/// schedule and the (future) time-of-day content shaping.
///
/// [unknown] is the initial state before the user picks a window. It is
/// never persisted; [setWindow] rejects it.
enum PracticeWindow { unknown, morning, midday, evening, anytime }

/// Minimal local state for `hush.`:
///   - whether onboarding is complete
///   - the chosen practice window
///   - whether today has been practiced
///   - the total number of practices
///   - whether the user has opted into "deeper practice" (the umbrella
///     for opt-in hooks like daily notification, future home widget,
///     future lock screen widget). Default false — brand is voluntary
///     until the user chooses otherwise.
///
/// No streak counter. No mood. No "best". No week row. The product is
/// the practice, not the score.
class PracticeState {
  final bool onboarded;
  final PracticeWindow window;
  final bool practicedToday;
  final int totalPractices;
  final bool deeperPractice;

  const PracticeState({
    required this.onboarded,
    required this.window,
    required this.practicedToday,
    required this.totalPractices,
    this.deeperPractice = false,
  });

  static const empty = PracticeState(
    onboarded: false,
    window: PracticeWindow.unknown,
    practicedToday: false,
    totalPractices: 0,
    deeperPractice: false,
  );

  PracticeState copyWith({
    bool? onboarded,
    PracticeWindow? window,
    bool? practicedToday,
    int? totalPractices,
    bool? deeperPractice,
  }) {
    return PracticeState(
      onboarded: onboarded ?? this.onboarded,
      window: window ?? this.window,
      practicedToday: practicedToday ?? this.practicedToday,
      totalPractices: totalPractices ?? this.totalPractices,
      deeperPractice: deeperPractice ?? this.deeperPractice,
    );
  }
}

class PracticeStateStore {
  PracticeStateStore(this._prefs);
  final SharedPreferences _prefs;

  static Future<PracticeStateStore> open() async {
    final prefs = await SharedPreferences.getInstance();
    return PracticeStateStore(prefs);
  }

  static const _kOnboarded = 'hush.onboarded';
  static const _kWindow = 'hush.window';
  static const _kLastDay = 'hush.lastDay';
  static const _kTotal = 'hush.total';
  static const _kDeeperPractice = 'hush.deeperPractice';
  static const _kSchemaVersion = 'hush.schemaVersion';

  /// The current storage schema version. Bump this whenever the
  /// storage format changes. A `read()` call will then trigger
  /// `migrate()` on next launch, allowing forward-compatibility.
  static const int currentSchemaVersion = 1;

  PracticeState read() {
    // Run any pending migrations first. If a previous version of the
    // app wrote a different schema, this is where we bring it forward.
    _migrate();

    final onboarded = _prefs.getBool(_kOnboarded) ?? false;
    final windowIdx = _prefs.getInt(_kWindow) ?? 0;
    final window = PracticeWindow
        .values[windowIdx.clamp(0, PracticeWindow.values.length - 1)];
    final lastIso = _prefs.getString(_kLastDay);
    final last = lastIso == null ? null : DateTime.tryParse(lastIso);
    final practiced = last != null && StreakMath.dayKey(last) == StreakMath.today();
    final total = _prefs.getInt(_kTotal) ?? 0;
    final deeperPractice = _prefs.getBool(_kDeeperPractice) ?? false;
    return PracticeState(
      onboarded: onboarded,
      window: window,
      practicedToday: practiced,
      totalPractices: total,
      deeperPractice: deeperPractice,
    );
  }

  /// Bring the stored state forward to [currentSchemaVersion]. Called
  /// on every read. Each case is a no-op for users already on the
  /// current version; only out-of-date users get touched.
  ///
  /// Add a new case when bumping [currentSchemaVersion]:
  /// ```dart
  /// case 1: // -> 2
  ///   // ...
  ///   await _setSchemaVersion(2);
  ///   continue;
  /// ```
  Future<void> _migrate() async {
    final from = _prefs.getInt(_kSchemaVersion) ?? 0;
    while (from < currentSchemaVersion) {
      switch (from) {
        // No migrations yet — schema version 1 is the initial release.
        default:
          // Defensive: if we don't know a migration path, don't loop.
          await _setSchemaVersion(currentSchemaVersion);
          return;
      }
    }
  }

  Future<void> _setSchemaVersion(int v) => _prefs.setInt(_kSchemaVersion, v);

  Future<void> setOnboarded(bool v) => _prefs.setBool(_kOnboarded, v);

  Future<void> setWindow(PracticeWindow w) async {
    if (w == PracticeWindow.unknown) {
      throw ArgumentError('cannot persist PracticeWindow.unknown');
    }
    await _prefs.setInt(_kWindow, w.index);
  }

  /// Idempotent: tapping "done" twice in one day is a no-op for the
  /// day-key, but the total counter only increments on a new day.
  Future<bool> markPracticed() async {
    final today = StreakMath.today();
    final lastIso = _prefs.getString(_kLastDay);
    final last = lastIso == null ? null : DateTime.tryParse(lastIso);
    if (last != null && StreakMath.dayKey(last) == today) {
      return false; // already counted today
    }
    await _prefs.setString(_kLastDay, StreakMath.iso(today));
    await _prefs.setInt(_kTotal, (_prefs.getInt(_kTotal) ?? 0) + 1);
    return true;
  }

  Future<void> reset() async {
    await _prefs.remove(_kOnboarded);
    await _prefs.remove(_kWindow);
    await _prefs.remove(_kLastDay);
    await _prefs.remove(_kTotal);
    await _prefs.remove(_kDeeperPractice);
    // Note: we don't reset the schema version. The next read() will
    // see it at the current version and skip migration. This is
    // correct: a reset is "start over" not "downgrade the schema".
  }

  /// Set the "deeper practice" mode. When true, opt-in hooks
  /// (currently: daily notification; future: home widget, lock
  /// screen) are enabled. The caller is responsible for actually
  /// wiring the hooks — this method just persists the preference.
  Future<void> setDeeperPractice(bool enabled) async {
    await _prefs.setBool(_kDeeperPractice, enabled);
  }
}
