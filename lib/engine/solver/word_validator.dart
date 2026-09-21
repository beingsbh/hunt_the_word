import '../models/grid_coordinate.dart';
import '../models/puzzle_board.dart';
import '../models/word_placement.dart';

/// Validates user letter selections against the puzzle board solutions.
class WordValidator {
  WordValidator._();

  /// Checks if [coordinates] match any unfound word on the [board].
  /// Supports forward selection as well as backward (reverse) dragging.
  static WordPlacement? matchSelection({
    required List<GridCoordinate> coordinates,
    required PuzzleBoard board,
  }) {
    if (coordinates.isEmpty) return null;

    for (final placement in board.placements) {
      if (placement.isFound) continue;

      if (placement.length != coordinates.length) continue;

      // Check forward match
      bool forwardMatch = true;
      for (int i = 0; i < coordinates.length; i++) {
        if (placement.coordinates[i] != coordinates[i]) {
          forwardMatch = false;
          break;
        }
      }
      if (forwardMatch) return placement;

      // Check reverse match (player dragged from word end to start)
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
}
