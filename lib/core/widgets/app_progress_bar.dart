import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Smooth rounded progress bar with customizable gradient or fill color.
class AppProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color? fillColor;
  final Gradient? gradient;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final String? label;

  const AppProgressBar({
    super.key,
    required this.progress,
    this.height = 8.0,
    this.fillColor,
    this.gradient,
    this.backgroundColor,
    this.borderRadius,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final clamped = progress.clamp(0.0, 1.0);
    final radius = borderRadius ?? AppRadius.radiusPill;

    final defaultGradient = LinearGradient(
      colors: [
        fillColor ?? theme.colorScheme.primary,
        fillColor != null
            ? Color.lerp(fillColor, Colors.white, 0.25)!
            : theme.colorScheme.tertiary,
      ],
    );

    Widget bar = Container(
      height: height,
      decoration: BoxDecoration(
        color:
            backgroundColor ??
            theme.colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: radius,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fillWidth = constraints.maxWidth * clamped;
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: fillWidth,
              height: height,
              decoration: BoxDecoration(
                color: gradient == null
                    ? (fillColor ?? theme.colorScheme.primary)
                    : null,
                gradient:
                    gradient ?? (fillColor == null ? defaultGradient : null),
                borderRadius: radius,
              ),
            ),
          );
        },
      ),
    );

    if (label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          bar,
          const SizedBox(height: 4),
          Text(
            label!,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      );
    }

    return bar;
  }
}
