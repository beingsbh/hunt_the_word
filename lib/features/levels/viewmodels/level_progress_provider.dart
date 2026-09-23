import 'package:flutter/material.dart';

import '../../../core/storage/hive_storage_service.dart';
import '../../sync/repositories/sync_repository.dart';
import '../models/world_model.dart';
import '../repositories/levels_repository.dart';

class LevelNodeState {
  final int levelNumber;
  final int stars;
  final int score;
  final bool isCompleted;
  final bool isUnlocked;
  final bool isCurrent;
  final String title;
  final String description;

  const LevelNodeState({
    required this.levelNumber,
    this.stars = 0,
    this.score = 0,
    this.isCompleted = false,
    this.isUnlocked = false,
    this.isCurrent = false,
    this.title = '',
    this.description = '',
  });
}

/// Provider managing level map nodes, star totals, chapter progress, and cloud sync.
class LevelProgressProvider extends ChangeNotifier {
  final HiveStorageService _storage;
  final LevelsRepository _levelsRepo;
  final SyncRepository _syncRepo;

  int _currentWorld = 2; // World 2: Ocean Sanctuary (Active)
  int _activeLevel = 27; // Level 27 Coral Trench (Active in mockups)
  List<WorldModel> _worlds = [];
  bool _isLoadingWorlds = false;

  LevelProgressProvider({
    HiveStorageService? storage,
    LevelsRepository? levelsRepository,
    SyncRepository? syncRepository,
  })  : _storage = storage ?? HiveStorageService(),
        _levelsRepo = levelsRepository ?? LevelsRepository(),
        _syncRepo = syncRepository ?? SyncRepository() {
    _loadFromStorage();
    _reconcileAndSync();
  }

  void _loadFromStorage() {
    final profile = _storage.getPlayerProfile();
    final highest = (profile['highestUnlockedLevel'] as num?)?.toInt() ?? 27;
    _activeLevel = highest;
    _currentWorld = ((_activeLevel - 1) ~/ 20) + 1;

    final cached = _storage.getCachedWorlds();
    if (cached != null && cached.isNotEmpty) {
      _worlds = cached.map((e) => WorldModel.fromJson(e)).toList();
    } else {
      _worlds = WorldModel.getDefaultWorlds(highestUnlockedLevel: _activeLevel);
    }
  }

  /// Silently synchronizes offline queued completions and fetches latest server progression map
  Future<void> _reconcileAndSync() async {
    try {
      await _syncRepo.reconcilePendingOfflineData();
      final levelMapFuture = _levelsRepo.fetchLevelMap();
      final worldsFuture = refreshWorlds();
      await Future.wait([levelMapFuture, worldsFuture]);
      _loadFromStorage();
      notifyListeners();
    } catch (_) {}
  }

  /// Refreshes worlds data from the backend API with offline caching
  Future<void> refreshWorlds() async {
    _isLoadingWorlds = true;
    notifyListeners();
    try {
      final fetchedWorlds = await _levelsRepo.fetchWorlds();
      if (fetchedWorlds.isNotEmpty) {
        _worlds = fetchedWorlds;
      }
    } catch (_) {
      // Keep existing cached worlds on failure
    } finally {
      _isLoadingWorlds = false;
      notifyListeners();
    }
  }

  void resetProgress() {
    _loadFromStorage();
    notifyListeners();
  }

  int get currentWorld => _currentWorld;
  int get activeLevel => _activeLevel;
  List<WorldModel> get worlds => _worlds;
  bool get isLoadingWorlds => _isLoadingWorlds;

  WorldModel get selectedWorld {
    if (_worlds.isNotEmpty) {
      final found = _worlds.where((w) => w.worldNumber == _currentWorld);
      if (found.isNotEmpty) return found.first;
      return _worlds.first;
    }
    final defaultWorlds =
        WorldModel.getDefaultWorlds(highestUnlockedLevel: _activeLevel);
    final found = defaultWorlds.where((w) => w.worldNumber == _currentWorld);
    if (found.isNotEmpty) return found.first;
    return defaultWorlds.first;
  }

  void setWorld(int world) {
    _currentWorld = world;
    notifyListeners();
  }

  /// Retrieves the state of a specific level node
  LevelNodeState getLevelNode(int levelNumber) {
    final saved = _storage.getLevelProgress(levelNumber);

    if (saved != null && (saved['isCompleted'] as bool? ?? false)) {
      return LevelNodeState(
        levelNumber: levelNumber,
        stars: (saved['stars'] as num?)?.toInt() ?? 3,
        score: (saved['score'] as num?)?.toInt() ?? 850,
        isCompleted: true,
        isUnlocked: true,
        isCurrent: false,
        title: _getLevelTitle(levelNumber),
        description: 'Level completed with mastery.',
      );
    }

    // Default mock progression from the design
    if (levelNumber < _activeLevel) {
      final stars = levelNumber == 26 ? 2 : 3;
      return LevelNodeState(
        levelNumber: levelNumber,
        stars: stars,
        score: 750 + (levelNumber * 10),
        isCompleted: true,
        isUnlocked: true,
        isCurrent: false,
        title: _getLevelTitle(levelNumber),
        description: 'Level completed with mastery.',
      );
    } else if (levelNumber == _activeLevel) {
      return LevelNodeState(
        levelNumber: levelNumber,
        stars: 0,
        score: 0,
        isCompleted: false,
        isUnlocked: true,
        isCurrent: true,
        title: _getLevelTitle(levelNumber),
        description: 'Find all hidden words before time expires',
      );
    } else {
      return LevelNodeState(
        levelNumber: levelNumber,
        stars: 0,
        score: 0,
        isCompleted: false,
        isUnlocked: false,
        isCurrent: false,
        title: _getLevelTitle(levelNumber),
        description: 'Locked level.',
      );
    }
  }

  /// Completes a level: immediately updates local state, then submits to server with offline fallback.
  void completeLevel(
    int levelNumber,
    int stars,
    int score, {
    double elapsedTime = 30.0,
    List<String>? wordsFound,
    List<List<String>>? grid,
  }) {
    // 1. Immediate local persistence
    _storage.saveLevelProgress(levelNumber, stars, score);

    if (levelNumber >= _activeLevel) {
      _activeLevel = levelNumber + 1;
      _currentWorld = ((_activeLevel - 1) ~/ 20) + 1;
      final profile = _storage.getPlayerProfile();
      profile['highestUnlockedLevel'] = _activeLevel;
      profile['currentLevel'] = _activeLevel;
      profile['playerLevel'] = _activeLevel;
      profile['puzzlesSolved'] =
          ((profile['puzzlesSolved'] as num?)?.toInt() ?? 0) + 1;
      _storage.savePlayerProfile(profile);
    }
    notifyListeners();

    // 2. Asynchronous API submission
    _levelsRepo
        .completeLevel(
          levelNumber: levelNumber,
          stars: stars,
          score: score,
          elapsedTime: elapsedTime,
          wordsFound: wordsFound ?? ['WORD', 'HUNT'],
          grid: grid,
        )
        .then((_) => refreshWorlds())
        .ignore();
  }

  /// Claims milestone mystery box reward
  Future<bool> claimMysteryBox(int levelNumber) async {
    final res = await _levelsRepo.claimMysteryBox(levelNumber);
    if (res.isSuccessful) {
      notifyListeners();
      return true;
    }
    return false;
  }

  String _getLevelTitle(int level) {
    const titles = [
      'Green Meadow',
      'Pine Grove',
      'Sunny Trail',
      'River Bend',
      'Birch Forest',
      'Wild Thicket',
      'Owl Perch',
      'Mossy Ridge',
      'Hidden Pond',
      'Cedar Crest',
      'Fern Hollow',
      'Oak Sanctuary',
      'Whispering Pines',
      'Timber Woods',
      'Timberland',
      'Clover Field',
      'Bramble Patch',
      'Canopy Walk',
      'Eagle Peak',
      'Forest Heart',
      'Tide Pool',
      'Coral Shelf',
      'Sunken Reef',
      'Azure Atoll',
      'Starfish Bay',
      'Kelp Forest',
      'Coral Trench',
      'Undersea Clues',
      'Mystery Depth',
      'Abyssal Gate',
    ];
    if (level > 0 && level <= titles.length) {
      return titles[level - 1];
    }
    return 'Level $level Quest';
  }
}
