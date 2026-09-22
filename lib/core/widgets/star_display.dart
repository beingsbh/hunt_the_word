import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 0 to 3 Star rating display for level completion and level cards.
class StarDisplay extends StatelessWidget {
  final int earnedStars;
  final int maxStars;
  final double starSize;
  final Color activeColor;
  final Color inactiveColor;

  const StarDisplay({
    super.key,
    required this.earnedStars,
    this.maxStars = 3,
    this.starSize = 18.0,
    this.activeColor = AppColors.starActive,
    this.inactiveColor = AppColors.starInactive,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final isFilled = index < earnedStars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: starSize,
            color: isFilled ? activeColor : inactiveColor,
          ),
        );
      }),
    );
  }
}
