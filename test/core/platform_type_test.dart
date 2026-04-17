import 'package:directfast/core/constants/platform_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlatformType requirements', () {
    test('phone based platforms require phone number only', () {
      expect(PlatformType.whatsapp.requiresPhoneNumber, isTrue);
      expect(PlatformType.signal.requiresPhoneNumber, isTrue);
      expect(PlatformType.viber.requiresPhoneNumber, isTrue);

      expect(PlatformType.whatsapp.requiresUsername, isFalse);
      expect(PlatformType.signal.requiresUsername, isFalse);
      expect(PlatformType.viber.requiresUsername, isFalse);
      expect(PlatformType.whatsapp.requiresEmail, isFalse);
    });

    test('username based platforms require username only', () {
      const usernamePlatforms = <PlatformType>[
        PlatformType.telegram,
        PlatformType.wechat,
        PlatformType.line,
        PlatformType.messenger,
        PlatformType.discord,
        PlatformType.instagram,
        PlatformType.twitter,
        PlatformType.snapchat,
        PlatformType.youtube,
        PlatformType.tiktok,
        PlatformType.twitch,
        PlatformType.facebook,
        PlatformType.kick,
        PlatformType.linkedin,
      ];

      for (final platform in usernamePlatforms) {
        expect(platform.requiresUsername, isTrue, reason: platform.name);
        expect(platform.requiresPhoneNumber, isFalse, reason: platform.name);
        expect(platform.requiresEmail, isFalse, reason: platform.name);
      }
    });

    test('email platform requires email only', () {
      expect(PlatformType.email.requiresEmail, isTrue);
      expect(PlatformType.email.requiresUsername, isFalse);
      expect(PlatformType.email.requiresPhoneNumber, isFalse);
    });
  });

  group('PlatformType logo assets', () {
    test('twitter uses x logo alias', () {
      expect(PlatformType.twitter.logoAssetName, 'x');
    });

    test('email uses material icon fallback', () {
      expect(PlatformType.email.logoAssetName, isNull);
    });

    test('other platforms use enum name as logo asset', () {
      expect(PlatformType.telegram.logoAssetName, PlatformType.telegram.name);
      expect(PlatformType.discord.logoAssetName, PlatformType.discord.name);
      expect(PlatformType.linkedin.logoAssetName, PlatformType.linkedin.name);
    });
  });

  group('PlatformType categories', () {
    test('chat category is assigned correctly', () {
      expect(PlatformType.whatsapp.category, PlatformCategory.chat);
      expect(PlatformType.telegram.category, PlatformCategory.chat);
      expect(PlatformType.messenger.category, PlatformCategory.chat);
    });

    test('social category is assigned correctly', () {
      expect(PlatformType.instagram.category, PlatformCategory.social);
      expect(PlatformType.youtube.category, PlatformCategory.social);
      expect(PlatformType.kick.category, PlatformCategory.social);
    });

    test('utility category is assigned correctly', () {
      expect(PlatformType.email.category, PlatformCategory.utility);
    });
  });
}
