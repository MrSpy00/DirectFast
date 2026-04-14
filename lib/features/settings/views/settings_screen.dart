import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../core/services/locale_service.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/theme/app_theme.dart';
import '../viewmodels/theme_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr('settings')),
      ),
      body: Container(
        decoration: BoxDecoration(
          // In dark mode the scaffold background is already #000000 — no
          // gradient needed (redundant layer over a pure-black surface).
          gradient: Theme.of(context).brightness == Brightness.dark
              ? null
              : LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // ── Language ───────────────────────────────────────────────────
            _SectionTitle(title: AppStrings.tr('language'))
                .animate()
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.2, end: 0),
            const SizedBox(height: 12),

            // GlassmorphicContainer.flat — option lists do not benefit from
            // BackdropFilter; flat avoids the GPU compositing layer entirely.
            GlassmorphicContainer.flat(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _LanguageOption(
                    icon: Icons.language,
                    title: AppStrings.tr('turkish'),
                    subtitle: 'Türkçe',
                    isSelected: currentLocale == AppStrings.turkish,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(AppStrings.turkish);
                    },
                  ),
                  const _Divider(),
                  _LanguageOption(
                    icon: Icons.language,
                    title: AppStrings.tr('english'),
                    subtitle: 'English',
                    isSelected: currentLocale == AppStrings.english,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(AppStrings.english);
                    },
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 50.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 32),

            // ── Theme ──────────────────────────────────────────────────────
            _SectionTitle(title: AppStrings.tr('theme'))
                .animate()
                .fadeIn(duration: 400.ms, delay: 100.ms)
                .slideX(begin: -0.2, end: 0),
            const SizedBox(height: 12),

            GlassmorphicContainer.flat(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ThemeOption(
                    icon: Icons.light_mode,
                    title: AppStrings.tr('light_mode'),
                    isSelected: themeMode == ThemeMode.light,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.light);
                    },
                  ),
                  const _Divider(),
                  _ThemeOption(
                    icon: Icons.dark_mode,
                    title: AppStrings.tr('dark_mode'),
                    isSelected: themeMode == ThemeMode.dark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.dark);
                    },
                  ),
                  const _Divider(),
                  _ThemeOption(
                    icon: Icons.brightness_auto,
                    title: AppStrings.tr('system_default'),
                    isSelected: themeMode == ThemeMode.system,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(ThemeMode.system);
                    },
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 32),

            // ── About ──────────────────────────────────────────────────────
            _SectionTitle(title: AppStrings.tr('about'))
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideX(begin: -0.2, end: 0),
            const SizedBox(height: 12),

            // App info card — uses GlassmorphicContainer (with blur) as the
            // hero card; only one BackdropFilter on this screen.
            GlassmorphicContainer(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Animated logo — glow is handled internally.
                  // No extra .shimmer() repeat here; repeating shimmers on
                  // settings (a long-lived screen) waste battery.
                  const AnimatedAppLogo(size: 100),

                  const SizedBox(height: 24),

                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${AppStrings.tr('version')} ${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Developer / Links card — static gradient, no repeating
                  // shimmer (all white text is intentional: sits on accentGradient).
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.tr(
                                'developed_by',
                                args: [AppConstants.developerName],
                              ),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // GitHub button
                        _LinkButton(
                          icon: Icons.code,
                          label: AppStrings.tr('view_github'),
                          onTap: () => _launchGitHub(context),
                        ),
                        const SizedBox(height: 12),

                        // Coffee button
                        _LinkButton(
                          icon: Icons.local_cafe,
                          label: AppStrings.tr('buy_coffee'),
                          onTap: () => _launchCoffee(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 250.ms).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                ),

            const SizedBox(height: 32),

            // Privacy notice
            GlassmorphicContainer.flat(
              padding: const EdgeInsets.all(16),
              opacity: 0.05,
              child: Row(
                children: [
                  Icon(
                    Icons.privacy_tip_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppStrings.tr('privacy_notice'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

            const SizedBox(height: 16),

            // Copyright
            Center(
              child: Text(
                AppStrings.tr('copyright', args: [AppConstants.developerName]),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                    ),
              ),
            ).animate().fadeIn(duration: 600.ms, delay: 350.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _launchGitHub(BuildContext context) async {
    final uri = Uri.parse(AppConstants.githubUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr('could_not_open_link'))),
      );
    }
  }

  Future<void> _launchCoffee(BuildContext context) async {
    final uri = Uri.parse(AppConstants.coffeeUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr('could_not_open_link'))),
      );
    }
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}

/// Reusable frosted-glass link button inside the developer card.
class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LinkButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.open_in_new, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
    );
  }
}
