import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'streak_store.dart';

/// Singleton StreakStore, opened at app start.
final streakStoreProvider = Provider<StreakStore>((ref) {
  throw UnimplementedError('streakStoreProvider must be overridden in main()');
});

/// Reactive view of the current streak. Refreshed after `markPrayedToday`.
class StreakState {
  final int current;
  final int best;
  final int prayerCount;
  final bool practicedToday;
  const StreakState({
    required this.current,
    required this.best,
    required this.prayerCount,
    required this.practicedToday,
  });

  StreakState copy() => StreakState(
        current: current,
        best: best,
        prayerCount: prayerCount,
        practicedToday: practicedToday,
      );

  factory StreakState.fromStore(StreakStore s) {
    final last = s.lastDay;
    final today = DateTime.now();
    final practiced = last != null &&
        last.year == today.year &&
        last.month == today.month &&
        last.day == today.day;
    return StreakState(
      current: s.current,
      best: s.best,
      prayerCount: s.prayerCount,
      practicedToday: practiced,
    );
  }
}

class StreakNotifier extends StateNotifier<StreakState> {
  StreakNotifier(this._store)
      : super(StreakState.fromStore(_store));
  final StreakStore _store;

  Future<void> markPrayedToday() async {
    await _store.markPrayedToday();
    state = StreakState.fromStore(_store);
  }

  Future<void> reset() async {
    await _store.reset();
    state = StreakState.fromStore(_store);
  }
}

final streakProvider =
    StateNotifierProvider<StreakNotifier, StreakState>((ref) {
  return StreakNotifier(ref.watch(streakStoreProvider));
});

class GodMoodNotifier extends StateNotifier<int?> {
  GodMoodNotifier(this._store) : super(_store.godMood);
  final StreakStore _store;
  Future<void> set(int v) async {
    await _store.setGodMood(v);
    state = v;
  }
}

final godMoodProvider =
    StateNotifierProvider<GodMoodNotifier, int?>((ref) {
  return GodMoodNotifier(ref.watch(streakStoreProvider));
});

class FeelingMoodNotifier extends StateNotifier<int?> {
  FeelingMoodNotifier(this._store) : super(_store.feelingMood);
  final StreakStore _store;
  Future<void> set(int v) async {
    await _store.setFeelingMood(v);
    state = v;
  }
}

final feelingMoodProvider =
    StateNotifierProvider<FeelingMoodNotifier, int?>((ref) {
  return FeelingMoodNotifier(ref.watch(streakStoreProvider));
});
