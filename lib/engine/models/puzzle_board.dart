import 'grid_coordinate.dart';
import 'word_placement.dart';

/// Complete puzzle board with matrix characters and word placements.
class PuzzleBoard {
  final int rows;
  final int cols;
  final List<List<String>> matrix;
  final List<WordPlacement> placements;

  const PuzzleBoard({
    required this.rows,
    required this.cols,
    required this.matrix,
    required this.placements,
  });

  bool get isComplete => placements.every((p) => p.isFound);
  int get totalWords => placements.length;
  int get foundWordsCount => placements.where((p) => p.isFound).length;

  /// Map of coordinate -> Color index for all found words.
  Map<GridCoordinate, int> get foundCoordinatesMap {
    final map = <GridCoordinate, int>{};
    for (final p in placements) {
      if (p.isFound) {
        for (final coord in p.coordinates) {
          map[coord] = p.colorIndex;
        }
      }
    }
    return map;
  }

  Map<String, dynamic> toMap() => {
        'rows': rows,
        'cols': cols,
        'matrix': matrix,
        'placements': placements.map((p) => p.toMap()).toList(),
      };

  factory PuzzleBoard.fromMap(Map<dynamic, dynamic> map) {
    final rawMatrix = map['matrix'] as List;
    final parsedMatrix = rawMatrix
        .map((row) => (row as List).map((cell) => cell.toString()).toList())
        .toList();

    final rawPlacements = map['placements'] as List;
    final parsedPlacements = rawPlacements
        .map((p) => WordPlacement.fromMap(p as Map))
        .toList();

    return PuzzleBoard(
      rows: (map['rows'] as num).toInt(),
      cols: (map['cols'] as num).toInt(),
      matrix: parsedMatrix,
      placements: parsedPlacements,
    );
  }
}
