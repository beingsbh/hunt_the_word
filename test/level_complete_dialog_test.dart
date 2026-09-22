import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_the_word/features/completion/screens/level_complete_dialog.dart';
import 'package:hunt_the_word/features/profile/viewmodels/player_profile_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets(
    'LevelCompleteDialog shows REPLAY and NEXT LEVEL and removes PREV LEVEL and HOME',
    (WidgetTester tester) async {
      bool replayTapped = false;
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
              onNextLevel: () {
                nextTapped = true;
              },
              onReplay: () {
                replayTapped = true;
              },
              hasMysteryGift: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LEVEL COMPLETE!'), findsOneWidget);
      expect(find.text('Level 5 Solved'), findsOneWidget);
      expect(find.text('NEXT LEVEL'), findsOneWidget);
      expect(find.text('REPLAY'), findsOneWidget);

      // PREV LEVEL and HOME buttons must NOT be present
      expect(find.text('PREV LEVEL'), findsNothing);
      expect(find.text('HOME'), findsNothing);

      await tester.tap(find.text('REPLAY'));
      await tester.pumpAndSettle();
      expect(replayTapped, isTrue);

      await tester.tap(find.text('NEXT LEVEL'));
      await tester.pumpAndSettle();
      expect(nextTapped, isTrue);
    },
  );

  testWidgets(
    'LevelCompleteDialog displays Mystery Gift for Level 29 and claims 45 coins',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => PlayerProfileProvider()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: LevelCompleteDialog(
                levelNumber: 29,
                stars: 3,
                score: 950,
                time: '01:10',
                coinsEarned: 25,
                onNextLevel: () {},
                onReplay: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Mystery gift must be present for Level 29
      expect(find.text('MYSTERY GIFT'), findsOneWidget);
      expect(find.text('CLAIM'), findsOneWidget);

      // Tap CLAIM
      await tester.tap(find.text('CLAIM'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // After claim, button transitions to CLAIMED
      expect(find.text('CLAIMED'), findsOneWidget);
      expect(find.text('+45 Coins Claimed!'), findsOneWidget);
    },
  );
}
