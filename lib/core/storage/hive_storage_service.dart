import 'dart:async';

import 'package:hive_ce_flutter/hive_flutter.dart';

import 'storage_constants.dart';

/// Centralized local persistence service built on Hive CE.
class HiveStorageService {
  static final HiveStorageService _instance = HiveStorageService._internal();
  factory HiveStorageService() => _instance;
  HiveStorageService._internal();

  bool _initialized = false;
  Timer? _debounceSaveTimer;

  Box? _settingsBox;
  Box? _playerBox;
  Box? _levelsBox;
  Box? _activeGameBox;
  Box? _dailyBox;
  Box? _achievementsBox;

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    _settingsBox = await Hive.openBox(StorageConstants.settingsBox);
    _playerBox = await Hive.openBox(StorageConstants.playerBox);
    _levelsBox = await Hive.openBox(StorageConstants.levelsBox);
    _activeGameBox = await Hive.openBox(StorageConstants.activeGameBox);
    _dailyBox = await Hive.openBox(StorageConstants.dailyBox);
    _achievementsBox = await Hive.openBox(StorageConstants.achievementsBox);

    _initialized = true;
  }

  // --- Player Profile ---
  Map<String, dynamic> getPlayerProfile() {
    final raw = _playerBox?.get(StorageConstants.keyPlayerProfile);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    // Default values matching the high-fidelity mockups
    return {
      'nickname': 'Subha WordMaster',
      'playerTag': '#WH-9824',
      'playerTitle': 'Explorer Tier II',
      'playerLevel': 12,
      'coins': 1250,
      'totalStars': 78,
      'currentLevel': 27,
      'highestUnlockedLevel': 27,
      'streak': 7,
      'puzzlesSolved': 72,
      'wordsFound': 845,
      'accuracyRate': 94.2,
      'bestScore': 4820,
      'playTime': '18.5h',
      'activeThemeId': 'emerald_meadow',
      'unlockedThemes': ['emerald_meadow', 'cosmic_midnight'],
    };
  }

  Future<void> savePlayerProfile(Map<String, dynamic> profile) async {
    await _playerBox?.put(StorageConstants.keyPlayerProfile, profile);
  }

  Future<void> updateCoins(int delta) async {
    final profile = getPlayerProfile();
    final currentCoins = (profile['coins'] as num?)?.toInt() ?? 1250;
    profile['coins'] = (currentCoins + delta).clamp(0, 999999);
    await savePlayerProfile(profile);
  }

  // --- Active Game / Puzzle Resume ---
  Map<String, dynamic>? getActiveGame() {
    final raw = _activeGameBox?.get(StorageConstants.keyActivePuzzle);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  Future<void> saveActiveGame(Map<String, dynamic> gameData) async {
    await _activeGameBox?.put(StorageConstants.keyActivePuzzle, gameData);
  }

  /// Debounced auto-save so finding words during fast gameplay doesn't block UI frames.
  void debouncedSaveActiveGame(Map<String, dynamic> gameData) {
    _debounceSaveTimer?.cancel();
    _debounceSaveTimer = Timer(const Duration(milliseconds: 300), () {
      saveActiveGame(gameData);
    });
  }

  void cancelDebouncedSave() {
    _debounceSaveTimer?.cancel();
    _debounceSaveTimer = null;
  }

  Future<void> clearActiveGame() async {
    await _activeGameBox?.delete(StorageConstants.keyActivePuzzle);
  }

  // --- Level Progress ---
  Map<String, dynamic>? getLevelProgress(int levelNumber) {
    final raw = _levelsBox?.get('level_$levelNumber');
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  Future<void> saveLevelProgress(int levelNumber, int stars, int score) async {
    final existing = getLevelProgress(levelNumber);
    final previousStars = (existing?['stars'] as num?)?.toInt() ?? 0;
    final bestScore = (existing?['score'] as num?)?.toInt() ?? 0;

    await _levelsBox?.put('level_$levelNumber', {
      'levelNumber': levelNumber,
      'stars': stars > previousStars ? stars : previousStars,
      'score': score > bestScore ? score : bestScore,
      'isCompleted': true,
      'completedAt': DateTime.now().toIso8601String(),
    });

    // Advance highest unlocked level if this was the current highest
    final profile = getPlayerProfile();
    final currentHighest =
        (profile['highestUnlockedLevel'] as num?)?.toInt() ?? 1;
    if (levelNumber >= currentHighest) {
      profile['highestUnlockedLevel'] = levelNumber + 1;
      profile['currentLevel'] = levelNumber + 1;
      profile['puzzlesSolved'] =
          ((profile['puzzlesSolved'] as num?)?.toInt() ?? 0) + 1;
      await savePlayerProfile(profile);
    }
  }

  // --- Daily Challenge ---
  Map<String, dynamic> getDailyData() {
    final raw = _dailyBox?.get(StorageConstants.keyDailyData);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return {
      'streak': 7,
      'completedDates': <String>[
        '2024-09-16',
        '2024-09-17',
        '2024-09-18',
        '2024-09-19',
        '2024-09-20',
      ],
      'monthlyCount': 21,
    };
  }

  Future<void> markDailyCompleted(String dateStr) async {
    final data = getDailyData();
    final completed = List<String>.from(data['completedDates'] as List? ?? []);
    if (!completed.contains(dateStr)) {
      completed.add(dateStr);
      data['completedDates'] = completed;
      data['streak'] = ((data['streak'] as num?)?.toInt() ?? 0) + 1;
      data['monthlyCount'] = ((data['monthlyCount'] as num?)?.toInt() ?? 0) + 1;
      await _dailyBox?.put(StorageConstants.keyDailyData, data);
    }
  }

  // --- Achievements ---
  Set<String> getClaimedAchievements() {
    final raw = _achievementsBox?.get('claimed_ids');
    if (raw is List) {
      return Set<String>.from(raw);
    }
    return {'first_word', 'speed_solver'};
  }

  Future<void> claimAchievement(String id) async {
    final claimed = getClaimedAchievements();
    claimed.add(id);
    await _achievementsBox?.put('claimed_ids', claimed.toList());
  }

  // --- Settings ---
  Map<String, dynamic> getSettings() {
    final raw = _settingsBox?.get(StorageConstants.keySettings);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return {
      'soundFx': true,
      'music': true,
      'haptics': true,
      'notifications': true,
      'cloudSave': true,
    };
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    await _settingsBox?.put(StorageConstants.keySettings, settings);
  }
}
