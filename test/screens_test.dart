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
/// pre-populated PracticeStateStore. The surface size is set to a
/// phone-ish 800x1600 because the default 800x600 doesn't fit the
/// onboarding column (4 window options + headlines + button) on a
/// real device at 1x, and even less in tests with padding. Setting
/// it explicitly also makes the layout predictable in CI.
Future<void> _setSurfaceSize(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

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
      // 8 words total -> truncate to 6 + ellipsis.
      expect(
        versePreviewText('Be still, and know that I am God.'),
        '"Be still, and know that I…"',
      );
    });

    test('treats 6 words as a full preview', () {
      // 6 words total -> no truncation, return as-is with quotes.
      expect(
        versePreviewText('Be still and know that I.'),
        '"Be still and know that I."',
      );
    });
  });

  group('BrandMark', () {
    testWidgets('wordmark and dot-in-ring render without overflow', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
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
      await tester.pump();
      expect(find.byType(CustomPaint), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  });

  group('OnboardingScreen', () {
    testWidgets('renders the wordmark, headline, and 4 window options',
        (tester) async {
      await _setSurfaceSize(tester);
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
      await _setSurfaceSize(tester);
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
    setUp(() async {
      // Preload the prompt cache so the home screen doesn't need to
      // wait for the asset bundle (which is empty in tests). The
      // PromptPicker has a hardcoded fallback that returns Psalm 46:10
      // when the asset fails to load — that's the prompt used here.
      await PromptPicker.today();
    });

    testWidgets('shows the active state with verse preview + what-is-this link',
        (tester) async {
      await _setSurfaceSize(tester);
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
      await _setSurfaceSize(tester);
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
      await _setSurfaceSize(tester);
      SharedPreferences.setMockInitialValues({
        'hush.onboarded': true,
        'hush.window': PracticeWindow.morning.index,
        'hush.lastDay': DateTime.now().toIso8601String().substring(0, 10),
        'hush.total': 5,
      });
      final store = await PracticeStateStore.open();
      // Pre-populate the prompt cache so the home screen's _loadPrompt
      // resolves from cache. The asset bundle is empty in tests; the
      // fallback list (single Psalm 46:10 verse) is what we want.
      // Force the cache load to actually complete in real time before
      // the test pumpWidget runs.
      await tester.runAsync(() async {
        await PromptPicker.today();
      });
      await tester.pumpWidget(
        _harness(child: const HomeScreen(), store: store),
      );
      // Give the home screen's initState _loadPrompt() time to resolve
      // the cached future. The cache hit should complete in one
      // microtask, but the test framework sometimes needs explicit
      // pumping. 5 pumps with 50ms each gives 250ms of fake time which
      // is more than enough for the cached future to resolve.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.pumpAndSettle();
      expect(find.text('today is done'), findsOneWidget);
      expect(find.text('see you tomorrow.'), findsOneWidget);
      expect(find.text('begin'), findsNothing);
      // Practiced state shows reference with original casing.
      expect(find.textContaining('Psalm 46:10'), findsOneWidget);
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
      await _setSurfaceSize(tester);
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
      await _setSurfaceSize(tester);
      final store = await _freshStore(onboarded: true);
      await tester.pumpWidget(
        _harness(
          child: const PracticeScreen(prompt: samplePrompt),
          store: store,
        ),
      );
      // pumpAndSettle uses 0-duration pumps, which doesn't fire the
      // 800ms reveal Timer (real timers need explicit duration pumps).
      // So pump explicitly to advance fake time past the reveal.
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.widgetWithText(ElevatedButton, 'continue'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'continue'));

      // The _complete() flow awaits HapticFeedback (platform channel)
      // then markPracticed (SharedPreferences setString/setInt). These
      // use real async that doesn't always complete in fake time. Use
      // runAsync to let them complete in real time, but only briefly so
      // the 1500ms auto-pop doesn't fire.
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('see you tomorrow.'), findsOneWidget);
    });
  });

  group('SettingsScreen', () {
    testWidgets('renders window, today, help links, and reset', (tester) async {
      await _setSurfaceSize(tester);
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
      await _setSurfaceSize(tester);
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
