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
  Box? _authBox;
  Box? _syncBox;

  Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    _settingsBox = await Hive.openBox(StorageConstants.settingsBox);
    _playerBox = await Hive.openBox(StorageConstants.playerBox);
    _levelsBox = await Hive.openBox(StorageConstants.levelsBox);
    _activeGameBox = await Hive.openBox(StorageConstants.activeGameBox);
    _dailyBox = await Hive.openBox(StorageConstants.dailyBox);
    _achievementsBox = await Hive.openBox(StorageConstants.achievementsBox);
    _authBox = await Hive.openBox(StorageConstants.authBox);
    _syncBox = await Hive.openBox(StorageConstants.syncBox);

    _initialized = true;
  }

  // --- Player Profile ---
  Map<String, dynamic> getPlayerProfile() {
    final raw = _playerBox?.get(StorageConstants.keyPlayerProfile);
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      if (map['nickname'] == 'Subha WordMaster') {
        map['nickname'] = 'Word Hunter';
        map['playerTag'] = '#WH-1001';
        map['playerTitle'] = 'Word Novice';
      }
      return map;
    }
    // Clean default values for fresh players
    return {
      'nickname': 'Word Hunter',
      'playerTag': '#WH-1001',
      'playerTitle': 'Word Novice',
      'playerLevel': 1,
      'coins': 100,
      'totalStars': 0,
      'currentLevel': 1,
      'highestUnlockedLevel': 1,
      'streak': 0,
      'puzzlesSolved': 0,
      'wordsFound': 0,
      'accuracyRate': 100.0,
      'bestScore': 0,
      'playTime': '0m',
      'activeThemeId': 'emerald_meadow',
      'unlockedThemes': ['emerald_meadow'],
      'hasSetUniqueUsername': false,
      'needsUsernameSetup': false,
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

  // --- World Progression ---
  List<Map<String, dynamic>>? getCachedWorlds() {
    final raw = _levelsBox?.get('cached_worlds');
    if (raw is List) {
      return raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    return null;
  }

  Future<void> saveWorlds(List<Map<String, dynamic>> worlds) async {
    await _levelsBox?.put('cached_worlds', worlds);
  }

  // --- Daily Challenge ---
  Map<String, dynamic> getDailyData() {
    final raw = _dailyBox?.get(StorageConstants.keyDailyData);
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final dates = List<String>.from(map['completedDates'] as List? ?? []);
      if (dates.any((d) => d.startsWith('2024-'))) {
        dates.removeWhere((d) => d.startsWith('2024-'));
        map['completedDates'] = dates;
      }
      return map;
    }
    return {
      'streak': 0,
      'completedDates': <String>[],
      'monthlyCount': 0,
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

  // --- Auth & Identity ---
  Map<String, dynamic>? getAuthTokens() {
    final raw = _authBox?.get(StorageConstants.keyAuthTokens);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  Future<void> saveAuthTokens(Map<String, dynamic> tokens) async {
    await _authBox?.put(StorageConstants.keyAuthTokens, tokens);
  }

  Future<void> clearAuthTokens() async {
    await _authBox?.delete(StorageConstants.keyAuthTokens);
  }

  String getDeviceId() {
    final saved = _authBox?.get(StorageConstants.keyDeviceId);
    if (saved is String && saved.isNotEmpty) {
      return saved;
    }
    final generated = 'device_${DateTime.now().millisecondsSinceEpoch}_${(1000 + (DateTime.now().microsecond % 9000))}';
    _authBox?.put(StorageConstants.keyDeviceId, generated);
    return generated;
  }

  // --- Offline Sync Queue ---
  List<Map<String, dynamic>> getPendingSyncLevels() {
    final raw = _syncBox?.get(StorageConstants.keyPendingSyncLevels);
    if (raw is List) {
      return raw.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    return [];
  }

  Future<void> addPendingSyncLevel(Map<String, dynamic> levelData) async {
    final list = getPendingSyncLevels();
    list.removeWhere((l) => l['levelNumber'] == levelData['levelNumber']);
    list.add(levelData);
    await _syncBox?.put(StorageConstants.keyPendingSyncLevels, list);
  }

  Future<void> clearPendingSyncLevels() async {
    await _syncBox?.delete(StorageConstants.keyPendingSyncLevels);
  }

  // --- Cached Achievements ---
  List<Map<String, dynamic>>? getCachedAchievements() {
    final raw = _playerBox?.get('cached_achievements');
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return null;
  }

  Future<void> saveCachedAchievements(List<Map<String, dynamic>> list) async {
    await _playerBox?.put('cached_achievements', list);
  }
}
