# Changelog

All notable changes to `lock.` are documented in this file.

## [Unreleased] — v0.1 (the rebuild)

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
- `android/.../res/layout/lock_widget.xml` — no widget layout
- `android/.../res/xml/lock_widget_info.xml` — no widget metadata
- `android/.../res/drawable/widget_background.xml` — no widget background
- The orange + padlock + cross from the previous build

### Notes
- `lock.` is the *minimal-scope* sibling of `mx.pclub.cadence`. Both reject PBL. `lock.` is the floor, Cadence is the architecture.
- See `docs/BRAND.md` for the design tokens, the anti-patterns, and what was explicitly rejected.
- See `docs/VS-CADENCE.md` for the side-by-side comparison.
