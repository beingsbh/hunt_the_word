import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_coin_icon.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../profile/viewmodels/player_profile_provider.dart';
import '../models/achievement_mock_data.dart';
import '../viewmodels/achievements_provider.dart';

/// Badges & Achievements screen matching the exact Word Hunt design mockup.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  int _selectedFilterIndex =
      0; // 0: All, 1: Completed, 2: In Progress, 3: Locked

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PlayerProfileProvider>();
    final achievements = context.watch<AchievementsProvider>();

    final allList = achievements.allAchievements;
    final completedList = allList.where((a) => a.isCompleted).toList();
    final inProgressList =
        allList.where((a) => !a.isCompleted && a.currentProgress > 0).toList();
    final lockedList =
        allList.where((a) => !a.isCompleted && a.currentProgress == 0).toList();

    List<AchievementMockItem> displayedList;
    switch (_selectedFilterIndex) {
      case 1:
        displayedList = completedList;
        break;
      case 2:
        displayedList = inProgressList;
        break;
      case 3:
        displayedList = lockedList;
        break;
      default:
        displayedList = allList;
        break;
    }

    return Scaffold(
      appBar: AppCustomBar(
        title: 'Badges & Achievements',
        actions: [
          CoinBadge(coins: profile.coins),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: GradientBackground(
        child: ListView(
          padding: AppSpacing.paddingMd,
          children: [
            // Collector Tier III Hero Card
            AppCard(
              padding: AppSpacing.paddingLg,
              gradient: const LinearGradient(
                colors: [Color(0xFF5138EE), Color(0xFF6C5CE7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadius.radiusPill,
                        ),
                        child: Text(
                          'COLLECTOR TIER III',
                          style: AppTextStyles.buttonSmall(color: Colors.white)
                              .copyWith(fontSize: 10),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AnimatedCoinIcon(size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '1,450 PTS',
                            style: AppTextStyles.buttonSmall(
                              color: AppColors.coinGoldLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${achievements.completedCount} of ${achievements.totalAchievements} Badges',
                              style: AppTextStyles.headlineLarge(
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Halfway to Grandmaster Lexicon',
                              style: AppTextStyles.bodySmall(
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '${(achievements.totalProgressFraction * 100).toInt()}%',
                        style: AppTextStyles.displayMedium(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0.0,
                      end: achievements.totalProgressFraction,
                    ),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutCubic,
                    builder: (context, factor, _) {
                      return ClipRRect(
                        borderRadius: AppRadius.radiusPill,
                        child: Container(
                          height: 8,
                          color: Colors.white.withValues(alpha: 0.25),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: factor,
                              child: Container(color: AppColors.coinGold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Filter Tabs Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterTab('All (${allList.length})', 0),
                  const SizedBox(width: AppSpacing.xs),
                  _buildFilterTab(
                    'Completed (${completedList.length})',
                    1,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildFilterTab(
                    'In Progress (${inProgressList.length})',
                    2,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildFilterTab('Locked (${lockedList.length})', 3),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Dynamically filtered achievement cards
            if (displayedList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text(
                    'No badges in this category yet.',
                    style: AppTextStyles.bodyMedium(color: Colors.grey),
                  ),
                ),
              )
            else
              ...displayedList.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _buildAchievementCard(
                    context,
                    item,
                    achievements,
                    profile,
                  ),
                ),
              ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, int index) {
    final isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6C5CE7) : Colors.white,
          borderRadius: AppRadius.radiusPill,
          border: Border.all(
            color: isSelected ? const Color(0xFF6C5CE7) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          child: Text(label),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(
    BuildContext context,
    AchievementMockItem item,
    AchievementsProvider achievements,
    PlayerProfileProvider profile,
  ) {
    Color badgeColor;
    String statusLabel;
    Color statusColor;

    if (item.isClaimed) {
      badgeColor = AppColors.coinGoldDark;
      statusLabel = 'CLAIMED';
      statusColor = AppColors.primaryEmerald;
    } else if (item.isCompleted) {
      badgeColor = AppColors.primaryEmerald;
      statusLabel = 'COMPLETED';
      statusColor = AppColors.coinGoldDark;
    } else if (item.currentProgress > 0) {
      badgeColor = AppColors.warning;
      statusLabel = 'IN PROGRESS';
      statusColor = AppColors.warning;
    } else {
      badgeColor = Colors.grey;
      statusLabel = 'LOCKED';
      statusColor = Colors.grey;
    }

    return AppCard(
      padding: AppSpacing.paddingMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgeIcon(item.icon, badgeColor),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title.toUpperCase(),
                        style: AppTextStyles.headlineSmall(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _buildStatusChip(statusLabel, statusColor),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: AppTextStyles.bodySmall(),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.currentProgress} / ${item.targetProgress}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(item.progressFraction * 100).toInt()}%',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AppProgressBar(
                  progress: item.progressFraction,
                  height: 6,
                  fillColor: badgeColor,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const AnimatedCoinIcon(size: 15),
                        const SizedBox(width: 4),
                        Text(
                          '+${item.rewardCoins} Coins',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    if (item.isCompleted && !item.isClaimed)
                      GestureDetector(
                        onTap: () async {
                          final coins = await achievements.claimReward(item.id);
                          if (coins != null && context.mounted) {
                            profile.refreshFromStorage();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Claimed +$coins Coins! 🎉'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.coinGoldLight,
                                AppColors.coinGoldDark,
                              ],
                            ),
                            borderRadius: AppRadius.radiusPill,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    AppColors.coinGold.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'CLAIM REWARD',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )
                    else if (item.isClaimed)
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 14,
                            color: AppColors.primaryEmerald,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Claimed',
                            style: AppTextStyles.bodySmall().copyWith(
                              color: AppColors.primaryEmerald,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        item.currentProgress == 0 ? 'Locked' : 'In Progress',
                        style: AppTextStyles.bodySmall().copyWith(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(IconData icon, Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.75, end: 1.0),
      duration: const Duration(milliseconds: 320),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: child,
      ),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: AppRadius.radiusMd,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.radiusPill,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
