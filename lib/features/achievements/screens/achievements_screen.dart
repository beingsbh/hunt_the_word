import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../profile/viewmodels/player_profile_provider.dart';
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
                      Text(
                        '🪙 1,450 PTS',
                        style: AppTextStyles.buttonSmall(
                          color: AppColors.coinGoldLight,
                        ),
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
                              '18 of 36 Badges',
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
                        '50%',
                        style: AppTextStyles.displayMedium(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 0.5),
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
                  _buildFilterTab('All (${achievements.totalAchievements})', 0),
                  const SizedBox(width: AppSpacing.xs),
                  _buildFilterTab(
                    'Completed (${achievements.completedCount})',
                    1,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildFilterTab(
                    'In Progress (${achievements.totalAchievements - achievements.completedCount})',
                    2,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildFilterTab('Locked (0)', 3),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Achievement Cards matching Mockup
            _buildFirstWordCard(),
            const SizedBox(height: AppSpacing.sm),
            _buildWordStreakCard(),
            const SizedBox(height: AppSpacing.sm),
            _buildSpeedSolverCard(),
            const SizedBox(height: AppSpacing.sm),
            _buildMasterHunterCard(),
            const SizedBox(height: AppSpacing.sm),
            _buildNightOwlCard(),
            const SizedBox(height: 40),
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

  Widget _buildFirstWordCard() {
    return AppCard(
      padding: AppSpacing.paddingMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgeIcon(Icons.search_rounded, AppColors.coinGoldDark),
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
                        'FIRST WORD',
                        style: AppTextStyles.headlineSmall(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _buildStatusChip('COMPLETED', AppColors.primaryEmerald),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Find your very first hidden word.',
                  style: AppTextStyles.bodySmall(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🪙 +25 Coins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
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

  Widget _buildWordStreakCard() {
    return AppCard(
      padding: AppSpacing.paddingMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgeIcon(
            Icons.local_fire_department_rounded,
            AppColors.warning,
          ),
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
                        'WORD STREAK',
                        style: AppTextStyles.headlineSmall(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _buildStatusChip('IN PROGRESS', AppColors.warning),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Find 50 words without using a single hint.',
                  style: AppTextStyles.bodySmall(),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '32 / 50 Words',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '64%',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const AppProgressBar(
                  progress: 0.64,
                  height: 6,
                  fillColor: AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🪙 +100 Coins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '18 remaining',
                      style: AppTextStyles.bodySmall().copyWith(fontSize: 10),
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

  Widget _buildSpeedSolverCard() {
    return AppCard(
      padding: AppSpacing.paddingMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgeIcon(Icons.bolt_rounded, const Color(0xFF6C5CE7)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'SPEED SOLVER',
                          style: AppTextStyles.headlineSmall(),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.starActive,
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.starActive,
                        ),
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: AppColors.starActive,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Solve an entire puzzle board in under 60 seconds.',
                  style: AppTextStyles.bodySmall(),
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildStatusChip(
                  'COMPLETED • 42S RECORD',
                  AppColors.primaryEmerald,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🪙 +50 Coins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
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

  Widget _buildMasterHunterCard() {
    return AppCard(
      padding: AppSpacing.paddingMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgeIcon(Icons.military_tech_rounded, const Color(0xFF8B5CF6)),
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
                        'MASTER HUNTER',
                        style: AppTextStyles.headlineSmall(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _buildStatusChip('MAJOR GOAL', const Color(0xFF8B5CF6)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Conquer 100 adventure levels.',
                  style: AppTextStyles.bodySmall(),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '72 / 100 Levels',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      '72%',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const AppProgressBar(
                  progress: 0.72,
                  height: 6,
                  fillColor: Color(0xFF8B5CF6),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  '🪙 +250 Coins & Master Title',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNightOwlCard() {
    return AppCard(
      padding: AppSpacing.paddingMd,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBadgeIcon(Icons.dark_mode_rounded, Colors.grey),
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
                        'NIGHT OWL',
                        style: AppTextStyles.headlineSmall(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _buildStatusChip('🔒 LOCKED', Colors.grey),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Complete 5 daily puzzles after 10 PM.',
                  style: AppTextStyles.bodySmall(),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Progress: 1/5 Completed',
                  style: AppTextStyles.bodySmall().copyWith(fontSize: 11),
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🪙 +50 Coins',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      'Daily Challenge',
                      style: AppTextStyles.bodySmall().copyWith(fontSize: 10),
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
