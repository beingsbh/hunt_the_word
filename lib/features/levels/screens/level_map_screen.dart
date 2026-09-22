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
class LevelMapScreen extends StatefulWidget {
  const LevelMapScreen({super.key});

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _activeLevelKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActiveLevel();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActiveLevel() {
    if (!mounted) return;
    final targetContext = _activeLevelKey.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.35,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onStartLevel(BuildContext context, int level, String title) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GameScreen(levelNumber: level, category: title),
      ),
    );
  }

  int _getMysteryBoxReward(int level) {
    final interval = (level / 10).ceil();
    if (interval <= 1) return 20;
    double reward = 20.0;
    for (int i = 1; i < interval; i++) {
      reward *= 1.5;
    }
    return reward.round();
  }

  String _getWorldTitle(int world) {
    switch (world) {
      case 1:
        return 'WORLD 1: VERDANT FOREST (Levels 1–20)';
      case 2:
        return 'WORLD 2: OCEAN SANCTUARY (Levels 21–40)';
      case 3:
        return 'WORLD 3: SKY REALM (Levels 41–60)';
      default:
        final start = (world - 1) * 20 + 1;
        final end = world * 20;
        return 'WORLD $world (Levels $start–$end)';
    }
  }

  void _showWorldPicker(BuildContext context, LevelProgressProvider provider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Select World', style: AppTextStyles.headlineSmall()),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                leading:
                    const Icon(Icons.forest_rounded, color: AppColors.success),
                title: const Text('World 1: Verdant Forest (Levels 1–20)'),
                trailing: provider.currentWorld == 1
                    ? const Icon(Icons.check, color: AppColors.success)
                    : null,
                onTap: () {
                  provider.setWorld(1);
                  Navigator.pop(ctx);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToActiveLevel();
                  });
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.waves_rounded, color: Color(0xFF00B4D8)),
                title: const Text('World 2: Ocean Sanctuary (Levels 21–40)'),
                trailing: provider.currentWorld == 2
                    ? const Icon(Icons.check, color: Color(0xFF00B4D8))
                    : null,
                onTap: () {
                  provider.setWorld(2);
                  Navigator.pop(ctx);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToActiveLevel();
                  });
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.cloud_rounded, color: Color(0xFF6C5CE7)),
                title: const Text('World 3: Sky Realm (Levels 41–60)'),
                trailing: provider.currentWorld == 3
                    ? const Icon(Icons.check, color: Color(0xFF6C5CE7))
                    : null,
                onTap: () {
                  provider.setWorld(3);
                  Navigator.pop(ctx);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToActiveLevel();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProgressionPath(
    BuildContext context,
    LevelProgressProvider levelProgress,
  ) {
    final currentWorld = levelProgress.currentWorld;
    final int startLevel;
    final int endLevel;
    switch (currentWorld) {
      case 1:
        startLevel = 1;
        endLevel = 20;
        break;
      case 2:
        startLevel = 21;
        endLevel = 30;
        break;
      case 3:
        startLevel = 31;
        endLevel = 40;
        break;
      default:
        startLevel = (currentWorld - 1) * 10 + 1;
        endLevel = currentWorld * 10;
    }

    final widgets = <Widget>[];
    for (int lvl = endLevel; lvl >= startLevel; lvl--) {
      final node = levelProgress.getLevelNode(lvl);
      if (lvl == endLevel) {
        widgets.add(_buildBossNode(
          context,
          level: lvl,
          title: node.title.isNotEmpty ? node.title : 'Star Gate Boss',
          rewardCoins: 500,
          isUnlocked: node.isUnlocked,
        ));
      } else if (lvl == endLevel - 1 || lvl % 10 == 9 || lvl % 10 == 0) {
        final mysteryReward = _getMysteryBoxReward(lvl);
        widgets.add(_buildTreasureNode(
          context,
          level: lvl,
          title: node.title.isNotEmpty ? node.title : 'Bonus Treasure',
          subtitle: 'Mystery Box (+$mysteryReward🪙)',
          rewardCoins: mysteryReward,
          isUnlocked: node.isUnlocked,
        ));
      } else if (node.isCurrent) {
        widgets.add(_buildActiveLevelCard(context, node));
      } else if (node.isCompleted) {
        widgets.add(_buildCompletedNode(
          context,
          level: lvl,
          stars: node.stars,
          title: node.title,
          subtitle: node.stars == 3 ? '3-STAR MASTER' : 'Completed',
          color: node.stars == 3
              ? AppColors.primaryEmerald
              : AppColors.coinGoldDark,
        ));
      } else {
        widgets.add(_buildLockedNode(
          level: lvl,
          title: node.title,
        ));
      }

      if (lvl > startLevel) {
        widgets.add(_buildDottedConnector());
      }
    }
    return widgets;
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
              child: GestureDetector(
                onTap: () => _showWorldPicker(context, levelProgress),
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
                          _getWorldTitle(levelProgress.currentWorld),
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
            ),

            // Vertical Winding Progression Path
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  ..._buildProgressionPath(context, levelProgress),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          mini: true,
          backgroundColor: AppColors.coinGoldDark,
          tooltip: 'Play Level ${levelProgress.activeLevel}',
          onPressed: () {
            final activeNode =
                levelProgress.getLevelNode(levelProgress.activeLevel);
            _onStartLevel(context, activeNode.levelNumber, activeNode.title);
          },
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildActiveLevelCard(BuildContext context, LevelNodeState node) {
    return Container(
      key: _activeLevelKey,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        builder: (context, glowProgress, child) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: AppRadius.radiusLg,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7)
                      .withValues(alpha: 0.28 * glowProgress),
                  blurRadius: 18 * glowProgress,
                  spreadRadius: 2 * glowProgress,
                ),
              ],
            ),
            child: child,
          );
        },
        child: AppCard(
        padding: AppSpacing.paddingLg,
        border: Border.all(color: const Color(0xFF6C5CE7), width: 2.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                        'ACTIVE QUEST',
                        style:
                            AppTextStyles.buttonSmall(color: AppColors.warning)
                                .copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Level ${node.levelNumber}',
                  style: const TextStyle(
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
                  child: Center(
                    child: Text(
                      '${node.levelNumber}',
                      style: const TextStyle(
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
                      Text(node.title, style: AppTextStyles.headlineMedium()),
                      Text(
                        node.description.isNotEmpty
                            ? node.description
                            : 'Find all hidden words before time expires',
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
              onPressed: () =>
                  _onStartLevel(context, node.levelNumber, node.title),
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
      ),
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
    int rewardCoins = 20,
    bool isUnlocked = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isUnlocked ? () => _onStartLevel(context, level, title) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? AppColors.error.withValues(alpha: 0.25)
                  : AppColors.error.withValues(alpha: 0.15),
              borderRadius: AppRadius.radiusMd,
              border: Border.all(
                color: isUnlocked
                    ? AppColors.error
                    : AppColors.error.withValues(alpha: 0.5),
                width: isUnlocked ? 2 : 1,
              ),
            ),
            child: Center(
              child: Icon(
                isUnlocked ? Icons.card_giftcard_rounded : Icons.lock_rounded,
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
      ),
    );
  }

  Widget _buildBossNode(
    BuildContext context, {
    required int level,
    required String title,
    required int rewardCoins,
    bool isUnlocked = false,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isUnlocked ? () => _onStartLevel(context, level, title) : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? AppColors.coinGold.withValues(alpha: 0.35)
                  : AppColors.coinGold.withValues(alpha: 0.2),
              border: Border.all(
                color: isUnlocked ? AppColors.coinGoldDark : AppColors.coinGold,
                width: 2.5,
              ),
            ),
            child: Center(
              child: Icon(
                isUnlocked ? Icons.stars_rounded : Icons.lock_clock_rounded,
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
                  isUnlocked
                      ? 'Boss Unlocked! Defeat for +$rewardCoins🪙'
                      : 'Defeat boss for +$rewardCoins🪙 reward',
                  style: AppTextStyles.bodySmall(),
                ),
              ],
            ),
          ),
        ],
      ),
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
