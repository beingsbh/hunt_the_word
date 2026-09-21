import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_the_word/engine/generator/grid_generator.dart';
import 'package:hunt_the_word/engine/models/direction_vector.dart';
import 'package:hunt_the_word/engine/models/grid_coordinate.dart';
import 'package:hunt_the_word/engine/models/level_configuration.dart';
import 'package:hunt_the_word/engine/solver/hint_solver.dart';
import 'package:hunt_the_word/engine/solver/word_validator.dart';

void main() {
  group('Word Hunt Game Engine Tests', () {
    test('Level 1 Configuration generates 5x5 board with 3-4 words', () {
      final config = LevelConfiguration.forLevel(1);
      expect(config.gridRows, 5);
      expect(config.gridCols, 5);
      expect(config.wordCount, 3);

      final board = GridGenerator.generate(config, seed: 42);
      expect(board.rows, 5);
      expect(board.cols, 5);
      expect(board.placements.length, 3);
      expect(board.matrix.length, 5);
      expect(board.matrix[0].length, 5);

      // Verify all letters in matrix are populated
      for (int r = 0; r < 5; r++) {
        for (int c = 0; c < 5; c++) {
          expect(board.matrix[r][c].isNotEmpty, true);
        }
      }
    });

    test('Level 12 Configuration generates 7x7 board with 5-7 words and diagonals', () {
      final config = LevelConfiguration.forLevel(12);
      expect(config.gridRows, 7);
      expect(config.gridCols, 7);
      expect(config.allowedDirections.contains(DirectionVector.diagonalDownRight), true);

      final board = GridGenerator.generate(config, seed: 100);
      expect(board.rows, 7);
      expect(board.cols, 7);
      expect(board.placements.length >= 5, true);
    });

    test('DirectionVector calculates straight ray between coordinates', () {
      const start = GridCoordinate(1, 1);
      const end = GridCoordinate(1, 4);
      final ray = DirectionVector.getRayBetween(start, end);

      expect(ray, isNotNull);
      expect(ray!.length, 4);
      expect(ray[0], const GridCoordinate(1, 1));
      expect(ray[1], const GridCoordinate(1, 2));
      expect(ray[2], const GridCoordinate(1, 3));
      expect(ray[3], const GridCoordinate(1, 4));
    });

    test('WordValidator matches forward and reverse selections', () {
      final config = LevelConfiguration.forLevel(1);
      final board = GridGenerator.generate(config, seed: 123);
      final target = board.placements.first;

      // Test forward match
      final forwardMatch = WordValidator.matchSelection(
        coordinates: target.coordinates,
        board: board,
      );
      expect(forwardMatch, isNotNull);
      expect(forwardMatch!.word, target.word);

      // Test reverse match
      final reverseCoords = target.coordinates.reversed.toList();
      final reverseMatch = WordValidator.matchSelection(
        coordinates: reverseCoords,
        board: board,
      );
      expect(reverseMatch, isNotNull);
      expect(reverseMatch!.word, target.word);
    });

    test('HintSolver retrieves first unfound word', () {
      final config = LevelConfiguration.forLevel(1);
      final board = GridGenerator.generate(config, seed: 456);

      final hint = HintSolver.getLetterHint(board);
      expect(hint, isNotNull);
      expect(hint!.highlightedCoordinate, board.placements.first.coordinates.first);
    });
  });
}
