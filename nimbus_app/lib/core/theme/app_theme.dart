import 'package:flutter/material.dart';

/// Nimbus application theme — Material 3, light and dark.
///
/// Design tokens follow a modern M3 baseline:
///  - flat, tonal cards (elevation 0, hairline outline, 16px radius)
///  - filled rounded text fields with focus rings (no default grey)
///  - floating snackbars, 52px primary buttons, pill chips
///  - full dark palette with elevation-tinted surfaces
///
/// Screens should consume these through `Theme.of(context)`; the static
/// constants are kept for compatibility with existing screen code.
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

  // Dark-mode neutrals
  static const Color _darkBackground = Color(0xFF0F1115);
  static const Color _darkSurface = Color(0xFF171A21);
  static const Color _darkSurfaceHigh = Color(0xFF232833);
  static const Color _darkOnSurface = Color(0xFFE4E6EB);
  static const Color _darkOutline = Color(0xFF3A404C);

  /// Secondary text/icon color that stays legible in both modes.
  static Color muted(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF9AA3B2)
          : const Color(0xFF5F6368);

  /// Card background that adapts to brightness.
  static Color card(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? _darkSurface
          : surface;

  static const _radius = 14.0;

  // ── Light ────────────────────────────────────────────────────────────
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: Color(0xFFBBDEFB),
      onPrimaryContainer: Color(0xFF0D47A1),
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: Color(0xFFB2DFDB),
      onSecondaryContainer: Color(0xFF004D40),
      error: error,
      onError: onError,
      background: background,
      onBackground: onBackground,
      surface: surface,
      onSurface: onSurface,
      outline: outline,
      surfaceVariant: Color(0xFFECEEF1),
      onSurfaceVariant: Color(0xFF5F6368),
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onPrimary,
        letterSpacing: 0.15,
      ),
    ),
    textTheme: _textTheme(onBackground, const Color(0xFF5F6368)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondary,
      foregroundColor: onSecondary,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: outline),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF1F3F5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF9AA0A6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: error, width: 2),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE4E7EB)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0xFF2B2F36),
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      elevation: 0,
      backgroundColor: surface,
      indicatorColor: primary.withOpacity(0.12),
      labelTextStyle: MaterialStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: mutedStatic),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE4E7EB)),
      ),
      backgroundColor: surface,
      labelStyle: const TextStyle(fontSize: 12, color: onSurface),
    ),
    dividerTheme: const DividerThemeData(color: Color(0xFFE4E7EB), thickness: 1),
    dialogTheme: DialogTheme(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),
  );

  // ── Dark ─────────────────────────────────────────────────────────────
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: Color(0xFF64B5F6),
      onPrimary: Color(0xFF0D253F),
      primaryContainer: Color(0xFF1E4B8F),
      onPrimaryContainer: Color(0xFFBBDEFB),
      secondary: Color(0xFF4DB6AC),
      onSecondary: Color(0xFF00332E),
      error: Color(0xFFCF6679),
      onError: Color(0xFF2B0000),
      background: _darkBackground,
      onBackground: _darkOnSurface,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      outline: _darkOutline,
      surfaceVariant: _darkSurfaceHigh,
      onSurfaceVariant: Color(0xFF9AA3B2),
    ),
    scaffoldBackgroundColor: _darkBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkBackground,
      foregroundColor: _darkOnSurface,
      elevation: 0,
      scrolledUnderElevation: 2,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _darkOnSurface,
        letterSpacing: 0.15,
      ),
    ),
    textTheme: _textTheme(_darkOnSurface, const Color(0xFF9AA3B2)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: secondary,
      foregroundColor: Color(0xFF00332E),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF64B5F6),
        foregroundColor: const Color(0xFF0D253F),
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF64B5F6),
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: _darkOutline),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: const Color(0xFF64B5F6),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: Color(0xFF64B5F6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: const BorderSide(color: error, width: 2),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: _darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _darkOutline),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _darkSurfaceHigh,
      contentTextStyle: TextStyle(color: _darkOnSurface, fontSize: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      height: 68,
      elevation: 0,
      backgroundColor: _darkSurface,
      indicatorColor: const Color(0xFF64B5F6).withOpacity(0.16),
      labelTextStyle: const MaterialStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _darkOnSurface),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: _darkOutline),
      ),
      backgroundColor: _darkSurfaceHigh,
      labelStyle: const TextStyle(fontSize: 12, color: _darkOnSurface),
    ),
    dividerTheme: const DividerThemeData(color: _darkOutline, thickness: 1),
    dialogTheme: DialogTheme(
      backgroundColor: _darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _darkSurface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),
  );

  /// Static muted tone for widgets that cannot access a BuildContext.
  static const Color mutedStatic = Color(0xFF5F6368);

  static TextTheme _textTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      headlineSmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w700, color: onSurface, letterSpacing: -0.5),
      titleLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: onSurface, letterSpacing: 0.15),
      bodyLarge: TextStyle(fontSize: 15, height: 1.4, color: onSurface),
      bodyMedium: TextStyle(fontSize: 14, height: 1.4, color: onSurface),
      bodySmall: TextStyle(fontSize: 12.5, height: 1.35, color: onSurfaceVariant),
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: onSurface, letterSpacing: 0.1),
      labelSmall: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w500, color: onSurfaceVariant, letterSpacing: 0.5),
    );
  }
}
