import 'package:flutter/material.dart';

/// ResQ Design System
/// Modern SaaS flat vector aesthetic with pastel palette,
/// bold black outlines (2px), rounded corners (16-24px),
/// and zero gradients/drop-shadows/3D/cyberpunk.
class AppTheme {
  // Pastel Palette
  static const Color pastelBlue = Color(0xFFE0EBFF);
  static const Color pastelPurple = Color(0xFFECE5FF);
  static const Color lilac = Color(0xFFDDD6FE);
  static const Color lilacDark = Color(0xFF8B5CF6);
  static const Color pastelMint = Color(0xFFD1FAE5);
  static const Color mintDark = Color(0xFF059669);
  static const Color pastelAmber = Color(0xFFFEF3C7);
  static const Color amberDark = Color(0xFFD97706);
  static const Color pastelCoral = Color(0xFFFEE2E2);
  static const Color coralDark = Color(0xFFDC2626);
  static const Color pastelRose = Color(0xFFFFE4E6);

  // Surface & Neutral
  static const Color bgNeutral = Color(0xFFF8FAFC);
  static const Color bgSurface = Color(0xFFFFFFFF);
  static const Color surfaceSecondary = Color(0xFFF1F5F9);

  // Outlines & Typography (Clean 2D vector style)
  static const Color strokeBlack = Color(0xFF0F172A);
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textMuted = Color(0xFF64748B);

  // Stroke width rule
  static const double strokeWidth = 2.0;
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 18.0;
  static const double radiusLarge = 24.0;

  // Box border styling
  static Border get neoBorder => Border.all(
        color: strokeBlack,
        width: strokeWidth,
      );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgNeutral,
      primaryColor: pastelPurple,
      colorScheme: const ColorScheme.light(
        primary: strokeBlack,
        secondary: lilac,
        surface: bgSurface,
        error: coralDark,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: bgNeutral,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: strokeBlack),
        titleTextStyle: TextStyle(
          color: strokeBlack,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: pastelPurple,
          foregroundColor: strokeBlack,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
            side: const BorderSide(color: strokeBlack, width: strokeWidth),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: bgSurface,
          foregroundColor: strokeBlack,
          side: const BorderSide(color: strokeBlack, width: strokeWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
