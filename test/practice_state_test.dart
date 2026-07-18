import 'package:flutter_test/flutter_test.dart';
import 'package:lock/core/storage/practice_state.dart';
import 'package:lock/core/utils/streak_math.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('StreakMath', () {
    test('dayKey normalizes to midnight in local timezone', () {
      final t = DateTime(2026, 7, 14, 14, 32, 17, 500);
      final k = StreakMath.dayKey(t);
      expect(k.hour, 0);
      expect(k.minute, 0);
      expect(k.second, 0);
      expect(k.year, 2026);
      expect(k.month, 7);
      expect(k.day, 14);
    });

    test('daysBetween same day is 0', () {
      final a = DateTime(2026, 7, 14);
      final b = DateTime(2026, 7, 14);
      expect(StreakMath.daysBetween(a, b), 0);
    });

    test('daysBetween one day apart is 1', () {
      expect(
        StreakMath.daysBetween(DateTime(2026, 7, 14), DateTime(2026, 7, 15)),
        1,
      );
    });

    test('daysBetween handles b < a (clamps to 0)', () {
      expect(
        StreakMath.daysBetween(DateTime(2026, 7, 15), DateTime(2026, 7, 14)),
        0,
      );
    });

    test('startOfWeek returns Monday for a Wednesday', () {
      final wed = DateTime(2026, 7, 15);
      expect(StreakMath.startOfWeek(wed), DateTime(2026, 7, 13));
    });

    test('startOfWeek on Monday is the same day', () {
      final mon = DateTime(2026, 7, 13);
      expect(StreakMath.startOfWeek(mon), DateTime(2026, 7, 13));
    });

    test('iso produces yyyy-MM-dd', () {
      expect(StreakMath.iso(DateTime(2026, 7, 14)), '2026-07-14');
    });
  });

  group('PracticeStateStore', () {
    test('read returns the empty state on a fresh install', () async {
      final store = await PracticeStateStore.open();
      final state = store.read();
      expect(state.onboarded, isFalse);
      expect(state.window, PracticeWindow.unknown);
      expect(state.practicedToday, isFalse);
      expect(state.totalPractices, 0);
    });

    test('setWindow rejects PracticeWindow.unknown', () async {
      final store = await PracticeStateStore.open();
      expect(
        () => store.setWindow(PracticeWindow.unknown),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('setWindow persists a valid window', () async {
      final store = await PracticeStateStore.open();
      await store.setWindow(PracticeWindow.morning);
      final state = store.read();
      expect(state.window, PracticeWindow.morning);
    });

    test('markPracticed is idempotent on the same day', () async {
      final store = await PracticeStateStore.open();
      final first = await store.markPracticed();
      final second = await store.markPracticed();
      final state = store.read();
      expect(first, isTrue);
      expect(second, isFalse);
      expect(state.practicedToday, isTrue);
      expect(state.totalPractices, 1);
    });

    test('reset clears all state and returns to empty', () async {
      final store = await PracticeStateStore.open();
      await store.setOnboarded(true);
      await store.setWindow(PracticeWindow.evening);
      await store.markPracticed();
      await store.reset();
      final state = store.read();
      expect(state.onboarded, isFalse);
      expect(state.window, PracticeWindow.unknown);
      expect(state.practicedToday, isFalse);
      expect(state.totalPractices, 0);
    });

    test('practicedToday is true after markPracticed, false if last day != today',
        () async {
      // Simulate a stored last day that's yesterday.
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      SharedPreferences.setMockInitialValues({
        'lock.lastDay': StreakMath.iso(yesterday),
      });
      final store = await PracticeStateStore.open();
      final stateBefore = store.read();
      expect(stateBefore.practicedToday, isFalse);

      await store.markPracticed();
      final stateAfter = store.read();
      expect(stateAfter.practicedToday, isTrue);
      expect(stateAfter.totalPractices, 1);
    });
  });

  group('PromptPicker', () {
    test('today() returns a prompt from the curated pool', () async {
      final p = await PromptPicker.today();
      expect(p.ref, isNotEmpty);
      expect(p.text, isNotEmpty);
      expect(p.isVerse, isTrue);
    });

    test('today() returns the same prompt for the same day (deterministic)',
        () async {
      final a = await PromptPicker.today();
      final b = await PromptPicker.today();
      expect(a.id, b.id);
    });
  });
}
