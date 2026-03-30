import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    const palette = AppColors.light;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.seed,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: palette.scaffold,
      cardTheme: CardThemeData(
        elevation: 0,
        color: palette.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    const palette = AppColors.dark;
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.seed,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: palette.scaffold,
      cardTheme: CardThemeData(
        elevation: 0,
        color: palette.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
