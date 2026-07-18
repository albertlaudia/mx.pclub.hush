# lock.

> A daily practice, quietly.

![lock. social preview](media/social-preview-1280x640.png)

**The mark:** the word `lock.` in a distinctive warm serif (DM Serif Display), set in cream on deep teal, with a single small muted amber dot above the `o`. The wordmark is the icon. The dot is the only symbol.

**Repo:** `albertlaudia/mx.pclub.lock`
**Org prefix:** `mx.pclub.*` (pclub product family)
**Sibling apps:** `mx.pclub.cadence` (the no-PBL counterpart), `mx.pclub.caloriecounter`, `mx.pclub.pulse`

---

## What this is

A **minimal, working daily-practice app** — the v0.1 vertical slice. The product is the practice. One verse, one moment of attention, one quiet "done" tap. That's it.

**This is the deliberately-simpler sibling of `mx.pclub.cadence`.** Where Cadence ships a chapter mark, a Section, a composition, and an E2E-encrypted social layer, `lock.` ships **three screens and a settings page**. No streak counter. No home widget. No mood check-in. No notifications. No subscription. The minimal is the feature.

## The mark

![lock. app icon](media/icons/primary-1024.png)

A wordmark in cream on deep teal, with a small amber dot above the `o`. A journal cover, not a streak counter.

## The platform — minimal v0.1

The MVP ships with **three screens and a settings page**:

| Screen | What it does |
|---|---|
| **Onboarding** | A single screen. Pick a practice window (morning / midday / evening / anytime). One button. |
| **Home** | "good morning." Today's practice — a verse, a prompt, a "begin" button. After completion, the home screen says "see you tomorrow." |
| **Practice** | A full-screen verse. A moment of attention. A quiet "done" button. No timer. No countdown. No "you prayed for 1:32". |
| **Settings** | Practice window, today status, total practices, version, reset. |

That's the entire product.

## What this is NOT

- **Not** a streak counter. No flame. No "Day 47!". No "best ever".
- **Not** a mood check-in. No "how are you feeling today?" slider.
- **Not** a public widget. No home screen broadcast.
- **Not** a cross-app blocker. No AccessibilityService. No iOS FamilyControls.
- **Not** a notification engine. No daily reminder. (Yet.)
- **Not** a social product. No Section. No leaderboard. No "share my streak".
- **Not** a subscription. No paywall. No "PRO" tier. No "Restore your streak for $4.99".
- **Not** a multi-locale product. English only. Add locales via `flutter_localizations` + `intl` ARB files.
- **Not** a clone of anything. The mark, the colors, the copy, the UX — all genuinely ours. See `docs/BRAND.md` for the design tokens and `docs/VS-CADENCE.md` for the side-by-side with Cadence.

## The brand

- **Wordmark:** `lock.` in DM Serif Display, cream on deep teal
- **Secondary mark:** a small dot inside a thin ring (for small contexts)
- **Palette:** deep teal `#1F3D3A`, warm cream `#F5F0E6`, muted amber `#B89968`, ink `#1A1A1A`
- **Type:** DM Serif Display (display) + Inter (body)
- **Voice:** lowercase, no exclamation marks, no superlatives, no guilt copy
- **Detail in `docs/BRAND.md`**

The brand is not the Prayer Lock orange + padlock + cross. It is a journal cover. See `docs/BRAND.md` for what was explicitly rejected.

## Stack

- **Flutter 3.27+** — single codebase, iOS + Android from the same `lib/`
- **Riverpod 2.5+** — state management
- **shared_preferences 2.3+** — local persistence
- **google_fonts 6+** — DM Serif Display + Inter
- **intl 0.19+** — date formatting

No backend. No Firebase. No notifications. No E2E encryption. The product is local-only.

## Repo layout

```
mx.pclub.lock/
├── lib/                       Dart source
│   ├── main.dart              entry, gate, ProviderScope
│   ├── core/
│   │   ├── theme/             AppTheme (teal/cream/amber) + BrandMark
│   │   ├── storage/           PracticeState + Riverpod provider
│   │   └── utils/             date math + curated verse pool
│   └── features/
│       ├── onboarding/        1-screen first-launch
│       ├── home/              today's practice card
│       ├── practice/          the moment — full-screen verse
│       └── settings/          window, today, total, reset
├── assets/verses/verses.json  12 curated ESV verses
├── ios/                       iOS Runner target (no widget extension)
├── android/                   Android target (no widget receiver)
├── media/                     brand mark, full icon set, social preview
├── docs/                      BRAND.md, VS-CADENCE.md
├── test/                      date math unit tests
└── README.md
```

## How to run

```bash
flutter pub get
cd ios && pod install && cd ..
flutter run -d <device>
```

## What's planned for v0.2 (the "better platform")

The minimal v0.1 is the floor. Once 5-10 internal users have lived with it for 14 days, we add:

- **A quiet day-count** (our way, not the PBL way — no flame, no public score, no shame)
- **A home screen widget** (the secondary mark + day count)
- **A daily notification** at the user's chosen window
- **Multi-locale** (8 locales, three-layer parity, no surprise languages)
- **Settings depth** (custom cadence, locale, sign out)

These are added *after* the minimal is validated, not before. The minimal is the feature.

## Why this exists

This is the **deliberately-simpler sibling of `mx.pclub.cadence`**. Where Cadence ships the philosophy of "no PBL, no streaks, no gamification", `lock.` ships the practice, full stop. Same Flutter + Riverpod base. Same `mx.pclub.*` repo convention. Different product scope.

If you ship both, you A/B-test the philosophy in the market. If you ship `lock.` alone, you bet that the practice is the feature and the score is the noise. Read `docs/VS-CADENCE.md` for the full side-by-side.

## License

Documentation: MIT. See `LICENSE`.
Product code: closed-source, all rights reserved.

---

🔗 **https://github.com/albertlaudia/mx.pclub.lock**
