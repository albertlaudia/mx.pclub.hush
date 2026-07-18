import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lock/core/storage/practice_state.dart';
import 'package:lock/core/storage/practice_state_provider.dart';
import 'package:lock/core/theme/app_theme.dart';
import 'package:lock/features/home/home_screen.dart';
import 'package:lock/features/onboarding/onboarding_screen.dart';
import 'package:lock/features/practice/practice_screen.dart';
import 'package:lock/features/settings/settings_screen.dart';
import 'package:lock/core/utils/prompts.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test helper: build a widget tree wrapped in ProviderScope with a
/// pre-populated PracticeStateStore.
Widget _harness({
  required Widget child,
  required PracticeStateStore store,
}) {
  return ProviderScope(
    overrides: [practiceStoreProvider.overrideWithValue(store)],
    child: MaterialApp(
      theme: AppTheme.light(),
      home: child,
    ),
  );
}

Future<PracticeStateStore> _freshStore({
  bool onboarded = false,
  PracticeWindow window = PracticeWindow.unknown,
  bool practicedToday = false,
  int total = 0,
}) async {
  SharedPreferences.setMockInitialValues({});
  final store = await PracticeStateStore.open();
  if (onboarded) await store.setOnboarded(true);
  if (window != PracticeWindow.unknown) await store.setWindow(window);
  // We can't easily simulate practicedToday without a real clock; the
  // window-set path is the most useful to test.
  if (total > 0) {
    // Bump the total by markPracticed calls.
    // (Marking will set lastDay to today; not used in these tests below.)
  }
  return store;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BrandMark', () {
    testWidgets('wordmark renders without overflow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BrandMark.wordmark(size: 18),
                  BrandMark.wordmark(size: 24),
                  BrandMark.dotInRing(size: 24),
                ],
              ),
            ),
          ),
        ),
      );
      // Pump a frame so the CustomPainter paints.
      await tester.pump();
      expect(find.byType(BrandMark), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('OnboardingScreen', () {
    testWidgets('renders the wordmark, headline, and 4 window options',
        (tester) async {
      final store = await _freshStore();
      await tester.pumpWidget(
        _harness(child: const OnboardingScreen(), store: store),
      );
      await tester.pumpAndSettle();
      expect(find.text('a daily practice,\nquietly.'), findsOneWidget);
      expect(find.text('morning'), findsOneWidget);
      expect(find.text('midday'), findsOneWidget);
      expect(find.text('evening'), findsOneWidget);
      expect(find.text('anytime'), findsOneWidget);
      // The "begin" button is disabled until a window is picked.
      final beginFinder = find.widgetWithText(ElevatedButton, 'begin');
      expect(beginFinder, findsOneWidget);
      final beginButton = tester.widget<ElevatedButton>(beginFinder);
      expect(beginButton.onPressed, isNull);
    });

    testWidgets('enables begin after a window is picked', (tester) async {
      final store = await _freshStore();
      await tester.pumpWidget(
        _harness(child: const OnboardingScreen(), store: store),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('morning'));
      await tester.pump();
      final beginFinder = find.widgetWithText(ElevatedButton, 'begin');
      final beginButton = tester.widget<ElevatedButton>(beginFinder);
      expect(beginButton.onPressed, isNotNull);
    });
  });

  group('HomeScreen', () {
    testWidgets('shows the active state when not practiced today',
        (tester) async {
      final store = await _freshStore(onboarded: true, window: PracticeWindow.morning);
      await tester.pumpWidget(
        _harness(child: const HomeScreen(), store: store),
      );
      // Wait for the async prompt to load.
      await tester.pumpAndSettle();
      expect(find.text("today's practice"), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'begin'), findsOneWidget);
      expect(find.text('see you tomorrow.'), findsNothing);
    });

    testWidgets('shows the practiced state when practiced today',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'lock.onboarded': true,
        'lock.window': PracticeWindow.morning.index,
        'lock.lastDay': DateTime.now().toIso8601String().substring(0, 10),
        'lock.total': 5,
      });
      final store = await PracticeStateStore.open();
      await tester.pumpWidget(
        _harness(child: const HomeScreen(), store: store),
      );
      await tester.pumpAndSettle();
      expect(find.text('today is done'), findsOneWidget);
      expect(find.text('see you tomorrow.'), findsOneWidget);
      expect(find.text('begin'), findsNothing);
    });
  });

  group('PracticeScreen', () {
    const samplePrompt = Prompt(
      id: 'test',
      ref: 'Psalm 46:10',
      text: 'Be still, and know that I am God.',
      translation: 'ESV',
    );

    testWidgets('renders the verse and a done button', (tester) async {
      final store = await _freshStore();
      await tester.pumpWidget(
        _harness(
          child: const PracticeScreen(prompt: samplePrompt),
          store: store,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Psalm 46:10'), findsOneWidget);
      expect(find.text('"Be still, and know that I am God."'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'done'), findsOneWidget);
    });

    testWidgets('shows "see you tomorrow" after done is tapped',
        (tester) async {
      final store = await _freshStore(onboarded: true);
      await tester.pumpWidget(
        _harness(
          child: const PracticeScreen(prompt: samplePrompt),
          store: store,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'done'));
      // Allow the async markPracticed to complete and the state to update.
      await tester.pumpAndSettle();
      expect(find.text('see you tomorrow.'), findsOneWidget);
    });
  });

  group('SettingsScreen', () {
    testWidgets('renders the practice window and the total', (tester) async {
      SharedPreferences.setMockInitialValues({
        'lock.onboarded': true,
        'lock.window': PracticeWindow.evening.index,
        'lock.total': 12,
      });
      final store = await PracticeStateStore.open();
      await tester.pumpWidget(
        _harness(child: const SettingsScreen(), store: store),
      );
      await tester.pumpAndSettle();
      expect(find.text('evening · 8–10pm'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('reset practice state'), findsOneWidget);
    });
  });
}
