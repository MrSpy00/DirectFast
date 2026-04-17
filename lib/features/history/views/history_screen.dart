import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/platform_type.dart';
import '../../../core/services/locale_service.dart';
import '../../../data/models/chat_history_item.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/brand_icon.dart';
import '../../../shared/widgets/glassmorphic_container.dart';
import '../../home/viewmodels/home_viewmodel.dart';
import '../viewmodels/history_viewmodel.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<_HistoryGroup> _groupHistoryByDate(List<ChatHistoryItem> history) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayItems = <ChatHistoryItem>[];
    final yesterdayItems = <ChatHistoryItem>[];
    final olderItems = <ChatHistoryItem>[];

    for (final item in history) {
      final itemDate = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );

      if (itemDate == today) {
        todayItems.add(item);
      } else if (itemDate == yesterday) {
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

  Future<void> _openChat({
    required WidgetRef ref,
    required ChatHistoryItem item,
  }) async {
    final launcher = ref.read(chatLauncherProvider);
    final result = await launcher.launchChat(
      platform: item.platform,
      contact: item.contact,
    );

    if (!mounted || result.success) {
      return;
    }

    final snackBar = SnackBar(
      content: Text(
        result.error ??
            AppStrings.tr(
              'failed_to_open',
              args: [item.platform.displayName],
            ),
      ),
      backgroundColor: Theme.of(context).colorScheme.error,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _deleteItemWithUndo({
    required WidgetRef ref,
    required ChatHistoryItem item,
  }) {
    final notifier = ref.read(historyProvider.notifier);

    unawaited(
      notifier.deleteItem(item.id).then((_) {
        if (!mounted) {
          return;
        }

        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(AppStrings.tr('history_item_deleted')),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: AppStrings.tr('undo'),
              onPressed: () {
                unawaited(notifier.restoreItem(item));
              },
            ),
          ),
        );
      }),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppStrings.tr('clear_history')),
          content: Text(AppStrings.tr('clear_history_confirm')),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(AppStrings.tr('cancel')),
            ),
            FilledButton(
              onPressed: () {
                unawaited(ref.read(historyProvider.notifier).clearAll());
                Navigator.pop(dialogContext);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppStrings.tr('clear_all')),
            ),
          ],
        );
      },
    );
  }

  void _resetFilters(WidgetRef ref) {
    ref.read(historySearchQueryProvider.notifier).state = '';
    ref.read(historyPlatformFilterProvider.notifier).state = null;
    ref.read(historySortProvider.notifier).state =
        HistorySortOption.newestFirst;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);

    final allHistory = ref.watch(historyProvider);
    final visibleHistory = ref.watch(filteredHistoryProvider);
    final availablePlatforms = ref.watch(historyAvailablePlatformsProvider);
    final searchQuery = ref.watch(historySearchQueryProvider);
    final selectedPlatform = ref.watch(historyPlatformFilterProvider);
    final sortOption = ref.watch(historySortProvider);

    final groupedHistory = _groupHistoryByDate(visibleHistory);
    final hasHistory = allHistory.isNotEmpty;
    final hasActiveFilters = searchQuery.trim().isNotEmpty ||
        selectedPlatform != null ||
        sortOption != HistorySortOption.newestFirst;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr('history')),
        actions: [
          if (hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off_outlined),
              onPressed: () => _resetFilters(ref),
              tooltip: AppStrings.tr('reset_filters'),
            ),
          if (hasHistory)
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
              ? AppTheme.darkGradientFor(context)
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
        child: SafeArea(
          child: hasHistory
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: _HistoryControls(
                        searchQuery: searchQuery,
                        selectedPlatform: selectedPlatform,
                        sortOption: sortOption,
                        availablePlatforms: availablePlatforms,
                        hasActiveFilters: hasActiveFilters,
                        onSearchChanged: (value) {
                          ref.read(historySearchQueryProvider.notifier).state =
                              value;
                        },
                        onClearSearch: () {
                          ref.read(historySearchQueryProvider.notifier).state =
                              '';
                        },
                        onPlatformChanged: (platform) {
                          ref
                              .read(historyPlatformFilterProvider.notifier)
                              .state = platform;
                        },
                        onSortChanged: (sort) {
                          ref.read(historySortProvider.notifier).state = sort;
                        },
                        onResetFilters: () {
                          _resetFilters(ref);
                        },
                      ),
                    ),
                    Expanded(
                      child: visibleHistory.isEmpty
                          ? _FilteredEmptyState(
                              onReset: () => _resetFilters(ref),
                            )
                          : RefreshIndicator(
                              onRefresh:
                                  ref.read(historyProvider.notifier).refresh,
                              child: ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 16),
                                cacheExtent: 1000,
                                itemCount: groupedHistory.length + 1,
                                itemBuilder: (itemContext, index) {
                                  if (index == 0) {
                                    return _AnalyticsHeader(
                                      visibleHistory: visibleHistory,
                                      totalHistoryCount: allHistory.length,
                                    );
                                  }

                                  final group = groupedHistory[index - 1];
                                  return RepaintBoundary(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _DateHeader(label: group.label),
                                        const SizedBox(height: 12),
                                        ...group.items.map((item) {
                                          return _HistoryCard(
                                            item: item,
                                            onTap: () {
                                              unawaited(
                                                _openChat(
                                                  ref: ref,
                                                  item: item,
                                                ),
                                              );
                                            },
                                            onDelete: () {
                                              _deleteItemWithUndo(
                                                ref: ref,
                                                item: item,
                                              );
                                            },
                                          )
                                              .animate()
                                              .fadeIn(duration: 280.ms)
                                              .slideX(begin: -0.08, end: 0);
                                        }),
                                        const SizedBox(height: 20),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                )
              : const _EmptyState(),
        ),
      ),
    );
  }
}

class _HistoryGroup {
  final String label;
  final List<ChatHistoryItem> items;

  const _HistoryGroup({required this.label, required this.items});
}

class _HistoryControls extends StatelessWidget {
  final String searchQuery;
  final PlatformType? selectedPlatform;
  final HistorySortOption sortOption;
  final List<PlatformType> availablePlatforms;
  final bool hasActiveFilters;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<PlatformType?> onPlatformChanged;
  final ValueChanged<HistorySortOption> onSortChanged;
  final VoidCallback onResetFilters;

  const _HistoryControls({
    required this.searchQuery,
    required this.selectedPlatform,
    required this.sortOption,
    required this.availablePlatforms,
    required this.hasActiveFilters,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onPlatformChanged,
    required this.onSortChanged,
    required this.onResetFilters,
  });

  Widget _platformAvatar(PlatformType platform) {
    final logoName = platform.logoAssetName;
    if (logoName == null) {
      return Icon(platform.icon, size: 16);
    }
    return BrandIcon(iconName: logoName, size: 16);
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer.flat(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            key: ValueKey(searchQuery),
            initialValue: searchQuery,
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: AppStrings.tr('search_history'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: onClearSearch,
                      tooltip: AppStrings.tr('clear_search'),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                AppStrings.tr('history_filters'),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              PopupMenuButton<HistorySortOption>(
                initialValue: sortOption,
                onSelected: onSortChanged,
                itemBuilder: (popupContext) {
                  return [
                    PopupMenuItem(
                      value: HistorySortOption.newestFirst,
                      child: Text(AppStrings.tr('sort_newest')),
                    ),
                    PopupMenuItem(
                      value: HistorySortOption.oldestFirst,
                      child: Text(AppStrings.tr('sort_oldest')),
                    ),
                  ];
                },
                child: Chip(
                  avatar: const Icon(Icons.swap_vert_rounded, size: 16),
                  label: Text(
                    sortOption == HistorySortOption.newestFirst
                        ? AppStrings.tr('sort_newest')
                        : AppStrings.tr('sort_oldest'),
                  ),
                ),
              ),
              if (hasActiveFilters)
                TextButton(
                  onPressed: onResetFilters,
                  child: Text(AppStrings.tr('reset_filters')),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: Text(AppStrings.tr('all_platforms')),
                  selected: selectedPlatform == null,
                  onSelected: (_) => onPlatformChanged(null),
                ),
                const SizedBox(width: 8),
                ...availablePlatforms.map((platform) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: _platformAvatar(platform),
                      label: Text(platform.displayName),
                      selected: selectedPlatform == platform,
                      onSelected: (_) {
                        final nextValue =
                            selectedPlatform == platform ? null : platform;
                        onPlatformChanged(nextValue);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsHeader extends StatelessWidget {
  final List<ChatHistoryItem> visibleHistory;
  final int totalHistoryCount;

  const _AnalyticsHeader({
    required this.visibleHistory,
    required this.totalHistoryCount,
  });

  @override
  Widget build(BuildContext context) {
    final usageMap = <PlatformType, int>{};
    for (final item in visibleHistory) {
      usageMap[item.platform] = (usageMap[item.platform] ?? 0) + 1;
    }

    if (usageMap.isEmpty) {
      return const SizedBox.shrink();
    }

    final top = usageMap.entries.reduce((a, b) => a.value >= b.value ? a : b);
    final isFiltered = visibleHistory.length != totalHistoryCount;

    final cards = [
      _StatPill(
        icon: Icons.link_rounded,
        gradient: AppTheme.primaryGradientFor(context),
        label: isFiltered
            ? AppStrings.tr('shown_connections')
            : AppStrings.tr('total_connections'),
        value: isFiltered
            ? '${visibleHistory.length}/$totalHistoryCount'
            : visibleHistory.length.toString(),
      ),
      _StatPill(
        platformType: top.key,
        gradient: LinearGradient(colors: top.key.gradientColors),
        label: AppStrings.tr('most_used'),
        value: '${top.key.displayName} (${top.value})',
      ),
      _StatPill(
        icon: Icons.category_rounded,
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.tertiary,
          ],
        ),
        label: AppStrings.tr('platform_count'),
        value: usageMap.length.toString(),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: RepaintBoundary(
        child: GlassmorphicContainer.flat(
          padding: const EdgeInsets.all(14),
          child: LayoutBuilder(
            builder: (layoutContext, constraints) {
              final compact = constraints.maxWidth < 460;
              final itemWidth = compact
                  ? constraints.maxWidth
                  : (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: cards
                    .map((card) => SizedBox(width: itemWidth, child: card))
                    .toList(growable: false),
              );
            },
          ),
        ).animate().fadeIn(duration: 380.ms).slideY(begin: -0.08, end: 0),
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

  Widget _leadingIcon() {
    if (platformType != null) {
      final logoName = platformType!.logoAssetName;
      if (logoName != null) {
        return BrandIcon(iconName: logoName, size: 20, color: Colors.white);
      }
      return Icon(platformType!.icon, size: 20, color: Colors.white);
    }
    return Icon(icon, size: 20, color: Colors.white);
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
          _leadingIcon(),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    ).animate().fadeIn(duration: 260.ms);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_rounded,
                size: 92,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.35),
              ).animate().fadeIn(duration: 520.ms),
              const SizedBox(height: 18),
              Text(
                AppStrings.tr('no_history'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.tr('no_history_desc'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.65),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  final VoidCallback onReset;

  const _FilteredEmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 82,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.tr('no_history_match'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(AppStrings.tr('reset_filters')),
            ),
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
    final logoName = item.platform.logoAssetName;
    if (logoName != null) {
      return BrandIcon(iconName: logoName, color: Colors.white);
    }
    return Icon(item.platform.icon, color: Colors.white, size: 28);
  }

  @override
  Widget build(BuildContext context) {
    final title =
        (item.displayName != null && item.displayName!.trim().isNotEmpty)
            ? item.displayName!.trim()
            : item.contact;
    final hasSubtitle = title != item.contact;

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
                  const Icon(Icons.delete_sweep, color: Colors.white, size: 30),
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
            confirmDismiss: (_) {
              return showDialog<bool>(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: Text(AppStrings.tr('delete')),
                    content: Text(AppStrings.tr('delete_this_chat')),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: Text(AppStrings.tr('cancel')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(dialogContext, true),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              Theme.of(dialogContext).colorScheme.error,
                        ),
                        child: Text(AppStrings.tr('delete')),
                      ),
                    ],
                  );
                },
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (hasSubtitle) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.contact,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  item.platform.displayName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: item.platform.color,
                                        fontWeight: FontWeight.w600,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
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
