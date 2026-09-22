import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography hierarchy for Word Hunt.
/// Uses Outfit for punchy game headings and Plus Jakarta Sans for readable UI text.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle displayLarge({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 36,
    fontWeight: fontWeight ?? FontWeight.w800,
    color: color,
    letterSpacing: -0.5,
  );

  static TextStyle displayMedium({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 28,
    fontWeight: fontWeight ?? FontWeight.w800,
    color: color,
    letterSpacing: -0.5,
  );

  static TextStyle displaySmall({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 24,
    fontWeight: fontWeight ?? FontWeight.w700,
    color: color,
    letterSpacing: -0.3,
  );

  static TextStyle headlineLarge({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 22,
    fontWeight: fontWeight ?? FontWeight.w700,
    color: color,
  );

  static TextStyle headlineMedium({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 18,
    fontWeight: fontWeight ?? FontWeight.w700,
    color: color,
  );

  static TextStyle headlineSmall({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 16,
    fontWeight: fontWeight ?? FontWeight.w600,
    color: color,
  );

  static TextStyle titleLarge({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 15,
    fontWeight: fontWeight ?? FontWeight.w600,
    color: color,
  );

  static TextStyle titleMedium({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 14,
    fontWeight: fontWeight ?? FontWeight.w600,
    color: color,
  );

  static TextStyle titleSmall({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 12,
    fontWeight: fontWeight ?? FontWeight.w600,
    color: color,
  );

  static TextStyle bodyLarge({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: fontSize ?? 16,
    fontWeight: fontWeight ?? FontWeight.w500,
    color: color,
  );

  static TextStyle bodyMedium({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: fontSize ?? 14,
    fontWeight: fontWeight ?? FontWeight.w400,
    color: color,
  );

  static TextStyle bodySmall({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: fontSize ?? 12,
    fontWeight: fontWeight ?? FontWeight.w400,
    color: color,
  );

  static TextStyle buttonLarge({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 16,
    fontWeight: fontWeight ?? FontWeight.w700,
    letterSpacing: 0.5,
    color: color,
  );

  static TextStyle buttonMedium({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 14,
    fontWeight: fontWeight ?? FontWeight.w700,
    letterSpacing: 0.3,
    color: color,
  );

  static TextStyle buttonSmall({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) => GoogleFonts.outfit(
    fontSize: fontSize ?? 12,
    fontWeight: fontWeight ?? FontWeight.w600,
    letterSpacing: 0.2,
    color: color,
  );
}
