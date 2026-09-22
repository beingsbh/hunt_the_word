import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../../features/store/screens/coin_store_screen.dart';
import 'animated_coin_icon.dart';

/// Pill badge displaying the player's coin balance with an animated 3D coin icon.
class CoinBadge extends StatelessWidget {
  final int coins;
  final VoidCallback? onTap;
  final double iconSize;
  final bool showAddIcon;

  const CoinBadge({
    super.key,
    required this.coins,
    this.onTap,
    this.iconSize = 18,
    this.showAddIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.coinGold.withValues(alpha: 0.15),
        borderRadius: AppRadius.radiusPill,
        border: Border.all(
          color: AppColors.coinGold.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            key: ValueKey(coins),
            tween: Tween<double>(begin: 1.25, end: 1.0),
            duration: const Duration(milliseconds: 320),
            curve: Curves.elasticOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: AnimatedCoinIcon(
              size: iconSize + 2,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.3),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: Text(
              _formatCoins(coins),
              key: ValueKey(coins),
              style: AppTextStyles.buttonSmall(
                color: AppColors.coinGoldDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          if (showAddIcon) ...[
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.coinGoldDark.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 12,
                color: AppColors.coinGoldDark,
              ),
            ),
          ],
        ],
      ),
    );

    final effectiveTap = onTap ??
        () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CoinStoreScreen()),
          );
        };

    return GestureDetector(
      onTap: effectiveTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }

  String _formatCoins(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
