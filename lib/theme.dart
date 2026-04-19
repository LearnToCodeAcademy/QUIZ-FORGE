import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/models.dart';

ThemeData buildTheme(AppSettings settings) {
  final base = ThemeData.dark(useMaterial3: true);
  final accent = Color(settings.accent);
  final textTheme = GoogleFonts.getTextTheme(settings.fontFamily, base.textTheme);

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF070B19),
    colorScheme: base.colorScheme.copyWith(
      primary: accent,
      secondary: accent,
      surface: const Color(0xFF131B36),
    ),
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF070B19),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: accent.withOpacity(0.5),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );
}
