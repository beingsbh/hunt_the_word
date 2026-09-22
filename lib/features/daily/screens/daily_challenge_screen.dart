import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_progress_bar.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/letter_cell_widget.dart';
import '../../game/screens/game_screen.dart';
import '../../profile/viewmodels/player_profile_provider.dart';
import '../viewmodels/daily_challenge_provider.dart';

/// Daily Challenge screen matching the exact Word Hunt design mockup.
class DailyChallengeScreen extends StatelessWidget {
  const DailyChallengeScreen({super.key});

  void _onStartChallenge(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const GameScreen(
          levelNumber: 0,
          category: 'Autumn Breeze',
          isDaily: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<PlayerProfileProvider>();
    final daily = context.watch<DailyChallengeProvider>();

    return Scaffold(
      appBar: AppCustomBar(
        title: 'Daily Challenge',
        actions: [
          CoinBadge(coins: profile.coins),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: GradientBackground(
        child: ListView(
          padding: AppSpacing.paddingMd,
          children: [
            // Date and Season Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
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
                    children: [
                      const Icon(Icons.calendar_today_rounded, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'September 21, 2024',
                        style: AppTextStyles.buttonSmall(
                          color: theme.colorScheme.onSurface,
                        ),
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
                    color: theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: AppRadius.radiusPill,
                  ),
                  child: Text(
                    'SEASON 4',
                    style: AppTextStyles.buttonSmall(
                      color: theme.colorScheme.primary,
                    ).copyWith(fontSize: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Weekly Calendar Strip
            AppCard(
              padding: AppSpacing.paddingMd,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'THIS WEEK',
                        style: AppTextStyles.bodySmall().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 14,
                            color: AppColors.coinGoldDark,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '7/7 ON TRACK',
                            style: AppTextStyles.bodySmall().copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.coinGoldDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: daily.weeklyCalendar.map((day) {
                      final isToday = day.isToday;
                      return Container(
                        width: 40,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFF6C5CE7)
                              : (day.isCompleted
                                    ? AppColors.primaryEmerald.withValues(
                                        alpha: 0.12,
                                      )
                                    : Colors.transparent),
                          borderRadius: AppRadius.radiusMd,
                          border: Border.all(
                            color: isToday
                                ? const Color(0xFF6C5CE7)
                                : (day.isCompleted
                                      ? AppColors.primaryEmerald
                                      : Colors.grey.shade300),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              day.dayName,
                              style: TextStyle(
                                color: isToday
                                    ? Colors.white
                                    : (day.isCompleted
                                          ? AppColors.primaryEmerald
                                          : Colors.grey),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (day.isCompleted)
                              const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: AppColors.primaryEmerald,
                              )
                            else if (day.isLocked)
                              const Icon(
                                Icons.lock_rounded,
                                size: 14,
                                color: Colors.grey,
                              )
                            else
                              Text(
                                '${day.dateNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Streak Booster Card
            AppCard(
              padding: AppSpacing.paddingMd,
              gradient: LinearGradient(
                colors: [
                  AppColors.warning.withValues(alpha: 0.15),
                  AppColors.coinGold.withValues(alpha: 0.15),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      borderRadius: AppRadius.radiusMd,
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${daily.streak} Day Streak!',
                              style: AppTextStyles.headlineSmall(),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.coinGold,
                                borderRadius: AppRadius.radiusPill,
                              ),
                              child: const Text(
                                '2X BOOST',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Solve today\'s puzzle to preserve your streak & lock in double rewards.',
                          style: AppTextStyles.bodySmall(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Today's Special Challenge Card (Autumn Breeze with 4x4 mini preview)
            AppCard(
              padding: AppSpacing.paddingLg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildChip('🔥 HARD', AppColors.error),
                      const SizedBox(width: 6),
                      _buildChip('⏱ 3:00 MIN', theme.colorScheme.primary),
                      const SizedBox(width: 6),
                      _buildChip('8 HIDDEN WORDS', AppColors.coinGoldDark),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TODAY\'S SPECIAL THEME',
                            style: AppTextStyles.bodySmall().copyWith(
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            'Autumn Breeze 🍁',
                            style: AppTextStyles.headlineMedium(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 4x4 Mini Interactive Grid Preview
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.05),
                      borderRadius: AppRadius.radiusLg,
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildDailyMiniRow([
                          'L',
                          'E',
                          'A',
                          'F',
                        ], isHighlighted: true),
                        const SizedBox(height: 4),
                        _buildDailyMiniRow(['C', 'O', 'R', 'N']),
                        const SizedBox(height: 4),
                        _buildDailyMiniRow(['W', 'I', 'N', 'D']),
                        const SizedBox(height: 4),
                        _buildDailyMiniRow(['R', 'U', 'S', 'T']),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: Text(
                      'WORD FOUND: "LEAF" (+25 PTS)',
                      style: AppTextStyles.bodySmall().copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6C5CE7),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Bonus Reward Row
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.coinGold.withValues(alpha: 0.12),
                      borderRadius: AppRadius.radiusMd,
                      border: Border.all(
                        color: AppColors.coinGold.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.military_tech_rounded,
                          color: AppColors.coinGoldDark,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'DAILY CLEAR BONUS: +50 Coins 🪙 & Golden Acorn Badge 🎖',
                            style: AppTextStyles.bodySmall().copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.coinGoldDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppButton(
                    text: 'START CHALLENGE',
                    icon: Icons.play_arrow_rounded,
                    onPressed: () => _onStartChallenge(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Monthly Progress Card
            AppCard(
              padding: AppSpacing.paddingMd,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'September Progress',
                          style: AppTextStyles.headlineSmall().copyWith(
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: AppRadius.radiusPill,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.card_giftcard_rounded,
                              size: 12,
                              color: AppColors.error,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '25 DAYS CHEST',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppProgressBar(
                    progress: daily.monthlyCount / 30,
                    label: '${daily.monthlyCount} of 30 Puzzles Solved',
                    height: 8,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'DAY 1',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                      Flexible(
                        child: Text(
                          '4 DAYS LEFT FOR TROPHY CHEST',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        'DAY 30',
                        style: TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Past Challenges
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Past Challenges', style: AppTextStyles.headlineSmall()),
                Text(
                  'VIEW ALL >',
                  style: AppTextStyles.buttonSmall(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              padding: AppSpacing.paddingSm,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sept 20 • Timber Woods ★★★',
                          style: AppTextStyles.headlineSmall().copyWith(
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Solved in 2:14 • 100% Accuracy',
                          style: AppTextStyles.bodySmall(),
                        ),
                      ],
                    ),
                  ),
                  AppButton(
                    text: 'REPLAY',
                    variant: AppButtonVariant.outline,
                    height: 32,
                    onPressed: () => _onStartChallenge(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, Color color) {
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

  Widget _buildDailyMiniRow(
    List<String> letters, {
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: letters
          .map(
            (l) => LetterCellWidget(
              letter: l,
              status: isHighlighted
                  ? LetterCellStatus.selected
                  : LetterCellStatus.idle,
              size: 38,
            ),
          )
          .toList(),
    );
  }
}
