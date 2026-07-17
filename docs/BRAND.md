# Brand — prayer lock

> The orange + lock + cross. The design tokens, the color story, the typography.

## The mark

A white padlock with a small Christian cross carved into the body, on warm orange (`#FF8B27`).

- The **lock** is the wedge — "block your phone until you pray"
- The **cross** is the audience — Christian, multi-denominational
- The **orange** is the brand — warm, energetic, not aggressive

## Color palette

| Token | Hex | Use |
|---|---|---|
| Primary | `#FF8B27` | Background of mark, primary CTA, day numbers, flame |
| Primary dark | `#E5711A` | Pressed states, border accents |
| Primary light | `#FFB66B` | Highlights, soft tints |
| Cream | `#FFF8E7` | Default scaffold background |
| Paper | `#FFFCF2` | Card background |
| Soft | `#FAEED1` | Streak display card background |
| Green | `#4A7C59` | "Relationship with God" check-in |
| Green dark | `#3A6447` | Pressed state on green screens |
| Blue | `#5BB3D9` | "How are you feeling" check-in |
| Blue dark | `#3A8FB5` | Pressed state on blue screens |
| Ink | `#1A1A1A` | Primary text on cream |
| Ink soft | `#4A4A4A` | Secondary text |
| Mute | `#8A8A8A` | Tertiary text, disabled states |
| Line | `#E5E5E5` | Dividers, borders |
| White | `#FFFFFF` | Inverted text, CTA background on color screens |

## Typography

- **Headings:** `DM Serif Display` (Google Fonts) — warm, reverent, editorial
- **Body / UI:** `Inter` (Google Fonts) — clean, modern, neutral
- **Numerals:** Inter's tabular figures for the streak number

## Voice

- **Lowercase** for "prayer lock" — casual, intimate
- **Sentence case** for body — readable, not shouty
- **Encouragement line** under the streak: short, varied, never shaming
  - Day 0: *"one prayer away from a streak. tap below to begin."*
  - Day 1: *"day one. the hardest and the holiest."*
  - Day 4: *"a small rhythm is forming. stay with it."*
  - Day 14+: *"extraordinary! your prayer journey is an inspiration to all"* (matches the reference)
- **No guilt copy.** Never "you missed 3 days". Never "your streak is gone". Never "don't break it".

## Anti-patterns

These would be wrong for this product:

- **No dark patterns.** No "are you sure you want to skip?" modal. No "you'll lose your streak!" warning. The user can pause, skip, or abandon. The product does not shame.
- **No "buy pro to keep your streak"** paywall.
- **No ads.** No upsell. The product is free, period.
- **No social feed.** No "your friends' streaks". No leaderboard.
- **No public profile.** No "share my streak" social posts.

## Assets

- `media/icons/app-icon-1024.png` — iOS App Store master
- `media/icons/app-icon-512.png` — Android Play Store
- `media/icons/ios/Icon-App-*.png` — full iOS asset catalog
- `media/icons/android/mipmap-*/ic_launcher.png` — full Android mipmap set
- `media/icons/favicon-*.png` — web favicons
- `media/social-preview-1280x640.png` — GitHub social preview

## When updating the mark

1. Update the source `app-icon-1024.png` (1024×1024 master)
2. Re-run `python3 scripts/resize-icons.py` to regenerate all derivatives
3. Re-copy the derivatives into `ios/Runner/Assets.xcassets/AppIcon.appiconset/` and `android/app/src/main/res/mipmap-*/`
4. Commit and push

The mark is the brand. The brand is the product. Don't drift.
