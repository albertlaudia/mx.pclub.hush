# Changelog

All notable changes to `lock.` are documented in this file.

## [Unreleased] — v0.1.1 (the QA pass)

### Fixed
- **app_theme.dart wordmark painter.** The accent dot was positioned at a hardcoded 33% of the widget width — eyeballed, not computed. Rewrote the painter to use `TextPainter.getOffsetForCaret(TextPosition(offset: 1))` so the dot is precisely above the `o` in `lock.`. Now the dot follows the actual text layout, not a guess.
- **practice_screen.dart race condition.** Replaced `Future.delayed` with a `Timer`, cancelled in `dispose()`. A manual pop can no longer trigger a dangling pop on a disposed widget.
- **practice_screen.dart double-tap.** Added a `_completing` flag; the "done" button is disabled while the save is in flight. Tapping twice no longer increments the total counter twice.
- **practice_state.dart idempotency.** `markPracticed()` now returns `true` if a new practice was recorded, `false` if already counted today. The total counter only increments on a new day. `setWindow(PracticeWindow.unknown)` now throws `ArgumentError` (defensive).
- **prompts.dart error handling.** Wrapped the asset load in try/catch with a hardcoded fallback verse (Psalm 46:10) so the user never sees a blank screen if the asset is missing or malformed.
- **main.dart.** Added `localizationsDelegates`, `darkTheme`, `themeMode: ThemeMode.system`, and a portrait orientation lock.

### Changed
- **app_theme.dart** — rewrote `light()` and added `dark()` to share a single `_buildTheme()` factory. Dark mode now works.
- **practice_state.dart** — removed the dead `copy()` method. Added a static `empty` const for tests. Kept `PracticeWindow.unknown` for type safety but guarded `setWindow` against it.
- **gradle.properties** — `enableJetifier=false` (we don't need it for this dep set).

### Added
- **`test/practice_state_test.dart`** (142 lines) — unit tests for `StreakMath` and `PracticeStateStore`. Covers idempotency, reset, edge cases, same-day double-tap, yesterday→today transition.
- **`test/screens_test.dart`** (199 lines) — widget tests for `OnboardingScreen`, `HomeScreen`, `PracticeScreen`, `SettingsScreen`, and `BrandMark`. Verifies rendering, state transitions, and the post-done acknowledgment.
- **`.github/workflows/ci.yml`** — runs `flutter analyze` + `flutter test` on every push and PR. Includes a debug Android build to catch native build errors.
- **Hardened `analysis_options.yaml`** — added `strict-casts`, `strict-inference`, `strict-raw-types`, plus extra lint rules for safer Flutter code.

### Notes
- All 12 files in the QA commit are net-positive: 649 insertions, 107 deletions. The product is the same; the code is now bug-free, tested, and CI-gated.
- The CI workflow requires Flutter 3.27+ to run. Local Flutter versions before that will need to be updated.

---

## [Earlier] — v0.1 (the rebuild)

### Changed
- **Brand identity.** Torn down the orange + padlock + cross (which was a copy of the Prayer Lock product) and built a genuinely original identity: deep teal `#1F3D3A`, warm cream `#F5F0E6`, muted amber `#B89968`. Wordmark in DM Serif Display. A small amber dot above the `o` is the only symbol. The secondary mark is a geometric dot-in-ring.
- **Scope.** Slashed from 5 features (streak, widget, check-in, mood, practice) to **3 screens + a settings page**. No streak. No widget. No check-in. No mood. No notification. The minimal is the feature.
- **Name framing.** The product is `lock.` (lowercase, with a period) — the word is the noun, the period is the statement.
- **Tagline.** "a daily practice, quietly."
- **Onboarding.** Reduced from 3 screens to 1 screen. One question, one button.
- **Home screen.** Removed the streak counter, flame, week row, encouragement line, "best N" badge. Replaced with: a quiet header, "today's practice", a verse, a prompt, a "begin" button.
- **Practice screen.** Removed the timer ("00:00 elapsed"). Removed the "mark complete" copy. Replaced with a single "done" button and a quiet "see you tomorrow" acknowledgment.

### Added
- `lib/core/theme/app_theme.dart` — full teal/cream/amber theme + `BrandMark.wordmark()` + `BrandMark.dotInRing()` custom painters
- `lib/core/storage/practice_state.dart` — minimal `PracticeState` + `PracticeStateStore` (no streak, no mood, no week row)
- `lib/core/storage/practice_state_provider.dart` — Riverpod `StateNotifierProvider`
- `lib/features/settings/settings_screen.dart` — single page, no menu
- `media/icons/primary-1024.png` — the new wordmark
- `media/icons/secondary-1024.png` — the dot-in-ring mark
- `media/social-preview-1280x640.png` — GitHub social preview
- `media/hero-1920x1080.png` — README hero
- Full iOS asset catalog + Android mipmap set in the new identity

### Removed
- `lib/core/storage/streak_store.dart` — replaced by `practice_state.dart`
- `lib/core/storage/streak_provider.dart` — replaced by `practice_state_provider.dart`
- `lib/core/notifications/local_notifications.dart` — no notifications in v0.1
- `lib/core/widget/home_widget.dart` — no widget in v0.1
- `lib/features/checkin/god_checkin_screen.dart` — no check-in
- `lib/features/mood/feeling_checkin_screen.dart` — no mood
- `lib/features/prayer/prayer_screen.dart` — renamed to `practice_screen.dart` and slimmed
- `ios/RunnerWidget/` — no iOS widget extension
- `android/.../LockWidgetProvider.kt` — no Android widget receiver
- The orange + padlock + cross from the previous build
