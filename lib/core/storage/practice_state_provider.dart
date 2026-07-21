import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'practice_state.dart';

/// Singleton store, opened at app start.
final practiceStoreProvider = Provider<PracticeStateStore>((ref) {
  throw UnimplementedError('practiceStoreProvider must be overridden in main()');
});

class PracticeStateNotifier extends StateNotifier<PracticeState> {
  PracticeStateNotifier(this._store) : super(_store.read());
  final PracticeStateStore _store;

  Future<void> setWindow(PracticeWindow w) async {
    await _store.setWindow(w);
    state = _store.read();
  }

  Future<void> completeOnboarding() async {
    await _store.setOnboarded(true);
    state = _store.read();
  }

  /// Returns true if the practice was newly recorded, false if it was
  /// already counted today (idempotent).
  Future<bool> markPracticed() async {
    final changed = await _store.markPracticed();
    state = _store.read();
    return changed;
  }

  Future<void> reset() async {
    await _store.reset();
    state = _store.read();
  }
}

final practiceStateProvider =
    StateNotifierProvider<PracticeStateNotifier, PracticeState>((ref) {
  // ref.read (not ref.watch) — the store is opened once in main() and
  // never changes. Using ref.watch would cause the notifier to be
  // rebuilt every time the store reference changes, which is wasteful
  // and would lose any in-flight state.
  return PracticeStateNotifier(ref.read(practiceStoreProvider));
});
