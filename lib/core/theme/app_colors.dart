import 'package:flutter/material.dart';

/// Semantic colors and palette constants for Word Hunt.
class AppColors {
  AppColors._();

  // Brand / Core Accents
  static const Color primaryPurple = Color(0xFF6C5CE7);
  static const Color primaryDarkPurple = Color(0xFF5138EE);
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color primaryCyan = Color(0xFF06B6D4);

  // Rewards & Metals
  static const Color coinGold = Color(0xFFFFB800);
  static const Color coinGoldLight = Color(0xFFFFD54F);
  static const Color coinGoldDark = Color(0xFFD97706);

  static const Color starActive = Color(0xFFFFC107);
  static const Color starInactive = Color(0xFFCBD5E1);

  // Feedback
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Word Highlights (8 harmonious colors for discovered words)
  static const List<Color> wordHighlights = [
    Color(0xFF06B6D4), // Cyan
    Color(0xFF6C5CE7), // Purple
    Color(0xFF10B981), // Emerald
    Color(0xFFF97316), // Coral / Orange
    Color(0xFFEC4899), // Pink
    Color(0xFFEAB308), // Yellow
    Color(0xFF8B5CF6), // Violet
    Color(0xFF14B8A6), // Teal
  ];
}
