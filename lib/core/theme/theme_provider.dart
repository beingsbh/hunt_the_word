import 'package:flutter/material.dart';

import '../storage/hive_storage_service.dart';
import 'app_theme.dart';
import 'theme_palette.dart';

/// State management provider for active theme palette and dark mode toggling.
class ThemeProvider extends ChangeNotifier {
  final HiveStorageService _storage = HiveStorageService();

  late ThemePalette _activePalette;
  late Set<String> _unlockedThemeIds;
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final profile = _storage.getPlayerProfile();
    final activeId = profile['activeThemeId'] as String? ?? 'emerald_meadow';
    final unlocked = List<String>.from(
      profile['unlockedThemes'] as List? ??
          ['emerald_meadow', 'cosmic_midnight'],
    );

    _activePalette = ThemePalette.getById(activeId);
    _unlockedThemeIds = unlocked.toSet();
    _isDarkMode = _activePalette.isDark;
  }

  ThemePalette get activePalette => _activePalette;
  String get activeThemeId => _activePalette.id;
  Set<String> get unlockedThemeIds => _unlockedThemeIds;
  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => AppTheme.buildTheme(_activePalette);

  Future<void> setTheme(String paletteId) async {
    _activePalette = ThemePalette.getById(paletteId);
    _isDarkMode = _activePalette.isDark;

    final profile = _storage.getPlayerProfile();
    profile['activeThemeId'] = paletteId;
    await _storage.savePlayerProfile(profile);

    notifyListeners();
  }

  Future<bool> unlockTheme(String paletteId, int cost) async {
    if (_unlockedThemeIds.contains(paletteId)) return true;

    final profile = _storage.getPlayerProfile();
    final currentCoins = (profile['coins'] as num?)?.toInt() ?? 0;

    if (currentCoins < cost) return false;

    // Deduct coins and unlock
    profile['coins'] = currentCoins - cost;
    _unlockedThemeIds.add(paletteId);
    profile['unlockedThemes'] = _unlockedThemeIds.toList();
    profile['activeThemeId'] = paletteId;
    _activePalette = ThemePalette.getById(paletteId);
    _isDarkMode = _activePalette.isDark;

    await _storage.savePlayerProfile(profile);
    notifyListeners();
    return true;
  }

  Future<void> toggleDarkMode() async {
    if (_activePalette.id == ThemePalette.cosmicMidnight.id) {
      await setTheme(ThemePalette.emeraldMeadow.id);
    } else {
      await setTheme(ThemePalette.cosmicMidnight.id);
    }
  }
}
