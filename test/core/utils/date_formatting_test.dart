import 'package:directfast/core/utils/date_formatting.dart';
import 'package:directfast/data/models/chat_history_item.dart';
import 'package:directfast/shared/constants/app_strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Date formatting safety', () {
    test('initializeDateFormatting handles regional locale values', () async {
      await expectLater(
        ensureDateFormattingInitialized('tr_TR'),
        completes,
      );
      await expectLater(
        ensureDateFormattingInitialized('en-US'),
        completes,
      );
    });

    test('fallback formatters always return non-empty strings', () {
      final timestamp = DateTime(2026, 4, 18, 9, 5);

      final formattedTime = formatTimeHm(timestamp, 'xx_YY');
      final formattedDate = formatDateYMd(timestamp, 'xx_YY');

      expect(formattedTime, isNotEmpty);
      expect(formattedDate, isNotEmpty);
      expect(formattedTime, matches(RegExp(r'^\d{2}:\d{2}$')));
    });

    test('ChatHistoryItem.formattedDate never throws', () {
      AppStrings.setLocale(AppStrings.turkish);
      final item = ChatHistoryItem(
        id: 'item-1',
        contact: '5551234567',
        platformName: 'whatsapp',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      );

      expect(() => item.formattedDate, returnsNormally);
      expect(item.formattedDate, isNotEmpty);
    });
  });
}
