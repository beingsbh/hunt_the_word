import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/audio/audio_haptic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/animated_coin_icon.dart';
import '../../../core/widgets/app_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/coin_badge.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../profile/viewmodels/player_profile_provider.dart';

/// Specification for a coin package in the 2x2 store grid.
class CoinStorePack {
  final int coins;
  final int price;
  final String title;
  final String subtitle;
  final String? badgeText;
  final bool isFeatured;
  final int tier;

  const CoinStorePack({
    required this.coins,
    required this.price,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.isFeatured = false,
    required this.tier,
  });
}

/// 2x2 Game Store Screen featuring 3D Treasure Chests, glowing cards, and value badges.
class CoinStoreScreen extends StatelessWidget {
  const CoinStoreScreen({super.key});

  static const List<CoinStorePack> packs = [
    CoinStorePack(
      coins: 100,
      price: 19,
      title: 'Handful',
      subtitle: 'Starter Stash',
      badgeText: 'STARTER',
      tier: 1,
    ),
    CoinStorePack(
      coins: 500,
      price: 29,
      title: 'Coin Pouch',
      subtitle: 'Explorer Pack',
      badgeText: 'POPULAR 🔥',
      isFeatured: true,
      tier: 2,
    ),
    CoinStorePack(
      coins: 1000,
      price: 50,
      title: 'Gold Sack',
      subtitle: 'Hunter Treasury',
      badgeText: 'BEST VALUE ✨',
      tier: 3,
    ),
    CoinStorePack(
      coins: 10000,
      price: 100,
      title: 'Royal Vault',
      subtitle: 'Imperial Fortune',
      badgeText: 'MEGA VALUE 🏆',
      isFeatured: true,
      tier: 4,
    ),
  ];

  void _onPurchase(
    BuildContext context,
    CoinStorePack pack,
    PlayerProfileProvider profile,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PurchaseConfirmSheet(
        pack: pack,
        onConfirm: () {
          profile.updateCoins(pack.coins);
          AudioHapticService().playLevelComplete();
          Navigator.of(ctx).pop();
          _showCelebrationDialog(context, pack);
        },
      ),
    );
  }

  void _showCelebrationDialog(BuildContext context, CoinStorePack pack) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151928) : Colors.white,
            borderRadius: AppRadius.radiusXl,
            border: Border.all(
              color: AppColors.coinGold.withValues(alpha: 0.6),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.coinGold.withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.coinGold.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.coinGold.withValues(alpha: 0.25),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const AnimatedCoinIcon(size: 56),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'COINS UNLOCKED!',
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium(
                  color: AppColors.coinGoldDark,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '+${pack.coins} Coins added to your vault',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: 'CONTINUE PLAYING',
                icon: Icons.check_circle_rounded,
                height: 48,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<PlayerProfileProvider>();

    return Scaffold(
      appBar: AppCustomBar(
        title: 'Coin Vault',
        actions: [
          CoinBadge(
            coins: profile.coins,
            onTap: () {}, // already on store
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: GradientBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          children: [
            // Current Balance Hero Card
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  AppColors.coinGold.withValues(alpha: 0.18),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.surface.withValues(alpha: 0.7),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.coinGold.withValues(alpha: 0.25),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const AnimatedCoinIcon(size: 38),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VAULT BALANCE',
                          style: AppTextStyles.bodySmall().copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            fontSize: 10,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${profile.coins}',
                              style: AppTextStyles.displaySmall(
                                color: AppColors.coinGoldDark,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Coins',
                              style: AppTextStyles.bodyMedium().copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.coinGoldDark,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Hints • Letter Solves • Exclusive Themes',
                          style: AppTextStyles.bodySmall().copyWith(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Section Header
            Text(
              'Treasury Packs',
              style: AppTextStyles.headlineSmall(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // 2x2 Grid of 3D Treasure Chests
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: packs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.74,
              ),
              itemBuilder: (context, index) {
                final pack = packs[index];
                return _build3DTreasureCard(
                  context,
                  pack,
                  profile,
                  theme,
                );
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // Trust / Guarantee Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.6),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.security_rounded,
                    size: 16,
                    color: AppColors.primaryEmerald,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Instant Delivery • Safe • Permanent Balance',
                    style: AppTextStyles.bodySmall().copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _build3DTreasureCard(
    BuildContext context,
    CoinStorePack pack,
    PlayerProfileProvider profile,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    final isFeatured = pack.isFeatured;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181D31) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFeatured
              ? AppColors.coinGold
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          width: isFeatured ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isFeatured
                ? AppColors.coinGold.withValues(alpha: 0.28)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isFeatured ? 16 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          children: [
            // Ambient Radial Background Glow for Featured Packs
            if (isFeatured)
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.coinGold.withValues(alpha: 0.18),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Ribbon Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (pack.badgeText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isFeatured
                                  ? [
                                      AppColors.coinGoldLight,
                                      AppColors.coinGoldDark,
                                    ]
                                  : [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                    ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: AppRadius.radiusPill,
                            boxShadow: [
                              BoxShadow(
                                color: (isFeatured
                                        ? AppColors.coinGold
                                        : theme.colorScheme.primary)
                                    .withValues(alpha: 0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            pack.badgeText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 9.5,
                              letterSpacing: 0.4,
                            ),
                          ),
                        )
                      else
                        const SizedBox.shrink(),
                      // Small star accent
                      Icon(
                        isFeatured ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 14,
                        color: isFeatured
                            ? AppColors.coinGold
                            : theme.colorScheme.outlineVariant,
                      ),
                    ],
                  ),

                  // 3D Chest / Visual Representation
                  Center(
                    child: _buildTreasureVisual(pack.tier, isFeatured),
                  ),

                  // Coin Count & Title
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const AnimatedCoinIcon(size: 17),
                          const SizedBox(width: 5),
                          Text(
                            _formatCoinNumber(pack.coins),
                            style: AppTextStyles.headlineMedium(
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 1),
                      Text(
                        pack.title,
                        style: AppTextStyles.bodySmall().copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Tactile Price Button (No INR, pure numerical price)
                  ElevatedButton(
                    onPressed: () => _onPurchase(context, pack, profile),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFeatured
                          ? AppColors.coinGoldDark
                          : theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: isFeatured ? 3 : 1,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusPill,
                      ),
                    ),
                    child: Text(
                      '${pack.price}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreasureVisual(int tier, bool isFeatured) {
    switch (tier) {
      case 1:
        // Single 3D Coin with glowing circle
        return Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.coinGold.withValues(alpha: 0.12),
          ),
          child: const Center(
            child: AnimatedCoinIcon(size: 40),
          ),
        );

      case 2:
        // Coin Pouch / 3D Cluster
        return SizedBox(
          width: 68,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.coinGold.withValues(alpha: 0.15),
                ),
              ),
              const Positioned(
                left: 6,
                bottom: 4,
                child: AnimatedCoinIcon(size: 32),
              ),
              const Positioned(
                right: 6,
                top: 2,
                child: AnimatedCoinIcon(size: 36),
              ),
            ],
          ),
        );

      case 3:
        // Gold Sack / Treasure Chest
        return SizedBox(
          width: 72,
          height: 58,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.coinGold.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 4,
                bottom: 2,
                child: AnimatedCoinIcon(size: 30),
              ),
              const Positioned(
                right: 4,
                bottom: 2,
                child: AnimatedCoinIcon(size: 30),
              ),
              const Positioned(
                top: 0,
                child: AnimatedCoinIcon(size: 36),
              ),
            ],
          ),
        );

      case 4:
      default:
        // Royal Treasure Vault / Chest with aura
        return SizedBox(
          width: 76,
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.coinGold.withValues(alpha: 0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              const Positioned(
                left: 2,
                bottom: 2,
                child: AnimatedCoinIcon(size: 28),
              ),
              const Positioned(
                right: 2,
                bottom: 2,
                child: AnimatedCoinIcon(size: 28),
              ),
              const Positioned(
                top: 2,
                child: AnimatedCoinIcon(size: 42),
              ),
              const Positioned(
                top: 0,
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppColors.coinGoldLight,
                ),
              ),
            ],
          ),
        );
    }
  }

  String _formatCoinNumber(int count) {
    if (count >= 10000) {
      return '10,000';
    } else if (count >= 1000) {
      return '1,000';
    }
    return count.toString();
  }
}

/// Sleek order confirmation modal.
class _PurchaseConfirmSheet extends StatelessWidget {
  final CoinStorePack pack;
  final VoidCallback onConfirm;

  const _PurchaseConfirmSheet({
    required this.pack,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151928) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title
            Row(
              children: [
                const AnimatedCoinIcon(size: 32),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock Coins',
                        style: AppTextStyles.headlineSmall(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Instant credit to your balance',
                        style: AppTextStyles.bodySmall(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Order Summary Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2438) : const Color(0xFFF8FAFC),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${pack.coins} Coins',
                        style: AppTextStyles.headlineSmall(
                          fontWeight: FontWeight.w900,
                          color: AppColors.coinGoldDark,
                        ),
                      ),
                      Text(
                        pack.title,
                        style: AppTextStyles.bodySmall(),
                      ),
                    ],
                  ),
                  Text(
                    '${pack.price}',
                    style: AppTextStyles.headlineLarge(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'Cancel',
                    variant: AppButtonVariant.secondary,
                    height: 48,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  flex: 2,
                  child: AppButton(
                    text: 'GET FOR ${pack.price}',
                    icon: Icons.check_circle_rounded,
                    height: 48,
                    onPressed: onConfirm,
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
