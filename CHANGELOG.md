# Changelog

All notable changes to `hush.` are documented in this file.

## [Unreleased] — v0.3 (the rename: lock. → hush.)

### Changed
- **The platform is now `hush.`** Renamed from `lock.`. The old name implied *blocking* (your phone, your day, your distractions) — the product is not a blocker. The new name is the *state* the user enters: **to hush** = to make quiet, to settle. Connects directly to the seed verse, "Be still, and know that I am God" (Psalm 46:10). Multi-faith, universal, calm.
- **GitHub repo renamed** from `albertlaudia/mx.pclub.lock` to `albertlaudia/mx.pclub.hush`. Redirects automatically.
- **App icon** regenerated. New wordmark `hush.` in DM Serif Display, cream on deep teal, with the amber dot above the `u` (was above the `o`). The two `h`s frame the `u` and `s` like a doorway; the dot is centered in the word, like a gem in a setting.
- **Bundle ID / package name** changed from `mx.pclub.lock` to `mx.pclub.hush`. iOS `PRODUCT_BUNDLE_IDENTIFIER`, Android `namespace` and `applicationId`, Kotlin package, all updated.
- **Pubspec name** changed from `lock` to `hush`. All Dart imports updated.
- **App entry point** renamed: `LockApp` → `HushApp`.
- **SharedPreferences keys** renamed: `lock.onboarded` → `hush.onboarded`, etc. (Existing user data will be silently re-initialized — v0.3 is pre-launch so this is acceptable; post-launch, a migration would be required.)
- **Wordmark text** in the in-app painter updated from "lock." to "hush.". The dot is still at offset 1 of the wordmark, which is now the `u` (was the `o`).

### Added
- **Full `/media` rebuild for marketing.** Every marketing asset is regenerated in the new brand. See `media/README.md` for the full inventory.
  - `media/icons/primary-1024.png` — new wordmark master
  - `media/icons/secondary-1024.png` — secondary mark (unchanged)
  - `media/icons/app-icon-{1024,512}.png` — iOS App Store + Play Store masters
  - `media/icons/ios/Icon-App-*.png` — all 15 iOS sizes, regenerated
  - `media/icons/android/mipmap-*/ic_launcher.png` — all 5 Android densities, regenerated
  - `media/icons/favicon-{16,32,48,256}.png` — web favicons, regenerated
  - `media/social-preview-1280x640.png` — GitHub social preview (regenerated)
  - `media/hero-1920x1080.png` — README hero (regenerated)
  - `media/poster-1080x1920.png` — vertical social poster (NEW)
  - `media/banner-twitter-1500x500.png` — Twitter header (NEW)
  - `media/banner-linkedin-1584x396.png` — LinkedIn cover banner (NEW)
  - `media/opengraph-1200x630.png` — Open Graph default (NEW)
  - `media/logo-lockup-1500x1000.png` — press kit lockup (NEW)
  - `media/brand-colors-1500x1000.png` — brand palette (NEW)
- **`scripts/resize-icons.py`** — a single command to regenerate every iOS / Android / favicon derivative from the source masters. Idempotent, re-runnable.
- **iOS pbxproj fixed.** The hand-crafted `project.pbxproj` was missing the target-level `XCBuildConfiguration` sections — it referenced `97C147081CF9000F007C117D` and `97C147091CF9000F007C117D` but never defined them. Added the missing sections with `PRODUCT_BUNDLE_IDENTIFIER = mx.pclub.hush`, `INFOPLIST_FILE`, `SWIFT_VERSION`, and the standard Flutter build settings. Without this fix, the iOS build would have failed to find a valid bundle ID. This is a pre-existing bug, fixed as part of the rename.

### Notes
- The rename is **pre-launch**, so no migration is needed for existing users. After launch, a `hush.schemaVersion` key + a migration function would be required to translate old `lock.*` keys to new `hush.*` keys.
- The asset filenames kept the `Icon-App-*` prefix (Apple's convention) — only the image content changed. The Contents.json files in the asset catalog are unchanged because the filenames are the same.
- The Android Kotlin source moved from `android/app/src/main/kotlin/mx/pclub/lock/MainActivity.kt` to `android/app/src/main/kotlin/mx/pclub/hush/MainActivity.kt`. The package declaration inside is updated.

---

## [Earlier] — v0.2 (the UX pass)

### Added
- **`WhatIsThisSheet` (`lib/core/ui/what_is_this_sheet.dart`).** A bottom sheet that explains the product in 4 brand-locked points: (1) one short practice, once a day; (2) read one verse, attend to it, continue; (3) no streak, no score, no notification reminders; (4) no data leaves this phone. Used from the home screen and the settings page. Reachable in 1 tap. The most important UX gap closed.
- **`AboutSheet` (`lib/features/settings/about_sheet.dart`).** Dev info goes here, behind a tap. Shows the wordmark, the brand copy, the open source licenses (via Flutter's built-in `showLicensePage`), a "send feedback" link, and the "made by pclub" byline. The main settings page is for user actions, not for reading numbers.
- **`versePreviewText()` (`lib/core/ui/verse_preview.dart`).** A pure helper that returns the first 6 words of a verse, italicized, with an ellipsis. Used by the home screen to show a *preview* of the day's verse — the full text is reserved for the practice moment.
- **"what is this?" link on the home screen.** Subtle, amber, low-importance visually but high-importance for the new user. Opens the sheet.
- **"what is this?" and "about hush." rows in the settings page.** Two new entries under a "help" section. The settings page now has `practice` and `help` sections, with `reset` as a small button at the bottom.
- **Pre-verse breathing space on the practice screen.** 800ms of silence after the screen opens — only the wordmark is visible. The verse then fades in over 400ms. The user has time to put the phone down and "arrive" at the practice before the text appears.
- **Haptic feedback on practice completion.** A single `HapticFeedback.lightImpact()` when the user taps "continue". The brand is tactile — "hush." is a verb, a hush on the world, a moment sealed. No haptic anywhere else; the moment is the only one.
- **"see you tomorrow" auto-pop extended to 1500ms.** Was 1200ms in v0.1.1. The extra 300ms gives the user time to read the acknowledgment.
- **Three new test files** for the UX components: `test/what_is_this_sheet_test.dart` (2 tests), `test/about_sheet_test.dart` (2 tests), and expanded `test/screens_test.dart` (now 9 tests covering the new home/practice/settings flows).

### Changed
- **Home screen: home is now a *preview*, not the practice.** The home used to show the full verse. It now shows the reference + first 6 words + a "what is this?" link. The full verse is reserved for the practice screen. Same text, two intents. The first read is a taste; the second is the moment.
- **Practice screen: "done" → "continue".** The user is continuing their day, not finishing a task. The label matches the intent.
- **Practice screen: verse reveal is now a state machine.** The screen opens with a 800ms breathing space (only the wordmark), then the verse fades in over 400ms. The "continue" button is disabled until the reveal completes. The button shows "..." while waiting, then transitions to "continue" with an `AnimatedSwitcher`.
- **Settings: removed the "version" and "made by" rows from the main page.** Moved to the `AboutSheet` instead. The main page is now `practice` (window, today) + `help` (what is this?, about hush.) + a small `reset` link at the bottom.
- **Settings: removed the "total practices" counter from the main page.** The brand says the product is the practice, not the score. The total is still tracked internally (for the user's self-knowledge) but no longer surfaced on the home page. A future "about hush." entry could expose it; for now, it's behind a tap.
- **Practiced state: shows reference only, not full verse.** "today's practice was psalm 46:10." The full text is gone after the practice. The brand says the practice is the moment, not the archive.

### Fixed
- **The new user had no way to learn what the product is.** The home showed a verse and a "begin" button — no explanation. A new user either tapped (committed without context) or closed (deleted without trying). The "what is this?" affordance closes this gap. Now every user has 1-tap access to the brand's promise.

---

## [Earlier] — v0.1.1 (the QA pass)

### Fixed
- **app_theme.dart wordmark painter.** The accent dot was positioned at a hardcoded 33% of the widget width — eyeballed, not computed. Rewrote the painter to use `TextPainter.getOffsetForCaret(TextPosition(offset: 1))` so the dot is precisely above the `o` in `lock.`. Now the dot follows the actual text layout, not a guess.
- **practice_screen.dart race condition.** Replaced `Future.delayed` with a `Timer`, cancelled in `dispose()`. A manual pop can no longer trigger a dangling pop on a disposed widget.
- **practice_screen.dart double-tap.** Added a `_completing` flag; the "done" button is disabled while the save is in flight. Tapping twice no longer increments the total counter twice.
- **practice_state.dart idempotency.** `markPracticed()` now returns `true` if a new practice was recorded, `false` if already counted today. The total counter only increments on a new day. `setWindow()` now throws `ArgumentError` on `unknown` (defensive).
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

---

## [Earlier] — v0.1 (the original `lock.` build)

The first build of the product was named `lock.`. The brand was deep teal, cream, amber. The wordmark was a serif `lock.` with an amber dot above the `o`. The repo was `albertlaudia/mx.pclub.lock`.

The first build was the *rejection* of the Prayer Lock product (orange + padlock + cross) but the *name* `lock.` was still a stretch — it implied *blocking*, which is not what the product is. The product is *quieting* — putting the world on mute for one verse. That's why v0.3 renamed it to `hush.`.

The original v0.1 still has the v0.2 UX pass and the v0.1.1 QA pass documented above — those are still valid for the `hush.` product. Only the name and the icon changed.
