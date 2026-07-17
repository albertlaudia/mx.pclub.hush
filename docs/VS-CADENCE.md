# vs. `mx.pclub.cadence`

> The two products. The two philosophies. The same daily practice.

`mx.pclub.cadence` and `mx.pclub.lock` are siblings. They share a daily-practice problem, a faith audience, a Flutter codebase, and a `mx.pclub.*` repo prefix. They differ in **philosophy**: one is the PBL (points/badges/leaderboards) version, the other is the no-PBL version.

If you ship both, you A/B-test the philosophy in the market. If you ship one, you bet on the philosophy.

## At a glance

| | **mx.pclub.lock** (this repo) | **mx.pclub.cadence** |
|---|---|---|
| **Wedge** | "block your phone until you pray" | "a daily practice that keeps" |
| **Engagement** | Day streak, flame, weekly progress, mood check-in | Section (E2E encrypted small circle), chapter mark, composition |
| **Visibility** | Public — streak on home screen widget | Private — Section is opt-in, capped at 7, end-to-end encrypted |
| **Gamification** | Yes — PBL mechanics throughout | No — explicitly anti-PBL by design |
| **Tone** | Warm, encouraging, streak-positive | Quiet, contemplative, no-shame |
| **Privacy** | Local-only, no backend | Local + Firestore, Section E2E encrypted |
| **Subscription** | Free | Free tier + paid (true upgrade, not paywall) |
| **Stack** | Flutter 3.27, Riverpod, home_widget | Flutter 3.27, Riverpod, go_router, Firebase, E2E |
| **iOS app blocking** | Simulated (full-screen prayer view) | None — doesn't need it |
| **Android app blocking** | Simulated | None — doesn't need it |
| **Locale support** | English only | 8 locales day-one-to-day-90 |
| **Audience** | Christian (multi-denominational) | Christian, interfaith, secular practitioners |

## Same problem, different frame

**Both apps answer the same question:** *how do we help a person keep a daily faith practice in a phone-full world?*

**The lock app answers:** by making the streak the score. The day counter is the metric. The widget broadcasts it to the world. The mood check-in quantifies the relationship.

**The cadence app answers:** by making the practice the score. The chapter is the metric. The Section witnesses it quietly. The composition is the long arc.

Neither is "right". They are two bets on the same product problem, framed differently.

## Why have both?

**Three reasons:**

1. **A/B-test the philosophy.** If you ship both, you can measure which one retains better, which one converts to paid better, which one generates more word-of-mouth. The data answers the philosophy question.

2. **Different audiences.** Some users *want* the streak. They want the gamification. They want the public widget. They want the "extraordinary! your prayer journey is an inspiration" line. The lock app is for them. Other users want quiet. They want E2E encryption. They want no-shame. The cadence app is for them.

3. **Strategic optionality.** Two repos = two potential exits. Hallow might buy the lock app. A different publisher might buy the cadence app. Two repos = two acquisition targets. One repo with two philosophies = one product that confuses everyone.

## What you can't learn from either alone

- **Lock alone:** you don't know if the streak actually drives retention, or if it's the practice underneath. The streak is correlated with the practice but you can't disentangle them.
- **Cadence alone:** you don't know if the no-streak framing *retains as well as* the streak framing. Maybe the streak genuinely helps. Maybe it doesn't. You don't know.

**Both together:** you can measure the same practice, framed two ways, in two cohorts. The lock app measures what the PBL version does. The cadence app measures what the no-PBL version does. The difference is the design effect.

## What they share

- Same Flutter + Riverpod base
- Same `mx.pclub.*` repo convention
- Same `shared_preferences` local-store pattern
- Same `home_widget` package for the streak / chapter widget
- Same notification scheduling approach
- Same `intl` date math
- Same general theming (warm, contemplative, no aggressive red)
- Same `inter` + `dm_serif_display` type pairing (cadence: cream/navy; lock: cream/orange)

If you build a third pclub product, the shared code can be factored into `mx.pclub.dashboard` or `mx.pclub.core` packages and reused.

## What they don't share

- **Brand mark.** Lock is a padlock + cross on orange. Cadence is three dots on midnight navy. The visual identity is different on purpose.
- **Tone of voice.** Lock says "day 70! extraordinary!". Cadence says "see you tomorrow."
- **Engagement mechanism.** Lock uses PBL. Cadence uses The Section.
- **Privacy posture.** Lock is local-only. Cadence has E2E Section + Firestore for the rest.

## Recommended reading

- `mx.pclub.cadence/PHILOSOPHY.md` — the no-PBL manifesto
- `mx.pclub.cadence/docs/RETENTION.md` — the 3 mechanisms (Craving, Infinite, Scoreboard) translated to features
- `mx.pclub.cadence/docs/COMMERCIAL.md` — the business case for the no-PBL framing
- `mx.pclub.cadence/docs/PRIVACY.md` — the structural privacy architecture
- This repo's `BRAND.md` — the lock app's design tokens

If you're going to ship one, ship the one whose philosophy you believe. If you're going to ship both, ship both. Both are honest bets on the same problem.
