import 'dart:math';

import '../dictionary/category_vocabulary.dart';
import '../models/direction_vector.dart';
import '../models/grid_coordinate.dart';
import '../models/level_configuration.dart';
import '../models/puzzle_board.dart';
import '../models/word_placement.dart';
import '../models/word_placement_exception.dart';

/// Algorithmic generator producing dense, solvable Word Search puzzle boards.
class GridGenerator {
  static const int _defaultMaxRetries = 100;

  // Weighted distribution of English letters for filling empty cells
  static const String _letterPool =
      'EEEEEEEEEEEETTTTTTTTTAAAAAAAAAIIIIIIIIOOOOOOOONNNNNNNSSSSSSSHHHHHHRRRRRR'
      'DDDDLLLLCCCCUUUUMMMMWWWFGGYYPPBBVKJXQZ';

  /// Generates a complete PuzzleBoard given a [config] and optional custom [words] and [seed].
  ///
  /// Throws [WordPlacementException] if a word is longer than the grid or if placement
  /// cannot be satisfied after [maxRetries] attempts.
  static PuzzleBoard generate(
    LevelConfiguration config, {
    List<String>? words,
    int? seed,
    int maxRetries = _defaultMaxRetries,
  }) {
    final random = seed != null ? Random(seed) : Random();
    final rows = config.gridRows;
    final cols = config.gridCols;

    if (rows <= 0 || cols <= 0) {
      throw const WordPlacementException('Grid dimensions must be positive');
    }

    // Handle explicit empty word list
    if (words != null && words.isEmpty) {
      final emptyMatrix = List.generate(
        rows,
        (_) => List.generate(
          cols,
          (_) => _letterPool[random.nextInt(_letterPool.length)],
        ),
      );
      return PuzzleBoard(
        rows: rows,
        cols: cols,
        matrix: emptyMatrix,
        placements: const [],
      );
    }

    // Prepare and sanitize target words
    List<String> targetWords;
    if (words != null) {
      // Sanitize: trim, uppercase, remove empty, deduplicate while preserving order
      final seen = <String>{};
      targetWords = [];
      for (final w in words) {
        final clean = w.trim().toUpperCase();
        if (clean.isNotEmpty && seen.add(clean)) {
          targetWords.add(clean);
        }
      }
    } else {
      targetWords = _selectVocabularyWords(config, random);
    }

    // Geometrical validity check: verify each word can theoretically fit on the grid
    for (final word in targetWords) {
      _validateWordFitsGrid(word, rows, cols, config.allowedDirections);
    }

    // Attempt generation with retries
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      final board = _tryGenerateBoard(
        config: config,
        targetWords: targetWords,
        random: random,
      );
      if (board != null) {
        return board;
      }
    }

    // If explicit words were provided and failed, throw WordPlacementException
    if (words != null) {
      throw WordPlacementException(
        'Failed to place all target words within the grid after $maxRetries attempts: ${targetWords.join(", ")}',
      );
    }

    // For auto-generated levels, attempt fallback if vocabulary configuration was tight
    return _generateFallbackBoard(config, random);
  }

  static void _validateWordFitsGrid(
    String word,
    int rows,
    int cols,
    List<DirectionVector> allowedDirections,
  ) {
    if (word.length > max(rows, cols)) {
      throw WordPlacementException(
        'Word "$word" (length ${word.length}) exceeds grid dimensions (${rows}x$cols)',
        word: word,
      );
    }

    // Check if at least one allowed direction can accommodate this word length
    bool canFitInAnyDirection = false;
    for (final dir in allowedDirections) {
      if (dir.isHorizontal && word.length <= cols) {
        canFitInAnyDirection = true;
        break;
      }
      if (dir.isVertical && word.length <= rows) {
        canFitInAnyDirection = true;
        break;
      }
      if (dir.isDiagonal && word.length <= rows && word.length <= cols) {
        canFitInAnyDirection = true;
        break;
      }
    }

    if (!canFitInAnyDirection) {
      throw WordPlacementException(
        'Word "$word" cannot fit within ${rows}x$cols grid under the allowed directions',
        word: word,
      );
    }
  }

  static List<String> _selectVocabularyWords(
    LevelConfiguration config,
    Random random,
  ) {
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
    return candidateWords.take(config.wordCount).toList();
  }

  static PuzzleBoard? _tryGenerateBoard({
    required LevelConfiguration config,
    required List<String> targetWords,
    required Random random,
  }) {
    final rows = config.gridRows;
    final cols = config.gridCols;

    // Initialize blank matrix
    final matrix = List.generate(rows, (_) => List.filled(cols, ''));

    // Sort words by length descending (longest words are hardest to fit, place them first)
    final wordsToPlace = List<String>.from(targetWords);
    wordsToPlace.sort((a, b) => b.length.compareTo(a.length));

    final placements = <WordPlacement>[];

    for (int i = 0; i < wordsToPlace.length; i++) {
      final word = wordsToPlace[i];
      final placement = _placeWord(
        word: word,
        matrix: matrix,
        allowedDirections: config.allowedDirections,
        allowOverlaps: config.allowOverlaps,
        colorIndex: i % 8,
        random: random,
      );

      if (placement == null) {
        // Failed to place this word, abort this attempt
        return null;
      }

      placements.add(placement);
    }

    // Fill remaining empty cells with weighted letter distribution
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
                  overlapScore++; // Valid intersection!
                }
              }
            }

            if (canPlace) {
              candidatePositions.add(
                _PlacementCandidate(
                  startRow: r,
                  startCol: c,
                  direction: dir,
                  overlapScore: overlapScore,
                ),
              );
            }
          }
        }
      }
    }

    if (candidatePositions.isEmpty) {
      return null;
    }

    // Shuffle candidates first using random so equal scores are evenly dispersed
    candidatePositions.shuffle(random);

    // Sort to prioritize positions with higher overlapping intersections if overlaps are allowed
    if (allowOverlaps) {
      candidatePositions.sort((a, b) => b.overlapScore.compareTo(a.overlapScore));
    }

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
    final words = [
      'HUNT',
      'WORD',
      'PLAY',
      'FIND',
    ].take(config.wordCount).toList();
    final placements = <WordPlacement>[];

    for (int r = 0; r < min(words.length, rows); r++) {
      final word = words[r];
      final coords = <GridCoordinate>[];
      for (int c = 0; c < word.length && c < cols; c++) {
        matrix[r][c] = word[c];
        coords.add(GridCoordinate(r, c));
      }
      placements.add(
        WordPlacement(
          word: word,
          coordinates: coords,
          direction: DirectionVector.horizontalRight,
          colorIndex: r % 8,
        ),
      );
    }

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
