import 'package:flutter/material.dart';

/// Achievement item data representation for milestones and trophy cards.
class AchievementMockItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final int currentProgress;
  final int targetProgress;
  final int rewardCoins;
  final bool isClaimed;

  const AchievementMockItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.currentProgress,
    required this.targetProgress,
    required this.rewardCoins,
    this.isClaimed = false,
  });

  bool get isCompleted => currentProgress >= targetProgress;

  double get progressFraction => targetProgress == 0
      ? 1.0
      : (currentProgress / targetProgress).clamp(0.0, 1.0);

  static List<AchievementMockItem> getMockAchievements() {
    return const [
      AchievementMockItem(
        id: 'first_word',
        title: 'First Discovery',
        description: 'Find your very first hidden word on any grid.',
        icon: Icons.search_rounded,
        currentProgress: 1,
        targetProgress: 1,
        rewardCoins: 50,
        isClaimed: true,
      ),
      AchievementMockItem(
        id: 'word_streak',
        title: 'Streak Master',
        description: 'Maintain a consecutive 7-day daily puzzle streak.',
        icon: Icons.local_fire_department_rounded,
        currentProgress: 7,
        targetProgress: 7,
        rewardCoins: 150,
        isClaimed: false,
      ),
      AchievementMockItem(
        id: 'speed_solver',
        title: 'Lightning Reflexes',
        description: 'Complete any 7x7 puzzle in under 90 seconds.',
        icon: Icons.bolt_rounded,
        currentProgress: 1,
        targetProgress: 1,
        rewardCoins: 100,
        isClaimed: true,
      ),
      AchievementMockItem(
        id: 'master_hunter',
        title: 'Vocabulary Titan',
        description: 'Locate 1,000 total words across all game modes.',
        icon: Icons.military_tech_rounded,
        currentProgress: 845,
        targetProgress: 1000,
        rewardCoins: 500,
        isClaimed: false,
      ),
      AchievementMockItem(
        id: 'night_owl',
        title: 'Star Gazer',
        description: 'Earn 100 total stars on the oceanic level map.',
        icon: Icons.star_rounded,
        currentProgress: 78,
        targetProgress: 100,
        rewardCoins: 250,
        isClaimed: false,
      ),
      AchievementMockItem(
        id: 'chapter_clear',
        title: 'Island Conqueror',
        description: 'Clear all 30 levels of Chapter 1 with 3 stars.',
        icon: Icons.explore_rounded,
        currentProgress: 26,
        targetProgress: 30,
        rewardCoins: 300,
        isClaimed: false,
      ),
    ];
  }
}
