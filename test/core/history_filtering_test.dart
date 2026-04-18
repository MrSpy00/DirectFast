import 'package:directfast/core/constants/platform_type.dart';
import 'package:directfast/core/features/history/providers/history_provider.dart';
import 'package:directfast/data/models/chat_history_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<ChatHistoryItem> seedItems() {
    return [
      ChatHistoryItem(
        id: '1',
        contact: 'aegis',
        platformName: 'telegram',
        timestamp: DateTime(2026, 4, 17, 12),
        displayName: 'Aegis Team',
      ),
      ChatHistoryItem(
        id: '2',
        contact: '+905550000001',
        platformName: 'whatsapp',
        timestamp: DateTime(2026, 4, 16, 12),
      ),
      ChatHistoryItem(
        id: '3',
        contact: 'mrspy',
        platformName: 'twitter',
        timestamp: DateTime(2026, 4, 15, 12),
      ),
    ];
  }

  group('applyHistoryFilters', () {
    test('filters by text across contact, display name and platform', () {
      final results = applyHistoryFilters(
        items: seedItems(),
        query: 'aegis',
        platformFilter: null,
        sort: HistorySortOption.newestFirst,
      );

      expect(results, hasLength(1));
      expect(results.first.id, '1');
    });

    test('filters by selected platform', () {
      final results = applyHistoryFilters(
        items: seedItems(),
        query: '',
        platformFilter: PlatformType.whatsapp,
        sort: HistorySortOption.newestFirst,
      );

      expect(results, hasLength(1));
      expect(results.first.id, '2');
    });

    test('sorts oldest first when requested', () {
      final results = applyHistoryFilters(
        items: seedItems(),
        query: '',
        platformFilter: null,
        sort: HistorySortOption.oldestFirst,
      );

      expect(results.first.id, '3');
      expect(results.last.id, '1');
    });
  });
}
