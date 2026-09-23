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
import '../models/world_model.dart';
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

  String _getWorldTitle(LevelProgressProvider levelProgress) {
    final world = levelProgress.selectedWorld;
    return '${world.icon} WORLD ${world.worldNumber}: ${world.name.toUpperCase()} (${world.levelRangeDisplay})';
  }

  void _showWorldPicker(BuildContext context, LevelProgressProvider provider) {
    final theme = Theme.of(context);
    final worlds = provider.worlds;
    final totalStars = worlds.fold<int>(0, (sum, w) => sum + w.starsEarned);
    final totalMaxStars = worlds.fold<int>(0, (sum, w) => sum + w.maxStars);
    final unlockedCount = worlds.where((w) => w.unlocked).length;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scrollSheetController) => Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Sheet Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'World Map 🗺️',
                                style: AppTextStyles.headlineSmall(),
                              ),
                              if (provider.isLoadingWorlds) ...[
                                const SizedBox(width: 8),
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '$unlockedCount of ${worlds.length} Worlds Unlocked',
                            style: AppTextStyles.bodySmall(),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.coinGoldDark.withValues(alpha: 0.15),
                        borderRadius: AppRadius.radiusPill,
                        border: Border.all(
                          color: AppColors.coinGoldDark.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.coinGoldDark,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$totalStars/$totalMaxStars',
                            style: AppTextStyles.buttonSmall(
                              color: AppColors.coinGoldDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: AppSpacing.lg),

              // World List
              Expanded(
                child: ListView.separated(
                  controller: scrollSheetController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  itemCount: worlds.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final WorldModel world = worlds[index];
                    final isCurrent = provider.currentWorld == world.worldNumber;
                    final isUnlocked = world.unlocked;

                    return GestureDetector(
                      onTap: () {
                        if (isUnlocked) {
                          provider.setWorld(world.worldNumber);
                          Navigator.pop(ctx);
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToActiveLevel();
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Reach Level ${world.startLevel} to unlock ${world.name}!',
                              ),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: AppSpacing.paddingMd,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : (isUnlocked
                                  ? theme.cardColor
                                  : theme.cardColor.withValues(alpha: 0.45)),
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: isCurrent
                                ? theme.colorScheme.primary
                                : (isUnlocked
                                    ? theme.dividerColor.withValues(alpha: 0.2)
                                    : Colors.transparent),
                            width: isCurrent ? 2.0 : 1.0,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                // World Emoji / Icon
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: isUnlocked
                                        ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                        : Colors.grey.withValues(alpha: 0.15),
                                    borderRadius: AppRadius.radiusMd,
                                  ),
                                  child: Center(
                                    child: isUnlocked
                                        ? Text(
                                            world.icon,
                                            style: const TextStyle(fontSize: 22),
                                          )
                                        : const Icon(
                                            Icons.lock_rounded,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),

                                // Title and Subtitle
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'World ${world.worldNumber}: ${world.name}',
                                              style: AppTextStyles.headlineSmall().copyWith(
                                                fontSize: 15,
                                                color: isUnlocked
                                                    ? theme.colorScheme.onSurface
                                                    : theme.colorScheme.onSurface.withValues(alpha: 0.45),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (world.isCompleted) ...[
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              size: 16,
                                              color: AppColors.success,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isUnlocked
                                            ? '${world.levelRangeDisplay} • ${world.category}'
                                            : 'Unlocks at Level ${world.startLevel}',
                                        style: AppTextStyles.bodySmall().copyWith(
                                          color: isUnlocked
                                              ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
                                              : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Trailing Pill or Arrow
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryEmerald.withValues(alpha: 0.18),
                                      borderRadius: AppRadius.radiusPill,
                                      border: Border.all(
                                        color: AppColors.primaryEmerald.withValues(alpha: 0.5),
                                      ),
                                    ),
                                    child: const Text(
                                      'ACTIVE',
                                      style: TextStyle(
                                        color: AppColors.primaryEmerald,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                else if (isUnlocked)
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                                  )
                                else
                                  const Icon(
                                    Icons.lock_outline_rounded,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                              ],
                            ),

                            // Progress Bar & Stats (if unlocked)
                            if (isUnlocked) ...[
                              const SizedBox(height: AppSpacing.sm),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: world.completionProgress,
                                  minHeight: 4,
                                  backgroundColor: theme.dividerColor.withValues(alpha: 0.15),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryEmerald,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${world.completedLevels}/${world.totalLevels} levels',
                                    style: AppTextStyles.bodySmall().copyWith(fontSize: 11),
                                  ),
                                  Text(
                                    '⭐ ${world.starsEarned}/${world.maxStars}',
                                    style: AppTextStyles.bodySmall().copyWith(
                                      fontSize: 11,
                                      color: AppColors.coinGoldDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
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
    final selectedWorld = levelProgress.selectedWorld;
    final int startLevel = selectedWorld.startLevel;
    final int endLevel = selectedWorld.endLevel;

    final widgets = <Widget>[];
    for (int lvl = endLevel; lvl >= startLevel; lvl--) {
      final node = levelProgress.getLevelNode(lvl);
      if (lvl == endLevel) {
        widgets.add(_buildBossNode(
          context,
          level: lvl,
          title: node.title.isNotEmpty
              ? node.title
              : '${selectedWorld.name} Star Gate',
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
        widgets.add(_buildActiveLevelCard(context, node, selectedWorld.category));
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
          IconButton(
            icon: const Icon(Icons.map_rounded, color: AppColors.primaryEmerald),
            tooltip: 'World Map 🗺️',
            onPressed: () => _showWorldPicker(context, levelProgress),
          ),
          CoinBadge(coins: profile.coins),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: GradientBackground(
        child: RefreshIndicator(
          onRefresh: () async {
            await levelProgress.refreshWorlds();
          },
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
                            _getWorldTitle(levelProgress),
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
                  physics: const AlwaysScrollableScrollPhysics(),
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
            _onStartLevel(
              context,
              activeNode.levelNumber,
              levelProgress.selectedWorld.category,
            );
          },
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildActiveLevelCard(
    BuildContext context,
    LevelNodeState node, [
    String? category,
  ]) {
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
              onPressed: () => _onStartLevel(
                context,
                node.levelNumber,
                category ?? node.title,
              ),
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
