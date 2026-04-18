import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../constants/platform_type.dart';
import '../../../services/storage_service.dart';
import '../../../../data/models/chat_history_item.dart';

enum HistorySortOption {
  newestFirst,
  oldestFirst,
  alphabetical,
}

final historyProvider =
    NotifierProvider<HistoryNotifier, List<ChatHistoryItem>>(
  HistoryNotifier.new,
);

final historySearchQueryProvider =
    NotifierProvider<HistorySearchQueryNotifier, String>(
  HistorySearchQueryNotifier.new,
);

final historyPlatformFilterProvider =
    NotifierProvider<HistoryPlatformFilterNotifier, PlatformType?>(
  HistoryPlatformFilterNotifier.new,
);

final historySortProvider =
    NotifierProvider<HistorySortNotifier, HistorySortOption>(
  HistorySortNotifier.new,
);

final historyAvailablePlatformsProvider = Provider<List<PlatformType>>((ref) {
  final items = ref.watch(historyProvider);
  final platforms = items.map((item) => item.platform).toSet().toList();
  platforms
      .sort((left, right) => left.displayName.compareTo(right.displayName));
  return platforms;
});

final filteredHistoryProvider = Provider<List<ChatHistoryItem>>((ref) {
  return applyHistoryFilters(
    items: ref.watch(historyProvider),
    query: ref.watch(historySearchQueryProvider),
    platformFilter: ref.watch(historyPlatformFilterProvider),
    sort: ref.watch(historySortProvider),
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
    if (platformFilter != null && item.platform != platformFilter) {
      return false;
    }

    if (normalizedQuery.isEmpty) {
      return true;
    }

    return _matchesQuery(item, normalizedQuery);
  }).toList(growable: false);

  filtered.sort((left, right) {
    switch (sort) {
      case HistorySortOption.newestFirst:
        return right.timestamp.compareTo(left.timestamp);
      case HistorySortOption.oldestFirst:
        return left.timestamp.compareTo(right.timestamp);
      case HistorySortOption.alphabetical:
        final leftLabel = _sortableLabel(left);
        final rightLabel = _sortableLabel(right);
        final labelCompare = leftLabel.compareTo(rightLabel);
        if (labelCompare != 0) {
          return labelCompare;
        }
        return right.timestamp.compareTo(left.timestamp);
    }
  });

  return filtered;
}

bool _matchesQuery(ChatHistoryItem item, String normalizedQuery) {
  final displayName = item.displayName?.toLowerCase() ?? '';
  final contact = item.contact.toLowerCase();
  final platformLabel = item.platform.displayName.toLowerCase();

  return displayName.contains(normalizedQuery) ||
      contact.contains(normalizedQuery) ||
      platformLabel.contains(normalizedQuery);
}

String _sortableLabel(ChatHistoryItem item) {
  final displayName = item.displayName?.trim();
  if (displayName != null && displayName.isNotEmpty) {
    return displayName.toLowerCase();
  }

  return item.contact.toLowerCase();
}

class HistorySearchQueryNotifier extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void update(String value) {
    final next = value.trimLeft();
    if (next == state) {
      return;
    }
    state = next;
  }

  void clear() {
    if (state.isEmpty) {
      return;
    }
    state = '';
  }
}

class HistoryPlatformFilterNotifier extends Notifier<PlatformType?> {
  @override
  PlatformType? build() {
    return null;
  }

  void set(PlatformType? platform) {
    if (platform == state) {
      return;
    }
    state = platform;
  }

  void clear() {
    if (state == null) {
      return;
    }
    state = null;
  }
}

class HistorySortNotifier extends Notifier<HistorySortOption> {
  @override
  HistorySortOption build() {
    return HistorySortOption.newestFirst;
  }

  void set(HistorySortOption sort) {
    if (sort == state) {
      return;
    }
    state = sort;
  }

  void reset() {
    state = HistorySortOption.newestFirst;
  }
}

class HistoryNotifier extends Notifier<List<ChatHistoryItem>> {
  static const Uuid _uuid = Uuid();

  @override
  List<ChatHistoryItem> build() {
    return _loadFromStorage();
  }

  List<ChatHistoryItem> _loadFromStorage() {
    final items = List<ChatHistoryItem>.from(StorageService.getAllHistory());
    items.sort((left, right) => right.timestamp.compareTo(left.timestamp));
    return List<ChatHistoryItem>.unmodifiable(items);
  }

  void loadHistory() {
    state = _loadFromStorage();
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
