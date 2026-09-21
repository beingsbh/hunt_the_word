import '../models/direction_vector.dart';
import '../models/grid_coordinate.dart';
import '../models/puzzle_board.dart';
import '../models/word_placement.dart';

class HintResult {
  final WordPlacement targetPlacement;
  final GridCoordinate highlightedCoordinate;
  final DirectionVector? direction;

  const HintResult({
    required this.targetPlacement,
    required this.highlightedCoordinate,
    this.direction,
  });
}

/// Provides hints by inspecting remaining unfound words on the board.
class HintSolver {
  HintSolver._();

  /// Returns the starting letter coordinate of the first unfound word.
  static HintResult? getLetterHint(PuzzleBoard board) {
    for (final placement in board.placements) {
      if (!placement.isFound) {
        return HintResult(
          targetPlacement: placement,
          highlightedCoordinate: placement.coordinates.first,
          direction: placement.direction,
        );
      }
    }
    return null;
  }

  /// Returns the full coordinates of the first unfound word for auto-solving.
  static WordPlacement? getWordSolveHint(PuzzleBoard board) {
    for (final placement in board.placements) {
      if (!placement.isFound) {
        return placement;
      }
    }
    return null;
  }
}
