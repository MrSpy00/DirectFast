import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;
import 'package:uuid/uuid.dart';

import '../../../core/constants/platform_type.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/chat_history_item.dart';

enum HistorySortOption {
  newestFirst,
  oldestFirst,
}

// Provider for history list
final historyProvider =
    NotifierProvider<HistoryNotifier, List<ChatHistoryItem>>(HistoryNotifier.new);

final historySearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

final historyPlatformFilterProvider = StateProvider<PlatformType?>((ref) {
  return null;
});

final historySortProvider = StateProvider<HistorySortOption>((ref) {
  return HistorySortOption.newestFirst;
});

final historyAvailablePlatformsProvider = Provider<List<PlatformType>>((ref) {
  final allItems = ref.watch(historyProvider);
  final uniquePlatforms =
      allItems.map((item) => item.platform).toSet().toList();
  uniquePlatforms.sort((a, b) => a.displayName.compareTo(b.displayName));
  return uniquePlatforms;
});

final filteredHistoryProvider = Provider<List<ChatHistoryItem>>((ref) {
  final allItems = ref.watch(historyProvider);
  final query = ref.watch(historySearchQueryProvider);
  final platformFilter = ref.watch(historyPlatformFilterProvider);
  final sort = ref.watch(historySortProvider);

  return applyHistoryFilters(
    items: allItems,
    query: query,
    platformFilter: platformFilter,
    sort: sort,
  );
});

List<ChatHistoryItem> applyHistoryFilters({
  required List<ChatHistoryItem> items,
  required String query,
  required PlatformType? platformFilter,
  required HistorySortOption sort,
}) {
  final normalizedQuery = query.trim().toLowerCase();

  final filtered = items.where((item) {
    if (!_matchesPlatform(item: item, platformFilter: platformFilter)) {
      return false;
    }

    if (normalizedQuery.isEmpty) {
      return true;
    }

    return _matchesQuery(item: item, normalizedQuery: normalizedQuery);
  }).toList(growable: false);

  filtered.sort((a, b) {
    if (sort == HistorySortOption.newestFirst) {
      return b.timestamp.compareTo(a.timestamp);
    }

    return a.timestamp.compareTo(b.timestamp);
  });

  return filtered;
}

bool _matchesPlatform({
  required ChatHistoryItem item,
  required PlatformType? platformFilter,
}) {
  return platformFilter == null || item.platform == platformFilter;
}

bool _matchesQuery({
  required ChatHistoryItem item,
  required String normalizedQuery,
}) {
  final displayName = item.displayName?.toLowerCase() ?? '';
  final contact = item.contact.toLowerCase();
  final platformLabel = item.platform.displayName.toLowerCase();

  return displayName.contains(normalizedQuery) ||
      contact.contains(normalizedQuery) ||
      platformLabel.contains(normalizedQuery);
}

class HistoryNotifier extends Notifier<List<ChatHistoryItem>> {
  static const Uuid _uuid = Uuid();

  @override
  List<ChatHistoryItem> build() {
    return StorageService.getAllHistory();
  }

  void _reloadHistory() {
    state = StorageService.getAllHistory();
  }

  void loadHistory() {
    _reloadHistory();
  }

  Future<void> addHistoryItem({
    required PlatformType platform,
    required String contact,
    String? displayName,
  }) async {
    final item = ChatHistoryItem(
      id: _uuid.v4(),
      contact: contact,
      platformName: platform.name,
      timestamp: DateTime.now(),
      displayName: displayName,
    );

    await StorageService.addToHistory(item);
    _reloadHistory();
  }

  Future<void> deleteItem(String id) async {
    await StorageService.deleteHistoryItem(id);
    _reloadHistory();
  }

  Future<void> clearAll() async {
    await StorageService.clearAllHistory();
    _reloadHistory();
  }

  Future<void> restoreItem(ChatHistoryItem item) async {
    await StorageService.addToHistory(item);
    _reloadHistory();
  }

  Future<void> refresh() async {
    _reloadHistory();
  }
}
