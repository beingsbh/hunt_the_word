import '../models/direction_vector.dart';
import '../models/grid_coordinate.dart';
import '../models/puzzle_board.dart';
import '../models/word_detection_result.dart';
import '../models/word_placement.dart';

/// Validates user letter selections against puzzle board solutions.
class WordValidator {
  WordValidator._();

  /// Validates a selection between [start] and [end] coordinates on the [board].
  ///
  /// Calculates the selected cells, converts them into a string, checks both
  /// normal and reverse word against target placements, and returns a structured
  /// [WordDetectionResult].
  static WordDetectionResult validateSelection({
    required PuzzleBoard board,
    required GridCoordinate start,
    required GridCoordinate end,
  }) {
    // 1. Validate boundary limits
    if (!_isWithinBounds(board, start) || !_isWithinBounds(board, end)) {
      return WordDetectionResult.outOfBounds(
        start: start,
        end: end,
        message: 'Coordinate ($start or $end) is outside board boundaries '
            '(${board.rows}x${board.cols})',
      );
    }

    // 2. Compute straight-line ray between start and end
    final ray = DirectionVector.getRayBetween(start, end);
    if (ray == null) {
      return WordDetectionResult.invalidLine(
        start: start,
        end: end,
        message: 'Coordinates $start and $end do not form a straight '
            'horizontal, vertical, or diagonal ray.',
      );
    }

    // 3. Convert cells into normal and reverse strings
    final normalWord = ray.map((c) => board.matrix[c.row][c.col]).join();
    final reverseWord = normalWord.split('').reversed.join();

    // 4. Check against all target placements on the board
    for (final placement in board.placements) {
      if (placement.length != ray.length) continue;

      // Check forward match (ray coordinates match placement coordinates)
      bool forwardMatch = true;
      for (int i = 0; i < ray.length; i++) {
        if (placement.coordinates[i] != ray[i]) {
          forwardMatch = false;
          break;
        }
      }
      if (forwardMatch && placement.word == normalWord) {
        return WordDetectionResult.match(
          coordinates: ray,
          normalWord: normalWord,
          reverseWord: reverseWord,
          matchedPlacement: placement,
          isReverseMatch: false,
        );
      }

      // Check reverse match (ray matches reverse of placement coordinates)
      bool reverseMatch = true;
      for (int i = 0; i < ray.length; i++) {
        if (placement.coordinates[placement.length - 1 - i] != ray[i]) {
          reverseMatch = false;
          break;
        }
      }
      if (reverseMatch && placement.word == reverseWord) {
        return WordDetectionResult.match(
          coordinates: ray,
          normalWord: normalWord,
          reverseWord: reverseWord,
          matchedPlacement: placement,
          isReverseMatch: true,
        );
      }
    }

    // 5. No target placement matched
    return WordDetectionResult.noMatch(
      coordinates: ray,
      normalWord: normalWord,
      reverseWord: reverseWord,
    );
  }

  /// Checks if [coordinates] match any unfound word on the [board].
  ///
  /// Supports forward selection as well as backward (reverse) dragging.
  /// Maintained for backwards compatibility with presentation viewmodels.
  static WordPlacement? matchSelection({
    required List<GridCoordinate> coordinates,
    required PuzzleBoard board,
  }) {
    if (coordinates.isEmpty) return null;

    if (coordinates.length >= 2) {
      final result = validateSelection(
        board: board,
        start: coordinates.first,
        end: coordinates.last,
      );
      if (result.isMatch &&
          result.length == coordinates.length &&
          !result.matchedPlacement!.isFound) {
        return result.matchedPlacement;
      }
    }

    // Fallback coordinate-by-coordinate comparison for ad-hoc collections
    for (final placement in board.placements) {
      if (placement.isFound) continue;
      if (placement.length != coordinates.length) continue;

      bool forwardMatch = true;
      for (int i = 0; i < coordinates.length; i++) {
        if (placement.coordinates[i] != coordinates[i]) {
          forwardMatch = false;
          break;
        }
      }
      if (forwardMatch) return placement;

      bool reverseMatch = true;
      for (int i = 0; i < coordinates.length; i++) {
        if (placement.coordinates[placement.length - 1 - i] != coordinates[i]) {
          reverseMatch = false;
          break;
        }
      }
      if (reverseMatch) return placement;
    }

    return null;
  }

  static bool _isWithinBounds(PuzzleBoard board, GridCoordinate c) {
    return c.row >= 0 && c.row < board.rows && c.col >= 0 && c.col < board.cols;
  }
}
