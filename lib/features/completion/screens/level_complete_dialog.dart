import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/star_display.dart';

/// Victory dialog presented when the player successfully locates all hidden words.
class LevelCompleteDialog extends StatelessWidget {
  final int levelNumber;
  final int stars;
  final int score;
  final String time;
  final int coinsEarned;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const LevelCompleteDialog({
    super.key,
    required this.levelNumber,
    required this.stars,
    required this.score,
    required this.time,
    required this.coinsEarned,
    required this.onNextLevel,
    required this.onReplay,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151928) : Colors.white,
          borderRadius: AppRadius.radiusXl,
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.25),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: AppSpacing.paddingLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Victory Ribbon / Trophy Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.coinGoldLight, AppColors.coinGoldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coinGold.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 44,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title
            Text(
              'LEVEL COMPLETE!',
              style: AppTextStyles.displaySmall(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Level $levelNumber Solved',
              style: AppTextStyles.bodyMedium(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Star Rating
            StarDisplay(earnedStars: stars, starSize: 36),
            const SizedBox(height: AppSpacing.md),

            // Stats Container
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E2438)
                    : const Color(0xFFF8FAFC),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Score
                  Column(
                    children: [
                      Text(
                        'SCORE',
                        style: AppTextStyles.bodySmall().copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        score.toString(),
                        style: AppTextStyles.headlineMedium(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  // Time
                  Column(
                    children: [
                      Text(
                        'TIME',
                        style: AppTextStyles.bodySmall().copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: AppTextStyles.headlineMedium(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    height: 28,
                    width: 1,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                  // Coins Earned
                  Column(
                    children: [
                      Text(
                        'REWARD',
                        style: AppTextStyles.bodySmall().copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.monetization_on_rounded,
                            size: 16,
                            color: AppColors.coinGoldDark,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '+$coinsEarned',
                            style: AppTextStyles.headlineMedium(
                              color: AppColors.coinGoldDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action Buttons
            AppButton(
              text: 'NEXT LEVEL',
              icon: Icons.play_arrow_rounded,
              onPressed: onNextLevel,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'REPLAY',
                    icon: Icons.replay_rounded,
                    variant: AppButtonVariant.secondary,
                    height: 44,
                    onPressed: onReplay,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    text: 'HOME',
                    icon: Icons.home_rounded,
                    variant: AppButtonVariant.outline,
                    height: 44,
                    onPressed: onHome,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
