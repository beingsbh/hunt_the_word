import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:hunt_the_word/features/auth/screens/login_screen.dart';
import 'package:hunt_the_word/features/home/screens/home_screen.dart';
import 'package:hunt_the_word/features/profile/viewmodels/player_profile_provider.dart';

void main() {
  group('Unique Username & Social Login Flow', () {
    testWidgets('New user gets 500 coins and triggers username setup upon social login', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      bool loggedIn = false;
      final profileProvider = PlayerProfileProvider();

      // Ensure fresh state
      expect(profileProvider.coins, equals(500));

      await tester.pumpWidget(
        ChangeNotifierProvider<PlayerProfileProvider>.value(
          value: profileProvider,
          child: MaterialApp(
            home: LoginScreen(
              onLoginSuccess: () {
                loggedIn = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify only social buttons exist (no text fields)
      expect(find.byType(TextField), findsNothing);
      expect(find.byKey(const Key('google_login_button')), findsOneWidget);
      expect(find.byKey(const Key('facebook_login_button')), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Facebook'), findsOneWidget);

      // Tap Google Login
      await tester.tap(find.byKey(const Key('google_login_button')));
      await tester.pumpAndSettle();

      expect(loggedIn, isTrue);
      expect(profileProvider.coins, equals(500));
      expect(profileProvider.needsUsernameSetup, isTrue);
      expect(profileProvider.hasSetUniqueUsername, isFalse);
    });

    testWidgets('Home screen shows unique username popup on first login and sets username once', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);

      final profileProvider = PlayerProfileProvider();
      profileProvider.flagNeedsUsernameSetup();

      await tester.pumpWidget(
        ChangeNotifierProvider<PlayerProfileProvider>.value(
          value: profileProvider,
          child: MaterialApp(
            home: HomeScreen(
              onOpenMap: () {},
              onOpenThemes: () {},
              onOpenAchievements: () {},
              onOpenProfile: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.text('Claim Your Hunter Tag'), findsOneWidget);
      expect(
        find.text(
          'Generate or customize your unique username. This is set one time only for your profile!',
        ),
        findsOneWidget,
      );

      final rollButton = find.byKey(const Key('generate_username_button'));
      expect(rollButton, findsOneWidget);

      final confirmButton = find.byKey(const Key('confirm_username_button'));
      expect(confirmButton, findsOneWidget);

      // Get initial generated username
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      final initialName = (tester.widget<TextField>(textField)).controller!.text;
      expect(initialName.isNotEmpty, isTrue);

      // Tap Roll to generate a new name
      await tester.tap(rollButton);
      await tester.pumpAndSettle();

      // Enter a custom valid username
      await tester.enterText(textField, 'CosmicRiddle_99');
      await tester.pumpAndSettle();

      // Confirm username
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('Claim Your Hunter Tag'), findsNothing);
      expect(profileProvider.hasSetUniqueUsername, isTrue);
      expect(profileProvider.needsUsernameSetup, isFalse);
      expect(profileProvider.nickname, equals('CosmicRiddle_99'));

      // Re-pumping home screen should not show dialog again
      await tester.pump();
      expect(find.text('Claim Your Hunter Tag'), findsNothing);
    });
  });
}
