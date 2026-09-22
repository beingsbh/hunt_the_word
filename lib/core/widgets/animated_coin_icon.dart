import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A premium animated 3D game coin with a rotating metallic sheen and embossed star emblem.
class AnimatedCoinIcon extends StatefulWidget {
  final double size;
  final bool animate;

  const AnimatedCoinIcon({
    super.key,
    this.size = 20.0,
    this.animate = false,
  });

  @override
  State<AnimatedCoinIcon> createState() => _AnimatedCoinIconState();
}

class _AnimatedCoinIconState extends State<AnimatedCoinIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    if (widget.animate) {
      _shimmerController.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedCoinIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _shimmerController.repeat();
      } else {
        _shimmerController.stop();
      }
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final starSize = size * 0.52;

    if (!widget.animate) {
      return _buildCoinBody(size, starSize, 0.0);
    }

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return _buildCoinBody(size, starSize, _shimmerController.value);
      },
    );
  }

  Widget _buildCoinBody(double size, double starSize, double shimmerValue) {
    final gleamStop = -0.4 + (shimmerValue * 1.8);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: const [
            Color(0xFFFFDF00),
            Color(0xFFF59E0B),
            Color(0xFFD97706),
            Color(0xFFFEF08A),
            Color(0xFFFFDF00),
          ],
          stops: const [0.0, 0.3, 0.6, 0.85, 1.0],
          transform: GradientRotation(shimmerValue * 2 * math.pi),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD97706).withValues(alpha: 0.4),
            blurRadius: (size * 0.28).clamp(3.0, 10.0),
            offset: Offset(0, (size * 0.08).clamp(1.0, 3.0)),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFFFFBEB),
          width: (size * 0.065).clamp(1.0, 2.5),
        ),
      ),
      child: Center(
        child: Container(
          width: size * 0.74,
          height: size * 0.74,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [
                Color(0xFFFBBF24),
                Color(0xFFD97706),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: const Color(0xFF78350F).withValues(alpha: 0.3),
              width: 0.8,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Embossed Golden Star Crest
              Icon(
                Icons.star_rounded,
                size: starSize,
                color: Colors.white.withValues(alpha: 0.95),
                shadows: [
                  Shadow(
                    color: const Color(0xFF78350F).withValues(alpha: 0.55),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              // Dynamic diagonal sheen highlight
              if (widget.animate)
                Positioned.fill(
                  child: ClipOval(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          stops: [
                            (gleamStop - 0.25).clamp(0.0, 1.0),
                            gleamStop.clamp(0.0, 1.0),
                            (gleamStop + 0.25).clamp(0.0, 1.0),
                          ],
                          colors: [
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
