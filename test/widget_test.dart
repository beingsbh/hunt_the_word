import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_the_word/app/app.dart';

void main() {
  testWidgets('Word Hunt full app navigation and gameplay smoke test', (
    WidgetTester tester,
  ) async {
    // Set a phone-like viewport size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    // Build Word Hunt app
    await tester.pumpWidget(const WordHuntApp());
    await tester.pumpAndSettle();

    // Verify Home Screen renders title and primary elements
    expect(find.text('Good evening, Subha 👋'), findsOneWidget);
    expect(find.text('CONTINUE PUZZLE'), findsOneWidget);
    expect(find.text('Level 27'), findsOneWidget);
    expect(find.text('Autumn Breeze'), findsOneWidget);

    // Verify 4 bottom navigation items exist (Badges removed from bottom bar)
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Levels'), findsOneWidget);
    expect(find.text('Daily'), findsOneWidget);
    expect(find.text('Badges'), findsNothing);
    expect(find.text('Profile'), findsOneWidget);

    // 1. Test Levels Tab
    await tester.tap(find.text('Levels'));
    await tester.pumpAndSettle();
    expect(
      find.text('WORLD 2: OCEAN SANCTUARY (Levels 21–40)'),
      findsOneWidget,
    );
    expect(find.text('Coral Trench'), findsOneWidget);
    expect(find.text('PLAY NOW'), findsOneWidget);

    // 2. Test Daily Tab
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    expect(find.text('Daily Challenge'), findsOneWidget);
    expect(find.text('Autumn Breeze 🍁'), findsOneWidget);
    expect(find.text('START CHALLENGE'), findsOneWidget);

    // 3. Test Profile Tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Subha WordMaster'), findsOneWidget);
    expect(find.text('Levels Solved'), findsOneWidget);
    expect(find.text('Words Found'), findsOneWidget);

    // 4. Test Opening Badges via Profile 'View All (18)'
    expect(find.text('View All (18)'), findsOneWidget);
    await tester.tap(find.text('View All (18)'));
    await tester.pumpAndSettle();
    expect(find.text('18 of 36 Badges'), findsOneWidget);
    expect(find.text('FIRST WORD'), findsOneWidget);
    expect(find.text('WORD STREAK'), findsOneWidget);

    // Pop back from Badges to Profile
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Subha WordMaster'), findsOneWidget);

    // 5. Return to Home and enter Game Screen
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CONTINUE PLAYING'));
    await tester.pumpAndSettle();

    // Verify Gameplay Screen
    expect(find.text('FIND WORDS'), findsOneWidget);
    expect(find.text('Hint 20🪙'), findsOneWidget);

    // 6. Return back to Home screen
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Good evening, Subha 👋'), findsOneWidget);
  });
}
