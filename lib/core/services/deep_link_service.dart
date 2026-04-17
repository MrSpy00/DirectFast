import '../constants/platform_type.dart';
import '../models/deep_link_request.dart';
import 'url_launcher_service.dart';

class DeepLinkService {
  const DeepLinkService._();

  static const String scheme = 'directfast';
  static const String _chatTarget = 'chat';

  static final Map<String, PlatformType> _platformAliases =
      <String, PlatformType>{
    'whatsapp': PlatformType.whatsapp,
    'wa': PlatformType.whatsapp,
    'telegram': PlatformType.telegram,
    'tg': PlatformType.telegram,
    'signal': PlatformType.signal,
    'sgnl': PlatformType.signal,
    'viber': PlatformType.viber,
    'wechat': PlatformType.wechat,
    'line': PlatformType.line,
    'messenger': PlatformType.messenger,
    'discord': PlatformType.discord,
    'instagram': PlatformType.instagram,
    'ig': PlatformType.instagram,
    'twitter': PlatformType.twitter,
    'x': PlatformType.twitter,
    'snapchat': PlatformType.snapchat,
    'youtube': PlatformType.youtube,
    'yt': PlatformType.youtube,
    'tiktok': PlatformType.tiktok,
    'tt': PlatformType.tiktok,
    'twitch': PlatformType.twitch,
    'facebook': PlatformType.facebook,
    'fb': PlatformType.facebook,
    'kick': PlatformType.kick,
    'linkedin': PlatformType.linkedin,
    'li': PlatformType.linkedin,
    'gmail': PlatformType.email,
    'email': PlatformType.email,
    'mail': PlatformType.email,
  };

  static DeepLinkRequest? parse(Uri uri) {
    if (uri.scheme.toLowerCase() != scheme) {
      return null;
    }

    final String? target = _extractTarget(uri);
    if (target != _chatTarget) {
      return null;
    }

    final List<String> segments =
        uri.pathSegments.where((segment) => segment.isNotEmpty).toList();

    final PlatformType? platform = _resolvePlatform(
      uri.queryParameters['platform'] ??
          _extractPlatformFromPath(uri, segments),
    );

    if (platform == null) {
      return null;
    }

    if (platform.category == PlatformCategory.utility) {
      return null;
    }

    final String? rawContact = _resolveContact(uri, platform, segments);
    if (rawContact == null || rawContact.trim().isEmpty) {
      return null;
    }

    final String contact = rawContact.trim();
    if (!UrlLauncherService.validateContact(
      platform: platform,
      contact: contact,
    )) {
      return null;
    }

    return DeepLinkRequest(
      platform: platform,
      contact: contact,
      sourceUri: uri,
    );
  }

  static Uri buildChatUri({
    required PlatformType platform,
    required String contact,
  }) {
    return Uri(
      scheme: scheme,
      host: _chatTarget,
      queryParameters: <String, String>{
        'platform': platform.name,
        _contactKeyForPlatform(platform): contact,
      },
    );
  }

  static String _contactKeyForPlatform(PlatformType platform) {
    if (platform.requiresPhoneNumber) {
      return 'phone';
    }
    if (platform.requiresUsername) {
      return 'username';
    }
    return 'email';
  }

  static String? _extractTarget(Uri uri) {
    if (uri.host.isNotEmpty) {
      return uri.host.toLowerCase();
    }

    final List<String> segments =
        uri.pathSegments.where((segment) => segment.isNotEmpty).toList();
    if (segments.isEmpty) {
      return null;
    }

    return segments.first.toLowerCase();
  }

  static String? _extractPlatformFromPath(Uri uri, List<String> segments) {
    if (segments.isEmpty) {
      return null;
    }

    if (uri.host.isNotEmpty) {
      if (segments.isNotEmpty) {
        return segments.first;
      }
      return null;
    }

    if (segments.length >= 2 && segments.first.toLowerCase() == _chatTarget) {
      return segments[1];
    }

    return null;
  }

  static PlatformType? _resolvePlatform(String? rawPlatform) {
    if (rawPlatform == null || rawPlatform.trim().isEmpty) {
      return null;
    }

    final String normalized = rawPlatform.trim().toLowerCase();
    return _platformAliases[normalized];
  }

  static String? _resolveContact(
    Uri uri,
    PlatformType platform,
    List<String> segments,
  ) {
    final String? fromQuery = _extractContactFromQuery(uri, platform);
    if (fromQuery != null) {
      return fromQuery;
    }

    return _extractContactFromPath(uri, segments);
  }

  static String? _extractContactFromQuery(Uri uri, PlatformType platform) {
    final List<String> keys;
    if (platform.requiresPhoneNumber) {
      keys = <String>['phone', 'number', 'contact'];
    } else if (platform.requiresUsername) {
      keys = <String>['username', 'user', 'handle', 'contact'];
    } else {
      keys = <String>['email', 'contact'];
    }

    for (final String key in keys) {
      final String? value = uri.queryParameters[key];
      if (value != null && value.trim().isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  static String? _extractContactFromPath(Uri uri, List<String> segments) {
    if (segments.isEmpty) {
      return null;
    }

    if (uri.host.isNotEmpty) {
      if (segments.length >= 2) {
        return Uri.decodeComponent(segments[1]);
      }
      return null;
    }

    if (segments.length >= 3 && segments.first.toLowerCase() == _chatTarget) {
      return Uri.decodeComponent(segments[2]);
    }

    return null;
  }
}
