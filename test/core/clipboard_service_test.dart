import 'package:directfast/core/services/clipboard_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClipboardService.extractPhoneCandidates', () {
    test('extracts and normalizes multiple phone numbers', () {
      const text = 'Call +90 (555) 123 45 67 or 0044 7700 900123 now';

      final phones = ClipboardService.extractPhoneCandidates(text);

      expect(phones, equals(<String>['+905551234567', '+447700900123']));
    });

    test('removes duplicates after normalization', () {
      const text = '+1 (202) 555-0101 and 0012025550101';

      final phones = ClipboardService.extractPhoneCandidates(text);

      expect(phones, equals(<String>['+12025550101']));
    });

    test('ignores invalid short sequences', () {
      const text = 'pin 12345, ext 777';

      final phones = ClipboardService.extractPhoneCandidates(text);

      expect(phones, isEmpty);
    });
  });
}
