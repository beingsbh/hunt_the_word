import 'package:flutter/material.dart';

import '../core/widgets/app_bottom_nav.dart';
import '../features/achievements/screens/achievements_screen.dart';
import '../features/daily/screens/daily_challenge_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/levels/screens/level_map_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/themes/screens/themes_screen.dart';

/// Main navigation shell holding the 5 core tabs from the Figma design.
class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeScreen(
        onOpenMap: () => _onTabSelected(1),
        onOpenThemes: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const ThemesScreen()));
        },
        onOpenAchievements: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AchievementsScreen()),
          );
        },
        onOpenProfile: () => _onTabSelected(3),
      ),
      const LevelMapScreen(),
      const DailyChallengeScreen(),
      ProfileScreen(
        onOpenJourney: () => _onTabSelected(1),
      ),
    ];

    final navItems = const [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      BottomNavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view_rounded,
        label: 'Levels',
      ),
      BottomNavItem(
        icon: Icons.calendar_today_outlined,
        activeIcon: Icons.calendar_today_rounded,
        label: 'Daily',
      ),
      BottomNavItem(
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
        items: navItems,
      ),
    );
  }
}
