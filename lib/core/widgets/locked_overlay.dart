import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Overlay for locked content, themes, and higher level chapters.
class LockedOverlay extends StatelessWidget {
  final String? lockMessage;
  final Widget? child;
  final BorderRadius? borderRadius;

  const LockedOverlay({
    super.key,
    this.lockMessage,
    this.child,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.radiusLg;

    return Stack(
      children: [
        if (child != null) Opacity(opacity: 0.45, child: child!),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: effectiveRadius,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  if (lockMessage != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      lockMessage!,
                      style: AppTextStyles.bodySmall(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
