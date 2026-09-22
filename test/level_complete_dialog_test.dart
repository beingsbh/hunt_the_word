import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_the_word/features/completion/screens/level_complete_dialog.dart';

void main() {
  testWidgets(
    'LevelCompleteDialog shows PREV LEVEL and NEXT LEVEL when onPreviousLevel is provided and level > 1',
    (WidgetTester tester) async {
      bool prevTapped = false;
      bool nextTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelCompleteDialog(
              levelNumber: 5,
              stars: 3,
              score: 750,
              time: '01:23',
              coinsEarned: 25,
              onPreviousLevel: () {
                prevTapped = true;
              },
              onNextLevel: () {
                nextTapped = true;
              },
              onReplay: () {},
              onHome: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LEVEL COMPLETE!'), findsOneWidget);
      expect(find.text('Level 5 Solved'), findsOneWidget);
      expect(find.text('PREV LEVEL'), findsOneWidget);
      expect(find.text('NEXT LEVEL'), findsOneWidget);

      await tester.tap(find.text('PREV LEVEL'));
      await tester.pumpAndSettle();
      expect(prevTapped, isTrue);

      await tester.tap(find.text('NEXT LEVEL'));
      await tester.pumpAndSettle();
      expect(nextTapped, isTrue);
    },
  );

  testWidgets(
    'LevelCompleteDialog has disabled PREV LEVEL button on Level 1',
    (WidgetTester tester) async {
      bool prevTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LevelCompleteDialog(
              levelNumber: 1,
              stars: 3,
              score: 550,
              time: '00:45',
              coinsEarned: 25,
              onPreviousLevel: () {
                prevTapped = true;
              },
              onNextLevel: () {},
              onReplay: () {},
              onHome: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PREV LEVEL'), findsOneWidget);
      // Tap disabled PREV LEVEL button
      await tester.tap(find.text('PREV LEVEL'));
      await tester.pumpAndSettle();
      expect(prevTapped, isFalse);
    },
  );
}
