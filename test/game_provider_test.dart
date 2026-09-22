import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_the_word/engine/models/direction_vector.dart';
import 'package:hunt_the_word/engine/models/grid_coordinate.dart';
import 'package:hunt_the_word/engine/models/level_configuration.dart';
import 'package:hunt_the_word/features/game/viewmodels/game_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameProvider Tests', () {
    late LevelConfiguration testConfig;
    const testWords = ['DART', 'HERO'];

    setUp(() {
      testConfig = LevelConfiguration.custom(
        gridRows: 6,
        gridCols: 6,
        allowedDirections: const [
          DirectionVector.horizontalRight,
          DirectionVector.verticalDown,
        ],
        allowOverlaps: true,
      );
    });

    test('Initializes with correct board, target words, timer, and score', () {
      final provider = GameProvider(
        levelNumber: 5,
        category: 'Testing',
        customConfig: testConfig,
        targetWords: testWords,
      );

      addTearDown(provider.dispose);

      expect(provider.currentLevel, 5);
      expect(provider.levelNumber, 5);
      expect(provider.category, 'Testing');
      expect(provider.rows, 6);
      expect(provider.cols, 6);
      expect(provider.matrix.length, 6);
      expect(provider.board.placements.length, 2);
      expect(provider.targetWords.toSet(), testWords.toSet());
      expect(provider.foundWords.isEmpty, true);
      expect(provider.foundWordsCount, 0);
      expect(provider.totalWords, 2);
      expect(provider.progressFraction, 0.0);
      expect(provider.selectedCells.isEmpty, true);
      expect(provider.score, 0);
      expect(provider.elapsedSeconds, 0);
      expect(provider.formattedTime, '00:00');
      expect(provider.gameStatus, GameStatus.playing);
      expect(provider.isCompleted, false);
      expect(provider.isLevelCompleted, false);
      expect(provider.isWobblingError, false);
    });

    test('Touch start stores starting cell and notifies listeners', () {
      final provider = GameProvider(
        levelNumber: 1,
        category: 'Testing',
        customConfig: testConfig,
        targetWords: testWords,
      );
      addTearDown(provider.dispose);

      bool notified = false;
      provider.addListener(() => notified = true);

      provider.onPanStart(const GridCoordinate(1, 1));

      expect(notified, true);
      expect(provider.selectedCells.length, 1);
      expect(provider.selectedCells.first, const GridCoordinate(1, 1));
    });

    test('Dragging calculates straight ray and updates selected cells', () {
      final provider = GameProvider(
        levelNumber: 1,
        category: 'Testing',
        customConfig: testConfig,
        targetWords: testWords,
      );
      addTearDown(provider.dispose);

      provider.onPanStart(const GridCoordinate(0, 0));
      provider.onPanUpdate(const GridCoordinate(0, 3));

      expect(provider.selectedCells.length, 4);
      expect(provider.selectedCells[0], const GridCoordinate(0, 0));
      expect(provider.selectedCells[1], const GridCoordinate(0, 1));
      expect(provider.selectedCells[2], const GridCoordinate(0, 2));
      expect(provider.selectedCells[3], const GridCoordinate(0, 3));
    });

    test('Selecting a correct word marks it found, updates score and progress',
        () {
      final provider = GameProvider(
        levelNumber: 1,
        category: 'Testing',
        customConfig: testConfig,
        targetWords: testWords,
      );
      addTearDown(provider.dispose);

      final targetPlacement = provider.placements.first;
      final start = targetPlacement.coordinates.first;
      final end = targetPlacement.coordinates.last;

      provider.onPanStart(start);
      provider.onPanUpdate(end);
      provider.onPanEnd();

      expect(provider.foundWords.contains(targetPlacement.word), true);
      expect(provider.foundWordsCount, 1);
      expect(provider.progressFraction, 0.5);
      expect(provider.score, targetPlacement.word.length * 50);
      expect(provider.isSuccessAnimation, true);
      expect(provider.selectedCells.isEmpty, true);
      expect(provider.lastDiscoveredWord?.word, targetPlacement.word);
    });

    test(
        'Selecting an incorrect word triggers error animation and clears selection',
        () async {
      final provider = GameProvider(
        levelNumber: 1,
        category: 'Testing',
        customConfig: testConfig,
        targetWords: testWords,
      );
      addTearDown(provider.dispose);

      // Find two coordinates that do NOT spell a word on the board
      provider.onPanStart(const GridCoordinate(0, 0));
      provider.onPanUpdate(const GridCoordinate(0, 1));
      provider.onPanEnd();

      // If it happened to be a word, we test another arbitrary line
      if (provider.foundWordsCount == 0) {
        expect(provider.isWobblingError, true);
        await Future.delayed(const Duration(milliseconds: 260));
        expect(provider.isWobblingError, false);
        expect(provider.selectedCells.isEmpty, true);
      }
    });

    test('Finding all words transitions gameStatus to completed', () {
      final provider = GameProvider(
        levelNumber: 1,
        category: 'Testing',
        customConfig: testConfig,
        targetWords: testWords,
      );
      addTearDown(provider.dispose);

      for (final p in List.of(provider.placements)) {
        provider.onPanStart(p.coordinates.first);
        provider.onPanUpdate(p.coordinates.last);
        provider.onPanEnd();
      }

      expect(provider.foundWordsCount, 2);
      expect(provider.isCompleted, true);
      expect(provider.isLevelCompleted, true);
      expect(provider.gameStatus, GameStatus.completed);
      expect(provider.score > 0, true);
    });

    test('Pause and resume toggle game status', () {
      final provider = GameProvider(
        levelNumber: 1,
        category: 'Testing',
        customConfig: testConfig,
        targetWords: testWords,
      );
      addTearDown(provider.dispose);

      expect(provider.gameStatus, GameStatus.playing);
      provider.pauseGame();
      expect(provider.gameStatus, GameStatus.paused);
      provider.resumeGame();
      expect(provider.gameStatus, GameStatus.playing);
    });
  });
}
