import 'direction_vector.dart';
import 'grid_coordinate.dart';

/// Represents a word placed onto the grid with its coordinates and found state.
class WordPlacement {
  final String word;
  final List<GridCoordinate> coordinates;
  final DirectionVector direction;
  final bool isFound;
  final int colorIndex;

  const WordPlacement({
    required this.word,
    required this.coordinates,
    required this.direction,
    this.isFound = false,
    this.colorIndex = 0,
  });

  GridCoordinate get start => coordinates.first;
  GridCoordinate get end => coordinates.last;
  int get length => coordinates.length;

  WordPlacement copyWith({bool? isFound, int? colorIndex}) {
    return WordPlacement(
      word: word,
      coordinates: coordinates,
      direction: direction,
      isFound: isFound ?? this.isFound,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  Map<String, dynamic> toMap() => {
        'word': word,
        'coordinates': coordinates.map((c) => c.toMap()).toList(),
        'direction': direction.name,
        'isFound': isFound,
        'colorIndex': colorIndex,
      };

  factory WordPlacement.fromMap(Map<dynamic, dynamic> map) {
    return WordPlacement(
      word: map['word'] as String,
      coordinates: (map['coordinates'] as List)
          .map((c) => GridCoordinate.fromMap(c as Map))
          .toList(),
      direction: DirectionVector.values.firstWhere(
        (d) => d.name == map['direction'],
        orElse: () => DirectionVector.horizontalRight,
      ),
      isFound: map['isFound'] as bool? ?? false,
      colorIndex: (map['colorIndex'] as num?)?.toInt() ?? 0,
    );
  }
}
