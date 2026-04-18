import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/storage_service.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../core/features/history/providers/history_provider.dart';
import '../../utils/viewmodels/templates_viewmodel.dart';

class PrivacyDashboardScreen extends ConsumerWidget {
  const PrivacyDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final templates = ref.watch(templatesProvider);
    final snapshot = StorageService.getPrivacySnapshot();
    final storedKeys = (snapshot['storedKeys'] as List<String>?) ?? <String>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr('privacy_dashboard')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('local_only_storage'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        label: AppStrings.tr('history_entries'),
                        value: '${history.length}',
                        icon: Icons.history_rounded,
                      ),
                      _StatChip(
                        label: AppStrings.tr('template_entries'),
                        value: '${templates.length}',
                        icon: Icons.auto_awesome_rounded,
                      ),
                      _StatChip(
                        label: AppStrings.tr('stored_keys'),
                        value: '${storedKeys.length}',
                        icon: Icons.storage_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('settings'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _SettingsRow(
                    label: AppStrings.tr('theme_mode'),
                    value: '${snapshot['themeMode'] ?? 'system'}',
                  ),
                  _SettingsRow(
                    label: AppStrings.tr('theme_color'),
                    value: '${snapshot['themeColorId'] ?? '-'}',
                  ),
                  _SettingsRow(
                    label: AppStrings.tr('language'),
                    value: '${snapshot['locale'] ?? '-'}',
                  ),
                  _SettingsRow(
                    label: AppStrings.tr('onboarding_status'),
                    value: (snapshot['onboardingCompleted'] as bool? ?? false)
                        ? AppStrings.tr('enabled')
                        : AppStrings.tr('disabled'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ExpansionTile(
              title: Text(AppStrings.tr('stored_keys')),
              subtitle: Text(AppStrings.tr('stored_keys_subtitle')),
              children: [
                if (storedKeys.isEmpty)
                  ListTile(
                    title: Text(AppStrings.tr('no_data_available')),
                  )
                else
                  for (final key in storedKeys)
                    ListTile(
                      dense: true,
                      leading: const Icon(Icons.key_rounded),
                      title: Text(key),
                      subtitle: Text(_valueType(StorageService.prefs.get(key))),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ExpansionTile(
              title: Text(AppStrings.tr('history_preview')),
              subtitle: Text(AppStrings.tr('history_preview_subtitle')),
              children: [
                if (history.isEmpty)
                  ListTile(
                    title: Text(AppStrings.tr('no_data_available')),
                  )
                else
                  for (final item in history.take(5))
                    ListTile(
                      leading:
                          Icon(item.platform.icon, color: item.platform.color),
                      title: Text(item.platform.displayName),
                      subtitle: Text(_maskContact(item.contact)),
                    ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final report = <String, dynamic>{
                'generatedAt': DateTime.now().toIso8601String(),
                'snapshot': snapshot,
                'historyCount': history.length,
                'templateCount': templates.length,
              };

              await Clipboard.setData(
                ClipboardData(
                  text: const JsonEncoder.withIndent('  ').convert(report),
                ),
              );

              if (!context.mounted) {
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(AppStrings.tr('privacy_report_copied'))),
              );
            },
            icon: const Icon(Icons.copy_rounded),
            label: Text(AppStrings.tr('copy_privacy_report')),
          ),
        ],
      ),
    );
  }

  static String _valueType(Object? value) {
    if (value == null) {
      return 'null';
    }
    if (value is String) {
      return 'String';
    }
    if (value is bool) {
      return 'bool';
    }
    if (value is int) {
      return 'int';
    }
    if (value is double) {
      return 'double';
    }
    if (value is List) {
      return 'List';
    }
    return value.runtimeType.toString();
  }

  static String _maskContact(String value) {
    if (value.contains('@')) {
      final parts = value.split('@');
      final local = parts.first;
      final domain = parts.length > 1 ? parts[1] : '';
      if (local.length <= 2) {
        return '${local[0]}***@$domain';
      }
      return '${local.substring(0, 2)}***@$domain';
    }

    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 6) {
      return '${digits.substring(0, 2)}***${digits.substring(digits.length - 2)}';
    }

    if (value.length <= 2) {
      return '***';
    }

    return '${value.substring(0, 1)}***';
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.titleSmall),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value),
        ],
      ),
    );
  }
}
