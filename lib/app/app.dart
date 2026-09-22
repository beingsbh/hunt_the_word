import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/theme_provider.dart';
import '../features/achievements/viewmodels/achievements_provider.dart';
import '../features/daily/viewmodels/daily_challenge_provider.dart';
import '../features/levels/viewmodels/level_progress_provider.dart';
import '../features/profile/viewmodels/player_profile_provider.dart';
import 'main_navigation_shell.dart';

/// Root application widget configuring all core ViewModels and Material 3 theme.
class WordHuntApp extends StatelessWidget {
  const WordHuntApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => PlayerProfileProvider()),
        ChangeNotifierProvider(create: (_) => LevelProgressProvider()),
        ChangeNotifierProvider(create: (_) => DailyChallengeProvider()),
        ChangeNotifierProvider(create: (_) => AchievementsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Word Hunt',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.themeData,
            home: const MainNavigationShell(),
          );
        },
      ),
    );
  }
}
