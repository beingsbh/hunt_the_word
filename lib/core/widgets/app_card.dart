import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Reusable elevated / styled card with smooth gradients and gentle borders.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Gradient? gradient;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final double? elevation;
  final Clip clipBehavior;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.gradient,
    this.border,
    this.borderRadius,
    this.boxShadow,
    this.onTap,
    this.elevation,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveRadius = borderRadius ?? AppRadius.radiusLg;

    final defaultShadow = [
      BoxShadow(
        color: Colors.black.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.25 : 0.05,
        ),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ];

    Widget content = Container(
      padding: padding ?? AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? theme.cardColor) : null,
        gradient: gradient,
        borderRadius: effectiveRadius,
        border: border ??
            Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1.0,
            ),
        boxShadow: boxShadow ?? defaultShadow,
      ),
      clipBehavior: clipBehavior,
      child: Material(color: Colors.transparent, child: child),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null) {
      return _AppCardPressable(
        onTap: onTap!,
        borderRadius: effectiveRadius,
        child: content,
      );
    }

    return content;
  }
}

class _AppCardPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  const _AppCardPressable({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  @override
  State<_AppCardPressable> createState() => _AppCardPressableState();
}

class _AppCardPressableState extends State<_AppCardPressable> {
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isDown ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 90),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: widget.borderRadius,
        child: InkWell(
          onTapDown: (_) => setState(() => _isDown = true),
          onTapUp: (_) => setState(() => _isDown = false),
          onTapCancel: () => setState(() => _isDown = false),
          onTap: widget.onTap,
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    );
  }
}
