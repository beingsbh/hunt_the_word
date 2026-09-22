import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../completion/screens/level_complete_dialog.dart';
import '../../levels/viewmodels/level_progress_provider.dart';
import '../../profile/viewmodels/player_profile_provider.dart';
import '../../settings/screens/settings_screen.dart';
import '../viewmodels/game_provider.dart';
import '../widgets/interactive_game_board.dart';
import '../widgets/target_word_chip.dart';

/// Full gameplay screen matching the exact Word Hunt design specifications.
class GameScreen extends StatelessWidget {
  final int levelNumber;
  final String category;
  final bool isDaily;

  const GameScreen({
    super.key,
    this.levelNumber = 27,
    this.category = 'Nature Walk',
    this.isDaily = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(
        levelNumber: levelNumber,
        category: category,
        isDaily: isDaily,
      ),
      child: const _GameScreenContent(),
    );
  }
}

class _GameScreenContent extends StatefulWidget {
  const _GameScreenContent();

  @override
  State<_GameScreenContent> createState() => _GameScreenContentState();
}

class _GameScreenContentState extends State<_GameScreenContent> {
  bool _victoryDialogShown = false;

  void _checkVictory(GameProvider vm) {
    if (vm.isLevelCompleted && !_victoryDialogShown) {
      _victoryDialogShown = true;
      final earnedStars =
          vm.elapsedSeconds < 180 ? 3 : (vm.elapsedSeconds < 300 ? 2 : 1);
      final earnedScore = 500 + (vm.totalWords * 50);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Persist level completion, score, and coins
        context.read<LevelProgressProvider>().completeLevel(
              vm.levelNumber,
              earnedStars,
              earnedScore,
            );
        context.read<PlayerProfileProvider>().updateCoins(25);
        context.read<PlayerProfileProvider>().incrementWordsFound(
              vm.totalWords,
            );

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => LevelCompleteDialog(
            levelNumber: vm.levelNumber,
            stars: earnedStars,
            score: earnedScore,
            time: vm.formattedTime,
            coinsEarned: 25,
            onPreviousLevel: () {
              if (vm.levelNumber > 1) {
                Navigator.of(dialogCtx).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      levelNumber: vm.levelNumber - 1,
                      category: vm.category,
                    ),
                  ),
                );
              }
            },
            onNextLevel: () {
              Navigator.of(dialogCtx).pop();
              // Navigate to next level
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    levelNumber: vm.levelNumber + 1,
                    category: vm.category,
                  ),
                ),
              );
            },
            onReplay: () {
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => GameScreen(
                    levelNumber: vm.levelNumber,
                    category: vm.category,
                  ),
                ),
              );
            },
            onHome: () {
              Navigator.of(dialogCtx).pop();
              Navigator.of(context).pop();
            },
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final vm = context.watch<GameProvider>();
    final profile = context.watch<PlayerProfileProvider>();

    _checkVictory(vm);

    final remainingWords = vm.placements.where((p) => !p.isFound).length;

    return Scaffold(
      appBar: AppCustomBar(
        title: 'LEVEL ${vm.levelNumber} - ${vm.category}',
        actions: [
          if (vm.levelNumber > 1)
            IconButton(
              icon: Icon(
                Icons.skip_previous_rounded,
                color: theme.colorScheme.onSurface,
              ),
              tooltip: 'Previous Level',
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => GameScreen(
                      levelNumber: vm.levelNumber - 1,
                      category: vm.category,
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Timer and Coin Stats Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm + 2,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: AppRadius.radiusPill,
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vm.formattedTime,
                            style: AppTextStyles.buttonSmall(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CoinBadge(coins: profile.coins),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Milestone Progress Bar with Star Markers
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs + 2,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'WORDS FOUND',
                                style: AppTextStyles.bodySmall().copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${vm.foundWordsCount} / ${vm.totalWords}',
                            style: AppTextStyles.buttonSmall(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Progress track with star checkpoints
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: AppRadius.radiusPill,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween<double>(
                                  begin: 0.0,
                                  end: vm.progressFraction.clamp(0.0, 1.0),
                                ),
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic,
                                builder: (context, fillFactor, _) {
                                  return FractionallySizedBox(
                                    widthFactor: fillFactor,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primaryCyan,
                                            theme.colorScheme.primary,
                                          ],
                                        ),
                                        borderRadius: AppRadius.radiusPill,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Star Milestones at 33%, 66%, 100%
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 4),
                              _buildStarMarker(vm.progressFraction >= 0.33),
                              _buildStarMarker(vm.progressFraction >= 0.66),
                              _buildStarMarker(vm.progressFraction >= 1.0),
                              const SizedBox(width: 4),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Responsive Interactive 7x7 Grid
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: InteractiveGameBoard(),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Find Words Header & Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'FIND WORDS',
                      style: AppTextStyles.bodySmall().copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      '$remainingWords REMAINING',
                      style: AppTextStyles.bodySmall().copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Horizontal Scrollable Word Chips
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: vm.placements.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (context, index) {
                    final p = vm.placements[index];
                    final color = AppColors.wordHighlights[
                        p.colorIndex % AppColors.wordHighlights.length];
                    return Center(
                      child: TargetWordChip(
                        word: p.word,
                        isFound: p.isFound,
                        color: color,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Action Toolbar: [🔀 Shuffle] [💡 Hint 20¢] [🔍 Search]
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  children: [
                    // Shuffle / Rotate Button
                    _buildRoundToolButton(
                      icon: Icons.shuffle_rounded,
                      onTap: () {
                        vm.shuffleBoardVisuals();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Board shuffled!'),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Primary Hint Button
                    Expanded(
                      child: _InteractiveScaleWrapper(
                        onTap: () {
                          final success = vm.useLetterHint();
                          if (success) {
                            profile.updateCoins(-20);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Letter hint revealed! (-20 coins)',
                                ),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Not enough coins for a hint!'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.coinGoldLight,
                                AppColors.coinGoldDark,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: AppRadius.radiusPill,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.coinGold.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.lightbulb_rounded,
                                  color: Colors.white,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Hint 20🪙',
                                  style: AppTextStyles.buttonLarge(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    // Search / Spy Tool Button
                    _buildRoundToolButton(
                      icon: Icons.search_rounded,
                      onTap: () {
                        vm.useLetterHint();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarMarker(bool isActive) {
    return AnimatedScale(
      scale: isActive ? 1.2 : 0.9,
      duration: const Duration(milliseconds: 320),
      curve: Curves.elasticOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: isActive ? AppColors.coinGold : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? AppColors.coinGoldDark : Colors.grey.shade400,
            width: 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.coinGold.withValues(alpha: 0.6),
                    blurRadius: 6,
                    spreadRadius: 1.5,
                  ),
                ]
              : null,
        ),
        child: Icon(
          Icons.star_rounded,
          size: 12,
          color: isActive ? Colors.white : Colors.grey.shade400,
        ),
      ),
    );
  }

  Widget _buildRoundToolButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return _InteractiveScaleWrapper(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 22),
      ),
    );
  }
}

class _InteractiveScaleWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _InteractiveScaleWrapper({required this.child, this.onTap});

  @override
  State<_InteractiveScaleWrapper> createState() =>
      _InteractiveScaleWrapperState();
}

class _InteractiveScaleWrapperState extends State<_InteractiveScaleWrapper> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}
