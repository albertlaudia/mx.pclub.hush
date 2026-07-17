import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color tokens — these mirror the Prayer Lock palette in the design references.
/// See `docs/BRAND.md` for the full color story.
class AppColors {
  // Primary (orange)
  static const Color primary = Color(0xFFFF8B27);
  static const Color primaryDark = Color(0xFFE5711A);
  static const Color primaryLight = Color(0xFFFFB66B);

  // Backgrounds
  static const Color cream = Color(0xFFFFF8E7);
  static const Color paper = Color(0xFFFFFCF2);
  static const Color soft = Color(0xFFFAEED1);

  // Mood check-in (green)
  static const Color moodGreen = Color(0xFF4A7C59);
  static const Color moodGreenDark = Color(0xFF3A6447);
  static const Color moodGreenLight = Color(0xFF6B9B7B);

  // Mood emoji (blue)
  static const Color moodBlue = Color(0xFF5BB3D9);
  static const Color moodBlueDark = Color(0xFF3A8FB5);
  static const Color moodBlueLight = Color(0xFF7CC5E5);

  // Neutrals
  static const Color ink = Color(0xFF1A1A1A);
  static const Color inkSoft = Color(0xFF4A4A4A);
  static const Color mute = Color(0xFF8A8A8A);
  static const Color line = Color(0xFFE5E5E5);
  static const Color white = Color(0xFFFFFFFF);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final text = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    );
    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: AppColors.cream,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.moodGreen,
        surface: AppColors.cream,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          color: AppColors.ink,
          fontSize: 22,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        trackHeight: 6,
        activeTrackColor: AppColors.white,
        inactiveTrackColor: AppColors.white.withValues(alpha: 0.35),
        thumbColor: AppColors.white,
        overlayColor: AppColors.white.withValues(alpha: 0.15),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
      ),
    );
  }
}
