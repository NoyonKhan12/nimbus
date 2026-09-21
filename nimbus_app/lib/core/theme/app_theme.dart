import 'package:flutter/material.dart';

/// Nimbus application theme (light and dark modes).
/// Colors are inspired by Bangladesh branding.
class AppTheme {
  // Primary colors
  static const Color primary = Color(0xFF1565C0);
  static const Color primaryVariant = Color(0xFF0D47A1);
  static const Color secondary = Color(0xFF009688);
  static const Color secondaryVariant = Color(0xFF00796B);
  static const Color error = Color(0xFFB00020);

  // Neutrals
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF212121);
  static const Color onSurface = Color(0xFF212121);
  static const Color outline = Color(0xFFBDBDBD);

  // Status colors
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: Color(0xFFBBDEFB),
      secondary: secondary,
      onSecondary: onSecondary,
      error: error,
      onError: onError,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      outline: outline,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 2,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondary,
      foregroundColor: onSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: Color(0xFF90CAF9),
      secondary: secondary,
      onSecondary: onSecondary,
      error: error,
      onError: onError,
      background: Color(0xFF121212),
      onBackground: Color(0xFFE0E0E0),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE0E0E0),
      outline: outline,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryVariant,
      foregroundColor: onPrimary,
    ),
  );
}
