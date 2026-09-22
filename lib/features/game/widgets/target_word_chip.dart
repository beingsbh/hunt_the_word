import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Target word chip displayed in the top/bottom horizontal list of words to find.
class TargetWordChip extends StatelessWidget {
  final String word;
  final bool isFound;
  final Color color;
  final VoidCallback? onTap;

  const TargetWordChip({
    super.key,
    required this.word,
    required this.isFound,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isFound
              ? color.withValues(alpha: isDark ? 0.35 : 0.18)
              : (isDark ? const Color(0xFF1E2438) : Colors.white),
          borderRadius: AppRadius.radiusPill,
          border: Border.all(
            color: isFound
                ? color
                : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: isFound ? 1.8 : 1.0,
          ),
          boxShadow: [
            if (!isFound)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isFound) ...[
              Icon(Icons.check_circle_rounded, size: 14, color: color),
              const SizedBox(width: AppSpacing.xxs),
            ],
            Text(
              word.toUpperCase(),
              style:
                  AppTextStyles.buttonSmall(
                    color: isFound
                        ? (isDark
                              ? Colors.white
                              : Color.lerp(color, Colors.black, 0.4)!)
                        : theme.colorScheme.onSurface,
                    fontWeight: isFound ? FontWeight.w800 : FontWeight.w600,
                  ).copyWith(
                    decoration: isFound ? TextDecoration.lineThrough : null,
                    decorationColor: color,
                    decorationThickness: 2.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
