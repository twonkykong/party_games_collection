import 'package:flutter/material.dart';

import 'app_palette.dart';

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final palette = isDark ? AppPalette.dark : AppPalette.light;

  final scheme = ColorScheme.fromSeed(
    seedColor: palette.primary,
    brightness: brightness,
  ).copyWith(
    primary: palette.primary,
    secondary: palette.secondary,
    surface: palette.surface,
    error: palette.errorStrong,
    onPrimary: palette.white,
    onSurface: palette.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF1A1412) : palette.backgroundTop,
    extensions: [palette],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: palette.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: palette.textPrimary),
      actionsIconTheme: IconThemeData(color: palette.textPrimary),
      titleTextStyle: TextStyle(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: palette.textPrimary,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        letterSpacing: -0.4,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.45,
        color: palette.textSecondary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.4,
        color: palette.textSecondary,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(62),
        backgroundColor: palette.primary,
        foregroundColor: palette.white,
        shadowColor: palette.shadow,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(62),
        foregroundColor: palette.textPrimary,
        side: BorderSide(color: palette.outline),
        backgroundColor: palette.surface,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: palette.surface,
      labelStyle: TextStyle(color: palette.textSecondary),
      hintStyle: TextStyle(
        color: palette.textSecondary.withValues(alpha: 0.75),
      ),
      prefixIconColor: palette.textSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: palette.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: palette.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: palette.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: palette.surfaceMuted,
      selectedColor: palette.primarySoft,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      labelStyle: TextStyle(
        color: palette.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primarySoft;
          }
          return palette.surface;
        }),
        foregroundColor: WidgetStatePropertyAll(palette.textPrimary),
        side: WidgetStatePropertyAll(BorderSide(color: palette.outline)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: palette.textPrimary,
      contentTextStyle: TextStyle(color: palette.surface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
  );
}
