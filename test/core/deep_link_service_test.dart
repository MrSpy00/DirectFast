import 'package:flutter_test/flutter_test.dart';
import 'package:directfast/core/constants/platform_type.dart';
import 'package:directfast/core/services/deep_link_service.dart';

void main() {
  group('DeepLinkService.parse', () {
    test('parses valid directfast query deep link', () {
      final uri = Uri.parse(
        'directfast://chat?platform=wa&phone=%2B905551234567',
      );

      final request = DeepLinkService.parse(uri);

      expect(request, isNotNull);
      expect(request!.platform, PlatformType.whatsapp);
      expect(request.contact, '+905551234567');
    });

    test('parses path-style deep link', () {
      final uri = Uri.parse('directfast://chat/telegram/my_handle');

      final request = DeepLinkService.parse(uri);

      expect(request, isNotNull);
      expect(request!.platform, PlatformType.telegram);
      expect(request.contact, 'my_handle');
    });

    test('rejects unsupported scheme', () {
      final uri = Uri.parse('https://chat?platform=wa&phone=+905551234567');
      expect(DeepLinkService.parse(uri), isNull);
    });

    test('rejects malformed contact', () {
      final uri = Uri.parse('directfast://chat?platform=telegram&username=a');
      expect(DeepLinkService.parse(uri), isNull);
    });

    test('rejects utility-only platform links', () {
      final uri =
          Uri.parse('directfast://chat?platform=email&email=test@example.com');
      expect(DeepLinkService.parse(uri), isNull);
    });
  });
}
