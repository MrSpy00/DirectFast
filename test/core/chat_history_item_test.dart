import 'package:directfast/core/constants/platform_type.dart';
import 'package:directfast/data/models/chat_history_item.dart';
import 'package:directfast/shared/constants/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatHistoryItem.decodeList', () {
    test('keeps valid records when payload contains malformed entries', () {
      const payload = '''
[
  {
    "id": "ok-1",
    "contact": "+905551234567",
    "platformName": "whatsapp",
    "timestamp": "2026-04-17T10:00:00.000"
  },
  {
    "id": "bad-1",
    "contact": "broken",
    "platformName": "telegram",
    "timestamp": "invalid-timestamp"
  },
  "unexpected-value",
  {
    "id": "",
    "contact": "missing-id",
    "platformName": "signal",
    "timestamp": "2026-04-17T11:00:00.000"
  }
]
''';

      final decoded = ChatHistoryItem.decodeList(payload);

      expect(decoded, hasLength(1));
      expect(decoded.first.id, 'ok-1');
      expect(decoded.first.contact, '+905551234567');
      expect(decoded.first.platform, PlatformType.whatsapp);
    });

    test('supports legacy platform field name', () {
      const payload = '''
[
  {
    "id": "legacy-1",
    "contact": "aegis",
    "platform": "twitter",
    "timestamp": "2026-04-17T10:00:00.000"
  }
]
''';

      final decoded = ChatHistoryItem.decodeList(payload);

      expect(decoded, hasLength(1));
      expect(decoded.first.platform, PlatformType.twitter);
    });

    test('returns empty list for non-list JSON payloads', () {
      final decoded = ChatHistoryItem.decodeList('{"foo":"bar"}');
      expect(decoded, isEmpty);
    });
  });

  group('ChatHistoryItem.formattedDate', () {
    test('does not throw when locale symbols are not initialized', () {
      AppStrings.setLocale(AppStrings.turkish);

      final item = ChatHistoryItem(
        id: 'fmt-1',
        contact: '+905551234567',
        platformName: 'whatsapp',
        timestamp: DateTime.now(),
      );

      expect(() => item.formattedDate, returnsNormally);
    });
  });
}
