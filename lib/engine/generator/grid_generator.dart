import 'dart:math';
import '../dictionary/category_vocabulary.dart';
import '../models/direction_vector.dart';
import '../models/grid_coordinate.dart';
import '../models/level_configuration.dart';
import '../models/puzzle_board.dart';
import '../models/word_placement.dart';

/// Algorithmic generator producing dense, solvable Word Search puzzle boards.
class GridGenerator {
  static const int _maxRetries = 40;

  // Weighted distribution of English letters for filling empty cells
  static const String _letterPool =
      'EEEEEEEEEEEETTTTTTTTTAAAAAAAAAIIIIIIIIOOOOOOOONNNNNNNSSSSSSSHHHHHHRRRRRR'
      'DDDDLLLLCCCCUUUUMMMMWWWFGGYYPPBBVKJXQZ';

  /// Generates a complete PuzzleBoard given a LevelConfiguration and optional seed.
  static PuzzleBoard generate(LevelConfiguration config, {int? seed}) {
    final random = seed != null ? Random(seed) : Random();

    for (int attempt = 0; attempt < _maxRetries; attempt++) {
      final board = _tryGenerateBoard(config, random);
      if (board != null) {
        return board;
      }
    }

    // Fallback: guaranteed generation if tight space
    return _generateFallbackBoard(config, random);
  }

  static PuzzleBoard? _tryGenerateBoard(
    LevelConfiguration config,
    Random random,
  ) {
    final rows = config.gridRows;
    final cols = config.gridCols;

    // Initialize blank matrix
    final matrix = List.generate(rows, (_) => List.filled(cols, ''));

    // Fetch candidate vocabulary
    final candidateWords = List<String>.from(
      CategoryVocabulary.getWordsForCategory(
        config.category,
        minLength: config.minWordLength,
        maxLength: config.maxWordLength,
      ),
    );

    if (candidateWords.length < config.wordCount) {
      candidateWords.addAll(CategoryVocabulary.generalWords);
    }

    candidateWords.shuffle(random);
    final targetWords = candidateWords.take(config.wordCount).toList();

    // Sort words by length descending (longest words are hardest to fit, place them first)
    targetWords.sort((a, b) => b.length.compareTo(a.length));

    final placements = <WordPlacement>[];

    for (int i = 0; i < targetWords.length; i++) {
      final word = targetWords[i];
      final placement = _placeWord(
        word: word,
        matrix: matrix,
        allowedDirections: config.allowedDirections,
        allowOverlaps: config.allowOverlaps,
        colorIndex: i % 8,
        random: random,
      );

      if (placement == null) {
        // Failed to place this word, abort attempt to retry with fresh board
        return null;
      }

      placements.add(placement);
    }

    // Fill remaining empty cells with weighted distribution
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (matrix[r][c].isEmpty) {
          matrix[r][c] = _letterPool[random.nextInt(_letterPool.length)];
        }
      }
    }

    return PuzzleBoard(
      rows: rows,
      cols: cols,
      matrix: matrix,
      placements: placements,
    );
  }

  static WordPlacement? _placeWord({
    required String word,
    required List<List<String>> matrix,
    required List<DirectionVector> allowedDirections,
    required bool allowOverlaps,
    required int colorIndex,
    required Random random,
  }) {
    final rows = matrix.length;
    final cols = matrix[0].length;

    // Generate all valid starting points and directions
    final candidatePositions = <_PlacementCandidate>[];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        for (final dir in allowedDirections) {
          final endRow = r + (dir.dRow * (word.length - 1));
          final endCol = c + (dir.dCol * (word.length - 1));

          // Check boundary limits
          if (endRow >= 0 && endRow < rows && endCol >= 0 && endCol < cols) {
            // Check collisions and letter overlaps
            bool canPlace = true;
            int overlapScore = 0;

            for (int i = 0; i < word.length; i++) {
              final curR = r + (dir.dRow * i);
              final curC = c + (dir.dCol * i);
              final existingChar = matrix[curR][curC];

              if (existingChar.isNotEmpty) {
                if (!allowOverlaps || existingChar != word[i]) {
                  canPlace = false;
                  break;
                } else {
                  overlapScore++; // Prefer positions that intersect existing words!
                }
              }
            }

            if (canPlace) {
              candidatePositions.add(_PlacementCandidate(
                startRow: r,
                startCol: c,
                direction: dir,
                overlapScore: overlapScore,
              ));
            }
          }
        }
      }
    }

    if (candidatePositions.isEmpty) {
      return null;
    }

    // Sort to prioritize positions with higher overlapping intersections
    candidatePositions.sort((a, b) => b.overlapScore.compareTo(a.overlapScore));

    // Choose from top candidates randomly to keep variety
    final topPoolSize = min(5, candidatePositions.length);
    final chosen = candidatePositions[random.nextInt(topPoolSize)];

    final coords = <GridCoordinate>[];
    for (int i = 0; i < word.length; i++) {
      final r = chosen.startRow + (chosen.direction.dRow * i);
      final c = chosen.startCol + (chosen.direction.dCol * i);
      matrix[r][c] = word[i];
      coords.add(GridCoordinate(r, c));
    }

    return WordPlacement(
      word: word,
      coordinates: coords,
      direction: chosen.direction,
      colorIndex: colorIndex,
    );
  }

  static PuzzleBoard _generateFallbackBoard(
    LevelConfiguration config,
    Random random,
  ) {
    final rows = config.gridRows;
    final cols = config.gridCols;
    final matrix = List.generate(rows, (_) => List.filled(cols, ''));
    final words = ['HUNT', 'WORD', 'PLAY', 'FIND'].take(config.wordCount).toList();
    final placements = <WordPlacement>[];

    for (int r = 0; r < min(words.length, rows); r++) {
      final word = words[r];
      final coords = <GridCoordinate>[];
      for (int c = 0; c < word.length && c < cols; c++) {
        matrix[r][c] = word[c];
        coords.add(GridCoordinate(r, c));
      }
      placements.add(WordPlacement(
        word: word,
        coordinates: coords,
        direction: DirectionVector.horizontalRight,
        colorIndex: r % 8,
      ));
    }

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (matrix[r][c].isEmpty) {
          matrix[r][c] = _letterPool[random.nextInt(_letterPool.length)];
        }
      }
    }

    return PuzzleBoard(rows: rows, cols: cols, matrix: matrix, placements: placements);
  }
}

class _PlacementCandidate {
  final int startRow;
  final int startCol;
  final DirectionVector direction;
  final int overlapScore;

  _PlacementCandidate({
    required this.startRow,
    required this.startCol,
    required this.direction,
    required this.overlapScore,
  });
}
