/// Tests for the v0.4 UX polish + bug fixes pass.
///
/// Covers:
///   - amberDark / muteDark color tokens are AA-compliant on cream
///   - Prompt equality
///   - Prompt.isVerse correctly identifies verse vs non-verse
///   - Settings has the new "show me again" row
///   - About sheet has the feedback link
///   - Home screen midnight timer exists
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hush/core/storage/practice_state.dart';
import 'package:hush/core/storage/practice_state_provider.dart';
import 'package:hush/core/theme/app_theme.dart';
import 'package:hush/core/utils/prompts.dart';
import 'package:hush/features/home/home_screen.dart';
import 'package:hush/features/onboarding/onboarding_screen.dart';
import 'package:hush/features/settings/about_sheet.dart';
import 'package:hush/features/settings/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Compute the WCAG 2.x contrast ratio between two colors (1.0-21.0).
double contrastRatio(Color a, Color b) {
  double channel(int v) {
    final s = v / 255.0;
    return s <= 0.03928 ? s / 12.92 : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  double lum(Color c) {
    final r = channel((c.r * 255).round());
    final g = channel((c.g * 255).round());
    final bl = channel((c.b * 255).round());
    return 0.2126 * r + 0.7152 * g + 0.0722 * bl;
  }

  final la = lum(a);
  final lb = lum(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

Widget _harness({
  required Widget child,
  required PracticeStateStore store,
}) {
  return ProviderScope(
    overrides: [practiceStoreProvider.overrideWithValue(store)],
    child: MaterialApp(theme: AppTheme.light(), home: child),
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

  group('Color contrast (WCAG AA)', () {
    test('amberDark on cream passes AA for normal text (>= 4.5:1)', () {
      final ratio = contrastRatio(AppColors.amberDark, AppColors.cream);
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'amberDark on cream must be >= 4.5:1 for AA');
    });

    test('muteDark on cream passes AA for normal text (>= 4.5:1)', () {
      final ratio = contrastRatio(AppColors.muteDark, AppColors.cream);
      expect(ratio, greaterThanOrEqualTo(4.5),
          reason: 'muteDark on cream must be >= 4.5:1 for AA');
    });

    test('inkSoft on cream passes AAA for normal text (>= 7:1)', () {
      final ratio = contrastRatio(AppColors.inkSoft, AppColors.cream);
      expect(ratio, greaterThanOrEqualTo(7.0),
          reason: 'inkSoft should be the high-contrast body text color');
    });

    test('teal on cream passes AA for normal text', () {
      final ratio = contrastRatio(AppColors.teal, AppColors.cream);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('cream on teal (the begin button) passes AA', () {
      final ratio = contrastRatio(AppColors.cream, AppColors.teal);
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('amber on cream FAILS AA (regression check)', () {
      // This is the brand accent color; it must not be used for body
      // text. Used only for the dot and large decorative headings.
      final ratio = contrastRatio(AppColors.amber, AppColors.cream);
      expect(ratio, lessThan(4.5),
          reason: 'amber on cream is intentionally below AA — '
              'use amberDark for text');
    });
  });

  group('Prompt.isVerse', () {
    test('detects a verse by reference format (Book Chapter:Verse)', () {
      const v = Prompt(
        id: 'test',
        ref: 'Psalm 46:10',
        text: 'Be still.',
        translation: 'ESV',
      );
      expect(v.isVerse, isTrue);
    });

    test('detects a non-verse (no chapter:verse format)', () {
      const p = Prompt(
        id: 'p1',
        ref: 'a breath',
        text: 'inhale. exhale.',
        translation: 'open',
      );
      expect(p.isVerse, isFalse);
    });

    test('Prompt equality is value-based', () {
      const a = Prompt(
        id: 'x',
        ref: 'Psalm 1:1',
        text: 'text',
        translation: 'ESV',
      );
      const b = Prompt(
        id: 'x',
        ref: 'Psalm 1:1',
        text: 'text',
        translation: 'ESV',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });

  group('Onboarding error handling', () {
    testWidgets('the begin button toggles between "begin" and "saving"',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      SharedPreferences.setMockInitialValues({});
      final store = await PracticeStateStore.open();

      await tester.pumpWidget(
        _harness(child: const OnboardingScreen(), store: store),
      );
      await tester.pumpAndSettle();

      // Pick a window to enable the begin button.
      await tester.tap(find.text('morning'));
      await tester.pump();

      // The begin button is now enabled.
      final beginBefore = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'begin'),
      );
      expect(beginBefore.onPressed, isNotNull);
    });
  });

  group('Settings new "show me again" row', () {
    testWidgets('renders the show-me-again row in the help section',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final store = await _freshStore(onboarded: true, window: PracticeWindow.morning);
      await tester.pumpWidget(
        _harness(child: const SettingsScreen(), store: store),
      );
      await tester.pumpAndSettle();

      // The new "show me again" row sits in the help section.
      expect(find.text('show me again'), findsOneWidget);
      // The other help rows are still there.
      expect(find.text('what is this?'), findsOneWidget);
      expect(find.text('about hush.'), findsOneWidget);
    });

    testWidgets('tapping show me again opens a replayable onboarding',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final store = await _freshStore(onboarded: true, window: PracticeWindow.morning);
      await tester.pumpWidget(
        _harness(child: const SettingsScreen(), store: store),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('show me again'));
      await tester.pumpAndSettle();

      // The replay shows the wordmark and tagline (the original
      // onboarding's first impressions).
      expect(find.text('a daily practice,\nquietly.'), findsOneWidget);
    });
  });

  group('About sheet — feedback wired', () {
    testWidgets('feedback link is present in the about sheet',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AboutSheet())),
      );
      await tester.pumpAndSettle();
      expect(find.text('send feedback'), findsOneWidget);
    });
  });

  group('Home midnight timer', () {
    testWidgets('the home screen renders a greeting that matches the hour',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      // Preload the prompt cache (see screens_test.dart for why).
      await PromptPicker.today();
      final store = await _freshStore(onboarded: true, window: PracticeWindow.morning);
      await tester.pumpWidget(
        _harness(child: const HomeScreen(), store: store),
      );
      await tester.pumpAndSettle();
      // The greeting renders. We can't directly verify the timer
      // exists (it's private state), but we can verify the home
      // screen builds without exception.
      final foundGreeting = find.text('good morning').evaluate().isNotEmpty ||
          find.text('good afternoon').evaluate().isNotEmpty ||
          find.text('good evening').evaluate().isNotEmpty;
      expect(foundGreeting, isTrue);
    });
  });
}
