import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/star_display.dart';
import '../../profile/viewmodels/player_profile_provider.dart';

/// Victory dialog presented when the player successfully locates all hidden words.
class LevelCompleteDialog extends StatefulWidget {
  final int levelNumber;
  final int stars;
  final int score;
  final String time;
  final int coinsEarned;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback? onHome;
  final VoidCallback? onPreviousLevel;
  final bool? hasMysteryGift;

  const LevelCompleteDialog({
    super.key,
    required this.levelNumber,
    required this.stars,
    required this.score,
    required this.time,
    required this.coinsEarned,
    required this.onNextLevel,
    required this.onReplay,
    this.onHome,
    this.onPreviousLevel,
    this.hasMysteryGift,
  });

  @override
  State<LevelCompleteDialog> createState() => _LevelCompleteDialogState();
}

class _LevelCompleteDialogState extends State<LevelCompleteDialog>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  // Mystery Gift Animation & State
  late final AnimationController _coinBurstController;
  bool _mysteryClaimed = false;

  bool get _hasMysteryGift =>
      widget.hasMysteryGift ??
      (widget.levelNumber == 29 || widget.levelNumber % 10 == 9);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _coinBurstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _coinBurstController.dispose();
    super.dispose();
  }

  void _claimMysteryGift() {
    if (_mysteryClaimed) return;
    setState(() {
      _mysteryClaimed = true;
    });
    _coinBurstController.forward(from: 0.0);
    try {
      context.read<PlayerProfileProvider>().updateCoins(500);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Victory Ribbon / Trophy Header with Elastic Bounce
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.coinGoldLight,
                            AppColors.coinGoldDark,
                          ],
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
                    'Level ${widget.levelNumber} Solved',
                    style: AppTextStyles.bodyMedium(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Star Rating with sequential bounce
                  StarDisplay(
                    earnedStars: widget.stars,
                    starSize: 36,
                    animate: true,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Animated Stats Container and Action Buttons
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: AppSpacing.paddingMd,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF1E2438)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: AppRadius.radiusMd,
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.4),
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
                                      widget.score.toString(),
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
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.4),
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
                                      widget.time,
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
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.4),
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
                                          '+${widget.coinsEarned}',
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

                          // Mystery Gift Card (if level has mystery gift)
                          if (_hasMysteryGift) ...[
                            const SizedBox(height: AppSpacing.sm),
                            _buildMysteryGiftCard(theme, isDark),
                          ],

                          const SizedBox(height: AppSpacing.md),

                          // Action Buttons: REPLAY and NEXT LEVEL (HOME and PREV LEVEL removed)
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: 'REPLAY',
                                  icon: Icons.replay_rounded,
                                  variant: AppButtonVariant.secondary,
                                  height: 48,
                                  onPressed: widget.onReplay,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                flex: 1,
                                child: AppButton(
                                  text: 'NEXT LEVEL',
                                  icon: Icons.play_arrow_rounded,
                                  height: 48,
                                  onPressed: widget.onNextLevel,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Animated Coin Burst Overlay
          _buildCoinBurstOverlay(),
        ],
      ),
    );
  }

  Widget _buildMysteryGiftCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2A1B4E), const Color(0xFF1A1F36)]
              : [const Color(0xFFFFFBEB), const Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.radiusMd,
        border: Border.all(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated bouncing gift box
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.92, end: 1.08),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
            builder: (context, scale, child) => Transform.scale(
              scale: _mysteryClaimed ? 1.0 : scale,
              child: child,
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.coinGoldLight, AppColors.coinGoldDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.coinGold.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _mysteryClaimed
                    ? Icons.lock_open_rounded
                    : Icons.card_giftcard_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Info text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'MYSTERY GIFT',
                      style: AppTextStyles.headlineSmall().copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('🎁', style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _mysteryClaimed
                      ? '+500 Coins Claimed!'
                      : 'Special level mystery prize',
                  style: AppTextStyles.bodySmall().copyWith(
                    fontSize: 11,
                    color: _mysteryClaimed
                        ? AppColors.primaryEmerald
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight:
                        _mysteryClaimed ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Claim Button or Claimed badge
          if (!_mysteryClaimed)
            ElevatedButton(
              onPressed: _claimMysteryGift,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                elevation: 3,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.radiusPill,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.monetization_on_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'CLAIM',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                borderRadius: AppRadius.radiusPill,
                border: Border.all(color: AppColors.success, width: 1.2),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: AppColors.success,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'CLAIMED',
                    style: TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCoinBurstOverlay() {
    return AnimatedBuilder(
      animation: _coinBurstController,
      builder: (context, child) {
        final t = _coinBurstController.value;
        if (t == 0.0 || t == 1.0) return const SizedBox.shrink();

        final burstCurve = Curves.easeOutCubic.transform(t);
        final fadeOut = (1.0 - t * 1.1).clamp(0.0, 1.0);

        return Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 12 radiating golden coins flying outwards
                ...List.generate(12, (i) {
                  final angle = (i * (2 * math.pi / 12));
                  final distance = 100.0 * burstCurve;
                  final coinScale = 0.5 + 0.7 * math.sin(t * math.pi);

                  return Transform.translate(
                    offset: Offset(
                      math.cos(angle) * distance,
                      math.sin(angle) * distance - (burstCurve * 30),
                    ),
                    child: Transform.scale(
                      scale: coinScale,
                      child: Opacity(
                        opacity: fadeOut,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.coinGold.withValues(
                                  alpha: 0.6 * fadeOut,
                                ),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.monetization_on_rounded,
                            color: AppColors.coinGold,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                // Floating "+500 COINS" celebratory badge
                Transform.translate(
                  offset: Offset(0, -60 * burstCurve),
                  child: Transform.scale(
                    scale: 1.0 + 0.3 * math.sin(t * math.pi),
                    child: Opacity(
                      opacity: fadeOut,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.coinGold.withValues(alpha: 0.6),
                              blurRadius: 18,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.monetization_on_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              '+500 COINS!',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
