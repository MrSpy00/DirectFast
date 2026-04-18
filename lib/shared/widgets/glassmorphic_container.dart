import 'dart:ui';
import 'package:flutter/material.dart';

/// A lightweight glass-style container.
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;

  final double blur;

  final double opacity;

  final BorderRadius? borderRadius;
  final LinearGradient? gradient;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  final bool useBlur;

  const GlassmorphicContainer({
    required this.child,
    super.key,
    this.blur = 6.0,
    this.opacity = 0.1,
    this.borderRadius,
    this.gradient,
    this.border,
    this.padding,
    this.width,
    this.height,
    this.useBlur = true,
  });

  // Zero-blur variant for performance-critical paths.
  const GlassmorphicContainer.flat({
    required this.child,
    super.key,
    this.opacity = 0.1,
    this.borderRadius,
    this.gradient,
    this.border,
    this.padding,
    this.width,
    this.height,
  })  : blur = 0,
        useBlur = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(20);

    final decoration = BoxDecoration(
      gradient: gradient ??
          LinearGradient(
            colors: [
              Colors.white.withValues(alpha: opacity),
              Colors.white.withValues(alpha: opacity * 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
      borderRadius: effectiveBorderRadius,
      border: border ??
          Border.all(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.5,
          ),
    );

    final inner = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (!useBlur || blur <= 0) {
      return ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: inner,
      );
    }

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: inner,
      ),
    );
  }
}
