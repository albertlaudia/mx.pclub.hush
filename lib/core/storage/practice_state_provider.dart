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

  Future<void> markPracticed() async {
    await _store.markPracticed();
    state = _store.read();
  }

  Future<void> reset() async {
    await _store.reset();
    state = _store.read();
  }
}

final practiceStateProvider =
    StateNotifierProvider<PracticeStateNotifier, PracticeState>((ref) {
  return PracticeStateNotifier(ref.watch(practiceStoreProvider));
});
