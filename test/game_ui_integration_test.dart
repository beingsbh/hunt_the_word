import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_the_word/engine/models/direction_vector.dart';
import 'package:hunt_the_word/engine/models/level_configuration.dart';
import 'package:hunt_the_word/features/game/screens/game_screen.dart';
import 'package:hunt_the_word/features/game/viewmodels/game_provider.dart';
import 'package:hunt_the_word/features/game/widgets/interactive_game_board.dart';
import 'package:hunt_the_word/features/levels/viewmodels/level_progress_provider.dart';
import 'package:hunt_the_word/features/profile/viewmodels/player_profile_provider.dart';
import 'package:provider/provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestGame({
    required LevelConfiguration config,
    required List<String> words,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerProfileProvider()),
        ChangeNotifierProvider(create: (_) => LevelProgressProvider()),
        ChangeNotifierProvider(
          create: (_) => GameProvider(
            levelNumber: 1,
            category: 'Testing',
            customConfig: config,
            targetWords: words,
          ),
        ),
      ],
      child: const MaterialApp(
        home: Scaffold(
          body: InteractiveGameBoard(),
        ),
      ),
    );
  }

  group('Game UI Engine Integration Tests', () {
    testWidgets('Horizontal selection marks word found and updates board', (
      WidgetTester tester,
    ) async {
      final config = LevelConfiguration.custom(
        gridRows: 5,
        gridCols: 5,
        allowedDirections: const [DirectionVector.horizontalRight],
      );

      await tester.pumpWidget(
        buildTestGame(config: config, words: ['TREE']),
      );
      await tester.pumpAndSettle();

      final provider = tester
          .element(find.byType(InteractiveGameBoard))
          .read<GameProvider>();
      final placement = provider.placements.first;
      expect(placement.word, 'TREE');
      expect(provider.foundWordsCount, 0);

      // Perform swipe along horizontal placement
      provider.onPanStart(placement.coordinates.first);
      provider.onPanUpdate(placement.coordinates.last);
      provider.onPanEnd();
      await tester.pumpAndSettle();

      expect(provider.foundWordsCount, 1);
      expect(provider.foundWords, contains('TREE'));
      expect(provider.isCompleted, true);
    });

    testWidgets('Vertical selection marks word found', (
      WidgetTester tester,
    ) async {
      final config = LevelConfiguration.custom(
        gridRows: 6,
        gridCols: 6,
        allowedDirections: const [DirectionVector.verticalDown],
      );

      await tester.pumpWidget(
        buildTestGame(config: config, words: ['LION']),
      );
      await tester.pumpAndSettle();

      final provider = tester
          .element(find.byType(InteractiveGameBoard))
          .read<GameProvider>();
      final placement = provider.placements.first;
      expect(placement.word, 'LION');

      provider.onPanStart(placement.coordinates.first);
      provider.onPanUpdate(placement.coordinates.last);
      provider.onPanEnd();
      await tester.pumpAndSettle();

      expect(provider.foundWordsCount, 1);
      expect(provider.foundWords, contains('LION'));
    });

    testWidgets('Diagonal selection marks word found', (
      WidgetTester tester,
    ) async {
      final config = LevelConfiguration.custom(
        gridRows: 6,
        gridCols: 6,
        allowedDirections: const [DirectionVector.diagonalDownRight],
      );

      await tester.pumpWidget(
        buildTestGame(config: config, words: ['TIGER']),
      );
      await tester.pumpAndSettle();

      final provider = tester
          .element(find.byType(InteractiveGameBoard))
          .read<GameProvider>();
      final placement = provider.placements.first;
      expect(placement.word, 'TIGER');

      provider.onPanStart(placement.coordinates.first);
      provider.onPanUpdate(placement.coordinates.last);
      provider.onPanEnd();
      await tester.pumpAndSettle();

      expect(provider.foundWordsCount, 1);
      expect(provider.foundWords, contains('TIGER'));
    });

    testWidgets('Reverse selection dragging marks word found', (
      WidgetTester tester,
    ) async {
      final config = LevelConfiguration.custom(
        gridRows: 5,
        gridCols: 5,
        allowedDirections: const [DirectionVector.horizontalRight],
      );

      await tester.pumpWidget(
        buildTestGame(config: config, words: ['WOLF']),
      );
      await tester.pumpAndSettle();

      final provider = tester
          .element(find.byType(InteractiveGameBoard))
          .read<GameProvider>();
      final placement = provider.placements.first;

      // Drag from END to START (reverse)
      provider.onPanStart(placement.coordinates.last);
      provider.onPanUpdate(placement.coordinates.first);
      provider.onPanEnd();
      await tester.pumpAndSettle();

      expect(provider.foundWordsCount, 1);
      expect(provider.foundWords, contains('WOLF'));
    });

    testWidgets(
        'Invalid selection triggers wobble feedback and clears selection', (
      WidgetTester tester,
    ) async {
      final config = LevelConfiguration.custom(
        gridRows: 5,
        gridCols: 5,
        allowedDirections: const [DirectionVector.horizontalRight],
      );

      await tester.pumpWidget(
        buildTestGame(config: config, words: ['BEAR']),
      );
      await tester.pumpAndSettle();

      final provider = tester
          .element(find.byType(InteractiveGameBoard))
          .read<GameProvider>();
      final placedRow = provider.placements.first.coordinates.first.row;
      final emptyRow = (placedRow + 1) % 5;

      // Select an empty row that doesn't match the word
      provider.onPanStart(provider.placements.first.coordinates.first);
      // Change to invalid angle (diagonal when only horizontal was placed)
      provider.onPanStart(provider.board.matrix.length > emptyRow
          ? provider.placements.first.coordinates.first
          : provider.placements.first.coordinates.first);

      // Perform invalid selection
      provider.onPanStart(provider.placements.first.coordinates.first);
      provider.onPanEnd(); // 1 letter selection is invalid
      await tester.pump();

      expect(provider.isWobblingError, true);
      await tester.pump(const Duration(milliseconds: 300));
      expect(provider.isWobblingError, false);
      expect(provider.selectedCells.isEmpty, true);
    });

    testWidgets('Completing all words triggers victory dialog on GameScreen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PlayerProfileProvider()),
            ChangeNotifierProvider(create: (_) => LevelProgressProvider()),
          ],
          child: const MaterialApp(
            home: GameScreen(levelNumber: 1, category: 'Nature Walk'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final provider = tester
          .element(find.byType(InteractiveGameBoard))
          .read<GameProvider>();

      // Solve all target words
      for (final p in List.of(provider.placements)) {
        provider.onPanStart(p.coordinates.first);
        provider.onPanUpdate(p.coordinates.last);
        provider.onPanEnd();
        await tester.pumpAndSettle();
      }

      // Victory dialog should appear with Level Complete
      expect(find.text('LEVEL COMPLETE!'), findsOneWidget);
      expect(find.text('NEXT LEVEL'), findsOneWidget);
      expect(find.text('REPLAY'), findsOneWidget);
      expect(find.text('PREV LEVEL'), findsNothing);
      expect(find.text('HOME'), findsNothing);
    });
  });
}
