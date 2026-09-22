import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_the_word/engine/dictionary/category_vocabulary.dart';
import 'package:hunt_the_word/engine/generator/grid_generator.dart';
import 'package:hunt_the_word/engine/models/direction_vector.dart';
import 'package:hunt_the_word/engine/models/grid_coordinate.dart';
import 'package:hunt_the_word/engine/models/level_configuration.dart';
import 'package:hunt_the_word/engine/models/puzzle_board.dart';
import 'package:hunt_the_word/engine/models/word_detection_result.dart';
import 'package:hunt_the_word/engine/models/word_placement.dart';
import 'package:hunt_the_word/engine/models/word_placement_exception.dart';
import 'package:hunt_the_word/engine/solver/hint_solver.dart';
import 'package:hunt_the_word/engine/solver/word_validator.dart';

void main() {
  group('Word Hunt Game Engine Tests', () {
    // -------------------------------------------------------------
    // 1. Grid Size Scalability (5x5, 7x7, 9x9, 10x10, 15x15)
    // -------------------------------------------------------------
    group('Grid Size Scalability', () {
      for (final size in [5, 7, 9, 10, 15]) {
        test('Generates valid ${size}x$size grid', () {
          final config = LevelConfiguration.custom(
            gridRows: size,
            gridCols: size,
            wordCount: 3,
            minWordLength: 3,
            maxWordLength: size,
          );

          final board = GridGenerator.generate(config, seed: 100 + size);
          expect(board.rows, size);
          expect(board.cols, size);
          expect(board.matrix.length, size);
          for (int r = 0; r < size; r++) {
            expect(board.matrix[r].length, size);
            for (int c = 0; c < size; c++) {
              expect(board.matrix[r][c].isNotEmpty, true);
            }
          }
        });
      }
    });

    // -------------------------------------------------------------
    // 2. Horizontal Placement & Detection
    // -------------------------------------------------------------
    group('Horizontal Placement', () {
      test('Places horizontal word (left to right)', () {
        final config = LevelConfiguration.custom(
          gridRows: 5,
          gridCols: 5,
          allowedDirections: const [DirectionVector.horizontalRight],
        );
        final board = GridGenerator.generate(
          config,
          words: ['CAT'],
          seed: 42,
        );

        expect(board.placements.length, 1);
        final placement = board.placements.first;
        expect(placement.word, 'CAT');
        expect(placement.direction, DirectionVector.horizontalRight);
        expect(placement.coordinates.length, 3);

        // Verify row is constant and cols increment
        final row = placement.coordinates.first.row;
        for (int i = 0; i < 3; i++) {
          expect(placement.coordinates[i].row, row);
          expect(placement.coordinates[i].col,
              placement.coordinates.first.col + i);
          expect(board.matrix[row][placement.coordinates[i].col], 'CAT'[i]);
        }

        // Validate selection from start to end
        final result = WordValidator.validateSelection(
          board: board,
          start: placement.coordinates.first,
          end: placement.coordinates.last,
        );
        expect(result.isValidLine, true);
        expect(result.isMatch, true);
        expect(result.isReverseMatch, false);
        expect(result.status, WordDetectionStatus.match);
        expect(result.normalWord, 'CAT');
      });

      test('Places reverse horizontal word (right to left)', () {
        final config = LevelConfiguration.custom(
          gridRows: 5,
          gridCols: 5,
          allowedDirections: const [DirectionVector.horizontalLeft],
        );
        final board = GridGenerator.generate(
          config,
          words: ['BIRD'],
          seed: 99,
        );

        expect(board.placements.length, 1);
        final placement = board.placements.first;
        expect(placement.word, 'BIRD');
        expect(placement.direction, DirectionVector.horizontalLeft);

        // Verify row is constant and cols decrement
        final row = placement.coordinates.first.row;
        for (int i = 0; i < 4; i++) {
          expect(placement.coordinates[i].row, row);
          expect(placement.coordinates[i].col,
              placement.coordinates.first.col - i);
          expect(board.matrix[row][placement.coordinates[i].col], 'BIRD'[i]);
        }
      });
    });

    // -------------------------------------------------------------
    // 3. Vertical Placement & Detection
    // -------------------------------------------------------------
    group('Vertical Placement', () {
      test('Places vertical word (top to bottom)', () {
        final config = LevelConfiguration.custom(
          gridRows: 6,
          gridCols: 6,
          allowedDirections: const [DirectionVector.verticalDown],
        );
        final board = GridGenerator.generate(
          config,
          words: ['LION'],
          seed: 12,
        );

        expect(board.placements.length, 1);
        final placement = board.placements.first;
        expect(placement.word, 'LION');
        expect(placement.direction, DirectionVector.verticalDown);

        final col = placement.coordinates.first.col;
        for (int i = 0; i < 4; i++) {
          expect(placement.coordinates[i].col, col);
          expect(placement.coordinates[i].row,
              placement.coordinates.first.row + i);
          expect(board.matrix[placement.coordinates[i].row][col], 'LION'[i]);
        }

        final result = WordValidator.validateSelection(
          board: board,
          start: placement.coordinates.first,
          end: placement.coordinates.last,
        );
        expect(result.isMatch, true);
        expect(result.normalWord, 'LION');
      });

      test('Places reverse vertical word (bottom to top)', () {
        final config = LevelConfiguration.custom(
          gridRows: 6,
          gridCols: 6,
          allowedDirections: const [DirectionVector.verticalUp],
        );
        final board = GridGenerator.generate(
          config,
          words: ['WOLF'],
          seed: 88,
        );

        expect(board.placements.length, 1);
        final placement = board.placements.first;
        expect(placement.word, 'WOLF');
        expect(placement.direction, DirectionVector.verticalUp);

        final col = placement.coordinates.first.col;
        for (int i = 0; i < 4; i++) {
          expect(placement.coordinates[i].col, col);
          expect(placement.coordinates[i].row,
              placement.coordinates.first.row - i);
          expect(board.matrix[placement.coordinates[i].row][col], 'WOLF'[i]);
        }
      });
    });

    // -------------------------------------------------------------
    // 4. Diagonal Placement & Detection
    // -------------------------------------------------------------
    group('Diagonal Placement', () {
      test('Places diagonal down-right word', () {
        final config = LevelConfiguration.custom(
          gridRows: 7,
          gridCols: 7,
          allowedDirections: const [DirectionVector.diagonalDownRight],
        );
        final board = GridGenerator.generate(
          config,
          words: ['EAGLE'],
          seed: 45,
        );

        expect(board.placements.length, 1);
        final p = board.placements.first;
        expect(p.direction, DirectionVector.diagonalDownRight);
        for (int i = 0; i < 5; i++) {
          expect(p.coordinates[i].row, p.coordinates.first.row + i);
          expect(p.coordinates[i].col, p.coordinates.first.col + i);
          expect(board.matrix[p.coordinates[i].row][p.coordinates[i].col],
              'EAGLE'[i]);
        }

        final result = WordValidator.validateSelection(
          board: board,
          start: p.coordinates.first,
          end: p.coordinates.last,
        );
        expect(result.isMatch, true);
        expect(result.normalWord, 'EAGLE');
      });

      test('Places diagonal up-right word', () {
        final config = LevelConfiguration.custom(
          gridRows: 7,
          gridCols: 7,
          allowedDirections: const [DirectionVector.diagonalUpRight],
        );
        final board = GridGenerator.generate(
          config,
          words: ['TIGER'],
          seed: 77,
        );

        expect(board.placements.length, 1);
        final p = board.placements.first;
        expect(p.direction, DirectionVector.diagonalUpRight);
        for (int i = 0; i < 5; i++) {
          expect(p.coordinates[i].row, p.coordinates.first.row - i);
          expect(p.coordinates[i].col, p.coordinates.first.col + i);
          expect(board.matrix[p.coordinates[i].row][p.coordinates[i].col],
              'TIGER'[i]);
        }
      });

      test('Places diagonal down-left word', () {
        final config = LevelConfiguration.custom(
          gridRows: 7,
          gridCols: 7,
          allowedDirections: const [DirectionVector.diagonalDownLeft],
        );
        final board = GridGenerator.generate(
          config,
          words: ['BEAR'],
          seed: 52,
        );

        expect(board.placements.length, 1);
        final p = board.placements.first;
        expect(p.direction, DirectionVector.diagonalDownLeft);
        for (int i = 0; i < 4; i++) {
          expect(p.coordinates[i].row, p.coordinates.first.row + i);
          expect(p.coordinates[i].col, p.coordinates.first.col - i);
        }
      });

      test('Places diagonal up-left word', () {
        final config = LevelConfiguration.custom(
          gridRows: 7,
          gridCols: 7,
          allowedDirections: const [DirectionVector.diagonalUpLeft],
        );
        final board = GridGenerator.generate(
          config,
          words: ['ZEBRA'],
          seed: 33,
        );

        expect(board.placements.length, 1);
        final p = board.placements.first;
        expect(p.direction, DirectionVector.diagonalUpLeft);
        for (int i = 0; i < 5; i++) {
          expect(p.coordinates[i].row, p.coordinates.first.row - i);
          expect(p.coordinates[i].col, p.coordinates.first.col - i);
        }
      });
    });

    // -------------------------------------------------------------
    // 5. Reverse Word Detection
    // -------------------------------------------------------------
    group('Reverse Word Detection', () {
      test('Detects word when dragging in reverse from end to start', () {
        final config = LevelConfiguration.custom(
          gridRows: 6,
          gridCols: 6,
          allowedDirections: const [DirectionVector.horizontalRight],
        );
        final board = GridGenerator.generate(
          config,
          words: ['PLANET'],
          seed: 10,
        );

        final p = board.placements.first;
        final start = p.coordinates.last;
        final end = p.coordinates.first;

        final result = WordValidator.validateSelection(
          board: board,
          start: start,
          end: end,
        );

        expect(result.isValidLine, true);
        expect(result.isMatch, true);
        expect(result.isReverseMatch, true);
        expect(result.normalWord, 'TENALP');
        expect(result.reverseWord, 'PLANET');
        expect(result.matchedPlacement!.word, 'PLANET');
      });

      test('Backwards compatible matchSelection detects reverse drag', () {
        final config = LevelConfiguration.custom(
          gridRows: 5,
          gridCols: 5,
          allowedDirections: const [DirectionVector.verticalDown],
        );
        final board = GridGenerator.generate(
          config,
          words: ['DOG'],
          seed: 123,
        );

        final p = board.placements.first;
        final reverseCoords = p.coordinates.reversed.toList();

        final match = WordValidator.matchSelection(
          coordinates: reverseCoords,
          board: board,
        );
        expect(match, isNotNull);
        expect(match!.word, 'DOG');
      });
    });

    // -------------------------------------------------------------
    // 6. Overlapping Words
    // -------------------------------------------------------------
    group('Overlapping Words', () {
      test('Places intersecting words sharing a common letter', () {
        final config = LevelConfiguration.custom(
          gridRows: 6,
          gridCols: 6,
          allowedDirections: const [
            DirectionVector.horizontalRight,
            DirectionVector.verticalDown,
          ],
          allowOverlaps: true,
        );

        // 'CAT' and 'TEA' can overlap at letter 'T'
        final board = GridGenerator.generate(
          config,
          words: ['CAT', 'TEA'],
          seed: 42,
        );

        expect(board.placements.length, 2);
        // Verify both words are spelled in the matrix at their coordinates
        for (final p in board.placements) {
          final spelled =
              p.coordinates.map((c) => board.matrix[c.row][c.col]).join();
          expect(spelled, p.word);
        }

        // Validate both words are detected independently
        for (final p in board.placements) {
          final res = WordValidator.validateSelection(
            board: board,
            start: p.coordinates.first,
            end: p.coordinates.last,
          );
          expect(res.isMatch, true);
          expect(res.matchedPlacement!.word, p.word);
        }
      });

      test(
          'Rejects overlapping placement when allowOverlaps is false and cells collide',
          () {
        // A 1x3 grid can only hold one 3-letter word horizontally
        final config = LevelConfiguration.custom(
          gridRows: 1,
          gridCols: 3,
          allowedDirections: const [DirectionVector.horizontalRight],
          allowOverlaps: false,
        );

        expect(
          () => GridGenerator.generate(
            config,
            words: ['CAT', 'DOG'],
            seed: 1,
            maxRetries: 5,
          ),
          throwsA(isA<WordPlacementException>()),
        );
      });
    });

    // -------------------------------------------------------------
    // 7. Invalid Selections
    // -------------------------------------------------------------
    group('Invalid Selections', () {
      test('Returns invalidLine for non-straight angles (knight moves)', () {
        final config = LevelConfiguration.custom(gridRows: 5, gridCols: 5);
        final board = GridGenerator.generate(config, words: ['TEST'], seed: 1);

        final result = WordValidator.validateSelection(
          board: board,
          start: const GridCoordinate(0, 0),
          end: const GridCoordinate(1, 2),
        );

        expect(result.isValidLine, false);
        expect(result.isMatch, false);
        expect(result.status, WordDetectionStatus.invalidLine);
      });

      test('Returns outOfBounds for coordinates outside grid', () {
        final config = LevelConfiguration.custom(gridRows: 5, gridCols: 5);
        final board = GridGenerator.generate(config, words: ['TEST'], seed: 1);

        final result = WordValidator.validateSelection(
          board: board,
          start: const GridCoordinate(-1, 0),
          end: const GridCoordinate(3, 0),
        );

        expect(result.isValidLine, false);
        expect(result.status, WordDetectionStatus.outOfBounds);
      });

      test(
          'Returns noMatch for arbitrary straight line that does not match target words',
          () {
        final config = LevelConfiguration.custom(
          gridRows: 5,
          gridCols: 5,
          allowedDirections: const [DirectionVector.horizontalRight],
        );
        final board = GridGenerator.generate(config, words: ['RIVER'], seed: 5);

        // Find a row where 'RIVER' is NOT placed
        final placedRow = board.placements.first.coordinates.first.row;
        final emptyRow = (placedRow + 1) % 5;

        final result = WordValidator.validateSelection(
          board: board,
          start: GridCoordinate(emptyRow, 0),
          end: GridCoordinate(emptyRow, 3),
        );

        expect(result.isValidLine, true);
        expect(result.isMatch, false);
        expect(result.status, WordDetectionStatus.noMatch);
      });

      test('Flags word as alreadyFound when validated again', () {
        final config = LevelConfiguration.custom(gridRows: 5, gridCols: 5);
        final board = GridGenerator.generate(config, words: ['TREE'], seed: 1);
        final p = board.placements.first;

        // Mark placement as found
        final foundBoard = PuzzleBoard(
          rows: board.rows,
          cols: board.cols,
          matrix: board.matrix,
          placements: [p.copyWith(isFound: true)],
        );

        final result = WordValidator.validateSelection(
          board: foundBoard,
          start: p.coordinates.first,
          end: p.coordinates.last,
        );

        expect(result.isValidLine, true);
        expect(result.isMatch, true);
        expect(result.status, WordDetectionStatus.alreadyFound);
        expect(result.isSuccessfulMatch, false);
      });
    });

    // -------------------------------------------------------------
    // 8. Impossible Word Placements
    // -------------------------------------------------------------
    group('Impossible Word Placements', () {
      test(
          'Throws WordPlacementException when word length exceeds grid dimensions',
          () {
        final config = LevelConfiguration.custom(
          gridRows: 5,
          gridCols: 5,
        );

        expect(
          () => GridGenerator.generate(config, words: ['EXTRAORDINARY']),
          throwsA(
            isA<WordPlacementException>().having(
              (e) => e.word,
              'word',
              'EXTRAORDINARY',
            ),
          ),
        );
      });

      test(
          'Throws WordPlacementException when direction cannot accommodate word length',
          () {
        // Grid is 3 rows x 8 cols, but only verticalDown is allowed for a 5-letter word
        final config = LevelConfiguration.custom(
          gridRows: 3,
          gridCols: 8,
          allowedDirections: const [DirectionVector.verticalDown],
        );

        expect(
          () => GridGenerator.generate(config, words: ['PLANET']),
          throwsA(isA<WordPlacementException>()),
        );
      });
    });

    // -------------------------------------------------------------
    // 9. Deterministic Seeded Generation & Reproducibility
    // -------------------------------------------------------------
    group('Deterministic Seeded Generation', () {
      test(
          'Identical seeds generate identical board matrix, placements, and filler cells',
          () {
        final config = LevelConfiguration.custom(
          gridRows: 7,
          gridCols: 7,
          wordCount: 4,
        );

        final board1 = GridGenerator.generate(
          config,
          words: ['APPLE', 'BERRY', 'CHERRY'],
          seed: 777,
        );
        final board2 = GridGenerator.generate(
          config,
          words: ['APPLE', 'BERRY', 'CHERRY'],
          seed: 777,
        );

        // Verify identical matrices
        for (int r = 0; r < 7; r++) {
          for (int c = 0; c < 7; c++) {
            expect(board1.matrix[r][c], board2.matrix[r][c]);
          }
        }

        // Verify identical placements and coordinates
        expect(board1.placements.length, board2.placements.length);
        for (int i = 0; i < board1.placements.length; i++) {
          expect(board1.placements[i].word, board2.placements[i].word);
          expect(
              board1.placements[i].direction, board2.placements[i].direction);
          expect(board1.placements[i].coordinates,
              board2.placements[i].coordinates);
        }
      });

      test('Different seeds produce different board layouts', () {
        final config = LevelConfiguration.custom(
          gridRows: 7,
          gridCols: 7,
        );

        final board1 = GridGenerator.generate(
          config,
          words: ['OCEAN', 'RIVER'],
          seed: 111,
        );
        final board2 = GridGenerator.generate(
          config,
          words: ['OCEAN', 'RIVER'],
          seed: 999,
        );

        // Verify at least some cell or placement differs
        bool differenceFound = false;
        for (int r = 0; r < 7; r++) {
          for (int c = 0; c < 7; c++) {
            if (board1.matrix[r][c] != board2.matrix[r][c]) {
              differenceFound = true;
              break;
            }
          }
          if (differenceFound) break;
        }

        expect(differenceFound, true);
      });
    });

    // -------------------------------------------------------------
    // 10. Board Filling & Boundary Conditions
    // -------------------------------------------------------------
    group('Board Filling & Boundary Conditions', () {
      test('Fills all empty cells with non-empty letters', () {
        final config = LevelConfiguration.custom(gridRows: 8, gridCols: 8);
        final board = GridGenerator.generate(config, words: ['SUN'], seed: 42);

        for (int r = 0; r < 8; r++) {
          for (int c = 0; c < 8; c++) {
            expect(board.matrix[r][c].length, 1);
            expect(board.matrix[r][c].codeUnitAt(0) >= 65,
                true); // Uppercase letter
            expect(board.matrix[r][c].codeUnitAt(0) <= 90, true);
          }
        }
      });

      test('Places words that reach grid boundary edges', () {
        // 5x5 grid with 5-letter word must span from edge 0 to edge 4
        final config = LevelConfiguration.custom(
          gridRows: 5,
          gridCols: 5,
          allowedDirections: const [DirectionVector.horizontalRight],
        );
        final board = GridGenerator.generate(config, words: ['APPLE'], seed: 1);

        final p = board.placements.first;
        expect(p.coordinates.first.col, 0);
        expect(p.coordinates.last.col, 4);
      });
    });

    // -------------------------------------------------------------
    // 11. Edge Cases: Empty Word List & Duplicate Words
    // -------------------------------------------------------------
    group('Edge Cases', () {
      test('Empty word list returns fully-filled board with zero placements',
          () {
        final config = LevelConfiguration.custom(gridRows: 5, gridCols: 5);
        final board = GridGenerator.generate(config, words: [], seed: 10);

        expect(board.rows, 5);
        expect(board.cols, 5);
        expect(board.placements.isEmpty, true);
        for (int r = 0; r < 5; r++) {
          for (int c = 0; c < 5; c++) {
            expect(board.matrix[r][c].isNotEmpty, true);
          }
        }
      });

      test('Duplicate input words are safely deduplicated', () {
        final config = LevelConfiguration.custom(gridRows: 6, gridCols: 6);
        final board = GridGenerator.generate(
          config,
          words: ['CAT', 'cat', 'CAT '],
          seed: 15,
        );

        expect(board.placements.length, 1);
        expect(board.placements.first.word, 'CAT');
      });

      test(
          'Whitespace-only words list returns fully-filled board with zero placements',
          () {
        final config = LevelConfiguration.custom(gridRows: 5, gridCols: 5);
        final board = GridGenerator.generate(
          config,
          words: ['', '   ', ' '],
          seed: 42,
        );

        expect(board.rows, 5);
        expect(board.cols, 5);
        expect(board.placements.isEmpty, true);
        for (int r = 0; r < 5; r++) {
          for (int c = 0; c < 5; c++) {
            expect(board.matrix[r][c].isNotEmpty, true);
          }
        }
      });

      test('Filters empty and whitespace-only strings from mixed word list',
          () {
        final config = LevelConfiguration.custom(gridRows: 6, gridCols: 6);
        final board = GridGenerator.generate(
          config,
          words: ['', 'FISH', '  ', 'BIRD'],
          seed: 20,
        );

        expect(board.placements.length, 2);
        final words = board.placements.map((p) => p.word).toSet();
        expect(words, contains('FISH'));
        expect(words, contains('BIRD'));
      });
    });

    // -------------------------------------------------------------
    // 12. Hint Solver Integration
    // -------------------------------------------------------------
    group('Hint Solver Integration', () {
      test('HintSolver retrieves first unfound word letter coordinate', () {
        final config = LevelConfiguration.forLevel(1);
        final board = GridGenerator.generate(config, seed: 456);

        final hint = HintSolver.getLetterHint(board);
        expect(hint, isNotNull);
        expect(
          hint!.highlightedCoordinate,
          board.placements.first.coordinates.first,
        );
      });

      test('HintSolver getWordSolveHint retrieves first unfound word placement',
          () {
        final config = LevelConfiguration.forLevel(1);
        final board = GridGenerator.generate(config, seed: 99);

        final solveHint = HintSolver.getWordSolveHint(board);
        expect(solveHint, isNotNull);
        expect(solveHint!.isFound, false);
        expect(solveHint.word, board.placements.first.word);

        // When all words are marked found, returns null
        final allFoundBoard = PuzzleBoard(
          rows: board.rows,
          cols: board.cols,
          matrix: board.matrix,
          placements:
              board.placements.map((p) => p.copyWith(isFound: true)).toList(),
        );
        expect(HintSolver.getLetterHint(allFoundBoard), isNull);
        expect(HintSolver.getWordSolveHint(allFoundBoard), isNull);
      });
    });

    // -------------------------------------------------------------
    // 13. Boundary Corner & Diagonal Edge Validation
    // -------------------------------------------------------------
    group('Boundary Corner & Diagonal Edge Validation', () {
      test('Diagonal word spans from top-left (0,0) to bottom-right corner',
          () {
        final config = LevelConfiguration.custom(
          gridRows: 5,
          gridCols: 5,
          allowedDirections: const [DirectionVector.diagonalDownRight],
        );
        final board = GridGenerator.generate(
          config,
          words: ['EAGLE'],
          seed: 1,
        );

        final p = board.placements.first;
        expect(p.coordinates.first, const GridCoordinate(0, 0));
        expect(p.coordinates.last, const GridCoordinate(4, 4));
        expect(p.direction, DirectionVector.diagonalDownRight);
      });

      test(
          'Diagonal word spans from bottom-left (4,0) to top-right (0,4) corner',
          () {
        final config = LevelConfiguration.custom(
          gridRows: 5,
          gridCols: 5,
          allowedDirections: const [DirectionVector.diagonalUpRight],
        );
        final board = GridGenerator.generate(
          config,
          words: ['TIGER'],
          seed: 1,
        );

        final p = board.placements.first;
        expect(p.coordinates.first, const GridCoordinate(4, 0));
        expect(p.coordinates.last, const GridCoordinate(0, 4));
        expect(p.direction, DirectionVector.diagonalUpRight);
      });

      test('Reverse diagonal dragging on diagonalUpRight is detected', () {
        final config = LevelConfiguration.custom(
          gridRows: 5,
          gridCols: 5,
          allowedDirections: const [DirectionVector.diagonalUpRight],
        );
        final board = GridGenerator.generate(
          config,
          words: ['TIGER'],
          seed: 1,
        );

        final p = board.placements.first;
        final res = WordValidator.validateSelection(
          board: board,
          start: p.coordinates.last,
          end: p.coordinates.first,
        );
        expect(res.isMatch, true);
        expect(res.isReverseMatch, true);
        expect(res.status, WordDetectionStatus.match);
      });
    });

    // -------------------------------------------------------------
    // 14. Complex Multi-Word Overlaps
    // -------------------------------------------------------------
    group('Complex Multi-Word Overlaps', () {
      test('Places three words intersecting at shared letters', () {
        final config = LevelConfiguration.custom(
          gridRows: 6,
          gridCols: 6,
          allowedDirections: const [
            DirectionVector.horizontalRight,
            DirectionVector.verticalDown,
            DirectionVector.diagonalDownRight,
          ],
          allowOverlaps: true,
        );
        final board = GridGenerator.generate(
          config,
          words: ['CAT', 'TEA', 'EAT'],
          seed: 42,
        );

        expect(board.placements.length, 3);
        for (final p in board.placements) {
          final spelled =
              p.coordinates.map((c) => board.matrix[c.row][c.col]).join();
          expect(spelled, p.word);
        }
      });
    });

    // -------------------------------------------------------------
    // 15. Engine Models Serialization & Round-Trip Integrity
    // -------------------------------------------------------------
    group('Engine Models Serialization & Round-Trip Integrity', () {
      test('GridCoordinate toMap and fromMap round-trip', () {
        const coord = GridCoordinate(3, 7);
        final map = coord.toMap();
        final restored = GridCoordinate.fromMap(map);
        expect(restored, coord);
        expect(restored.row, 3);
        expect(restored.col, 7);
      });

      test('WordPlacement toMap and fromMap round-trip', () {
        const p = WordPlacement(
          word: 'OCEAN',
          coordinates: [
            GridCoordinate(0, 0),
            GridCoordinate(0, 1),
            GridCoordinate(0, 2),
            GridCoordinate(0, 3),
            GridCoordinate(0, 4),
          ],
          direction: DirectionVector.horizontalRight,
          isFound: true,
          colorIndex: 3,
        );
        final map = p.toMap();
        final restored = WordPlacement.fromMap(map);
        expect(restored.word, 'OCEAN');
        expect(restored.direction, DirectionVector.horizontalRight);
        expect(restored.isFound, true);
        expect(restored.colorIndex, 3);
        expect(restored.coordinates.length, 5);
        expect(restored.start, const GridCoordinate(0, 0));
        expect(restored.end, const GridCoordinate(0, 4));
      });

      test('PuzzleBoard toMap and fromMap round-trip', () {
        final config = LevelConfiguration.forLevel(1);
        final board = GridGenerator.generate(config, seed: 101);
        final map = board.toMap();
        final restored = PuzzleBoard.fromMap(map);

        expect(restored.rows, board.rows);
        expect(restored.cols, board.cols);
        expect(restored.totalWords, board.totalWords);
        expect(restored.matrix, board.matrix);
        expect(restored.placements.length, board.placements.length);
        for (int i = 0; i < board.placements.length; i++) {
          expect(restored.placements[i].word, board.placements[i].word);
          expect(
            restored.placements[i].coordinates,
            board.placements[i].coordinates,
          );
        }
      });
    });

    // -------------------------------------------------------------
    // 16. Level Configuration Progressive Difficulty
    // -------------------------------------------------------------
    group('Level Configuration Progressive Difficulty', () {
      test('Levels 1-10 have 5x5 grid and horizontal/vertical only', () {
        final config = LevelConfiguration.forLevel(1);
        expect(config.gridRows, 5);
        expect(config.gridCols, 5);
        expect(config.allowedDirections.length, 2);
        expect(config.allowedDirections,
            contains(DirectionVector.horizontalRight));
        expect(
            config.allowedDirections, contains(DirectionVector.verticalDown));
        expect(config.allowOverlaps, false);
      });

      test('Levels 11-25 have 7x7 grid and diagonal directions', () {
        final config = LevelConfiguration.forLevel(15);
        expect(config.gridRows, 7);
        expect(config.gridCols, 7);
        expect(config.allowedDirections.length, 4);
        expect(config.allowOverlaps, true);
      });

      test('Levels 26-50 have 9x9 grid and all 8 directions', () {
        final config = LevelConfiguration.forLevel(30);
        expect(config.gridRows, 9);
        expect(config.gridCols, 9);
        expect(config.allowedDirections, DirectionVector.values);
        expect(config.allowOverlaps, true);
      });

      test('Levels 51+ have 10x10+ grid and higher word count', () {
        final config = LevelConfiguration.forLevel(55);
        expect(config.gridRows, greaterThanOrEqualTo(10));
        expect(config.gridCols, greaterThanOrEqualTo(10));
        expect(config.wordCount, greaterThanOrEqualTo(10));
      });

      test('Daily configuration generates 7x7 grid with time limit', () {
        final config = LevelConfiguration.daily(
          seed: 12345,
          themeTitle: 'Autumn Breeze',
        );
        expect(config.gridRows, 7);
        expect(config.gridCols, 7);
        expect(config.category, 'Autumn Breeze');
        expect(config.timeLimitSeconds, 180);
      });
    });

    // -------------------------------------------------------------
    // 17. Category Vocabulary Filtering
    // -------------------------------------------------------------
    group('Category Vocabulary Filtering', () {
      test('Filters words within length constraints', () {
        final words = CategoryVocabulary.getWordsForCategory(
          'Nature Walk',
          minLength: 4,
          maxLength: 5,
        );
        expect(words.isNotEmpty, true);
        for (final w in words) {
          expect(w.length >= 4 && w.length <= 5, true);
        }
      });

      test('Falls back to Nature Walk for unknown category', () {
        final words = CategoryVocabulary.getWordsForCategory(
          'NonExistentCategoryXYZ',
        );
        expect(words.isNotEmpty, true);
      });
    });

    // -------------------------------------------------------------
    // 18. Additional Edge Case & Exception Validations
    // -------------------------------------------------------------
    group('Additional Edge Case & Exception Validations', () {
      test('Non-positive dimensions throw WordPlacementException', () {
        final configZero = LevelConfiguration.custom(gridRows: 0, gridCols: 5);
        expect(
          () => GridGenerator.generate(configZero),
          throwsA(isA<WordPlacementException>()),
        );

        final configNegative = LevelConfiguration.custom(
          gridRows: 5,
          gridCols: -1,
        );
        expect(
          () => GridGenerator.generate(configNegative),
          throwsA(isA<WordPlacementException>()),
        );
      });

      test(
          'Single cell selection returns noMatch when no 1-letter target words exist',
          () {
        final config = LevelConfiguration.custom(gridRows: 5, gridCols: 5);
        final board = GridGenerator.generate(config, words: ['TREE'], seed: 1);

        final result = WordValidator.validateSelection(
          board: board,
          start: const GridCoordinate(2, 2),
          end: const GridCoordinate(2, 2),
        );
        expect(result.isValidLine, true);
        expect(result.isMatch, false);
        expect(result.status, WordDetectionStatus.noMatch);
      });
    });
  });
}
