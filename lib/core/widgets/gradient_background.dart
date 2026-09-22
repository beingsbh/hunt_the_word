import 'package:flutter/material.dart';

/// Ambient gradient background wrapper ensuring consistent atmosphere across screens.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveColors = colors ??
        (isDark
            ? [
                theme.scaffoldBackgroundColor,
                Color.lerp(
                  theme.scaffoldBackgroundColor,
                  theme.colorScheme.primary,
                  0.08,
                )!,
              ]
            : [
                theme.scaffoldBackgroundColor,
                Color.lerp(
                  theme.scaffoldBackgroundColor,
                  theme.colorScheme.primary,
                  0.04,
                )!,
              ]);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: effectiveColors,
          begin: begin,
          end: end,
        ),
      ),
      child: child,
    );
  }
}
