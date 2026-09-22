import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_spacing.dart';
import 'theme_palette.dart';

/// Builder for Word Hunt Material 3 theme data.
class AppTheme {
  AppTheme._();

  static ThemeData buildTheme(ThemePalette palette) {
    final isDark = palette.isDark;
    final brightness = isDark ? Brightness.dark : Brightness.light;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: palette.primaryColor,
      onPrimary: Colors.white,
      primaryContainer: palette.primaryColor.withValues(alpha: 0.15),
      onPrimaryContainer: palette.primaryColor,
      secondary: palette.secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: palette.secondaryColor.withValues(alpha: 0.15),
      onSecondaryContainer: palette.secondaryColor,
      tertiary: palette.accentColor,
      onTertiary: Colors.white,
      surface: palette.surfaceColor,
      onSurface: palette.textPrimary,
      surfaceContainerHighest: palette.cellBackgroundColor,
      outline: palette.borderColor,
      outlineVariant: palette.borderColor.withValues(alpha: 0.5),
      error: const Color(0xFFEF4444),
      onError: Colors.white,
    );

    final textTheme =
        GoogleFonts.plusJakartaSansTextTheme(
          ThemeData(brightness: brightness).textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.outfit(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary,
          ),
          displayMedium: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: palette.textPrimary,
          ),
          displaySmall: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
          headlineLarge: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
          headlineMedium: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
          headlineSmall: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
          titleLarge: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
          titleMedium: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: palette.textPrimary,
          ),
          bodyLarge: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: palette.textPrimary,
          ),
          bodyMedium: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: palette.textSecondary,
          ),
          bodySmall: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: palette.textSecondary,
          ),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.backgroundColor,
      cardColor: palette.cardColor,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: palette.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLg,
          side: BorderSide(color: palette.borderColor.withValues(alpha: 0.5)),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
        iconTheme: IconThemeData(color: palette.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primaryColor,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primaryColor,
          side: BorderSide(color: palette.borderColor),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusPill),
          textStyle: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.borderColor.withValues(alpha: 0.3),
        thickness: 1,
      ),
    );
  }
}
