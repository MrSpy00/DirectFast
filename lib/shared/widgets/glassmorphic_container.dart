import 'dart:ui';
import 'package:flutter/material.dart';

/// A glassmorphism-style container.
///
/// ## Performance notes
/// Every [BackdropFilter] creates a new GPU compositing layer and forces the
/// engine to rasterise all content behind it. Stacking five or more of these
/// on a single screen can cut render time in half on mid-range devices.
///
/// To preserve frame budget, keep [blur] at or below 6 and use [useBlur: false]
/// for deeply-nested or frequently rebuilt widgets (e.g. list-item cards).
/// When blur is disabled the widget renders a plain semi-transparent container
/// that is visually very close to the blurred version at a fraction of the cost.
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;

  /// Blur radius. Defaults to 6 — enough to convey depth without thrashing
  /// the compositor. Values above 10 are rarely perceptible and always costly.
  final double blur;

  /// White-overlay opacity for the gradient fill (0.0 – 1.0).
  final double opacity;

  final BorderRadius? borderRadius;
  final LinearGradient? gradient;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;

  /// When false, [BackdropFilter] is skipped entirely.
  /// The container still renders the semi-transparent gradient, so it looks
  /// nearly identical on dark backgrounds — without the compositing cost.
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

  // Named constructor: zero-blur variant for performance-critical paths
  // (e.g. list cells, grid items that rebuild often).
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
