/// Exception thrown when word placements cannot be satisfied on a puzzle board.
///
/// This occurs when a word cannot fit within the grid bounds given the allowed
/// directions, or when overlapping conflicts cannot be resolved after maximum retries.
class WordPlacementException implements Exception {
  final String message;
  final String? word;

  const WordPlacementException(this.message, {this.word});

  @override
  String toString() =>
      'WordPlacementException: $message${word != null ? ' (word: $word)' : ''}';
}
