import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'practice_state.dart';

/// Singleton store, opened at app start.
final practiceStoreProvider = Provider<PracticeStateStore>((ref) {
  throw UnimplementedError('practiceStoreProvider must be overridden in main()');
});

/// Riverpod 3.x: `Notifier` replaces the deprecated `StateNotifier`.
/// The pattern is similar: `build()` returns the initial state,
/// methods mutate `state` and trigger rebuilds.
class PracticeStateNotifier extends Notifier<PracticeState> {
  @override
  PracticeState build() {
    // Read the store once on first build. Each method re-reads it
    // for fresh data (cheap — SharedPreferences is in-memory cached).
    return ref.read(practiceStoreProvider).read();
  }

  Future<void> setWindow(PracticeWindow w) async {
    final store = ref.read(practiceStoreProvider);
    await store.setWindow(w);
    state = store.read();
  }

  Future<void> completeOnboarding() async {
    final store = ref.read(practiceStoreProvider);
    await store.setOnboarded(true);
    state = store.read();
  }

  /// Returns true if the practice was newly recorded, false if it was
  /// already counted today (idempotent).
  Future<bool> markPracticed() async {
    final store = ref.read(practiceStoreProvider);
    final changed = await store.markPracticed();
    state = store.read();
    return changed;
  }

  Future<void> reset() async {
    final store = ref.read(practiceStoreProvider);
    await store.reset();
    state = store.read();
  }

  /// Set the "deeper practice" mode. The caller (settings UI) is
  /// responsible for wiring the actual hooks — this just persists
  /// the preference and updates the in-memory state.
  Future<void> setDeeperPractice(bool enabled) async {
    final store = ref.read(practiceStoreProvider);
    await store.setDeeperPractice(enabled);
    state = store.read();
  }
}

final practiceStateProvider =
    NotifierProvider<PracticeStateNotifier, PracticeState>(
  PracticeStateNotifier.new,
);
