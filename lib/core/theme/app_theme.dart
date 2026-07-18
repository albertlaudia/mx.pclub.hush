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
  static ThemeData light() => _buildTheme(brightness: Brightness.light);

  /// Dark theme: deep teal scaffold, cream text. The dark side of the brand.
  static ThemeData dark() => _buildTheme(brightness: Brightness.dark);

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true);

    final primaryText = isDark ? AppColors.cream : AppColors.ink;
    final secondaryText = isDark ? AppColors.creamSoft : AppColors.inkSoft;
    final surfaceColor = isDark ? AppColors.tealDark : AppColors.cream;
    final onSurfaceColor = isDark ? AppColors.cream : AppColors.ink;
    final primaryBrand = isDark ? AppColors.amber : AppColors.teal;
    final onPrimaryBrand = isDark ? AppColors.tealDark : AppColors.cream;
    final accentBrand = isDark ? AppColors.amberSoft : AppColors.amber;
    final lineColor = isDark ? AppColors.tealSoft : AppColors.line;

    final text = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: primaryText,
      displayColor: primaryText,
    );

    return base.copyWith(
      textTheme: text,
      scaffoldBackgroundColor: surfaceColor,
      colorScheme: base.colorScheme.copyWith(
        primary: primaryBrand,
        onPrimary: onPrimaryBrand,
        secondary: accentBrand,
        onSecondary: onPrimaryBrand,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        brightness: brightness,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBrand,
          foregroundColor: onPrimaryBrand,
          disabledBackgroundColor: primaryBrand.withValues(alpha: 0.4),
          disabledForegroundColor: onPrimaryBrand.withValues(alpha: 0.7),
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
          foregroundColor: primaryBrand,
          side: BorderSide(color: primaryBrand, width: 1.5),
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
          foregroundColor: secondaryText,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.tealSoft : AppColors.creamSoft,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: lineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: lineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: primaryBrand, width: 1.5),
        ),
        hintStyle: GoogleFonts.inter(
          color: AppColors.mute,
          fontSize: 15,
        ),
      ),
      dividerTheme: DividerThemeData(color: lineColor, thickness: 1, space: 1),
    );
  }
}

/// The brand mark used in headers and small contexts.
class BrandMark {
  /// The full wordmark with the small amber dot above the "o".
  /// [size] is the cap-height of the rendered text in logical pixels.
  static Widget wordmark({double size = 24, Color? color, Color? accent}) {
    final c = color ?? AppColors.cream;
    final a = accent ?? AppColors.amber;
    // Width estimated for "lock." in DM Serif Display; height includes
    // headroom for the dot above the text.
    return SizedBox(
      width: size * 2.4,
      height: size * 1.25,
      child: CustomPaint(
        painter: _WordmarkPainter(textHeight: size, color: c, accent: a),
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
  _WordmarkPainter({
    required this.textHeight,
    required this.color,
    required this.accent,
  });
  final double textHeight;
  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    // Render the wordmark at ~75% of the canvas height so the dot has room.
    final fontSize = textHeight * 0.75;
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'lock.',
        style: GoogleFonts.dmSerifDisplay(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w400,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    // Center the text in the canvas.
    final textX = (size.width - textPainter.width) / 2;
    final textY = (size.height - textPainter.height) / 2 + textHeight * 0.05;

    // Find the center of the "o" character (index 1 of 5) so the dot
    // is precisely above the right letter, not eyeballed.
    final oStart = textPainter.getOffsetForCaret(const TextPosition(offset: 1));
    final oEnd = textPainter.getOffsetForCaret(const TextPosition(offset: 2));
    final oCenterX = textX + (oStart.dx + oEnd.dx) / 2;

    // Paint the text first.
    textPainter.paint(canvas, Offset(textX, textY));

    // Then paint the dot above the "o", with a small gap from the text top.
    final dotRadius = textHeight * 0.06;
    final dotY = textY - dotRadius - textHeight * 0.04;
    final dotPaint = Paint()..color = accent;
    canvas.drawCircle(Offset(oCenterX, dotY), dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(_WordmarkPainter old) =>
      old.textHeight != textHeight || old.color != color || old.accent != accent;
}

class _DotInRingPainter extends CustomPainter {
  _DotInRingPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final ringRadius = size.width * 0.40;
    final dotRadius = size.width * 0.14;
    final strokeWidth = size.width * 0.05;

    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, ringRadius, ringPaint);

    final dotPaint = Paint()..color = color;
    canvas.drawCircle(center, dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(_DotInRingPainter old) => old.color != color;
}
