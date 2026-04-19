import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/models.dart';

ThemeData buildTheme(AppSettings settings) {
  final base = ThemeData.dark(useMaterial3: true);
  final accent = Color(settings.accent);
  final textTheme = GoogleFonts.getTextTheme(settings.fontFamily, base.textTheme);

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF050924),
    colorScheme: base.colorScheme.copyWith(
      primary: accent,
      secondary: accent,
      surface: const Color(0xFF121C44),
    ),
    textTheme: textTheme,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}
