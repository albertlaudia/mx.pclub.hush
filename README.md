# prayer lock

> A basic daily-prayer habit app. App block + prayer screen, day streak, home widget, daily check-in. Local-only MVP.

![prayer lock social preview](media/social-preview-1280x640.png)

**Tagline:** *block your phone until you pray.*

**Repo:** `albertlaudia/mx.pclub.lock`
**Org prefix:** `mx.pclub.*` (pclub product family)
**Sibling apps:** `mx.pclub.cadence` (the no-PBL counterpart), `mx.pclub.caloriecounter`, `mx.pclub.pulse`

---

## What this is

A **basic, working Prayer Lock-style app** — the iOS-first MVP that demonstrates the full UX from the reference screenshots. Local-only (no backend, no account, no subscription). The day streak, the mood check-in, the daily reminder, the home screen widget — all working, all local.

**This is the PBL counterpart to `mx.pclub.cadence`.** Cadence is built on the philosophy of *no points, no streaks, no gamification*. This app is built on the philosophy of *every point, every streak, every gamification cue*. The two are siblings, not the same product. Read `docs/BRAND.md` for the design tokens and `docs/VS-CADENCE.md` for the side-by-side comparison.

## Features

The MVP ships with the five core features from the reference design:

| # | Feature | What it does | Status |
|---|---|---|---|
| 1 | **App block + prayer screen** | Full-screen prayer view that the user sees when they "open the app to pray" | ✅ Working — simulated block (no real cross-app blocking) |
| 2 | **Day streak counter** | Flame + day number, with weekly progress row (su mo tu we th fr sa) | ✅ Working — local persistence |
| 3 | **Home screen widget** | iOS SwiftUI widget + Android AppWidgetProvider, shows current streak | ✅ Code written, requires Xcode/Gradle build step |
| 4 | **Daily God check-in** | "How's your relationship with God today?" — slider 1-10, emoji shifts | ✅ Working |
| 5 | **How are you feeling** | "How are you feeling today?" — slider 1-10, emoji shifts | ✅ Working |

Plus: a 3-screen onboarding flow, daily notification reminder, deterministic-daily Bible verse from a curated pool of 12 verses.

## What this is NOT

- **Not** a real cross-app blocker. The "block" is a simulated full-screen prayer view that the user opens themselves. Real cross-app blocking requires iOS FamilyControls (Apple approval) or Android AccessibilityService (high-risk permission). Both are out of scope for the basic MVP.
- **Not** a backend. Everything is `shared_preferences` on the device.
- **Not** a paid product. There is no subscription, no paywall, no IAP.
- **Not** a multi-locale product. English only. Add locales via `flutter_localizations` + `intl` ARB files.

## Stack

- **Flutter 3.27+** — single codebase, iOS + Android from the same `lib/`
- **Riverpod 2.5+** — state management
- **shared_preferences 2.3+** — local persistence
- **flutter_local_notifications 17+** — daily reminder
- **home_widget 0.6+** — iOS SwiftUI widget + Android AppWidgetProvider bridge
- **google_fonts 6+** — Inter + DM Serif Display
- **intl 0.19+** — date formatting
- **timezone 0.9+** — scheduled notification timezone support

## Repo layout

```
mx.pclub.lock/
├── lib/                       Dart source
│   ├── main.dart              app entry, ProviderScope, gate
│   ├── core/
│   │   ├── theme/             AppTheme + AppColors (orange/cream/green/blue)
│   │   ├── storage/           StreakStore + Riverpod providers
│   │   ├── notifications/     flutter_local_notifications wrapper
│   │   ├── widget/            home_widget bridge
│   │   └── utils/             date math + curated verse pool
│   └── features/
│       ├── onboarding/        3-screen first-launch flow
│       ├── home/              streak display + week row + actions
│       ├── prayer/            full-screen prayer view
│       ├── checkin/           "how's your relationship with God today?"
│       └── mood/              "how are you feeling today?"
├── assets/verses/verses.json  12 curated ESV verses
├── ios/
│   ├── Runner/                main app target
│   └── RunnerWidget/          home screen widget extension (SwiftUI)
├── android/
│   └── app/src/main/
│       ├── AndroidManifest.xml
│       ├── kotlin/mx/pclub/lock/
│       │   ├── MainActivity.kt
│       │   └── LockWidgetProvider.kt
│       ├── res/layout/lock_widget.xml
│       ├── res/xml/lock_widget_info.xml
│       └── res/...
├── media/                     brand mark, full icon set, social preview
├── docs/                      BRAND.md, VS-CADENCE.md
└── README.md
```

## How to run

```bash
# 1. Install dependencies
flutter pub get

# 2. iOS
cd ios && pod install && cd ..
flutter run -d <ios-device>

# 3. Android
flutter run -d <android-device>
```

**iOS widget**: After `flutter build ios`, open `ios/Runner.xcworkspace` in Xcode, add the `RunnerWidget` target as a Widget Extension (File → New → Target → Widget Extension), set the bundle ID prefix to match the app group, and build.

**Android widget**: Already wired. The `LockWidgetProvider` is declared in `AndroidManifest.xml`, the layout is in `res/layout/lock_widget.xml`, and the metadata is in `res/xml/lock_widget_info.xml`. Just build and add the widget from the home screen.

## The mark

![prayer lock app icon](media/icons/app-icon-1024.png)

A white padlock with a small Christian cross carved into the body, on warm orange (`#FF8B27`). Matches the reference design. The orange is the brand; the cross is the audience. See [`media/`](media/) for the full asset set.

## Why this exists

This is the **PBL counterpart** to `mx.pclub.cadence`. Where Cadence ships:

- No streak counter
- No mood check-in as engagement
- No public scoreboard
- No mandatory subscription
- No gamification

This app ships:

- A 70-day flame streak
- A "how's your relationship with God" daily check-in
- A weekly progress row with day numbers
- A home screen widget that shows the streak to the world
- A "best 12 days" badge for shame-free reset

**The same daily practice, framed two different ways.** Cadence is the *longer* bet — does engagement work without PBL? This app is the *shorter* bet — does PBL drive the metrics that matter to the business?

If you ship both, you A/B-test the philosophy in the market. If you ship one, you bet on the philosophy. Read `docs/VS-CADENCE.md` for the full side-by-side.

## License

Documentation: MIT. See `LICENSE`.
Product code: closed-source, all rights reserved.

---

🔗 **https://github.com/albertlaudia/mx.pclub.lock**
