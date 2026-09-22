import 'package:flutter/material.dart';

/// Represents a distinct color palette for the Word Hunt game.
class ThemePalette {
  final String id;
  final String name;
  final String description;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color cardColor;
  final Color cellBackgroundColor;
  final Color cellSelectedColor;
  final Color cellFoundColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color borderColor;
  final bool isDark;
  final bool isUnlockedDefault;
  final int coinCost;
  final List<Color> previewColors;

  const ThemePalette({
    required this.id,
    required this.name,
    required this.description,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.cardColor,
    required this.cellBackgroundColor,
    required this.cellSelectedColor,
    required this.cellFoundColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.borderColor,
    this.isDark = false,
    this.isUnlockedDefault = false,
    this.coinCost = 0,
    required this.previewColors,
  });

  static const ThemePalette emeraldMeadow = ThemePalette(
    id: 'emerald_meadow',
    name: 'Emerald Meadow',
    description: 'Crisp woodland greens with vibrant mint accents.',
    primaryColor: Color(0xFF10B981),
    secondaryColor: Color(0xFF059669),
    accentColor: Color(0xFF34D399),
    backgroundColor: Color(0xFFF0FDF4),
    surfaceColor: Color(0xFFFFFFFF),
    cardColor: Color(0xFFFFFFFF),
    cellBackgroundColor: Color(0xFFECFDF5),
    cellSelectedColor: Color(0xFF10B981),
    cellFoundColor: Color(0xFFD1FAE5),
    textPrimary: Color(0xFF064E3B),
    textSecondary: Color(0xFF047857),
    borderColor: Color(0xFFA7F3D0),
    isUnlockedDefault: true,
    coinCost: 0,
    previewColors: [Color(0xFF10B981), Color(0xFF34D399), Color(0xFF059669)],
  );

  static const ThemePalette cosmicMidnight = ThemePalette(
    id: 'cosmic_midnight',
    name: 'Cosmic Midnight',
    description: 'Deep starlight indigo with radiant neon purple.',
    primaryColor: Color(0xFF6C5CE7),
    secondaryColor: Color(0xFF5138EE),
    accentColor: Color(0xFF00F0FF),
    backgroundColor: Color(0xFF0B0E17),
    surfaceColor: Color(0xFF151928),
    cardColor: Color(0xFF1A1F36),
    cellBackgroundColor: Color(0xFF222845),
    cellSelectedColor: Color(0xFF6C5CE7),
    cellFoundColor: Color(0xFF312E81),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    borderColor: Color(0xFF3730A3),
    isDark: true,
    isUnlockedDefault: true,
    coinCost: 300,
    previewColors: [Color(0xFF6C5CE7), Color(0xFF00F0FF), Color(0xFF151928)],
  );

  static const ThemePalette sunsetWarmth = ThemePalette(
    id: 'sunset_warmth',
    name: 'Sunset Warmth',
    description: 'Golden hour amber, coral fire, and rich dusk tones.',
    primaryColor: Color(0xFFF97316),
    secondaryColor: Color(0xFFEA580C),
    accentColor: Color(0xFFFBBF24),
    backgroundColor: Color(0xFFFFFBEB),
    surfaceColor: Color(0xFFFFFFFF),
    cardColor: Color(0xFFFFFFFF),
    cellBackgroundColor: Color(0xFFFEF3C7),
    cellSelectedColor: Color(0xFFF97316),
    cellFoundColor: Color(0xFFFFEDD5),
    textPrimary: Color(0xFF7C2D12),
    textSecondary: Color(0xFF9A3412),
    borderColor: Color(0xFFFED7AA),
    coinCost: 500,
    previewColors: [Color(0xFFF97316), Color(0xFFFBBF24), Color(0xFFEA580C)],
  );

  static const ThemePalette oceanBreeze = ThemePalette(
    id: 'ocean_breeze',
    name: 'Ocean Breeze',
    description: 'Soothing marine cyan and deep sea aquatic waves.',
    primaryColor: Color(0xFF06B6D4),
    secondaryColor: Color(0xFF0891B2),
    accentColor: Color(0xFF38BDF8),
    backgroundColor: Color(0xFFF0F9FF),
    surfaceColor: Color(0xFFFFFFFF),
    cardColor: Color(0xFFFFFFFF),
    cellBackgroundColor: Color(0xFFE0F2FE),
    cellSelectedColor: Color(0xFF06B6D4),
    cellFoundColor: Color(0xFFBAE6FD),
    textPrimary: Color(0xFF0C4A6E),
    textSecondary: Color(0xFF0369A1),
    borderColor: Color(0xFFBAE6FD),
    coinCost: 500,
    previewColors: [Color(0xFF06B6D4), Color(0xFF38BDF8), Color(0xFF0891B2)],
  );

  static const ThemePalette candyRetro = ThemePalette(
    id: 'candy_retro',
    name: 'Candy Retro',
    description: 'Playful pop pink, sweet lavender, and vibrant arcade vibes.',
    primaryColor: Color(0xFFEC4899),
    secondaryColor: Color(0xFFDB2777),
    accentColor: Color(0xFFA855F7),
    backgroundColor: Color(0xFFFDF2F8),
    surfaceColor: Color(0xFFFFFFFF),
    cardColor: Color(0xFFFFFFFF),
    cellBackgroundColor: Color(0xFFFCE7F3),
    cellSelectedColor: Color(0xFFEC4899),
    cellFoundColor: Color(0xFFFBCFE8),
    textPrimary: Color(0xFF831843),
    textSecondary: Color(0xFFBE185D),
    borderColor: Color(0xFFFBCFE8),
    coinCost: 750,
    previewColors: [Color(0xFFEC4899), Color(0xFFA855F7), Color(0xFFFCE7F3)],
  );

  static const List<ThemePalette> allPalettes = [
    emeraldMeadow,
    cosmicMidnight,
    sunsetWarmth,
    oceanBreeze,
    candyRetro,
  ];

  static ThemePalette getById(String id) {
    return allPalettes.firstWhere(
      (p) => p.id == id,
      orElse: () => emeraldMeadow,
    );
  }
}
