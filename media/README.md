# Media — Brand & marketing assets for `hush.`

This folder is the single source of truth for the brand. Every platform (iOS, Android, web, social) draws from here. When the mark changes, this folder changes, and the rest follows.

---

## What's in here

### Icon masters (`media/icons/`)

| File | Size | Purpose |
|---|---|---|
| `primary-1024.png` | 1024×1024 | The wordmark in cream on deep teal, amber dot above the `u`. The brand mark in its purest form. |
| `secondary-1024.png` | 1024×1024 | The geometric mark: a small filled dot inside a thin ring, both in cream on teal. Used for small contexts. |
| `app-icon-1024.png` | 1024×1024 | iOS App Store master. Identical to `primary-1024.png` (kept for naming convention). |
| `app-icon-512.png` | 512×512 | Google Play Store master. Resized from `primary-1024.png`. |
| `favicon-16.png` | 16×16 | Browser tab favicon (smallest). Resized from the secondary mark. |
| `favicon-32.png` | 32×32 | Browser tab favicon (HiDPI). |
| `favicon-48.png` | 48×48 | Browser tab favicon (Windows). |
| `favicon-256.png` | 256×256 | Pinned tab, large UI uses. |

### iOS asset catalog (`media/icons/ios/`)

Every size Apple requires for `Assets.xcassets/AppIcon.appiconset/`. All generated from `primary-1024.png` via `scripts/resize-icons.py`:

- `Icon-App-20x20@1x.png` (20×20)
- `Icon-App-20x20@2x.png` (40×40)
- `Icon-App-20x20@3x.png` (60×60)
- `Icon-App-29x29@1x.png` (29×29)
- `Icon-App-29x29@2x.png` (58×58)
- `Icon-App-29x29@3x.png` (87×87)
- `Icon-App-40x40@1x.png` (40×40)
- `Icon-App-40x40@2x.png` (80×80)
- `Icon-App-40x40@3x.png` (120×120)
- `Icon-App-60x60@2x.png` (120×120)
- `Icon-App-60x60@3x.png` (180×180)
- `Icon-App-76x76@1x.png` (76×76)
- `Icon-App-76x76@2x.png` (152×152)
- `Icon-App-83.5x83.5@2x.png` (167×167)
- `Icon-App-1024x1024@1x.png` (1024×1024, App Store)

### Android mipmap (`media/icons/android/`)

Every density Google requires for `res/mipmap-*/ic_launcher.png`:

- `mipmap-mdpi/ic_launcher.png` (48×48)
- `mipmap-hdpi/ic_launcher.png` (72×72)
- `mipmap-xhdpi/ic_launcher.png` (96×96)
- `mipmap-xxhdpi/ic_launcher.png` (144×144)
- `mipmap-xxxhdpi/ic_launcher.png` (192×192)

### Social & web (`media/*.png`)

| File | Size | Purpose |
|---|---|---|
| `social-preview-1280x640.png` | 1280×640 | GitHub social preview (when someone shares the repo link) |
| `opengraph-1200x630.png` | 1200×630 | Open Graph default (Slack, iMessage, Discord, Facebook, generic) |
| `hero-1920x1080.png` | 1920×1080 | README hero, blog posts, wide web use |
| `poster-1080x1920.png` | 1080×1920 | Instagram Story, vertical social poster, app-store scroll-stopper |
| `banner-twitter-1500x500.png` | 1500×500 | Twitter/X header |
| `banner-linkedin-1584x396.png` | 1584×396 | LinkedIn cover banner |
| `logo-lockup-1500x1000.png` | 1500×1000 | Press kit lockup: mark + wordmark + tagline |
| `brand-colors-1500x1000.png` | 1500×1000 | Press kit palette: the six brand colors as swatches |

---

## How to use

### iOS / Android

The icons in `media/icons/ios/` and `media/icons/android/` are the source. Copy them into your platform-specific locations before building:

```bash
# iOS
cp media/icons/ios/*.png ios/Runner/Assets.xcassets/AppIcon.appiconset/

# Android
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  cp media/icons/android/mipmap-$d/ic_launcher.png android/app/src/main/res/mipmap-$d/
done
```

These are *also* what `flutter build` and `flutter run` use, so the build pipeline picks them up automatically. They're already in the right paths for the in-repo icon assets — but you can re-copy if you regenerate the source masters.

### Web / GitHub

The `social-preview-1280x640.png` and `hero-1920x1080.png` are referenced from the repo's GitHub social settings and the README. No additional setup.

### Press kit

The `logo-lockup-1500x1000.png` and `brand-colors-1500x1000.png` are for journalists, bloggers, podcast hosts, and anyone else who needs to feature the brand. Send the lockup + the palette + a one-paragraph description.

---

## How to regenerate

If you update the wordmark master (`primary-1024.png`) or the secondary mark (`secondary-1024.png`), run:

```bash
python3 scripts/resize-icons.py
```

This regenerates every iOS size, every Android mipmap size, and every favicon. The script is idempotent — running it twice produces the same output.

For the marketing materials (hero, social, poster, banners, lockup, palette), regenerate the source images and place them at the correct paths. There is no script for this yet — the marketing assets are one-off designs.

---

## Brand summary

- **Name:** `hush.` (lowercase, with period)
- **Wordmark:** `hush.` in DM Serif Display, cream on deep teal
- **Mark accent:** small muted amber dot above the `u`
- **Secondary mark:** dot inside a thin ring
- **Tagline:** "a daily practice, quietly"
- **Palette:** deep teal `#1F3D3A`, warm cream `#F5F0E6`, muted amber `#B89968`, ink `#1A1A1A`
- **Type:** DM Serif Display (display) + Inter (body)
- **Voice:** lowercase, no exclamation marks, no superlatives, no guilt copy

The full design system is in [`docs/BRAND.md`](../docs/BRAND.md). The production-readiness checklist is in [`docs/PRODUCTION-READINESS.md`](../docs/PRODUCTION-READINESS.md).

---

*This folder is the brand. The brand is the product. Don't drift.*
