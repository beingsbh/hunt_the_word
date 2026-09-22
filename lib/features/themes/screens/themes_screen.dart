import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_palette.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../profile/viewmodels/player_profile_provider.dart';

/// Themes and visual styles customizer screen.
class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final profile = context.watch<PlayerProfileProvider>();

    return Scaffold(
      appBar: AppCustomBar(
        title: 'Themes & Skins',
        actions: [
          CoinBadge(coins: profile.coins),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: GradientBackground(
        child: ListView(
          padding: AppSpacing.paddingMd,
          children: [
            // Header Banner
            AppCard(
              padding: AppSpacing.paddingMd,
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.palette_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personalize Your Board',
                          style: AppTextStyles.headlineSmall(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Unlock vibrant color schemes with earned coins.',
                          style: AppTextStyles.bodySmall(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'AVAILABLE THEMES',
              style: AppTextStyles.titleSmall(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Palette Cards
            ...ThemePalette.allPalettes.map((palette) {
              final isEquipped = themeProvider.activeThemeId == palette.id;
              final isUnlocked =
                  themeProvider.unlockedThemeIds.contains(palette.id) ||
                  palette.isUnlockedDefault;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppCard(
                  padding: AppSpacing.paddingMd,
                  border: isEquipped
                      ? Border.all(color: theme.colorScheme.primary, width: 2.0)
                      : null,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                palette.name,
                                style: AppTextStyles.headlineSmall(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (palette.isDark) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.withValues(
                                      alpha: 0.15,
                                    ),
                                    borderRadius: AppRadius.radiusPill,
                                  ),
                                  child: const Text(
                                    'DARK',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (isEquipped)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: AppRadius.radiusPill,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 14,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'EQUIPPED',
                                    style: AppTextStyles.buttonSmall(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        palette.description,
                        style: AppTextStyles.bodySmall(),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      // Swatches & Sample Letter Tiles
                      Row(
                        children: [
                          // Color Swatches
                          ...palette.previewColors.map(
                            (c) => Container(
                              margin: const EdgeInsets.only(right: 6),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Spacer(),

                          // Sample Tiles Preview
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: palette.cellBackgroundColor,
                              borderRadius: AppRadius.radiusSm,
                              border: Border.all(color: palette.borderColor),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: palette.cellSelectedColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'W',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: palette.cellFoundColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'O',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: palette.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: palette.cardColor,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: palette.borderColor,
                                    ),
                                  ),
                                  child: Text(
                                    'R',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: palette.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Action Button
                      if (isEquipped)
                        const SizedBox.shrink()
                      else if (isUnlocked)
                        AppButton(
                          text: 'APPLY THEME',
                          variant: AppButtonVariant.secondary,
                          height: 40,
                          onPressed: () {
                            themeProvider.setTheme(palette.id);
                          },
                        )
                      else
                        AppButton(
                          text: 'UNLOCK (${palette.coinCost} COINS)',
                          icon: Icons.lock_open_rounded,
                          height: 40,
                          onPressed: () async {
                            final success = await themeProvider.unlockTheme(
                              palette.id,
                              palette.coinCost,
                            );
                            if (success) {
                              profile.refreshFromStorage();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${palette.name} unlocked!'),
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Not enough coins to unlock this theme!',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
