import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../../core/services/storage_service.dart';
import '../../../core/utils/app_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/constants/app_strings.dart';

/// Animated splash screen.
///
/// ## Animation budget
/// Three tickers are active for the ~2.7 s display window:
///   1. [_logoController] — 1.5 s one-shot (fade + elastic scale)
///   2. [_backgroundController] — 10 s continuous (grid drift + gradient stop)
///   3. [AnimatedAppLogo] internal controller — 2 s glow pulse
///
/// All three are disposed on leave. The background controller is isolated
/// inside [_CyberGridBackground] via [RepaintBoundary] so its repaints
/// do not propagate to the logo/text layer.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final AnimationController _backgroundController;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    _run();
  }

  Future<void> _run() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      final onboardingDone = StorageService.isOnboardingCompleted();
      context.go(onboardingDone ? AppRouter.home : AppRouter.welcome);
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background in its own repaint boundary — repaints never touch
          // the logo/text layer above.
          RepaintBoundary(
            child: _CyberGridBackground(controller: _backgroundController),
          ),

          // Logo, name, tagline
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, _) => Opacity(
                opacity: _logoFade.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AnimatedAppLogo(size: 150),
                      const SizedBox(height: 32),

                      // App name — gradient shader text
                      Text(
                        AppConstants.appName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                              foreground: Paint()
                                ..shader = AppTheme.primaryGradientFor(context)
                                    .createShader(
                                  const Rect.fromLTWH(0, 0, 200, 70),
                                ),
                            ),
                      ).animate().fadeIn(delay: 600.ms, duration: 800.ms),

                      const SizedBox(height: 12),

                      // Tagline
                      Text(
                        AppStrings.tr('splash_tagline'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              letterSpacing: 1.5,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                      ).animate().fadeIn(delay: 800.ms, duration: 800.ms),

                      const SizedBox(height: 48),

                      // Loading indicator
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 1000.ms, duration: 600.ms)
                          .scale(begin: const Offset(0.8, 0.8)),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom branding
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text(
                  AppStrings.tr(
                    'developed_by',
                    args: [AppConstants.developerName],
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.tr(
                    'copyright',
                    args: [AppConstants.developerName],
                  ),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.3),
                      ),
                ),
              ],
            ).animate().fadeIn(delay: 1200.ms, duration: 800.ms),
          ),
        ],
      ),
    );
  }
}

// ── Animated background ───────────────────────────────────────────────────────

class _CyberGridBackground extends StatelessWidget {
  final AnimationController controller;

  const _CyberGridBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final darkColors =
        AppTheme.darkGradientFromSeed(colorScheme.primary).colors;
    final lightColors = [
      colorScheme.surface,
      colorScheme.primaryContainer.withValues(alpha: 0.45),
      colorScheme.secondaryContainer.withValues(alpha: 0.35),
    ];

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark ? darkColors : lightColors,
            stops: [
              0.0,
              // Slight mid-stop oscillation driven by the controller.
              0.5 + math.sin(controller.value * 2 * math.pi) * 0.08,
              1.0,
            ],
          ),
        ),
        child: CustomPaint(
          painter: _CyberGridPainter(
            animationValue: controller.value,
            isDark: isDark,
            gridColor: colorScheme.primary,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  final double animationValue;
  final bool isDark;
  final Color gridColor;

  const _CyberGridPainter({
    required this.animationValue,
    required this.isDark,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withValues(alpha: isDark ? 0.12 : 0.08)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const gridSpacing = 40.0;
    final offset = animationValue * gridSpacing;

    // Vertical lines
    for (double x = -gridSpacing + offset % gridSpacing;
        x < size.width;
        x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = -gridSpacing + offset % gridSpacing;
        y < size.height;
        y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Animated diagonal accent line with glow
    final glowPaint = Paint()
      ..color = gridColor.withValues(alpha: isDark ? 0.35 : 0.2)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final diagonalOffset = animationValue * size.width;
    canvas.drawLine(
      Offset(-size.width / 2 + diagonalOffset % (size.width * 1.5), 0),
      Offset(size.width / 2 + diagonalOffset % (size.width * 1.5), size.height),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_CyberGridPainter old) =>
      old.animationValue != animationValue ||
      old.isDark != isDark ||
      old.gridColor != gridColor;
}
