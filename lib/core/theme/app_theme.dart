import 'package:flutter/material.dart';

// Mood score → color mapping (1=red, 3=amber, 5=green)
const moodColors = {
  1: Color(0xFFD32F2F), // red
  2: Color(0xFFE65100), // deep orange
  3: Color(0xFFF9A825), // amber
  4: Color(0xFF00897B), // teal
  5: Color(0xFF2E7D32), // forest green
};

Color moodColor(int score) => moodColors[score.clamp(1, 5)] ?? moodColors[3]!;

// ─── Palette ─────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Light
  static const primary = Color(0xFF7986CB);      // indigo 400
  static const primaryContainer = Color(0xFFE8EAF6); // indigo 50
  static const surface = Color(0xFFFAFAFA);
  static const background = Color(0xFFF5F5F5);
  static const onSurface = Color(0xFF212121);
  static const subtle = Color(0xFF757575);

  // Dark
  static const primaryDark = Color(0xFF9FA8DA);
  static const surfaceDark = Color(0xFF1E1E2E);
  static const backgroundDark = Color(0xFF13131F);
  static const onSurfaceDark = Color(0xFFE8E8F0);
}

// ─── Text styles ─────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const displaySmall = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
  );

  static const titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static const bodyMedium = TextStyle(
    fontSize: 15,
    height: 1.5,
  );

  static const labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}

// ─── ThemeData factories ──────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: isDark ? AppColors.primaryDark : AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: isDark
          ? const Color(0xFF303060)
          : AppColors.primaryContainer,
      onPrimaryContainer: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
      secondary: const Color(0xFFB39DDB),
      onSecondary: Colors.white,
      secondaryContainer: isDark
          ? const Color(0xFF2E2B40)
          : const Color(0xFFEDE7F6),
      onSecondaryContainer:
          isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
      surface: isDark ? AppColors.surfaceDark : AppColors.surface,
      onSurface: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
      error: const Color(0xFFCF6679),
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surface,
        foregroundColor:
            isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: isDark ? AppColors.onSurfaceDark : AppColors.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? const Color(0xFF2A2A3E)
            : const Color(0xFFF0F0F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      textTheme: TextTheme(
        displaySmall: AppTextStyles.displaySmall,
        titleLarge: AppTextStyles.titleLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),
    );
  }
}
