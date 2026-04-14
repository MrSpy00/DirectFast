import 'package:flutter/material.dart';

/// App logo rendered from `assets/images/logo.png`.
///
/// ## Why PNG, not SVG
/// The `logo.svg` carries an opaque background rectangle in its canvas, which
/// bleeds through any `ClipOval` or transparent container and produces the
/// visible square / colour-ring artifact. The `logo.png` asset is the
/// authoritative source (it is already used for launcher icons in pubspec) and
/// respects the image's own alpha channel, giving a clean circular clip.
///
/// ## Rendering pipeline
/// ```
/// DecoratedBox (glow BoxShadows, circle shape)
///   └── ClipOval
///         └── Image.asset(logo.png, BoxFit.cover)  ← fills circle cleanly
///               errorBuilder → _LogoFallback (gradient + ⚡ icon)
/// ```
class AppLogo extends StatelessWidget {
  final double size;

  /// Optional tint applied via [BlendMode.srcIn].
  /// When null the PNG renders with its original colours.
  final Color? color;

  /// When true, renders concentric neon glow shadows.
  final bool showGlow;

  const AppLogo({
    super.key,
    this.size = 80.0,
    this.color,
    this.showGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? Theme.of(context).colorScheme.primary;

    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: showGlow
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.55),
                      blurRadius: size * 0.28,
                    ),
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.28),
                      blurRadius: size * 0.14,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: size * 0.18,
                      offset: Offset(0, size * 0.06),
                    ),
                  ],
                )
              : const BoxDecoration(),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              color: color,
              colorBlendMode: color != null ? BlendMode.srcIn : null,
              errorBuilder: (_, __, ___) => _LogoFallback(
                size: size,
                primaryColor: primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated [AppLogo] with a pulsing neon glow.
///
/// The PNG raster layer is isolated inside a [RepaintBoundary], so only the
/// shadow decoration (driven by [AnimationController]) repaints each frame.
class AnimatedAppLogo extends StatefulWidget {
  final double size;
  final Color? color;

  const AnimatedAppLogo({super.key, this.size = 80.0, this.color});

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _glow = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.color ?? Theme.of(context).colorScheme.primary;
    final s = widget.size;

    return SizedBox(
      width: s,
      height: s,
      child: AnimatedBuilder(
        animation: _glow,
        builder: (context, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.6 * _glow.value),
                  blurRadius: s * 0.38 * _glow.value,
                ),
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.8 * _glow.value),
                  blurRadius: s * 0.2 * _glow.value,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: s * 0.22,
                  offset: Offset(0, s * 0.08),
                ),
              ],
            ),
            child: child,
          );
        },
        // PNG layer isolated so the shadow-animation repaints only the
        // DecoratedBox and leaves the raster cache for the image intact.
        child: RepaintBoundary(
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              width: s,
              height: s,
              fit: BoxFit.cover,
              color: widget.color,
              colorBlendMode: widget.color != null ? BlendMode.srcIn : null,
              errorBuilder: (_, __, ___) => _LogoFallback(
                size: s,
                primaryColor: primaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown while the PNG is loading or if it fails to decode.
class _LogoFallback extends StatelessWidget {
  final double size;
  final Color primaryColor;

  const _LogoFallback({required this.size, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(Icons.flash_on, size: size * 0.48, color: Colors.white),
      ),
    );
  }
}
