import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_the_word/app/app.dart';
import 'package:hunt_the_word/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('Settings screen displays logout button and confirms logout', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const WordHuntApp());
    await tester.pumpAndSettle();

    // Navigate to Settings Screen from Home Screen top bar
    final settingsIcon = find.byIcon(Icons.settings_rounded);
    expect(settingsIcon, findsOneWidget);
    await tester.tap(settingsIcon);
    await tester.pumpAndSettle();

    // Verify on Settings screen
    expect(find.text('Settings'), findsOneWidget);

    // Scroll until logout button is visible in the ListView
    final logoutButton = find.byKey(const Key('logout_button'));
    await tester.scrollUntilVisible(
      logoutButton,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();

    expect(logoutButton, findsOneWidget);
    expect(find.text('LOG OUT'), findsOneWidget);

    // Tap Logout Button
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();

    // Verify Confirmation Dialog
    expect(find.text('Log Out?'), findsOneWidget);
    expect(
      find.text(
        'Are you sure you want to log out? Your game progress remains saved on this device.',
      ),
      findsOneWidget,
    );

    // Tap Cancel first to test dismissal
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();
    expect(find.text('Log Out?'), findsNothing);
    expect(find.text('Settings'), findsOneWidget);

    // Tap Logout Button again and confirm
    await tester.tap(logoutButton);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'LOG OUT'));
    await tester.pumpAndSettle();

    // Should now be on the Login screen with social logins
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome to Word Hunt'), findsOneWidget);
    expect(find.byKey(const Key('google_login_button')), findsOneWidget);
    expect(find.byKey(const Key('facebook_login_button')), findsOneWidget);
  });
}
