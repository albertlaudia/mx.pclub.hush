# vs. `mx.pclub.cadence`

> Two products. Two philosophies. The same daily practice.

`mx.pclub.cadence` and `mx.pclub.hush` are siblings. They share a daily-practice problem, a multi-faith audience, a Flutter + Riverpod codebase, and a `mx.pclub.*` repo prefix. They differ in **scope, philosophy, and brand**.

If you ship both, you A/B-test the philosophy in the market. If you ship one, you bet on the philosophy.

## At a glance

| | **mx.pclub.lock** (this repo) | **mx.pclub.cadence** |
|---|---|---|
| **Scope** | Minimal v0.1 — 3 screens + settings | Full v1 — 22 screens, full workflow |
| **Wedge** | "a daily practice, quietly" | "a daily practice that keeps" |
| **Engagement** | None. No streak, no widget, no notification. | The Section (E2E encrypted, capped at 7), the chapter mark, the composition |
| **Gamification** | Zero. By design. | Zero. By design — explicitly anti-PBL |
| **Visibility** | Private. No public score. | Private. The Section is opt-in, end-to-end encrypted. |
| **Tone** | "see you tomorrow." | "see you tomorrow." (Same restraint, different mechanisms.) |
| **Privacy** | Local-only. No backend. | Local + Firestore for the rest, E2E Section |
| **Subscription** | None. Free. | Free tier + paid (true upgrade, not paywall) |
| **Stack** | Flutter + Riverpod + shared_preferences | Flutter + Riverpod + go_router + Firebase + E2E |
| **App blocking** | None. (Doesn't need it.) | None. (Doesn't need it.) |
| **Locale support** | English only | 8 locales day-one-to-day-90 |
| **Brand** | Deep teal + cream + amber. Wordmark in serif. | Midnight navy + amber. Three-dot mark. |
| **Audience** | Multi-faith, secular, anyone who wants a quiet practice | Multi-faith, secular, anyone who wants a long-arc practice |

## The same problem, two products

**Both apps answer the same question:** *how do we help a person keep a daily practice in a phone-full world?*

**`hush.` answers:** by being the simplest thing that could possibly work. One verse, one moment, one tap. The product is the practice, the practice is the product, nothing else.

**Cadence answers:** by composing the practice into a multi-year arc. Each day is a movement, each week is a chapter, each year is a composition. The Section is a small circle that quietly holds you to it.

Neither is "right". They are two bets on the same product problem, framed differently. `hush.` is the minimal bet (does the practice itself retain?). Cadence is the architecture bet (does the architecture, without PBL, retain?).

## Why ship both

**Three reasons:**

1. **Different scope, different audience.** Some users want the minimal. They want a single screen, a single verse, a single tap. They don't want a Section, a chapter, a composition. `hush.` is for them. Other users want the long arc. They want the Section. They want the chapter. They want the composition. Cadence is for them.

2. **A/B-test the scope, not just the philosophy.** `hush.` and Cadence both reject PBL. They differ in scope. If you ship both, you measure: does the minimal retain, or does the architecture retain? If only one retains, the data tells you which scope is the right bet.

3. **Strategic optionality.** Two repos = two potential acquisitions. A faith publisher might buy `hush.` (the minimal prayer app). A different publisher might buy Cadence (the architecture-driven daily practice). Two repos = two acquisition targets. One repo with two scopes = one product that confuses everyone.

## What they share

- Same Flutter + Riverpod base
- Same `mx.pclub.*` repo convention
- Same `shared_preferences` local-store pattern
- Same `intl` date math
- Same `inter` body type
- Same restraint: no PBL, no public score, no social share, no mood check-in, no subscription
- Same voice: "see you tomorrow."
- Same "the user is a whole person, not an engagement metric" philosophy

If you build a third pclub product, the shared code can be factored into `mx.pclub.dashboard` or `mx.pclub.core` packages and reused.

## What they don't share

- **Brand mark.** `hush.` is a wordmark in cream on deep teal. Cadence is three amber dots on midnight navy. The visual identity is different on purpose — they're different products, not the same product in two sizes.
- **Scope.** `hush.` is 3 screens. Cadence is 22 screens.
- **Backend.** `hush.` is local-only. Cadence has Firestore + E2E.
- **Engineering complexity.** `hush.` is a one-day Flutter project. Cadence is a 3-month architecture project.
- **Team required to ship.** `hush.` can ship solo. Cadence needs 2-3 people.

## What you can learn from each

- **`hush.` alone:** you don't know if the minimal scope is the right scope. Maybe users want more. Maybe they want less. You don't know.
- **Cadence alone:** you don't know if the architecture is the right architecture. Maybe users don't want a Section. Maybe they don't want a chapter. You don't know.
- **Both together:** you can measure the same practice, scoped two ways, in two cohorts. `hush.` measures what the minimal does. Cadence measures what the architecture does. The difference is the scope effect.

## What I built and rejected

The first build of `hush.` was a Prayer Lock clone — orange background, padlock icon, streak counter, mood check-in. I copied the visual language. The user caught it. We tore it down and built something genuinely ours.

The current identity — deep teal, cream, amber dot, no streak, no widget, no check-in, no mood, no notification — is the *rejection* of the PBL framing, not the embrace of it. `hush.` is the minimal-scope product, not the prayer-app clone.

If you find yourself adding a streak counter to `hush.`, ask: *is this Cadence, or is this `hush.`?* If it's Cadence, it belongs in the other repo. If it's `hush.`, it shouldn't be there.

## Recommended reading

- `mx.pclub.cadence/PHILOSOPHY.md` — the no-PBL manifesto
- `mx.pclub.cadence/docs/RETENTION.md` — the 3 mechanisms (Craving, Infinite, Scoreboard)
- `mx.pclub.cadence/docs/COMMERCIAL.md` — the business case for the architecture
- This repo's `BRAND.md` — the design tokens, the colors, the anti-patterns

If you're going to ship one, ship the one whose scope you believe. If you're going to ship both, ship both. Both are honest bets on the same problem.
