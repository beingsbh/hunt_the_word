import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, text }

/// Dynamic button with scale micro-animations and variant styling.
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final double? height;
  final double? width;
  final bool isLoading;
  final Gradient? gradient;
  final Color? color;
  final Color? customColor;
  final Color? textColor;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.height = 48,
    this.width,
    this.isLoading = false,
    this.gradient,
    this.color,
    this.customColor,
    this.textColor,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    Color bg;
    Color fg;
    Border? border;

    final effectiveColor = widget.customColor ?? widget.color;
    switch (widget.variant) {
      case AppButtonVariant.primary:
        bg = effectiveColor ?? theme.colorScheme.primary;
        fg =
            widget.textColor ??
            (bg == Colors.white ? theme.colorScheme.primary : Colors.white);
        break;
      case AppButtonVariant.secondary:
        bg =
            effectiveColor ??
            theme.colorScheme.primaryContainer.withValues(alpha: 0.2);
        fg = widget.textColor ?? theme.colorScheme.primary;
        break;
      case AppButtonVariant.outline:
        bg = Colors.transparent;
        fg = widget.textColor ?? (effectiveColor ?? theme.colorScheme.primary);
        border = Border.all(
          color: (effectiveColor ?? theme.colorScheme.primary).withValues(
            alpha: 0.5,
          ),
          width: 1.5,
        );
        break;
      case AppButtonVariant.text:
        bg = Colors.transparent;
        fg = widget.textColor ?? (effectiveColor ?? theme.colorScheme.primary);
        break;
    }

    if (!isEnabled) {
      bg = bg.withValues(alpha: 0.5);
      fg = fg.withValues(alpha: 0.5);
    }

    final isCompact = widget.height != null && widget.height! <= 40;
    final textStyle = isCompact
        ? AppTextStyles.buttonMedium(
            color: fg,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          )
        : AppTextStyles.buttonLarge(color: fg, fontWeight: FontWeight.w700);

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        else ...[
          if (widget.icon != null) ...[
            Icon(widget.icon, size: isCompact ? 16 : 20, color: fg),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.text,
                style: textStyle,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveWidth =
            widget.width ??
            (constraints.hasBoundedWidth ? double.infinity : null);

        return ScaleTransition(
          scale: _scaleAnimation,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: isEnabled ? widget.onPressed : null,
            child: Container(
              height: widget.height,
              width: effectiveWidth,
              decoration: BoxDecoration(
                color: widget.gradient == null ? bg : null,
                gradient:
                    widget.variant == AppButtonVariant.primary && isEnabled
                    ? (widget.gradient ??
                          LinearGradient(
                            colors: [
                              bg,
                              Color.lerp(bg, Colors.black, 0.1) ?? bg,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ))
                    : null,
                borderRadius: AppRadius.radiusPill,
                border: border,
                boxShadow:
                    widget.variant == AppButtonVariant.primary && isEnabled
                    ? [
                        BoxShadow(
                          color: bg.withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? AppSpacing.sm : AppSpacing.md,
              ),
              child: content,
            ),
          ),
        );
      },
    );
  }
}
