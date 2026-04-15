import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../../shared/widgets/brand_icon.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../shared/theme/app_theme.dart';
import '../viewmodels/history_viewmodel.dart';
import '../../home/viewmodels/home_viewmodel.dart';
import '../../../data/models/chat_history_item.dart';
import '../../../core/constants/platform_type.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final groupedHistory = _groupHistoryByDate(history);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr('history')),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              onPressed: () => _showClearConfirmation(context, ref),
              tooltip: AppStrings.tr('clear_all'),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: Theme.of(context).brightness == Brightness.dark
              ? AppTheme.darkGradient
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
        child: history.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                // +1 for the analytics header at index 0
                itemCount: groupedHistory.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _AnalyticsHeader(history: history);
                  }

                  final group = groupedHistory[index - 1];
                  return RepaintBoundary(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DateHeader(label: group.label),
                        const SizedBox(height: 12),
                        ...group.items.map((item) {
                          return _HistoryCard(
                            item: item,
                            onTap: () async {
                              final launcher = ref.read(chatLauncherProvider);
                              final result = await launcher.launchChat(
                                platform: item.platform,
                                contact: item.contact,
                              );
                              if (!result.success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      result.error ??
                                          AppStrings.tr(
                                            'failed_to_open',
                                            args: [
                                              item.platform.displayName,
                                            ],
                                          ),
                                    ),
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            onDelete: () {
                              ref
                                  .read(historyProvider.notifier)
                                  .deleteItem(item.id);
                            },
                          )
                              .animate()
                              .fadeIn(duration: 300.ms)
                              .slideX(begin: -0.1, end: 0);
                        }),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  List<_HistoryGroup> _groupHistoryByDate(List<ChatHistoryItem> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayItems = <ChatHistoryItem>[];
    final yesterdayItems = <ChatHistoryItem>[];
    final olderItems = <ChatHistoryItem>[];

    for (final item in history) {
      final d = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      if (d == today) {
        todayItems.add(item);
      } else if (d == yesterday) {
        yesterdayItems.add(item);
      } else {
        olderItems.add(item);
      }
    }

    return [
      if (todayItems.isNotEmpty)
        _HistoryGroup(label: AppStrings.tr('today'), items: todayItems),
      if (yesterdayItems.isNotEmpty)
        _HistoryGroup(label: AppStrings.tr('yesterday'), items: yesterdayItems),
      if (olderItems.isNotEmpty)
        _HistoryGroup(label: AppStrings.tr('older'), items: olderItems),
    ];
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.tr('clear_history')),
        content: Text(AppStrings.tr('clear_history_confirm')),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.tr('cancel')),
          ),
          FilledButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(AppStrings.tr('clear_all')),
          ),
        ],
      ),
    );
  }
}

// ── Data ─────────────────────────────────────────────────────────────────────

class _HistoryGroup {
  final String label;
  final List<ChatHistoryItem> items;
  const _HistoryGroup({required this.label, required this.items});
}

// ── Widgets ───────────────────────────────────────────────────────────────────

/// Analytics summary card — total connections + most-used platform.
/// Computed once per build from the history list; no extra provider needed.
class _AnalyticsHeader extends StatelessWidget {
  final List<ChatHistoryItem> history;

  const _AnalyticsHeader({required this.history});

  @override
  Widget build(BuildContext context) {
    // ── compute stats ──
    final usageMap = <PlatformType, int>{};
    for (final item in history) {
      usageMap[item.platform] = (usageMap[item.platform] ?? 0) + 1;
    }
    final top = usageMap.entries.reduce((a, b) => a.value >= b.value ? a : b);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: RepaintBoundary(
        child: GlassmorphicContainer.flat(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Total connections
              Expanded(
                child: _StatPill(
                  icon: Icons.link_rounded,
                  gradient: AppTheme.primaryGradient,
                  label: AppStrings.tr('total_connections'),
                  value: history.length.toString(),
                ),
              ),
              const SizedBox(width: 12),
              // Most-used platform
              Expanded(
                child: _StatPill(
                  platformType: top.key,
                  gradient: LinearGradient(colors: top.key.gradientColors),
                  label: AppStrings.tr('most_used'),
                  value: '${top.key.displayName} (${top.value})',
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData? icon;
  final PlatformType? platformType;
  final LinearGradient gradient;
  final String label;
  final String value;

  const _StatPill({
    required this.gradient,
    required this.label,
    required this.value,
    this.icon,
    this.platformType,
  });

  String? _svgName() {
    if (platformType == null) {
      return null;
    }
    return platformType!.logoAssetName;
  }

  Widget _leadingIcon(BuildContext context) {
    if (platformType != null) {
      final name = _svgName();
      if (name != null) {
        return BrandIcon(iconName: name, size: 20, color: Colors.white);
      }
      return Icon(platformType!.icon, size: 20, color: Colors.white);
    }
    return Icon(icon!, size: 20, color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _leadingIcon(context),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 100,
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
            const SizedBox(height: 24),
            Text(
              AppStrings.tr('no_history'),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
            ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
            const SizedBox(height: 12),
            Text(
              AppStrings.tr('no_history_desc'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
            ).animate().fadeIn(duration: 600.ms, delay: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final ChatHistoryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  Widget _platformIcon() {
    final name = item.platform.logoAssetName;
    if (name != null) {
      return BrandIcon(iconName: name, color: Colors.white);
    }
    return Icon(item.platform.icon, color: Colors.white, size: 28);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RepaintBoundary(
        child: GlassmorphicContainer(
          padding: EdgeInsets.zero,
          child: Dismissible(
            key: Key(item.id),
            direction: DismissDirection.endToStart,
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade400, Colors.red.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.delete_sweep, color: Colors.white, size: 32),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.tr('delete'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            confirmDismiss: (_) async {
              return showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(AppStrings.tr('delete')),
                  content: Text(AppStrings.tr('delete_this_chat')),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(AppStrings.tr('cancel')),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(ctx).colorScheme.error,
                      ),
                      child: Text(AppStrings.tr('delete')),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (_) => onDelete(),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Platform icon with gradient background
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: item.platform.gradientColors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(child: _platformIcon()),
                    ),
                    const SizedBox(width: 16),
                    // Contact info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.contact,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                item.platform.displayName,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: item.platform.color,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.formattedDate,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Reopen icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item.platform.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.open_in_new,
                        size: 18,
                        color: item.platform.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
