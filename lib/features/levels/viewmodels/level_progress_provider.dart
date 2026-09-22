import 'package:flutter/material.dart';

import '../../../core/storage/hive_storage_service.dart';

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

/// Provider managing level map nodes, star totals, and chapter progress.
class LevelProgressProvider extends ChangeNotifier {
  final HiveStorageService _storage = HiveStorageService();

  int _currentWorld = 2; // World 2: Ocean Sanctuary (Active)
  int _activeLevel = 27; // Level 27 Coral Trench (Active in mockups)

  int get currentWorld => _currentWorld;
  int get activeLevel => _activeLevel;

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
        title: 'Coral Trench',
        description: 'Find 10 hidden sea words before time expires',
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

  void completeLevel(int levelNumber, int stars, int score) {
    _storage.saveLevelProgress(levelNumber, stars, score);
    if (levelNumber >= _activeLevel) {
      _activeLevel = levelNumber + 1;
    }
    notifyListeners();
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
