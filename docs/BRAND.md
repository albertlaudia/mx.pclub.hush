# Brand — `lock.`

> A daily practice, quietly. The wordmark, the colors, the type, the voice.

## The name

`lock.` — lowercase, with a period.

The word is the noun. The period is the statement. The name says *the thing* and stops. No tagline-as-name, no marketing modifier, no "prayer" or "daily" or "faith" qualifier. The name is the action: **lock.** Lock what you do. Lock the day. Lock the practice. Then keep going.

The period matters. Without it, "lock" reads as a noun (a device). With it, "lock." reads as an imperative (a verb, a command, a done state).

## The mark

A wordmark in a distinctive serif (`DM Serif Display`) in warm cream (`#F5F0E6`) on deep teal (`#1F3D3A`). A single small muted amber dot (`#B89968`) floats above the letter `o` as the only symbol.

**Why this mark:**
- **The wordmark is the icon.** No symbol, no lock shape, no cross. The brand is the brand.
- **The serif says "this is a book, not an app."** Editorial. Restrained. Adult.
- **The dot is the only iconography.** A single, restrained accent. The same dot, isolated, becomes the favicon and the notification badge.
- **The deep teal is contemplative, not aggressive.** A meditation journal cover, not a workout tracker.

**The secondary mark** is a geometric dot-in-ring: a small filled dot inside a thin ring, both in cream. Used for contexts where the wordmark is too small or too text-heavy — the favicon, the notification badge, the future home widget.

## Color palette

| Token | Hex | Use |
|---|---|---|
| Teal | `#1F3D3A` | Primary background, primary text, primary CTA |
| Teal dark | `#142725` | Dark mode background, deep contrast |
| Teal soft | `#2D5250` | Hover/pressed states on teal |
| Cream | `#F5F0E6` | Scaffold background, light text on teal |
| Cream soft | `#FAF6EE` | Card background, subtle surface |
| Paper | `#EBE4D2` | Tertiary surface, separators |
| Amber | `#B89968` | The accent. The dot. The small mark of attention. |
| Amber soft | `#D4B98A` | Hover/pressed on amber |
| Ink | `#1A1A1A` | Primary text on cream |
| Ink soft | `#4A4A4A` | Secondary text on cream |
| Mute | `#8A8B8C` | Tertiary text, disabled states, dividers |
| Line | `#E0DBC9` | Borders, dividers on cream |

The palette is **field-journal**, not prayer-app. It evokes a leather-bound notebook on a wooden desk, not a stained-glass window. The amber dot is the wax seal on the letter. The teal is the cloth cover.

## Typography

- **Wordmark / display:** `DM Serif Display` (Google Fonts) — the only place the serif is used
- **Body / UI:** `Inter` (Google Fonts) — clean, modern, neutral, the workhorse

The serif is the brand. The sans is the workhorse. The two together say: this is a serious product, but it doesn't take itself too seriously.

## Voice

- **Lowercase** for the wordmark and short UI labels. Casual, intimate.
- **Sentence case** for body. Readable, not shouty.
- **No exclamation marks.** Never. Not one.
- **No superlatives.** Not "extraordinary". Not "amazing". Not "incredible".
- **No guilt copy.** Not "you missed 3 days". Not "your streak is gone". Not "don't break it".
- **The encouragement is the practice itself.** "see you tomorrow." is enough.

Examples of the voice:

| Don't | Do |
|---|---|
| "🔥 70-day streak! extraordinary!" | (no streak counter) |
| "you missed 3 days! let's get back on track" | (no missed-day copy) |
| "start your FREE TRIAL of prayer lock PRO" | (no subscription) |
| "share with friends!" | (no social share prompt) |
| "tap to begin your journey" | "begin" |
| "a moment of attention" | (already in the practice screen) |

## Anti-patterns

These would be wrong for this product:

- **No streak counter.** No "Day 47!". No flame. No "best ever".
- **No public profile.** No "share my streak". No social posts.
- **No mood check-in.** No "how are you feeling today?" slider.
- **No "extraordinary!" copy.** The product is the practice, not the hype.
- **No ads.** No upsell. The product is free, period.
- **No dark patterns.** No "are you sure you want to skip?" modal. No "you'll lose your streak!" warning.
- **No cross, rosary, dove, or any explicitly Christian iconography.** The product is multi-faith.
- **No orange.** No padlock. No flame. No flame emoji. No copy from the Prayer Lock product.
- **No "block your phone until you pray" framing.** The product is the practice, not the app-blocker.

## Where the mark lives

- **App Store / Play Store marketing icon:** the full wordmark, deep teal background
- **Home screen icon (default):** the full wordmark
- **Favicon:** the wordmark at 16-32px
- **Notification icon (Android):** the secondary mark, single-color cream
- **App badge (iOS):** the secondary mark, single-color
- **Future home widget (v0.2):** the secondary mark
- **Social preview banner:** the wordmark on cream, with the secondary mark to the right
- **README hero:** the wordmark on cream, with the secondary mark below

## When updating the mark

1. Update the source `media/icons/primary-1024.png` (1024×1024 master, deep teal with wordmark)
2. Update the source `media/icons/secondary-1024.png` (1024×1024, deep teal with dot-in-ring)
3. Re-run `python3 scripts/resize-icons.py` to regenerate all derivatives
4. Re-copy the derivatives into `ios/Runner/Assets.xcassets/AppIcon.appiconset/` and `android/app/src/main/res/mipmap-*/`
5. Update `lib/core/theme/app_theme.dart` if the palette changes
6. Commit and push

The mark is the brand. The brand is the product. Don't drift.
