# Production Readiness — `lock.`

> The complete list of every touchpoint before App Store / Play Store submission, with current status, priority, and effort estimate.

**Repo state at analysis time:** v0.1.1, 1,420 lines of Dart, 14 tests passing, CI green, brand locked.

**TL;DR — the critical path is ~5 working days of focused work, plus ~2 weeks of waiting on store review.** Everything else is "should have" for v1.0 and "nice to have" for v1.1+.

---

## How to read this

Each item has:
- **Status:** ✅ done · 🟡 partial · ❌ not started
- **Priority:** P0 = block launch · P1 = should launch with · P2 = v1.1
- **Owner:** who does it (you, your designer, the store review)
- **Effort:** S = <1h · M = 1-4h · L = 1-3d · XL = 3+d

The numbers are estimates for an experienced Flutter dev. They assume you have the Apple Developer account ($99/yr) and Google Play Console account ($25 one-time) already set up.

---

## 1. Code Quality & Correctness

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 1.1 | Dart code compiles clean (`flutter analyze` 0 issues) | ✅ done | P0 | — |
| 1.2 | Type safety with `strict-casts`, `strict-inference` | ✅ done | P0 | — |
| 1.3 | No race conditions, no dangling timers | ✅ done (QA pass) | P0 | — |
| 1.4 | Idempotent `markPracticed()` | ✅ done | P0 | — |
| 1.5 | Error handling on all async paths | ✅ done | P0 | — |
| 1.6 | Asset load fallback | ✅ done | P0 | — |
| 1.7 | **Remove `INTERNET` permission from AndroidManifest** | ❌ not started | P0 | S |
| | *Why:* we don't make network calls. The default Flutter template includes it, but the release build doesn't need it. Removing it also reduces user concern ("why does a prayer app need internet?"). Add it back if/when you wire analytics. | | | |
| 1.8 | **Pin Flutter SDK version in pubspec.yaml** | ❌ not started | P0 | S |
| | `environment: sdk: ^3.5.0` should be tightened to match what CI uses (`3.27.0`). | | | |
| 1.9 | **Add `flutter:` version constraint** | ❌ not started | P0 | S |
| | Add `flutter: ">=3.27.0"` to `environment` to prevent accidental old-Flutter builds. | | | |
| 1.10 | **Verify iOS deployment target ≥ 14.0** | ❌ not started | P0 | S |
| | Flutter 3.27 requires iOS 14+. The hand-crafted `project.pbxproj` has 13.0. Fix in `IPHONEOS_DEPLOYMENT_TARGET`. | | | |
| 1.11 | **Remove stale .gitignore entries** | ❌ not started | P1 | S |
| | The Cadence-era .gitignore references things that don't apply. Audit and clean. | | | |
| 1.12 | **iOS project.pbxproj — full Xcode verify** | ❌ not started | P1 | M |
| | The pbxproj is hand-crafted. Open in Xcode once, fix any issues, then `File → Save`. This produces a clean pbxproj we can check back in. | | | |
| 1.13 | **Android adaptive icon** | ❌ not started | P1 | M |
| | Android 8+ supports adaptive icons (foreground + background layers). The current `ic_launcher.png` is just one PNG. Add `mipmap-anydpi-v26/ic_launcher.xml` and `drawable/ic_launcher_foreground.xml`. | | | |
| 1.14 | **Splash screen — Android** | ❌ not started | P2 | M |
| | Add `drawable/launch_background.xml` with the deep teal color and a centered wordmark. Currently the launch screen is a default Flutter color. | | | |
| 1.15 | **iOS launch screen — already done** | ✅ done | P0 | — |
| | The hand-crafted `LaunchScreen.storyboard` has the deep teal background. | | | |

---

## 2. Testing

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 2.1 | Unit tests for `StreakMath` | ✅ done (7 tests) | P0 | — |
| 2.2 | Unit tests for `PracticeStateStore` | ✅ done (5 tests) | P0 | — |
| 2.3 | Widget tests for all 4 screens | ✅ done (7 tests) | P0 | — |
| 2.4 | **Integration test — full user flow** | ❌ not started | P0 | M |
| | Onboarding → home → practice → done → practiced state. The current widget tests are isolated. An integration test verifies the *flow* works. Use `integration_test` package. | | | |
| 2.5 | **Golden tests for the brand mark** | ❌ not started | P0 | S |
| | The wordmark and dot-in-ring painters should produce pixel-identical output. A golden test catches font changes (e.g., DM Serif Display getting a new version). | | | |
| 2.6 | **Golden tests for screens (light + dark)** | ❌ not started | P1 | M |
| | Onboarding, home (active + practiced), practice, settings — goldens for both light and dark. Catches accidental visual regressions. | | | |
| 2.7 | **Locale rendering tests** | ❌ not started | P1 | M |
| | For each supported locale, render every screen and assert no overflow. Critical for EN + ES at launch. | | | |
| 2.8 | **A11y tests** | ❌ not started | P1 | M |
| | Use `Semantics` finders to assert every interactive element has a label. | | | |
| 2.9 | **Performance baseline** | ❌ not started | P2 | M |
| | First-frame paint time, scroll FPS, memory footprint. Capture a baseline in CI. | | | |
| 2.10 | **Crash test: force-throw in save path** | ❌ not started | P1 | S |
| | The snackbar-on-failure path is only triggered if `markPracticed` throws. Add a test that mocks the store to throw, taps done, asserts the snackbar. | | | |

---

## 3. CI/CD

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 3.1 | `flutter analyze` on every push/PR | ✅ done | P0 | — |
| 3.2 | `flutter test --coverage` on every push/PR | ✅ done | P0 | — |
| 3.3 | Android debug build on every push/PR | ✅ done | P0 | — |
| 3.4 | **iOS build on every push/PR** | ❌ not started | P0 | M |
| | Add a `build-ios` job. Requires a macOS runner (GitHub-hosted: `macos-latest`, ~10 min build). Add the iOS build step. | | | |
| 3.5 | **Code coverage report to Codecov/Coveralls** | ❌ not started | P1 | S |
| | The CI already produces `coverage/lcov.info`. Upload to a service. Codecov is free for OSS. | | | |
| 3.6 | **Dependency vulnerability check** | ❌ not started | P1 | S |
| | `dart pub outdated` and `dart pub deps` in CI. Fail on outdated major versions. | | | |
| 3.7 | **PR title linting (Conventional Commits)** | ❌ not started | P2 | S |
| | Conventional Commits: `feat:`, `fix:`, `chore:`, etc. Use a GitHub Action to enforce. | | | |
| 3.8 | **Auto-generate CHANGELOG.md from commits** | ❌ not started | P2 | M |
| | Use a tool like `standard-version` or a custom GitHub Action. The current CHANGELOG is hand-written. | | | |
| 3.9 | **Release workflow** | ❌ not started | P1 | L |
| | On tag push, build signed iOS + Android, upload to TestFlight + Play Console internal track. | | | |

---

## 4. Accessibility (a11y)

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 4.1 | Touch targets ≥ 48dp | 🟡 partial | P0 | S |
| | The window option cards and "begin" button are 48dp+ already. The IconButton close is 48dp. Verify. | | | |
| 4.2 | Text contrast WCAG 2.1 AA | 🟡 partial | P0 | S |
| | Ink (#1A1A1A) on cream (#F5F0E6): contrast ratio ≈ 14.5:1. ✅ Teal on cream: ≈ 9.5:1. ✅ Amber on cream: ≈ 3.6:1. ⚠️ This is below AA 4.5:1 for normal text — the amber dot and "amber" labels may need darker amber or use the inkSoft instead. | | | |
| 4.3 | Semantic labels on icons | ❌ not started | P0 | S |
| | The IconButton close has `tooltip: 'close'`. The BrandMark wordmark and dot-in-ring need `Semantics(label: 'lock', excludeSemantics: true)` or similar. | | | |
| 4.4 | Semantic labels on the verse | ❌ not started | P0 | S |
| | The verse should be readable by screen readers. Wrap in `Semantics(label: 'verse', child: ...)`. | | | |
| 4.5 | Dynamic Type / font scaling | ❌ not started | P1 | M |
| | iOS Dynamic Type: use `MediaQuery.textScaler` to respect user font size. Android `sp` units. Test at 200% scaling — nothing should overflow. | | | |
| 4.6 | Reduce motion | ❌ not started | P2 | S |
| | The 180ms animation on the window option is subtle but should respect the OS reduce-motion preference. | | | |
| 4.7 | Focus order | ❌ not started | P1 | S |
| | Verify tab order on settings. The 3 sections should be navigable in a logical order. | | | |
| 4.8 | High-contrast mode (iOS) | ❌ not started | P2 | M |
| | The dark theme should be high-contrast-friendly. Apple's "Increase Contrast" setting. | | | |

---

## 5. Localization (i18n)

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 5.1 | `flutter_localizations` in pubspec | ✅ done | P0 | — |
| 5.2 | Localizations delegates wired in `MaterialApp` | ✅ done | P0 | — |
| 5.3 | `intl` in pubspec | ✅ done | P0 | — |
| 5.4 | **ARB workflow setup** | ❌ not started | P0 | M |
| | Add `l10n.yaml`, generate `app_en.arb`, set up `flutter:` `generate: true` in pubspec. Then convert every hardcoded string to `AppLocalizations.of(context).key`. | | | |
| 5.5 | **ES locale (Spanish) at launch** | ❌ not started | P0 | L |
| | The Cadence plan calls for EN + ES day-one. Spanish verse translations need a translator. The UI is a smaller lift. | | | |
| 5.6 | **Verse translations** | ❌ not started | P0 | L |
| | The 12 ESV verses need ES translations (Reina-Valera 1960, public domain). Each verse = 2 fields: ref + text. | | | |
| 5.7 | **Day-30 locales (PT, FR, ZH-Hans)** | ❌ not started | P1 | XL |
| | Same as ES but for 3 more locales. Translator + LLM + native review. | | | |
| 5.8 | **Day-90 locales (ZH-Hant, JA, KO, TL)** | ❌ not started | P2 | XL |
| 5.9 | **Locale picker in onboarding** | ❌ not started | P0 | M |
| | On first launch, if device locale is ambiguous (e.g., `zh`), show a 1-tap picker. The plan is in `docs/USER-WORKFLOW.md` of the prior plan but we deleted that doc — recreate the locale picker spec. | | | |
| 5.10 | **Locale change in settings** | ❌ not started | P1 | M |
| | User can change app locale at any time. Picker with all supported locales. | | | |

---

## 6. Privacy, Legal & Compliance

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 6.1 | **Privacy policy** | ❌ not started | P0 | M |
| | Host a privacy policy on a public URL (e.g., `lock.app/privacy`). Must cover: data collected (none), third parties (none), retention (local), user rights (delete via reset), contact. Apple/Google both require this. | | | |
| 6.2 | **Terms of service (EULA)** | ❌ not started | P1 | M |
| | Recommended. Hosts at `lock.app/terms`. | | | |
| 6.3 | **Support URL** | ❌ not started | P0 | S |
| | `lock.app/support` or a `mailto:hello@lock.app` link. | | | |
| 6.4 | **App Privacy details (iOS)** | ❌ not started | P0 | S |
| | In App Store Connect, declare: Data Not Collected. No tracking. No contact info. No health data. | | | |
| 6.5 | **Data safety form (Play Console)** | ❌ not started | P0 | S |
| | Same as iOS: no data collected, no data shared, no data sold. | | | |
| 6.6 | **Open source licenses screen** | ❌ not started | P1 | S |
| | Show the licenses for Flutter, Riverpod, google_fonts, intl, etc. The `package_info_plus` and `flutter_licenses` packages can auto-generate this. | | | |
| 6.7 | **Content rating questionnaire** | ❌ not started | P0 | S |
| | IARC for Play. Apple asks age questions in App Store Connect. Answer: 4+ (no objectionable content). | | | |
| 6.8 | **Export compliance (iOS)** | ✅ done | P0 | — |
| | `ITSAppUsesNonExemptEncryption=false` is set. Uses only HTTPS. | | | |
| 6.9 | **GDPR / CCPA compliance** | ✅ not applicable | P0 | — |
| | We collect no data. There is no GDPR-relevant processing. Document this in the privacy policy. | | | |
| 6.10 | **COPPA compliance (under-13)** | ❌ not started | P0 | S |
| | If you target under-13, additional rules apply. Default: target 13+. If so, App Store Connect asks for the under-13 option, and you must declare no targeted ads. | | | |
| 6.11 | **Bible translation licensing** | ❌ not started | P0 | M |
| | The current verses are ESV (copyrighted). For the launch, switch to public-domain (KJV, Reina-Valera 1960) OR license ESV from Crossway. Public-domain avoids the license cost and complexity. | | | |
| 6.12 | **App icon copyright** | ✅ done | P0 | — |
| | The icon is original (no copy of anyone else's mark). No copyright risk. | | | |

---

## 7. App Store Submission

### 7a. iOS App Store

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 7.1 | Apple Developer Program enrollment | ❌ not started (you) | P0 | — |
| | $99/yr. Required for App Store and TestFlight. | | | |
| 7.2 | App Store Connect app record | ❌ not started | P0 | S |
| | Bundle ID `mx.pclub.lock`, primary language English. | | | |
| 7.3 | App icon 1024×1024 (no alpha) | ✅ done | P0 | — |
| 7.4 | **Screenshots (6.7", 6.5", 5.5" iPhone)** | ❌ not started | P0 | L |
| | Need 4-6 screenshots per device class. Capture from a running build, or design in Figma. Sizes: 1290×2796, 1242×2688, 1242×2208. | | | |
| 7.5 | **App name** | ❌ not started | P0 | S |
| | "lock." (4 chars, fits). | | | |
| 7.6 | **Subtitle** | ❌ not started | P0 | S |
| | "a daily practice, quietly" (24 chars, fits in 30). | | | |
| 7.7 | **Promotional text** | ❌ not started | P0 | S |
| | 170 chars max. E.g., "one short practice, once a day. that's the whole product." | | | |
| 7.8 | **Description (4000 chars)** | ❌ not started | P0 | M |
| | Lead with the value prop. List the (small) feature set. Include the privacy story. End with a CTA. | | | |
| 7.9 | **Keywords (100 chars)** | ❌ not started | P0 | S |
| | Comma-separated. "prayer, daily, devotional, quiet, faith, practice, ritual, habit, reflection, journal" | | | |
| 7.10 | **Category** | ❌ not started | P0 | S |
| | Lifestyle (most natural) or Health & Fitness. | | | |
| 7.11 | **App Privacy nutrition labels** | ❌ not started | P0 | S |
| | See §6.4. | | | |
| 7.12 | **TestFlight beta** | ❌ not started | P0 | L |
| | Before public release, ship to 10-20 internal testers. Get feedback. Iterate. | | | |
| 7.13 | **App Review information** | ❌ not started | P0 | S |
| | Contact info, demo account (none needed — no auth), notes to reviewer. | | | |
| 7.14 | **Export compliance** | ✅ done | P0 | — |
| 7.15 | **Build archive in Xcode** | ❌ not started | P0 | M |
| | `flutter build ipa` + Xcode Organizer → Distribute App → App Store Connect. Requires a Mac. | | | |
| 7.16 | **Submission** | ❌ not started | P0 | S |
| | App Store Connect → My Apps → lock. → + Version → fill in the above → submit for review. | | | |
| 7.17 | **Review time** | — | — | — |
| | Apple review: 24-48h typically, longer for first submission. | | | |

### 7b. Google Play Store

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 7.18 | Google Play Console account | ❌ not started (you) | P0 | — |
| | $25 one-time. | | | |
| 7.19 | Play Console app creation | ❌ not started | P0 | S |
| | Package `mx.pclub.lock`, default category. | | | |
| 7.20 | App icon 512×512 | ✅ done | P0 | — |
| 7.21 | **Feature graphic 1024×500** | ❌ not started | P0 | M |
| | Required. The current `media/hero-1920x1080.png` is the wrong dimensions. Generate a 1024×500 version. | | | |
| 7.22 | **Phone screenshots (min 2, recommended 8)** | ❌ not started | P0 | L |
| | Min 320px, max 3840px. Recommended 1080×1920 or 1080×2400. Capture from a running build. | | | |
| 7.23 | **7" tablet screenshots (optional)** | ❌ not started | P2 | M |
| 7.24 | **10" tablet screenshots (optional)** | ❌ not started | P2 | M |
| 7.25 | **App name** | ❌ not started | P0 | S |
| | "lock." (50 char limit). | | | |
| 7.26 | **Short description (80 chars)** | ❌ not started | P0 | S |
| | "a daily practice, quietly. one verse. one moment. one tap." | | | |
| 7.27 | **Full description (4000 chars)** | ❌ not started | P0 | M |
| | Same content as iOS, but with Play's rich formatting (no bold/italic — plain text + `\n`). | | | |
| 7.28 | **App category** | ❌ not started | P0 | S |
| | Lifestyle. | | | |
| 7.29 | **Tags** | ❌ not started | P0 | S |
| | Up to 5 tags. | | | |
| 7.30 | **Contact details** | ❌ not started | P0 | S |
| | Email, website, phone (optional). | | | |
| 7.31 | **Privacy policy URL** | ❌ not started | P0 | S |
| | Same URL as iOS. | | | |
| 7.32 | **Data safety form** | ❌ not started | P0 | M |
| | "No data collected" in every category. | | | |
| 7.33 | **Content rating (IARC)** | ❌ not started | P0 | S |
| | 15-question questionnaire. Answers: no violence, no sexuality, no drugs, no gambling. Result: Everyone / PEGI 3. | | | |
| 7.34 | **App access** | ❌ not started | P0 | S |
| | "All functionality is available without special access." | | | |
| 7.35 | **Ads** | ❌ not started | P0 | S |
| | "No, my app does not contain ads." | | | |
| 7.36 | **COVID-19 contact tracing / health apps** | ❌ not started | P0 | S |
| | "No" to both. | | | |
| 7.37 | **App signing** | ❌ not started | P0 | S |
| | Generate an upload key. Enable Google Play App Signing (recommended — Google keeps the signing key for you). | | | |
| 7.38 | **AAB build** | ❌ not started | P0 | M |
| | `flutter build appbundle --release`. Upload the .aab to Play Console. | | | |
| 7.39 | **Release track** | ❌ not started | P0 | M |
| | Start with internal testing → closed testing → production. | | | |
| 7.40 | **Review time** | — | — | — |
| | Google review: hours to a few days, faster than Apple. | | | |

---

## 8. Onboarding & First-Run

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 8.1 | 1-screen onboarding with window picker | ✅ done | P0 | — |
| 8.2 | **Notification permission request — after onboarding** | ❌ not started | P1 | M |
| | After onboarding, ask for notification permission. Use a custom rationale screen first ("we'll send one quiet reminder a day") so the user understands. | | | |
| 8.3 | **Handle onboarding interrupted** | ❌ not started | P1 | S |
| | If the user kills the app mid-onboarding, on next launch they see onboarding again. ✅ already handled by the gate logic. | | | |
| 8.4 | **A welcome animation** | ❌ not started | P2 | M |
| | Subtle wordmark fade-in on first home screen visit. | | | |
| 8.5 | **Sample practice** | ❌ not started | P2 | M |
| | "Try a practice now" before completing onboarding. Reduces drop-off. | | | |
| 8.6 | **App preview video (iOS)** | ❌ not started | P2 | L |
| | 30s screen recording. Optional but boosts conversion. | | | |

---

## 9. Notifications (v0.2)

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 9.1 | `flutter_local_notifications` in pubspec | ❌ (we removed it) | P1 | S |
| 9.2 | Daily notification at user's chosen window | ❌ not started | P1 | M |
| 9.3 | Notification copy: "today's movement is ready." | ❌ not started | P1 | S |
| | Never "you missed 3 days!" or any shame copy. | | | |
| 9.4 | iOS notification entitlement + Info.plist | ❌ not started | P1 | S |
| 9.5 | Android notification channel + `POST_NOTIFICATIONS` | ❌ not started | P1 | S |
| 9.6 | **Settings: notification toggle + time picker** | ❌ not started | P1 | M |
| 9.7 | **Settings: quiet hours** | ❌ not started | P2 | M |
| | User can specify "no notifications between X and Y". | | | |

---

## 10. Settings (v0.2+)

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 10.1 | Practice window picker | ✅ done | P0 | — |
| 10.2 | Today status, total practices | ✅ done | P0 | — |
| 10.3 | Reset practice state | ✅ done | P0 | — |
| 10.4 | **Locale selector** | ❌ not started | P1 | M |
| 10.5 | **Theme override (light/dark/system)** | ❌ not started | P1 | S |
| 10.6 | **Notification toggle + time** | ❌ not started | P1 | M |
| 10.7 | **Reflection history (last 7 days, 30 days, all)** | ❌ not started | P2 | L |
| 10.8 | **Reflection export (PDF, JSON)** | ❌ not started | P2 | M |
| 10.9 | **Open source licenses screen** | ❌ not started | P1 | S |
| 10.10 | **Send feedback (mailto:)** | ❌ not started | P1 | S |
| 10.11 | **Rate the app (deep link to store)** | ❌ not started | P2 | S |
| 10.12 | **About / acknowledgments** | ❌ not started | P1 | S |
| 10.13 | **Share with a friend (system share)** | ❌ not started | P2 | S |
| 10.14 | **Data export (full JSON)** | ❌ not started | P2 | M |
| 10.15 | **Delete account (all data)** | ❌ not started | P1 | S |
| | Already implemented as "reset practice state" — just add a clearer label. | | | |

---

## 11. Data Persistence & Migration

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 11.1 | SharedPreferences for state | ✅ done | P0 | — |
| 11.2 | **Schema version key** | ❌ not started | P0 | S |
| | Add `lock.schemaVersion` so future migrations can run. | | | |
| 11.3 | **Migration logic** | ❌ not started | P1 | M |
| | When schema changes, run migrations in order. | | | |
| 11.4 | **Backup / restore** | ❌ not started | P2 | L |
| | Export all state to JSON, import from JSON via system share sheet. | | | |
| 11.5 | **Clear all data** | ✅ done (reset) | P0 | — |

---

## 12. Performance

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 12.1 | First-frame paint < 100ms | 🟡 likely ok | P1 | M |
| | Test on a 2-year-old mid-range Android (e.g., Pixel 5a). If slow, profile. | | | |
| 12.2 | Cold start < 2s | 🟡 likely ok | P1 | M |
| | Default Flutter app cold start is ~1s. Verify on low-end. | | | |
| 12.3 | Memory footprint < 100MB | 🟡 likely ok | P2 | M |
| | Default Flutter app is <60MB. | | | |
| 12.4 | **No debug code in release** | 🟡 needs verify | P0 | S |
| | `assert(kDebugMode)` checks should not leak. The `print()` in `prompts.dart` is wrapped in `kDebugMode`. ✅ | | | |
| 12.5 | **R8 / ProGuard for Android** | ❌ not started | P1 | S |
| | Add `minifyEnabled true` and `shrinkResources true` in `build.gradle.kts`. Test that the release build works. | | | |
| 12.6 | **Asset compression** | 🟡 not needed | P2 | M |
| | Our asset is a small JSON. The wordmark is rasterized. Both are small. | | | |

---

## 13. Security

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 13.1 | No third-party tracking | ✅ done | P0 | — |
| 13.2 | No cross-app blocking (no AccessibilityService) | ✅ done | P0 | — |
| 13.3 | No FamilyControls entitlement (iOS) | ✅ done | P0 | — |
| 13.4 | No `INTERNET` permission (Android, release) | ❌ not started | P0 | S |
| | See §1.7. | | | |
| 13.5 | `shared_preferences` is plaintext | 🟡 acceptable | P0 | — |
| | The data is not sensitive. If we ever add user-generated reflections, switch to `flutter_secure_storage`. | | | |
| 13.6 | No clipboard exfiltration | ✅ not applicable | P0 | — |
| | We don't read the clipboard. | | | |

---

## 14. Marketing

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 14.1 | Landing page (`lock.app`) | ❌ not started | P1 | L |
| | One-page: wordmark, tagline, "the practice" section, 3 screenshots, "get the app" CTA. | | | |
| 14.2 | Domain + DNS | ❌ not started | P1 | S |
| | Buy `lock.app`. | | | |
| 14.3 | Press kit | ❌ not started | P2 | M |
| | One-pager, brand assets zip, founder bio, contact. | | | |
| 14.4 | App Store screenshots — designed | ❌ not started | P0 | L |
| | See §7.4 and §7.22. | | | |
| 14.5 | Social media accounts | ❌ not started | P2 | M |
| | Twitter/X: `@lock_app`. Mastodon. | | | |
| 14.6 | Launch post | ❌ not started | P1 | M |
| | Personal blog, X, Product Hunt, Hacker News. | | | |

---

## 15. Analytics (Decision: No)

**Recommended: no analytics.**

The brand is a journal. Journals don't track their writers. The philosophy is "the user is a whole person, not an engagement metric." Adding analytics would compromise the brand.

If you need at least *some* signal for product decisions, the minimum is:

| # | Item | Status | Priority | Effort |
|---|---|---|---|---|
| 15.1 | First-party event log to local file | ❌ not started | P2 | M |
| | User opt-in. Counts app opens, completions, no PII. Stay on-device. | | | |
| 15.2 | On-device retention cohort | ❌ not started | P2 | M |
| | Compute D1/D7/D30 from the local log. Never leave the device. | | | |

No Crashlytics. No Sentry. No Mixpanel. No Firebase Analytics. No AppsFlyer. No Adjust. The brand says no.

---

## 16. Open Issues / Decisions

Things I made a call on that you might want to override:

| Decision | What I chose | Alternative |
|---|---|---|
| **No streak counter** | Removed entirely | Add a quiet "day count" (not streak, not PBL) |
| **No daily notification** | Removed in v0.1 | Add it back in v0.2 as a 1-tap opt-in |
| **No mood check-in** | Removed | Don't add it back. The product is the practice, not the feeling. |
| **No home widget** | Removed | Add in v0.2 with the dot-in-ring mark + day count |
| **No reflection input field** | The current practice screen has no reflection input | Add in v0.2 (encrypted, E2E-style) |
| **English only** | v0.1 is English | Add ES in v0.2, then PT/FR/ZH |
| **Closed-source product** | LICENSE is MIT for docs only | Open-source the product code under MIT if you want community contributions |
| **No analytics** | Local-only, zero tracking | Add first-party events if needed |
| **Inter (body) + DM Serif Display (display)** | Google Fonts | Self-host the fonts to avoid Google Fonts CDN dependency |
| **App name: `lock.`** | Lowercase, with period | "Lock" (capitalized) or "Lock." (capitalized) — both more conventional in stores |
| **Color: deep teal** | `#1F3D3A` | Adjust to e.g. `#1A3A37` if you want it slightly darker |

---

## 17. The Critical Path (the next 5 working days)

Day-by-day, what to ship before submission:

| Day | Tasks |
|---|---|
| **Day 1** | §1.7 remove INTERNET · §1.8-1.10 SDK pins · §1.13 adaptive icon · §5.4 ARB workflow + convert hardcoded strings · §6.1-6.3 privacy/TOS/support URLs |
| **Day 2** | §5.5 ES locale + verse translations (Reina-Valera 1960) · §5.9 locale picker · §6.11 Bible translation license decision · §1.12 iOS pbxproj verify in Xcode · §2.4-2.5 integration test + brand mark goldens |
| **Day 3** | §2.6 screen goldens (light + dark) · §2.7 locale goldens · §2.10 crash test · §4.1-4.4 a11y basics · §7.3-7.9 iOS App Store metadata (text only) |
| **Day 4** | §7.4 iOS screenshots · §7.21-7.28 Play metadata · §7.22 Play screenshots · §7.20 feature graphic · §14.1 landing page |
| **Day 5** | §3.4 iOS CI build · §7.15-7.16 iOS archive + submit · §7.38-7.39 Android AAB + upload to internal track · §12.5 R8 verify |

Then: **wait for Apple review (24-48h)** and **wait for Google review (hours to days)**.

After both pass: the app is in production.

---

## 18. Effort Summary

| Category | Items | Effort (rough) |
|---|---|---|
| Code quality | 5 | S |
| Testing | 7 | ~2 days |
| CI/CD | 6 | ~1 day |
| Accessibility | 8 | ~1 day |
| Localization | 10 | ~3 days for ES, ~3 weeks for full 8 |
| Privacy/Legal | 12 | ~1 day |
| App Store submission | 40 | ~2 days |
| Onboarding & first-run | 6 | ~1 day |
| Notifications (v0.2) | 7 | ~2 days |
| Settings (v0.2+) | 15 | ~3 days |
| Data persistence | 5 | ~1 day |
| Performance | 6 | ~1 day |
| Security | 6 | S |
| Marketing | 6 | ~3 days |
| Analytics | 2 | S (decision is "no") |
| **Total v1.0 launch** | — | **~3-4 weeks of focused work** |
| Plus 1-2 weeks store review | | |

---

## 19. Risk Register

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Apple rejects for missing privacy policy | High | High | Host before submitting. |
| Apple rejects for missing screenshot dimensions | Med | High | Use the right device-class sizes. |
| Apple rejects for app name with punctuation | Low | Med | The period in `lock.` may be flagged. Have a fallback name ready. |
| Google rejects for missing data safety form | High | High | Complete it before submitting. |
| Bible verse licensing issue (ESV) | Med | High | Use public-domain KJV / Reina-Valera 1960 at launch. |
| First-frame paint is slow on low-end Android | Med | Med | Profile. R8 / ProGuard. Smaller images. |
| Localization breaks at 200% font scale | Med | Med | Test at 200% in CI. Add `MediaQuery.textScaler` clamping if needed. |
| User uninstalls because "no streak, no progress" | Med | Med | Be honest in onboarding copy. The product is the practice, not the score. |
| Marketing copy uses "extraordinary!" or "amazing!" | Low | High | BRAND.md says no superlatives. Use lowercase, no exclamation. |
| iOS pbxproj has hand-crafted bugs | Med | High | Open in Xcode, fix any issues, save. |

---

## 20. What I would NOT do

- **Do not add a streak counter.** The product is the practice, not the score.
- **Do not add a "share my streak" feature.** The brand is private.
- **Do not add a leaderboard.** Solo is the default.
- **Do not add ads.** Ever. The brand says no.
- **Do not add a "Restore your streak for $4.99" paywall.** The product is free.
- **Do not use a cross icon or a padlock icon.** We've explicitly rejected these.
- **Do not use orange.** Ever. The brand is teal.
- **Do not add crash reporting that phones home.** Privacy is structural.

---

## Final word

The code is solid. The brand is locked. The CI is green. The next 5 working days are about **legal text, store metadata, screenshots, and one localized locale**. After that, you're in the App Store and Play Store.

The hard part isn't the code. The hard part is the privacy policy, the screenshots, and waiting for review.

🔗 **https://github.com/albertlaudia/mx.pclub.lock**

— end of analysis —
