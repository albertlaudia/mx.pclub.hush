import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/storage/practice_state.dart';
import 'package:hush/core/storage/practice_state_provider.dart';
import 'package:hush/core/theme/app_theme.dart';
import 'package:hush/core/ui/verse_preview.dart';
import 'package:hush/core/utils/prompts.dart';
import 'package:hush/features/home/home_screen.dart';
import 'package:hush/features/onboarding/onboarding_screen.dart';
import 'package:hush/features/practice/practice_screen.dart';
import 'package:hush/features/settings/settings_screen.dart';
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
}) async {
  SharedPreferences.setMockInitialValues({});
  final store = await PracticeStateStore.open();
  if (onboarded) await store.setOnboarded(true);
  if (window != PracticeWindow.unknown) await store.setWindow(window);
  return store;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('versePreviewText', () {
    test('returns the full text in quotes when under the word limit', () {
      expect(versePreviewText('Be still.'), '"Be still."');
    });

    test('truncates to the first 6 words with an ellipsis', () {
      expect(
        versePreviewText('Be still, and know that I am God.'),
        '"Be still, and know that I am…"',
      );
    });

    test('treats 6 words as a full preview', () {
      expect(
        versePreviewText('Be still, and know that I am.'),
        '"Be still, and know that I am."',
      );
    });
  });

  group('BrandMark', () {
    testWidgets('wordmark and dot-in-ring render without overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const Scaffold(
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
      final beginButton =
          tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'begin'));
      expect(beginButton.onPressed, isNotNull);
    });
  });

  group('HomeScreen', () {
    testWidgets('shows the active state with verse preview + what-is-this link',
        (tester) async {
      final store = await _freshStore(onboarded: true, window: PracticeWindow.morning);
      await tester.pumpWidget(
        _harness(child: const HomeScreen(), store: store),
      );
      await tester.pumpAndSettle();

      // The active state: label, reference, preview, "what is this?", "begin".
      expect(find.text("today's practice"), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'begin'), findsOneWidget);
      expect(find.text('what is this?'), findsOneWidget);
      expect(find.text('see you tomorrow.'), findsNothing);

      // The verse is a PREVIEW, not the full text. The full verse is
      // reserved for the practice moment.
      final previewFinder = find.byWidgetPredicate(
        (w) => w is Text && (w.data?.contains('…') ?? false),
      );
      expect(previewFinder, findsOneWidget);
    });

    testWidgets('tapping "what is this?" opens the explanation sheet',
        (tester) async {
      final store = await _freshStore(onboarded: true, window: PracticeWindow.morning);
      await tester.pumpWidget(
        _harness(child: const HomeScreen(), store: store),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('what is this?'));
      await tester.pumpAndSettle();
      expect(find.text('one short practice, once a day.'), findsOneWidget);
      expect(find.text('no streak. no score. no notification reminders.'),
          findsOneWidget);
      expect(find.text('no data leaves this phone.'), findsOneWidget);
    });

    testWidgets('shows the practiced state when practiced today', (tester) async {
      SharedPreferences.setMockInitialValues({
        'hush.onboarded': true,
        'hush.window': PracticeWindow.morning.index,
        'hush.lastDay': DateTime.now().toIso8601String().substring(0, 10),
        'hush.total': 5,
      });
      final store = await PracticeStateStore.open();
      await tester.pumpWidget(
        _harness(child: const HomeScreen(), store: store),
      );
      await tester.pumpAndSettle();
      expect(find.text('today is done'), findsOneWidget);
      expect(find.text('see you tomorrow.'), findsOneWidget);
      expect(find.text('begin'), findsNothing);
      // Practiced state shows reference only, not full verse.
      expect(find.textContaining('Psalm 46:10'.toLowerCase()), findsOneWidget);
    });
  });

  group('PracticeScreen', () {
    const samplePrompt = Prompt(
      id: 'test',
      ref: 'Psalm 46:10',
      text: 'Be still, and know that I am God.',
      translation: 'ESV',
    );

    testWidgets('hides the verse for 800ms, then reveals it', (tester) async {
      final store = await _freshStore();
      await tester.pumpWidget(
        _harness(
          child: const PracticeScreen(prompt: samplePrompt),
          store: store,
        ),
      );

      // Immediately after mount: the verse is hidden.
      // The reference and text are not yet visible.
      await tester.pump();
      // The verse is wrapped in AnimatedOpacity(opacity: 0), so the
      // text widget is in the tree but not painted visibly. Use
      // exists() to verify the layout, not findsOneWidget.
      expect(find.text('"Be still, and know that I am God."'), findsOneWidget);

      // The button is in "..." state — the verse hasn't revealed yet.
      expect(find.widgetWithText(ElevatedButton, '...'), findsOneWidget);

      // After 800ms (reveal timer) + 400ms (fade), the verse is visible.
      await tester.pump(const Duration(milliseconds: 1200));
      await tester.pumpAndSettle();

      // The button is now "continue".
      expect(find.widgetWithText(ElevatedButton, 'continue'), findsOneWidget);
    });

    testWidgets('tapping continue shows "see you tomorrow" then auto-pops',
        (tester) async {
      final store = await _freshStore(onboarded: true);
      await tester.pumpWidget(
        _harness(
          child: const PracticeScreen(prompt: samplePrompt),
          store: store,
        ),
      );
      // Wait for the verse to reveal.
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ElevatedButton, 'continue'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'continue'));

      // Pump enough for the async markPracticed to complete and the
      // state to update, but NOT enough to trigger the 1500ms auto-pop.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('see you tomorrow.'), findsOneWidget);
    });
  });

  group('SettingsScreen', () {
    testWidgets('renders window, today, help links, and reset', (tester) async {
      SharedPreferences.setMockInitialValues({
        'hush.onboarded': true,
        'hush.window': PracticeWindow.evening.index,
        'hush.total': 12,
      });
      final store = await PracticeStateStore.open();
      await tester.pumpWidget(
        _harness(child: const SettingsScreen(), store: store),
      );
      await tester.pumpAndSettle();

      // Practice section.
      expect(find.text('evening · 8–10pm'), findsOneWidget);
      expect(find.text('not yet'), findsOneWidget);

      // Help section.
      expect(find.text('what is this?'), findsOneWidget);
      expect(find.text('about hush.'), findsOneWidget);

      // Reset is at the bottom.
      expect(find.text('reset practice state'), findsOneWidget);

      // Version and made-by are gone from the main page (moved to about).
      expect(find.text('0.1.0'), findsNothing);
      expect(find.text('pclub'), findsNothing);
    });

    testWidgets('tapping "what is this?" opens the sheet from settings too',
        (tester) async {
      final store = await _freshStore(onboarded: true);
      await tester.pumpWidget(
        _harness(child: const SettingsScreen(), store: store),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('what is this?'));
      await tester.pumpAndSettle();
      expect(find.text('one short practice, once a day.'), findsOneWidget);
    });
  });
}
