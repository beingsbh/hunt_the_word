import 'grid_coordinate.dart';
import 'word_placement.dart';

/// Status classification for word selection detection.
enum WordDetectionStatus {
  /// The selected cells match an unfound target word on the board.
  match,

  /// The selected cells match a target word that was already found previously.
  alreadyFound,

  /// The selected cells form a valid straight line but do not match any target word.
  noMatch,

  /// The start and end coordinates do not form a straight horizontal, vertical, or diagonal ray.
  invalidLine,

  /// The start or end coordinate falls outside the puzzle board boundaries.
  outOfBounds,
}

/// Structured result returned when validating a word selection between two coordinates.
class WordDetectionResult {
  /// Whether the selection forms a valid straight ray (horizontal, vertical, or diagonal).
  final bool isValidLine;

  /// The ordered list of coordinates from start to end.
  final List<GridCoordinate> coordinates;

  /// The string of letters formed by reading the cells from start to end.
  final String normalWord;

  /// The reversed string of letters formed by reading the cells from end to start.
  final String reverseWord;

  /// The matching [WordPlacement] on the board, if any.
  final WordPlacement? matchedPlacement;

  /// Whether a valid target word was matched on the board.
  final bool isMatch;

  /// Whether the match was detected via reverse direction.
  final bool isReverseMatch;

  /// Detailed status code for this detection attempt.
  final WordDetectionStatus status;

  /// Human-readable explanation of an error or failure, if any.
  final String? errorMessage;

  const WordDetectionResult({
    required this.isValidLine,
    required this.coordinates,
    required this.normalWord,
    required this.reverseWord,
    required this.matchedPlacement,
    required this.isMatch,
    required this.isReverseMatch,
    required this.status,
    this.errorMessage,
  });

  /// Factory for selections outside board boundaries.
  factory WordDetectionResult.outOfBounds({
    required GridCoordinate start,
    required GridCoordinate end,
    required String message,
  }) {
    return WordDetectionResult(
      isValidLine: false,
      coordinates: const [],
      normalWord: '',
      reverseWord: '',
      matchedPlacement: null,
      isMatch: false,
      isReverseMatch: false,
      status: WordDetectionStatus.outOfBounds,
      errorMessage: message,
    );
  }

  /// Factory for selections that do not form a straight line.
  factory WordDetectionResult.invalidLine({
    required GridCoordinate start,
    required GridCoordinate end,
    required String message,
  }) {
    return WordDetectionResult(
      isValidLine: false,
      coordinates: const [],
      normalWord: '',
      reverseWord: '',
      matchedPlacement: null,
      isMatch: false,
      isReverseMatch: false,
      status: WordDetectionStatus.invalidLine,
      errorMessage: message,
    );
  }

  /// Factory for valid straight selections that do not match any puzzle target word.
  factory WordDetectionResult.noMatch({
    required List<GridCoordinate> coordinates,
    required String normalWord,
    required String reverseWord,
  }) {
    return WordDetectionResult(
      isValidLine: true,
      coordinates: List.unmodifiable(coordinates),
      normalWord: normalWord,
      reverseWord: reverseWord,
      matchedPlacement: null,
      isMatch: false,
      isReverseMatch: false,
      status: WordDetectionStatus.noMatch,
      errorMessage: 'Word "$normalWord" does not match any target word.',
    );
  }

  /// Factory for successful target word matches.
  factory WordDetectionResult.match({
    required List<GridCoordinate> coordinates,
    required String normalWord,
    required String reverseWord,
    required WordPlacement matchedPlacement,
    required bool isReverseMatch,
  }) {
    return WordDetectionResult(
      isValidLine: true,
      coordinates: List.unmodifiable(coordinates),
      normalWord: normalWord,
      reverseWord: reverseWord,
      matchedPlacement: matchedPlacement,
      isMatch: true,
      isReverseMatch: isReverseMatch,
      status: matchedPlacement.isFound
          ? WordDetectionStatus.alreadyFound
          : WordDetectionStatus.match,
    );
  }

  /// The matched word string, or the normal string if not matched.
  String get word => matchedPlacement?.word ?? normalWord;

  /// Convenience boolean indicating whether this word is new and successfully found.
  bool get isSuccessfulMatch => status == WordDetectionStatus.match;

  /// Number of cells in the selection ray.
  int get length => coordinates.length;

  @override
  String toString() =>
      'WordDetectionResult(status: $status, word: "$normalWord", isMatch: $isMatch, isReverse: $isReverseMatch)';
}
