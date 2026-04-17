import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../core/services/locale_service.dart';
import '../../../core/utils/app_router.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/theme/app_theme.dart';
import '../viewmodels/theme_viewmodel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeMode = ref.watch(appThemeModeProvider);
    final themeColorId = ref.watch(themeColorIdProvider);
    final customThemeColor = ref.watch(customThemeColorProvider);
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentLocale,
                  isExpanded: true,
                  borderRadius: BorderRadius.circular(14),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: [
                    for (final locale in AppStrings.supportedLocales)
                      DropdownMenuItem<String>(
                        value: locale,
                        child: Row(
                          children: [
                            const Icon(Icons.language_rounded, size: 18),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${AppStrings.tr(AppStrings.localeLabelKey(locale))} • ${AppStrings.localeNativeName(locale)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) async {
                    if (value == null || value == currentLocale) {
                      return;
                    }
                    await HapticFeedback.lightImpact();
                    await ref.read(localeProvider.notifier).setLocale(value);
                  },
                ),
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
                    isSelected: appThemeMode == AppThemeMode.light,
                    onTap: () async {
                      await HapticFeedback.lightImpact();
                      await ref
                          .read(appThemeModeProvider.notifier)
                          .setThemeMode(AppThemeMode.light);
                    },
                  ),
                  const _Divider(),
                  _ThemeOption(
                    icon: Icons.dark_mode,
                    title: AppStrings.tr('dark_mode'),
                    isSelected: appThemeMode == AppThemeMode.dark,
                    onTap: () async {
                      await HapticFeedback.lightImpact();
                      await ref
                          .read(appThemeModeProvider.notifier)
                          .setThemeMode(AppThemeMode.dark);
                    },
                  ),
                  const _Divider(),
                  _ThemeOption(
                    icon: Icons.dark_mode_outlined,
                    title: AppStrings.tr('amoled_mode'),
                    isSelected: appThemeMode == AppThemeMode.amoled,
                    onTap: () async {
                      await HapticFeedback.lightImpact();
                      await ref
                          .read(appThemeModeProvider.notifier)
                          .setThemeMode(AppThemeMode.amoled);
                    },
                  ),
                  const _Divider(),
                  _ThemeOption(
                    icon: Icons.brightness_auto,
                    title: AppStrings.tr('system_default'),
                    isSelected: appThemeMode == AppThemeMode.system,
                    onTap: () async {
                      await HapticFeedback.lightImpact();
                      await ref
                          .read(appThemeModeProvider.notifier)
                          .setThemeMode(AppThemeMode.system);
                    },
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 150.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 24),

            _SectionTitle(title: AppStrings.tr('theme_colors'))
                .animate()
                .fadeIn(duration: 400.ms, delay: 170.ms)
                .slideX(begin: -0.2, end: 0),
            const SizedBox(height: 8),

            Text(
              AppStrings.tr('choose_theme_color'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.65),
                  ),
            ).animate().fadeIn(duration: 350.ms, delay: 180.ms),

            const SizedBox(height: 12),

            GlassmorphicContainer.flat(
              padding: const EdgeInsets.all(14),
              child: DropdownButtonFormField<String>(
                key: ValueKey(themeColorId),
                initialValue: themeColorId == AppTheme.customColorId
                    ? AppTheme.customColorId
                    : AppTheme.optionById(themeColorId).id,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: AppStrings.tr('theme_colors'),
                  prefixIcon: const Icon(Icons.palette_rounded),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  for (final option in AppTheme.colorOptions)
                    DropdownMenuItem<String>(
                      value: option.id,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: option.seedColor,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppStrings.tr(option.labelKey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  DropdownMenuItem<String>(
                    value: AppTheme.customColorId,
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: customThemeColor ??
                                Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            AppStrings.tr('custom_color'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) async {
                  if (value == null) {
                    return;
                  }
                  await HapticFeedback.lightImpact();
                  if (!context.mounted) {
                    return;
                  }

                  if (value == AppTheme.customColorId) {
                    final baseColor = customThemeColor ??
                        Theme.of(context).colorScheme.primary;
                    await _showCustomColorPicker(
                      context: context,
                      ref: ref,
                      initialColor: baseColor,
                    );
                    return;
                  }

                  await ref
                      .read(themeColorIdProvider.notifier)
                      .setThemeColorId(value);
                },
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 200.ms)
                .slideX(begin: -0.2, end: 0),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final baseColor =
                      customThemeColor ?? Theme.of(context).colorScheme.primary;
                  await _showCustomColorPicker(
                    context: context,
                    ref: ref,
                    initialColor: baseColor,
                  );
                },
                icon: const Icon(Icons.palette_outlined),
                label: Text(AppStrings.tr('pick_custom_color')),
              ),
            ).animate().fadeIn(duration: 350.ms, delay: 220.ms),

            const SizedBox(height: 32),

            // ── Data & Privacy ─────────────────────────────────────────────
            _SectionTitle(title: AppStrings.tr('data_privacy'))
                .animate()
                .fadeIn(duration: 400.ms, delay: 180.ms)
                .slideX(begin: -0.2, end: 0),
            const SizedBox(height: 12),

            GlassmorphicContainer.flat(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _NavigationOption(
                    icon: Icons.backup_outlined,
                    title: AppStrings.tr('data_backup'),
                    subtitle: AppStrings.tr('data_backup_subtitle_short'),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(AppRouter.dataBackup);
                    },
                  ),
                  const _Divider(),
                  _NavigationOption(
                    icon: Icons.privacy_tip_outlined,
                    title: AppStrings.tr('privacy_dashboard'),
                    subtitle: AppStrings.tr('privacy_dashboard_subtitle'),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.push(AppRouter.privacyDashboard);
                    },
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 220.ms),

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
                      gradient: AppTheme.accentGradientFor(context),
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
                        const SizedBox(height: 12),

                        _LinkButton(
                          icon: Icons.source_outlined,
                          label: AppStrings.tr('open_source_licenses'),
                          onTap: () => _openLicenses(context),
                        ),

                        const SizedBox(height: 10),
                        Text(
                          AppStrings.tr('open_source_notice'),
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.88),
                                  ),
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

  Future<void> _showCustomColorPicker({
    required BuildContext context,
    required WidgetRef ref,
    required Color initialColor,
  }) async {
    var red = (initialColor.r * 255).roundToDouble();
    var green = (initialColor.g * 255).roundToDouble();
    var blue = (initialColor.b * 255).roundToDouble();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final pickedColor = Color.fromARGB(
              0xFF,
              red.round(),
              green.round(),
              blue.round(),
            );
            final hex =
                '#${pickedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

            Widget slider({
              required String label,
              required double value,
              required Color activeColor,
              required ValueChanged<double> onChanged,
            }) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      Text(
                        value.round().toString(),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                  Slider(
                    value: value,
                    max: 255,
                    activeColor: activeColor,
                    onChanged: onChanged,
                  ),
                ],
              );
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppStrings.tr('pick_custom_color'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: pickedColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      hex,
                      style: TextStyle(
                        color:
                            ThemeData.estimateBrightnessForColor(pickedColor) ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  slider(
                    label: 'R',
                    value: red,
                    activeColor: Colors.red,
                    onChanged: (v) => setModalState(() => red = v),
                  ),
                  slider(
                    label: 'G',
                    value: green,
                    activeColor: Colors.green,
                    onChanged: (v) => setModalState(() => green = v),
                  ),
                  slider(
                    label: 'B',
                    value: blue,
                    activeColor: Colors.blue,
                    onChanged: (v) => setModalState(() => blue = v),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref
                          .read(customThemeColorProvider.notifier)
                          .setColor(pickedColor);
                      await ref
                          .read(themeColorIdProvider.notifier)
                          .setThemeColorId(AppTheme.customColorId);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: Text(AppStrings.tr('apply_color')),
                  ),
                ],
              ),
            );
          },
        );
      },
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

  void _openLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
    );
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
        unawaited(HapticFeedback.lightImpact());
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

class _NavigationOption extends StatelessWidget {
  const _NavigationOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
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
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? primary : onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? primary : null,
                    ),
              ),
            ),
            SizedBox(
              width: 24,
              child: AnimatedOpacity(
                opacity: isSelected ? 1 : 0,
                duration: const Duration(milliseconds: 140),
                child: Icon(
                  Icons.check_circle,
                  color: primary,
                ),
              ),
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
