import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String? badge;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}

/// Floating bottom navigation bar matching the Word Hunt mobile mockups.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavItem> items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 68,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF151928).withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.95),
        borderRadius: AppRadius.radiusPill,
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final isSelected = index == currentIndex;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon with dedicated, balanced active indicator capsule
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withValues(
                                alpha: 0.14,
                              )
                            : Colors.transparent,
                        borderRadius: AppRadius.radiusPill,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.2,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: AnimatedScale(
                        scale: isSelected ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        child: Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Crisp label cleanly separated from indicator
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      style: AppTextStyles.titleSmall(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
