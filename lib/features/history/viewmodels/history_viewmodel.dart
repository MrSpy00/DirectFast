import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    StateNotifierProvider<HistoryNotifier, List<ChatHistoryItem>>((ref) {
  return HistoryNotifier();
});

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
    final matchesPlatform =
        platformFilter == null || item.platform == platformFilter;
    if (!matchesPlatform) {
      return false;
    }

    if (normalizedQuery.isEmpty) {
      return true;
    }

    final displayName = item.displayName?.toLowerCase() ?? '';
    final contact = item.contact.toLowerCase();
    final platformLabel = item.platform.displayName.toLowerCase();

    return displayName.contains(normalizedQuery) ||
        contact.contains(normalizedQuery) ||
        platformLabel.contains(normalizedQuery);
  }).toList(growable: false);

  filtered.sort((a, b) {
    if (sort == HistorySortOption.newestFirst) {
      return b.timestamp.compareTo(a.timestamp);
    }

    return a.timestamp.compareTo(b.timestamp);
  });

  return filtered;
}

class HistoryNotifier extends StateNotifier<List<ChatHistoryItem>> {
  HistoryNotifier() : super([]) {
    loadHistory();
  }

  void loadHistory() {
    state = StorageService.getAllHistory();
  }

  Future<void> addHistoryItem({
    required PlatformType platform,
    required String contact,
    String? displayName,
  }) async {
    final item = ChatHistoryItem(
      id: const Uuid().v4(),
      contact: contact,
      platformName: platform.name,
      timestamp: DateTime.now(),
      displayName: displayName,
    );

    await StorageService.addToHistory(item);
    loadHistory();
  }

  Future<void> deleteItem(String id) async {
    await StorageService.deleteHistoryItem(id);
    loadHistory();
  }

  Future<void> clearAll() async {
    await StorageService.clearAllHistory();
    loadHistory();
  }

  Future<void> restoreItem(ChatHistoryItem item) async {
    await StorageService.addToHistory(item);
    loadHistory();
  }

  Future<void> refresh() async {
    loadHistory();
  }
}
