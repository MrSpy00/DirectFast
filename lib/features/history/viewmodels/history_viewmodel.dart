import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/platform_type.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/chat_history_item.dart';

// Provider for history list
final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<ChatHistoryItem>>((ref) {
  return HistoryNotifier();
});

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
}
