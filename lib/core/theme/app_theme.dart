import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Brand tokens for `lock.`
///
/// The palette: deep teal, warm cream, muted amber. Quiet, editorial,
/// distinctive. No orange. No padlock. No cross. Genuinely ours.
class AppColors {
  // Primary brand
  static const Color teal = Color(0xFF1F3D3A);
  static const Color tealDark = Color(0xFF142725);
  static const Color tealSoft = Color(0xFF2D5250);

  // Surfaces
  static const Color cream = Color(0xFFF5F0E6);
  static const Color creamSoft = Color(0xFFFAF6EE);
  static const Color paper = Color(0xFFEBE4D2);

  // Accent
  static const Color amber = Color(0xFFB89968);
  static const Color amberSoft = Color(0xFFD4B98A);

  // Text
  static const Color ink = Color(0xFF1A1A1A);
  static const Color inkSoft = Color(0xFF4A4A4A);
  static const Color mute = Color(0xFF8A8B8C);
  static const Color line = Color(0xFFE0DBC9);
}

class AppTheme {
  /// Light theme: cream scaffold, teal ink, amber accent.
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
        primary: AppColors.teal,
        onPrimary: AppColors.cream,
        secondary: AppColors.amber,
        onSecondary: AppColors.cream,
        surface: AppColors.cream,
        onSurface: AppColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          foregroundColor: AppColors.cream,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.teal,
          side: const BorderSide(color: AppColors.teal, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.mute,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamSoft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.mute,
          fontSize: 15,
        ),
      ),
    );
  }

  /// Dark theme: deep teal scaffold, cream text. The dark side of the brand.
  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final text = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.cream,
      displayColor: AppColors.cream,
    );
    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: AppColors.tealDark,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.amber,
        onPrimary: AppColors.tealDark,
        secondary: AppColors.amberSoft,
        surface: AppColors.tealDark,
        onSurface: AppColors.cream,
      ),
    );
  }
}

/// The brand mark used in headers and small contexts.
class BrandMark {
  /// The full wordmark with the small amber dot above the "o".
  /// Size is the height of the wordmark in logical pixels.
  static Widget wordmark({double size = 24, Color color = AppColors.cream, Color? accent}) {
    return CustomPaint(
      size: Size(size * 3.0, size),
      painter: _WordmarkPainter(
        fontSize: size,
        color: color,
        accent: accent ?? AppColors.amber,
      ),
    );
  }

  /// The geometric secondary mark: a small dot inside a thin ring.
  static Widget dotInRing({double size = 24, Color color = AppColors.cream}) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _DotInRingPainter(color: color)),
    );
  }
}

class _WordmarkPainter extends CustomPainter {
  _WordmarkPainter({required this.fontSize, required this.color, required this.accent});
  final double fontSize;
  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the small accent dot above the "o" position.
    final dotY = size.height * 0.05;
    final dotX = size.width * 0.33;
    final dotRadius = size.height * 0.05;
    final dotPaint = Paint()..color = accent;
    canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);

    // Draw "lock." in DM Serif Display, cream.
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'lock.',
        style: GoogleFonts.dmSerifDisplay(
          color: color,
          fontSize: fontSize * 2.0,
          fontWeight: FontWeight.w400,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    // Center vertically with the dot taking some headroom
    final textY = (size.height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(0, textY));
  }

  @override
  bool shouldRepaint(_WordmarkPainter old) =>
      old.fontSize != fontSize || old.color != color || old.accent != accent;
}

class _DotInRingPainter extends CustomPainter {
  _DotInRingPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = size.width * 0.42;
    final dotRadius = size.width * 0.14;

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04;
    canvas.drawCircle(center, ringRadius, ringPaint);

    final dotPaint = Paint()..color = color;
    canvas.drawCircle(center, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(_DotInRingPainter old) => old.color != color;
}
