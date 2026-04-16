import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/locale_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/app_router.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../settings/viewmodels/theme_viewmodel.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final appThemeMode = ref.watch(appThemeModeProvider);
    final themeColorId = ref.watch(themeColorIdProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? null
              : LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.26),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            children: [
              const Center(child: AnimatedAppLogo(size: 92)),
              const SizedBox(height: 20),
              Text(
                AppStrings.tr('welcome_title'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.tr('welcome_subtitle'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.72),
                    ),
              ),
              const SizedBox(height: 24),
              _ConfigCard(
                child: Column(
                  children: [
                    _ConfigDropdown<String>(
                      title: AppStrings.tr('setup_language'),
                      value: locale,
                      items: [
                        for (final option in AppStrings.supportedLocales)
                          DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              '${AppStrings.tr(AppStrings.localeLabelKey(option))} • ${AppStrings.localeNativeName(option)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null || value == locale) {
                          return;
                        }
                        HapticFeedback.selectionClick();
                        ref.read(localeProvider.notifier).setLocale(value);
                      },
                    ),
                    const SizedBox(height: 14),
                    _ConfigDropdown<AppThemeMode>(
                      title: AppStrings.tr('setup_theme'),
                      value: appThemeMode,
                      items: [
                        DropdownMenuItem(
                          value: AppThemeMode.light,
                          child: Text(AppStrings.tr('light_mode')),
                        ),
                        DropdownMenuItem(
                          value: AppThemeMode.dark,
                          child: Text(AppStrings.tr('dark_mode')),
                        ),
                        DropdownMenuItem(
                          value: AppThemeMode.amoled,
                          child: Text(AppStrings.tr('amoled_mode')),
                        ),
                        DropdownMenuItem(
                          value: AppThemeMode.system,
                          child: Text(AppStrings.tr('system_default')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null || value == appThemeMode) {
                          return;
                        }
                        HapticFeedback.selectionClick();
                        ref
                            .read(appThemeModeProvider.notifier)
                            .setThemeMode(value);
                      },
                    ),
                    const SizedBox(height: 14),
                    _ConfigDropdown<String>(
                      title: AppStrings.tr('setup_theme_color'),
                      value: AppTheme.optionById(themeColorId).id,
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
                                const SizedBox(width: 8),
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
                      ],
                      onChanged: (value) {
                        if (value == null || value == themeColorId) {
                          return;
                        }
                        HapticFeedback.selectionClick();
                        ref
                            .read(themeColorIdProvider.notifier)
                            .setThemeColorId(value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () async {
                  await StorageService.setOnboardingCompleted(true);
                  if (context.mounted) {
                    context.go(AppRouter.home);
                  }
                },
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text(AppStrings.tr('continue_to_app')),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  await StorageService.setOnboardingCompleted(true);
                  if (context.mounted) {
                    context.go(AppRouter.home);
                  }
                },
                child: Text(AppStrings.tr('skip_for_now')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  final Widget child;

  const _ConfigCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: child,
    );
  }
}

class _ConfigDropdown<T> extends StatelessWidget {
  final String title;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _ConfigDropdown({
    required this.title,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          key: ValueKey(value),
          initialValue: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
