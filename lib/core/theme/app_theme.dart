import 'package:flutter/material.dart';

class AppColors {
  static const orange = Color(0xFFFF7A24);
  static const yellow = Color(0xFFFFD447);
  static const coral = Color(0xFFFF5263);
  static const mint = Color(0xFF42D6A4);
  static const lime = Color(0xFFB6E641);
  static const navy = Color(0xFF171B2F);
  static const offWhite = Color(0xFFF7F5F0);
  static const softGray = Color(0xFFE8E9EF);
  static const muted = Color(0xFF777D8D);
  static const darkSurface = Color(0xFF22263A);
  static const glassLight = Color(0xB3FFFFFF);
  static const glassDark = Color(0x33FFFFFF);
  static const glassBorder = Color(0x66FFFFFF);
}

class AppRadius {
  static const double card = 20;
  static const double button = 16;
}

class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness b) {
    final isDark = b == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.orange,
      brightness: b,
      primary: AppColors.orange,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.navy : AppColors.offWhite,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppColors.navy,
      ),
      textTheme: Typography.material2021().black.apply(
            bodyColor: isDark ? Colors.white : AppColors.navy,
            displayColor: isDark ? Colors.white : AppColors.navy,
          ),
    );
  }
}
