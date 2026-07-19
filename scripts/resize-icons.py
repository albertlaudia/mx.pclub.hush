#!/usr/bin/env python3
"""
Resize the primary (1024) and secondary (1024) source icons to every
size needed for iOS asset catalog, Android mipmap set, and web
favicons. Run after regenerating the source PNGs.

Usage: python3 scripts/resize-icons.py
"""
import os
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRIMARY = os.path.join(ROOT, "media/icons/primary-1024.png")
SECONDARY = os.path.join(ROOT, "media/icons/secondary-1024.png")
OUT = ROOT

# iOS AppIcon.appiconset — every size Apple requires
IOS_SIZES = {
    # (size, scale) → output filename
    (20, 1): "ios/Icon-App-20x20@1x.png",
    (20, 2): "ios/Icon-App-20x20@2x.png",
    (20, 3): "ios/Icon-App-20x20@3x.png",
    (29, 1): "ios/Icon-App-29x29@1x.png",
    (29, 2): "ios/Icon-App-29x29@2x.png",
    (29, 3): "ios/Icon-App-29x29@3x.png",
    (40, 1): "ios/Icon-App-40x40@1x.png",
    (40, 2): "ios/Icon-App-40x40@2x.png",
    (40, 3): "ios/Icon-App-40x40@3x.png",
    (60, 2): "ios/Icon-App-60x60@2x.png",
    (60, 3): "ios/Icon-App-60x60@3x.png",
    (76, 1): "ios/Icon-App-76x76@1x.png",
    (76, 2): "ios/Icon-App-76x76@2x.png",
    (83.5, 2): "ios/Icon-App-83.5x83.5@2x.png",
    (1024, 1): "ios/Icon-App-1024x1024@1x.png",
}

# Android mipmap densities
ANDROID_DENSITIES = {
    "mipmap-mdpi": 48,
    "mipmap-hdpi": 72,
    "mipmap-xhdpi": 96,
    "mipmap-xxhdpi": 144,
    "mipmap-xxxhdpi": 192,
}

# Web favicons
FAVICON_SIZES = [16, 32, 48, 256]


def resize_square(src_path: str, size_px: int, out_path: str) -> None:
    img = Image.open(src_path).convert("RGBA")
    img = img.resize((size_px, size_px), Image.LANCZOS)
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    img.save(out_path, "PNG", optimize=True)
    print(f"  {os.path.relpath(out_path, ROOT)} ({size_px}x{size_px})")


def main() -> None:
    print("Resizing primary (hush. wordmark) for iOS / Android / web...")
    if not os.path.exists(PRIMARY):
        raise SystemExit(f"missing source: {PRIMARY}")
    if not os.path.exists(SECONDARY):
        raise SystemExit(f"missing source: {SECONDARY}")

    primary_img = Image.open(PRIMARY).convert("RGBA")
    secondary_img = Image.open(SECONDARY).convert("RGBA")

    # --- App icon masters (used as the iOS / Android primary) ---
    # 1024 for iOS App Store master
    primary_img.save(
        os.path.join(OUT, "media/icons/app-icon-1024.png"), "PNG", optimize=True
    )
    primary_img.save(
        os.path.join(OUT, "media/icons/app-icon-512.png"), "PNG", optimize=True
    )

    # --- iOS AppIcon.appiconset ---
    for (size, scale), rel in IOS_SIZES.items():
        out_path = os.path.join(OUT, "media/icons", rel)
        px = int(round(size * scale))
        resize_square(PRIMARY, px, out_path)

    # --- Android mipmap set ---
    for dirname, size_px in ANDROID_DENSITIES.items():
        out_dir = os.path.join(OUT, "media/icons/android", dirname)
        os.makedirs(out_dir, exist_ok=True)
        out_path = os.path.join(out_dir, "ic_launcher.png")
        resize_square(PRIMARY, size_px, out_path)

    # --- Web favicons (use the secondary mark — smaller, more legible) ---
    for size_px in FAVICON_SIZES:
        out_path = os.path.join(OUT, "media/icons", f"favicon-{size_px}.png")
        resize_square(SECONDARY, size_px, out_path)

    print("\nDone.")


if __name__ == "__main__":
    main()
