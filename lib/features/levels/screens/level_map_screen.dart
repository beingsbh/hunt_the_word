import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/star_display.dart';
import '../../game/screens/game_screen.dart';
import '../../profile/viewmodels/player_profile_provider.dart';
import '../viewmodels/level_progress_provider.dart';

/// Level Map Screen matching the winding oceanic progression path design.
class LevelMapScreen extends StatelessWidget {
  const LevelMapScreen({super.key});

  void _onStartLevel(BuildContext context, int level, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(levelNumber: level, category: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<PlayerProfileProvider>();
    final levelProgress = context.watch<LevelProgressProvider>();

    return Scaffold(
      appBar: AppCustomBar(
        title: 'Level Map',
        actions: [
          CoinBadge(coins: profile.coins),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: GradientBackground(
        child: Column(
          children: [
            // Chapter Selector Dropdown Pill
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 4,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: AppRadius.radiusPill,
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'WORLD 2: OCEAN SANCTUARY (Levels 21–40)',
                        style: AppTextStyles.buttonSmall(
                          color: theme.colorScheme.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),

            // Worlds Tab Bar Filter
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildWorldTab(
                      label: 'World 1: 100% Complete',
                      icon: Icons.check_circle_rounded,
                      isActive: false,
                      color: AppColors.success,
                      onTap: () => levelProgress.setWorld(1),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _buildWorldTab(
                      label: 'World 2: Ocean (Active)',
                      icon: Icons.waves_rounded,
                      isActive: true,
                      color: theme.colorScheme.primary,
                      onTap: () => levelProgress.setWorld(2),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _buildWorldTab(
                      label: 'World 3: Sky Realm',
                      icon: Icons.lock_rounded,
                      isActive: false,
                      color: Colors.grey,
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),

            // Vertical Winding Progression Path
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // Boss Star Gate Node 30
                  _buildBossNode(
                    context,
                    level: 30,
                    title: 'Star Gate Boss',
                    rewardCoins: 500,
                  ),
                  _buildDottedConnector(),

                  // Mystery Bonus Treasure Node 29
                  _buildTreasureNode(
                    context,
                    level: 29,
                    title: 'Bonus Treasure',
                    subtitle: 'Mystery Rewards',
                  ),
                  _buildDottedConnector(),

                  // Locked Node 28
                  _buildLockedNode(level: 28, title: 'Undersea Clues'),
                  _buildDottedConnector(),

                  // Active Level 27 Floating Hero Card
                  _buildActiveLevel27Card(context),
                  _buildDottedConnector(),

                  // Completed Node 26
                  _buildCompletedNode(
                    context,
                    level: 26,
                    stars: 2,
                    title: 'Level 26',
                    subtitle: 'Completed',
                    color: AppColors.coinGoldDark,
                  ),
                  _buildDottedConnector(),

                  // Completed Node 25 (3-Star Master)
                  _buildCompletedNode(
                    context,
                    level: 25,
                    stars: 3,
                    title: 'Level 25',
                    subtitle: '3-STAR MASTER',
                    color: AppColors.primaryEmerald,
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: AppColors.coinGoldDark,
          onPressed: () {
            _onStartLevel(context, 27, 'Coral Trench');
          },
          child: const Icon(Icons.casino_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildWorldTab({
    required String label,
    required IconData icon,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.12),
          borderRadius: AppRadius.radiusPill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? Colors.white : color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.buttonSmall(
                color: isActive ? Colors.white : color,
              ).copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveLevel27Card(BuildContext context) {
    return AppCard(
      padding: AppSpacing.paddingLg,
      border: Border.all(color: const Color(0xFF6C5CE7), width: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: AppRadius.radiusPill,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'SPEED CHALLENGE',
                      style: AppTextStyles.buttonSmall(color: AppColors.warning)
                          .copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const Text(
                '8/10 Words',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C5CE7),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7),
                  borderRadius: AppRadius.radiusMd,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '27',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coral Trench', style: AppTextStyles.headlineMedium()),
                    Text(
                      'Find 10 hidden sea words before time expires',
                      style: AppTextStyles.bodySmall(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            text: 'PLAY NOW',
            icon: Icons.play_arrow_rounded,
            onPressed: () => _onStartLevel(context, 27, 'Coral Trench'),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(
              '★★☆ Earn 3 Stars for 50 Bonus Coins',
              style: AppTextStyles.bodySmall().copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedNode(
    BuildContext context, {
    required int level,
    required int stars,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _onStartLevel(context, level, title),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: color, width: 2.5),
            ),
            child: Center(
              child: Text(
                '$level',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                StarDisplay(earnedStars: stars, starSize: 16),
                Text(
                  '$title • $subtitle',
                  style: AppTextStyles.bodySmall().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedNode({required int level, required String title}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: const Center(
            child: Icon(Icons.lock_rounded, size: 20, color: Colors.grey),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'UP NEXT',
                style: AppTextStyles.bodySmall().copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: AppTextStyles.bodyMedium(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTreasureNode(
    BuildContext context, {
    required int level,
    required String title,
    required String subtitle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.15),
            borderRadius: AppRadius.radiusMd,
            border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
          ),
          child: const Center(
            child: Icon(
              Icons.card_giftcard_rounded,
              color: AppColors.error,
              size: 24,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lvl $level $title',
                style: AppTextStyles.headlineSmall().copyWith(fontSize: 14),
              ),
              Text(subtitle, style: AppTextStyles.bodySmall()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBossNode(
    BuildContext context, {
    required int level,
    required String title,
    required int rewardCoins,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.coinGold.withValues(alpha: 0.2),
            border: Border.all(color: AppColors.coinGold, width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.lock_clock_rounded,
              color: AppColors.coinGoldDark,
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '⭐ $title',
                style: AppTextStyles.headlineSmall().copyWith(fontSize: 14),
              ),
              Text(
                'Defeat boss for +$rewardCoins🪙 reward',
                style: AppTextStyles.bodySmall(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDottedConnector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Column(
          children: List.generate(
            3,
            (_) => Container(
              width: 4,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: const BoxDecoration(
                color: Color(0xFFB0A4F5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
