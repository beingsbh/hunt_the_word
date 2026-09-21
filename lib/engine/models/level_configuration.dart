import 'direction_vector.dart';

/// Scalable level difficulty configuration model and generator.
class LevelConfiguration {
  final int levelNumber;
  final String category;
  final int gridRows;
  final int gridCols;
  final int wordCount;
  final int minWordLength;
  final int maxWordLength;
  final List<DirectionVector> allowedDirections;
  final bool allowOverlaps;
  final int timeLimitSeconds; // 0 for untimed
  final int coinReward;

  const LevelConfiguration({
    required this.levelNumber,
    required this.category,
    required this.gridRows,
    required this.gridCols,
    required this.wordCount,
    required this.minWordLength,
    required this.maxWordLength,
    required this.allowedDirections,
    this.allowOverlaps = true,
    this.timeLimitSeconds = 0,
    this.coinReward = 25,
  });

  /// Factory method generating progressive level difficulty based on level number.
  factory LevelConfiguration.forLevel(int level) {
    // Categories cycle across worlds
    final categories = [
      'Nature Walk',
      'Forest Flora',
      'Ocean Creatures',
      'Safari Quest',
      'Mountain Peak',
      'Cosmic Wonders',
      'Ancient Relics',
      'Desert Sands',
      'Deep Sea',
      'Sky Sanctuary',
    ];
    final category = categories[(level - 1) % categories.length];

    if (level <= 10) {
      // Levels 1-10: 5x5 grid, 3-4 words, horizontal and vertical
      return LevelConfiguration(
        levelNumber: level,
        category: category,
        gridRows: 5,
        gridCols: 5,
        wordCount: 3 + (level > 5 ? 1 : 0),
        minWordLength: 3,
        maxWordLength: 5,
        allowedDirections: const [
          DirectionVector.horizontalRight,
          DirectionVector.verticalDown,
        ],
        allowOverlaps: false,
        coinReward: 20,
      );
    } else if (level <= 25) {
      // Levels 11-25: 7x7 grid, 5-7 words, diagonal enabled
      final words = 5 + ((level - 11) ~/ 5);
      return LevelConfiguration(
        levelNumber: level,
        category: category,
        gridRows: 7,
        gridCols: 7,
        wordCount: words.clamp(5, 7),
        minWordLength: 3,
        maxWordLength: 6,
        allowedDirections: const [
          DirectionVector.horizontalRight,
          DirectionVector.verticalDown,
          DirectionVector.diagonalDownRight,
          DirectionVector.diagonalUpRight,
        ],
        allowOverlaps: true,
        coinReward: 25,
      );
    } else if (level <= 50) {
      // Levels 26-50: 9x9 grid, 8-10 words, overlapping words, reverse words
      final words = 8 + ((level - 26) ~/ 8);
      return LevelConfiguration(
        levelNumber: level,
        category: category,
        gridRows: 9,
        gridCols: 9,
        wordCount: words.clamp(8, 10),
        minWordLength: 4,
        maxWordLength: 7,
        allowedDirections: DirectionVector.values, // All 8 directions
        allowOverlaps: true,
        coinReward: 35,
      );
    } else {
      // Levels 51+: 10x10 or larger, 10-15 words, longer words
      final dimension = (10 + ((level - 51) ~/ 25)).clamp(10, 12);
      final words = (10 + ((level - 51) ~/ 10)).clamp(10, 15);
      return LevelConfiguration(
        levelNumber: level,
        category: category,
        gridRows: dimension,
        gridCols: dimension,
        wordCount: words,
        minWordLength: 4,
        maxWordLength: 8,
        allowedDirections: DirectionVector.values,
        allowOverlaps: true,
        coinReward: 50,
      );
    }
  }

  /// Special configuration for Daily Challenge
  factory LevelConfiguration.daily({
    required int seed,
    required String themeTitle,
  }) {
    return LevelConfiguration(
      levelNumber: 0,
      category: themeTitle,
      gridRows: 7,
      gridCols: 7,
      wordCount: 6,
      minWordLength: 4,
      maxWordLength: 6,
      allowedDirections: const [
        DirectionVector.horizontalRight,
        DirectionVector.verticalDown,
        DirectionVector.diagonalDownRight,
        DirectionVector.diagonalUpRight,
      ],
      allowOverlaps: true,
      timeLimitSeconds: 180, // 3:00 min
      coinReward: 50,
    );
  }
}
