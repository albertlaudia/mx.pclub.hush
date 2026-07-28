# Product Value Analysis — `hush.`

> The honest, ultra-deep analysis of what makes hush. valuable, what's missing, and the task list to fix it.

**This is the most important document in the repo.** It answers the question that determines whether the product ships or doesn't: *why would anyone use this?*

---

## 1. Direct answer: does hush. lock the phone?

**No.** hush. is a voluntary, invite-only daily practice app. It does *none* of the following:

| What the original Prayer Lock did | Does hush. do it? |
|---|---|
| Lock the phone until you prayed | No |
| Show on the lock screen | No |
| Block other apps while you prayed | No |
| Send a daily notification | No (planned for v0.2) |
| Force the user to engage | No |
| Show a streak counter | No (by brand decision) |
| Show a flame or score | No (by brand decision) |
| Track mood before / after | No (by brand decision) |

**This is by design.** The brand philosophy in `docs/PHILOSOPHY.md` explicitly rejected all of these as forms of "coercion" that contradict "invitation, not command."

The question you're asking — *what makes this valuable?* — is the right question. The answer is complicated. Read on.

---

## 2. The fundamental tension

The brand philosophy says: **the moment is the product.** The verse, the breath, the "see you tomorrow." The user enters the hush. The user leaves the hush. The product is the room.

The product question says: **but how do users find the moment?** Without a hook, the moment doesn't exist. The user has to remember to open the app. The user has to choose. The hush invites, but the user has to walk in.

This is the tension at the heart of hush.:

> **The philosophy says don't force. The product needs a hook.**

The honest answer is: the philosophy has merit but the product is incomplete. The original Prayer Lock was successful *because* it forced engagement. hush. is a brand book, not a hook. The brand is beautiful. The hook is missing.

This document doesn't pretend the philosophy exempts us from this question. It addresses it head-on.

---

## 3. What made the original Prayer Lock valuable

For context, the original `Prayer Lock` (Covenant Studios, 2017) was reportedly doing $25K/month at its peak. Here's what made it work:

| Mechanism | How it worked | Why it was powerful |
|---|---|---|
| **Lock screen integration** | The prayer screen appeared when you woke the phone | Always present. The user saw it 50+ times a day. |
| **Forced engagement** | You couldn't dismiss the screen without praying | High commitment. The user did the practice. |
| **Daily verse** | A new verse every day | Content. The user came back to see what's there. |
| **Timer** | A timer counted the duration of the prayer | Feedback. The user knew they had spent 5 minutes. |
| **Streak counter** | "Day 47!" | FOMO + public commitment. The user didn't want to break the chain. |
| **Mood check-in** | "How are you feeling?" before the prayer | Self-tracking. The user saw patterns. |
| **Daily notification** | A reminder to pray at the chosen time | Trigger. The user didn't have to remember. |
| **App blocking** | Other apps were inaccessible until you prayed | Hard enforcement. The user couldn't escape. |
| **Multiple prayer types** | Different "tracks" (gratitude, confession, etc.) | Variety. The user could choose what fit. |
| **Sharing** | "Share my streak" buttons | Social proof. Other users saw the brand. |
| **Apple Watch** | Wrist presence | Convenience. The user could pray from the watch. |

**The pattern:** every one of these is a *hook*. The user is dragged into the practice by the product, the OS, the social context, or their own past behavior.

---

## 4. What hush. has today (the honest inventory)

| What hush. has | Is it a hook? |
|---|---|
| Brand identity (deep teal, cream, amber, DM Serif Display) | No — brand is recognition, not retention |
| App icon (the wordmark) | Weak — icon gets buried in the home screen |
| 3 screens (onboarding, home, practice) | No — these are the *room*, not the door |
| A curated verse (12 verses, rotated by date) | Yes, but only if the user opens the app |
| The practice moment (verse + continue) | Yes, but only if the user opens the app |
| The "see you tomorrow" closing | No — it closes the moment, doesn't open the next |
| The "what is this?" affordance | No — it's an explanation, not an invitation |
| The settings page | No — settings is a maintenance page |

**The pattern:** hush. has *moments* but not *hooks*. The user has to remember to open the app. The product doesn't help.

---

## 5. What's missing — the full list

Below is the exhaustive list of features that would make hush. valuable. Each item has:
- **Priority** (P0 = core value, P1 = engagement, P2 = depth, P3 = future)
- **Effort** (S = <4h, M = 1-3 days, L = 1-2 weeks, XL = 2+ weeks)
- **Brand fit** (🟢 on-brand, 🟡 needs care, 🔴 brand-violating)
- **Description** of what it is
- **Design notes** for how to do it without breaking the philosophy

### 5.1 P0 — Core value mechanisms (without these, the product is not valuable)

#### 🔔 Daily notification (opt-in)

- **Priority:** P0
- **Effort:** M (1-3 days for iOS + Android)
- **Brand fit:** 🟢 On-brand (if done right)
- **What it is:** A daily notification at the user's chosen window ("morning", "midday", "evening", or "anytime"). Tapping it deep-links to the practice.
- **Why it matters:** This is the *single most important missing feature*. Without it, the user has to remember to open the app. A notification is the door to the room.
- **Design notes:**
  - Default OFF. The user must opt in.
  - Copy: "today's movement is ready." or "the hush is ready." — never "you missed 3 days!" or "your streak is gone!".
  - Time: at the user's chosen window. If "morning", between 6-9am. If "anytime", let the user pick.
  - iOS: `UNUserNotificationCenter` via `flutter_localizations` or `flutter_local_notifications`.
  - Android: `NotificationChannel` + `POST_NOTIFICATIONS` permission (Android 13+).
- **Task:** Implement, test on both platforms, document opt-in flow.

#### 🏠 Home screen widget

- **Priority:** P0
- **Effort:** L (1-2 weeks for iOS + Android, native code required)
- **Brand fit:** 🟢 On-brand
- **What it is:** A small home screen widget showing the secondary mark (dot-in-ring). Tapping it opens the app to the home screen. Optional: shows a tiny "today is done" / "today's practice" state.
- **Why it matters:** The home screen is where the user spends 80% of their phone time. The widget is a passive reminder.
- **Design notes:**
  - Small (2x2) and medium (4x2) sizes.
  - Default state: the secondary mark, centered. No text.
  - Practiced state: the secondary mark + a thin ring around it (in teal).
  - No count, no flame, no streak, no score.
  - iOS: WidgetKit (Swift).
  - Android: AppWidgetProvider (Kotlin).
- **Task:** Implement, test, document.

#### 📱 Lock screen / Always-on Display

- **Priority:** P0
- **Effort:** XL (2-3 weeks, native code, App Store review risk)
- **Brand fit:** 🟡 Needs care
- **What it is:** A lock screen widget or wallpaper that shows the day's verse. Tapping it deep-links to the practice.
- **Why it matters:** This is the *original Prayer Lock* mechanism. The user sees the verse 50+ times a day. The verse becomes ambient.
- **Design notes:**
  - iOS: Lock screen widget (iOS 16+). The widget would show the reference + first 6 words of the verse (same preview as the home screen).
  - Android: Daydreams / Live Wallpaper / Lock screen widget.
  - Brand constraint: NOT a wallpaper that forces engagement. A *visible* verse, but the user can dismiss.
  - The widget does NOT block the user from using the phone. It's ambient, not coercive.
- **Risk:** Apple may reject lock screen widgets that show religious content. The widget should be opt-in.
- **Task:** Research, prototype, ship if approved.

#### ⌚ Apple Watch / Wear OS

- **Priority:** P0
- **Effort:** XL (2-4 weeks for both platforms)
- **Brand fit:** 🟢 On-brand
- **What it is:** A watch app that shows the day's verse. A tap on the watch opens the practice (or marks it as done).
- **Why it matters:** The user often checks their watch before their phone. The watch is a faster hook.
- **Design notes:**
  - Complications: the secondary mark + a tiny state indicator.
  - App: the verse + a "continue" button.
  - Haptic on continue.
- **Task:** Research, prototype, ship for at least one platform.

### 5.2 P1 — Engagement depth (with these, the product retains)

#### 🔊 Audio narration

- **Priority:** P1
- **Effort:** M (1-3 days for 12 verses)
- **Brand fit:** 🟢 On-brand
- **What it is:** A button on the practice screen that reads the verse aloud. Uses a calm, contemplative voice (think audiobook reader, not radio DJ).
- **Why it matters:** Some users want to listen, not read. Audio also enables eyes-closed, hands-free practice — closer to a meditation.
- **Design notes:**
  - Voice: a calm, neutral voice. The user can pick from 2-3 options.
  - Speed: 0.85x default (slower than normal).
  - The audio plays in the background. The screen can be off.
- **Task:** Source 12 audio recordings (use ElevenLabs, Google Cloud TTS, or hire a narrator), embed in the app.

#### ✍️ Reflection input (encrypted)

- **Priority:** P1
- **Effort:** L (1-2 weeks for encrypted storage + UI)
- **Brand fit:** 🟢 On-brand
- **What it is:** A text field on the practice screen. After reading the verse, the user can write a few lines. The reflection is stored encrypted on the device.
- **Why it matters:** Reading is passive. Reflection is active. The product becomes a *journal*, not a *reader*. The reflection is between the user and the verse.
- **Design notes:**
  - Storage: `flutter_secure_storage` (uses iOS Keychain + Android Keystore).
  - Format: short text (max 280 chars? a paragraph?).
  - View: the home screen could show "your last reflection was 3 days ago" — without specifics.
  - History: a "recent reflections" view in settings.
  - Export: optional, to a file the user can save.
- **Task:** Design, implement, ship.

#### 🧘 Practice types (not just a verse)

- **Priority:** P1
- **Effort:** L (1-2 weeks for 3-5 practice types)
- **Brand fit:** 🟢 On-brand
- **What it is:** Different practices the user can choose from:
  - **Verse** (the current default): read a verse, attend to it.
  - **Breath**: 5 cycles of inhale/hold/exhale. Animated.
  - **Body scan**: a 60-second guided scan from head to feet.
  - **Mantra**: a single word repeated (e.g., "hush", "be still", "let go"). The user picks.
  - **Gratitude**: 3 lines. What are you grateful for today?
- **Why it matters:** Some days a verse is the right practice. Some days a breath. Some days a gratitude list. Variety = retention.
- **Design notes:**
  - The home screen shows the day's "default" practice (verse). The user can switch.
  - Each practice has its own screen, its own moment.
  - "Continue" works for all of them.
- **Task:** Design, implement, ship.

#### 🕐 Time-aware home states

- **Priority:** P1
- **Effort:** M (1-3 days)
- **Brand fit:** 🟢 On-brand
- **What it is:** The home screen changes its content based on the time of day relative to the user's chosen window:
  - **Before window**: "practice arrives at 8pm" + a soft dot.
  - **During window**: "today's practice" + the verse preview (current).
  - **After window, not practiced**: "today's practice is open" + a quiet nudge.
  - **Practiced**: "today is done" + "see you tomorrow." (current).
- **Why it matters:** The user feels the rhythm. The window is real.
- **Design notes:**
  - The "before window" state should not push. The user knows.
  - The "after window, not practiced" state is the trickiest. Brand says no guilt. A quiet line like "the window is open" — gentle, not shaming.
- **Task:** Design, implement.

#### 📅 Verse collections

- **Priority:** P1
- **Effort:** L (1-2 weeks for 3-4 collections)
- **Brand fit:** 🟢 On-brand
- **What it is:** Curated verse sets for different seasons / moods:
  - **Daily**: the current 12-verse rotation.
  - **Calm**: verses about stillness (Psalm 46:10, Psalm 23, etc.).
  - **Courage**: verses about fear / strength.
  - **Gratitude**: verses about thanks.
  - **Lent / Advent / Ramadan / secular seasons**: optional, opt-in.
- **Why it matters:** The user can pick a collection that fits their moment. The verse is no longer random — it's chosen.
- **Design notes:**
  - The user subscribes to a collection. The home screen shows the next verse from the collection.
  - The user can have one active collection at a time.
  - Collections can be offline (downloaded with the app).
- **Task:** Design, implement, ship.

### 5.3 P2 — Multi-faith (the product becomes universal)

- **Priority:** P2
- **Effort:** XL per tradition
- **Brand fit:** 🟢 On-brand
- **What it is:** Content beyond Christian scripture:
  - **Buddhist**: passages from the Dhammapada, the Heart Sutra, etc.
  - **Jewish**: passages from the Psalms, the Talmud, etc.
  - **Muslim**: verses from the Quran (with translation), the 99 names, etc.
  - **Secular**: passages from Marcus Aurelius, Rilke, the Tao Te Ching, etc.
- **Why it matters:** The product's tag line is "a daily practice, quietly." Practice is universal. The verses should be too.
- **Design notes:**
  - The user picks a "tradition" in settings. Default: the current Christian-leaning set.
  - Each tradition has 12-30 verses, curated.
  - The brand mark is the same. The color palette is the same. Only the content changes.
- **Task:** Source content (with permission), implement, ship.

### 5.4 P3 — Future (the product becomes more than a single user)

- **E2E Section** (encrypted, capped at 7): XL, Cadence-style.
- **Custom cadence** (user-defined rhythm): M.
- **Verse of the day for special dates**: M.
- **Family / household sharing**: XL.
- **Premium tier** (with a real product difference, not paywall-to-unlock): XL.

---

## 6. The path forward — three options

### Option A: Stay purely voluntary (current path)

- **What it looks like:** The product ships as is. No notification, no widget, no lock screen. The user has to remember to open the app.
- **Pros:**
  - Philosophically pure. The brand is intact.
  - No App Store review risk.
  - Low complexity.
- **Cons:**
  - Low retention. The user opens the app 3 times and forgets.
  - No organic growth. The user has no reason to tell a friend.
  - The product is a brand book, not a hook.
- **Best for:** A small, dedicated audience. A meditation retreat center. A book publisher. A niche community.
- **Verdict:** *Don't ship this.* It's a beautiful artifact, not a product.

### Option B: Add a "deeper practice" mode (recommended)

- **What it looks like:** hush. ships with a gentle default (current state) plus an opt-in "deeper practice" mode. The deeper mode adds:
  - Daily notification (opt-in)
  - Home screen widget (opt-in)
  - Lock screen / always-on display (opt-in, opt-out anytime)
- **Pros:**
  - The brand stays voluntary by default. The user chooses to go deeper.
  - The hook exists for users who want it.
  - App Store review is friendlier (opt-in is less coercive).
  - The product can grow with the user.
- **Cons:**
  - More complexity. Two modes.
  - Need to design the "deeper" mode carefully so it doesn't feel coercive.
- **Best for:** Most users. The product can serve both the casual and the committed.
- **Verdict:** *Recommended.* This is the path I'd take.

### Option C: Full lock mode (don't do this)

- **What it looks like:** hush. ships as a full phone-locking app. The user can't dismiss the practice. The streak counter is on the home screen. The notification is daily and aggressive.
- **Pros:**
  - Aggressive hook. High retention. Proven model (the original Prayer Lock).
- **Cons:**
  - Brand-violating. The philosophy says no.
  - App Store review risk. Apple has rejected similar apps.
  - User backlash. "I can't use my phone until I do this?" is exactly the wrong feeling.
- **Best for:** A different product. Don't ship as hush.
- **Verdict:** *Don't.* This is a different product. If you want it, build it as a separate app.

---

## 7. The recommended task list (Option B)

| # | Task | Priority | Effort | Brand fit | Status |
|---|---|---|---|---|---|
| 1 | **Daily notification (opt-in)** | P0 | M | 🟢 | Not started. v0.2 in the CHANGELOG. |
| 2 | **Home screen widget (opt-in)** | P0 | L | 🟢 | Not started. |
| 3 | **Lock screen widget (opt-in, opt-out anytime)** | P0 | XL | 🟡 | Not started. |
| 4 | **Apple Watch app** | P0 | XL | 🟢 | Not started. |
| 5 | **Audio narration (12 verses)** | P1 | M | 🟢 | Not started. |
| 6 | **Reflection input (encrypted)** | P1 | L | 🟢 | Not started. |
| 7 | **Practice types (3-5: verse, breath, body scan, mantra, gratitude)** | P1 | L | 🟢 | Not started. |
| 8 | **Time-aware home states** | P1 | M | 🟢 | Not started. |
| 9 | **Verse collections (3-4: daily, calm, courage, gratitude)** | P1 | L | 🟢 | Not started. |
| 10 | **Multi-faith content (Buddhist, Jewish, Muslim, secular)** | P2 | XL each | 🟢 | Not started. |
| 11 | **A "deeper practice" mode toggle in settings** | P0 | M | 🟢 | Not started. |
| 12 | **Brand-aligned copy for every new feature** | P0 | M | 🟢 | Not started. |
| 13 | **Integration tests for each new feature** | P0 | M | n/a | Not started. |

---

## 8. The bottom line

hush. is a beautiful brand. It is not yet a valuable product. The brand is necessary but not sufficient. The product needs a hook — a way for the user to find the moment without remembering to look for it.

**The single highest-leverage addition is the daily notification.** It's the smallest, fastest, cheapest hook. It does the least violence to the brand (opt-in, gentle copy). It can ship in 1-3 days. It's the obvious next move.

After the notification: home screen widget. After the widget: lock screen (with care). After lock screen: watch app. After watch app: practice types. After practice types: audio. After audio: reflection. After reflection: collections. After collections: multi-faith.

Each step adds a hook, deepens the practice, expands the audience. None of them require abandoning the brand.

**The brand says: the moment is the product. The product needs to make the moment findable.**

---

*This document is the most honest thing in the repo. It admits the gap, names the path, and refuses to pretend the philosophy is a substitute for product value. The philosophy is the foundation. The product is the house. We're building the house next.*
