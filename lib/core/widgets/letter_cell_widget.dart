import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

enum LetterCellStatus { idle, selected, found, highlighted }

/// Visual letter tile component for game boards and previews.
class LetterCellWidget extends StatelessWidget {
  final String letter;
  final LetterCellStatus status;
  final Color? highlightColor;
  final double size;
  final VoidCallback? onTap;

  const LetterCellWidget({
    super.key,
    required this.letter,
    this.status = LetterCellStatus.idle,
    this.highlightColor,
    this.size = 42.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow>? shadows;
    double scale = 1.0;

    switch (status) {
      case LetterCellStatus.selected:
        final activeColor = theme.colorScheme.primary;
        bg = activeColor;
        fg = Colors.white;
        border = Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 2.0,
        );
        scale = 1.08;
        shadows = [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.5),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ];
        break;

      case LetterCellStatus.found:
        final color = highlightColor ?? AppColors.primaryEmerald;
        bg = color.withValues(alpha: isDark ? 0.45 : 0.22);
        fg = isDark ? Colors.white : Color.lerp(color, Colors.black, 0.45)!;
        border = Border.all(color: color, width: 2.0);
        shadows = [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
        break;

      case LetterCellStatus.highlighted:
        bg = AppColors.coinGold.withValues(alpha: 0.3);
        fg = AppColors.coinGoldDark;
        border = Border.all(color: AppColors.coinGold, width: 2.0);
        scale = 1.06;
        shadows = [
          BoxShadow(
            color: AppColors.coinGold.withValues(alpha: 0.6),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ];
        break;

      case LetterCellStatus.idle:
        bg = isDark ? const Color(0xFF1E2438) : const Color(0xFFF1F5F9);
        fg = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
        border = Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.0,
        );
        shadows = [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
        break;
    }

    final fontSize = (size * 0.48).clamp(12.0, 26.0);

    return AnimatedScale(
      scale: scale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular((size * 0.24).clamp(6.0, 14.0)),
          border: border,
          boxShadow: shadows,
        ),
        alignment: Alignment.center,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOut,
          style: GoogleFonts.outfit(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: fg,
          ),
          child: Text(letter.toUpperCase()),
        ),
      ),
    );
  }
}
