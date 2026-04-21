import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/models.dart';

ThemeData buildTheme(AppSettings settings) {
  final base = ThemeData.dark(useMaterial3: true);
  final accent = Color(settings.accent);
  final textTheme = GoogleFonts.getTextTheme(settings.fontFamily, base.textTheme);

  // Softer aesthetic background
  const backgroundColor = Color(0xFF0F172A); // Slate 900
  const surfaceColor = Color(0xFF1E293B);    // Slate 800

  return base.copyWith(
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: base.colorScheme.copyWith(
      primary: accent,
      secondary: accent,
      surface: surfaceColor,
      onSurface: Colors.white,
      background: backgroundColor,
    ),
    textTheme: textTheme.apply(
      bodyColor: Colors.white.withOpacity(0.9),
      displayColor: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor.withOpacity(0.8),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: surfaceColor,
      selectedColor: accent.withOpacity(0.2),
      secondarySelectedColor: accent.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: 0.5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accent.withOpacity(0.5), width: 2),
      ),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
    ),
  );
}
