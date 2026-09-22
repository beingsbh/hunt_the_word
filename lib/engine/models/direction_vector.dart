import 'grid_coordinate.dart';

/// 8 directional vectors for word search placement and ray validation.
enum DirectionVector {
  horizontalRight(0, 1),
  horizontalLeft(0, -1),
  verticalDown(1, 0),
  verticalUp(-1, 0),
  diagonalDownRight(1, 1),
  diagonalDownLeft(1, -1),
  diagonalUpRight(-1, 1),
  diagonalUpLeft(-1, -1);

  final int dRow;
  final int dCol;

  const DirectionVector(this.dRow, this.dCol);

  bool get isHorizontal => dRow == 0;
  bool get isVertical => dCol == 0;
  bool get isDiagonal => dRow.abs() == 1 && dCol.abs() == 1;
  bool get isReverse => dRow < 0 || (dRow == 0 && dCol < 0);

  /// Helper groupings for level constraints and testing
  static const List<DirectionVector> horizontalDirections = [
    horizontalRight,
    horizontalLeft,
  ];

  static const List<DirectionVector> verticalDirections = [
    verticalDown,
    verticalUp,
  ];

  static const List<DirectionVector> diagonalDirections = [
    diagonalDownRight,
    diagonalDownLeft,
    diagonalUpRight,
    diagonalUpLeft,
  ];

  static const List<DirectionVector> reverseDirections = [
    horizontalLeft,
    verticalUp,
    diagonalDownLeft,
    diagonalUpRight,
    diagonalUpLeft,
  ];

  static const List<DirectionVector> standardDirections = [
    horizontalRight,
    verticalDown,
    diagonalDownRight,
  ];

  /// Computes the straight ray of coordinates from start to end if they align with this vector.
  static List<GridCoordinate>? getRayBetween(
    GridCoordinate start,
    GridCoordinate end,
  ) {
    final dR = end.row - start.row;
    final dC = end.col - start.col;

    if (dR == 0 && dC == 0) {
      return [start];
    }

    final stepRow = dR == 0 ? 0 : (dR > 0 ? 1 : -1);
    final stepCol = dC == 0 ? 0 : (dC > 0 ? 1 : -1);

    // Verify straight line (either horizontal, vertical, or perfectly 45-degree diagonal)
    if (dR != 0 && dC != 0 && dR.abs() != dC.abs()) {
      return null;
    }

    final length = dR != 0 ? dR.abs() + 1 : dC.abs() + 1;
    final ray = <GridCoordinate>[];

    for (int i = 0; i < length; i++) {
      ray.add(
        GridCoordinate(start.row + (i * stepRow), start.col + (i * stepCol)),
      );
    }

    return ray;
  }
}
