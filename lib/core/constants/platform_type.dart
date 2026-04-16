import 'package:flutter/material.dart';
import '../../shared/constants/app_strings.dart';

enum PlatformType {
  whatsapp,
  telegram,
  signal,
  viber,
  wechat,
  line,
  messenger,
  discord,
  instagram,
  twitter,
  snapchat,
  youtube,
  tiktok,
  twitch,
  facebook,
  kick,
  linkedin,
  email;

  String get displayName {
    return AppStrings.tr(localizationKey);
  }

  String get localizationKey {
    switch (this) {
      case PlatformType.whatsapp:
        return 'whatsapp';
      case PlatformType.telegram:
        return 'telegram';
      case PlatformType.signal:
        return 'signal';
      case PlatformType.viber:
        return 'viber';
      case PlatformType.wechat:
        return 'wechat';
      case PlatformType.line:
        return 'line';
      case PlatformType.messenger:
        return 'messenger';
      case PlatformType.discord:
        return 'discord';
      case PlatformType.instagram:
        return 'instagram';
      case PlatformType.twitter:
        return 'twitter';
      case PlatformType.snapchat:
        return 'snapchat';
      case PlatformType.youtube:
        return 'youtube';
      case PlatformType.tiktok:
        return 'tiktok';
      case PlatformType.twitch:
        return 'twitch';
      case PlatformType.facebook:
        return 'facebook';
      case PlatformType.kick:
        return 'kick';
      case PlatformType.linkedin:
        return 'linkedin';
      case PlatformType.email:
        return 'email';
    }
  }

  IconData get icon {
    switch (this) {
      case PlatformType.whatsapp:
        return Icons.chat_bubble;
      case PlatformType.telegram:
        return Icons.send;
      case PlatformType.signal:
        return Icons.lock;
      case PlatformType.viber:
        return Icons.phone_in_talk;
      case PlatformType.wechat:
        return Icons.chat_bubble;
      case PlatformType.line:
        return Icons.chat;
      case PlatformType.messenger:
        return Icons.message;
      case PlatformType.discord:
        return Icons.forum;
      case PlatformType.instagram:
        return Icons.camera_alt;
      case PlatformType.twitter:
        return Icons.tag;
      case PlatformType.snapchat:
        return Icons.camera;
      case PlatformType.youtube:
        return Icons.play_circle_fill;
      case PlatformType.tiktok:
        return Icons.music_note;
      case PlatformType.twitch:
        return Icons.live_tv;
      case PlatformType.facebook:
        return Icons.facebook;
      case PlatformType.kick:
        return Icons.sports_esports;
      case PlatformType.linkedin:
        return Icons.business_center;
      case PlatformType.email:
        return Icons.email;
    }
  }

  Color get color {
    switch (this) {
      case PlatformType.whatsapp:
        return const Color(0xFF25D366);
      case PlatformType.telegram:
        return const Color(0xFF0088CC);
      case PlatformType.signal:
        return const Color(0xFF3A76F0);
      case PlatformType.viber:
        return const Color(0xFF7360F2);
      case PlatformType.wechat:
        return const Color(0xFF07C160);
      case PlatformType.line:
        return const Color(0xFF06C755);
      case PlatformType.messenger:
        return const Color(0xFF00B2FF);
      case PlatformType.discord:
        return const Color(0xFF5865F2);
      case PlatformType.instagram:
        return const Color(0xFFE4405F);
      case PlatformType.twitter:
        return const Color(0xFF000000);
      case PlatformType.snapchat:
        return const Color(0xFFFFFC00);
      case PlatformType.youtube:
        return const Color(0xFFFF0000);
      case PlatformType.tiktok:
        return const Color(0xFF000000);
      case PlatformType.twitch:
        return const Color(0xFF9146FF);
      case PlatformType.facebook:
        return const Color(0xFF1877F2);
      case PlatformType.kick:
        return const Color(0xFF53FC18);
      case PlatformType.linkedin:
        return const Color(0xFF0A66C2);
      case PlatformType.email:
        return const Color(0xFFEA4335);
    }
  }

  List<Color> get gradientColors {
    switch (this) {
      case PlatformType.whatsapp:
        return [const Color(0xFF25D366), const Color(0xFF128C7E)];
      case PlatformType.telegram:
        return [const Color(0xFF0088CC), const Color(0xFF0066AA)];
      case PlatformType.signal:
        return [const Color(0xFF3A76F0), const Color(0xFF2C5AA0)];
      case PlatformType.viber:
        return [const Color(0xFF7360F2), const Color(0xFF5A4AC8)];
      case PlatformType.wechat:
        return [const Color(0xFF07C160), const Color(0xFF0A9F53)];
      case PlatformType.line:
        return [const Color(0xFF06C755), const Color(0xFF049943)];
      case PlatformType.messenger:
        return [const Color(0xFF00B2FF), const Color(0xFF006AFF)];
      case PlatformType.discord:
        return [const Color(0xFF5865F2), const Color(0xFF7289DA)];
      case PlatformType.instagram:
        return [
          const Color(0xFFF58529),
          const Color(0xFFE4405F),
          const Color(0xFFC13584),
        ];
      case PlatformType.twitter:
        return [const Color(0xFF000000), const Color(0xFF14171A)];
      case PlatformType.snapchat:
        return [const Color(0xFFFFFC00), const Color(0xFFE6E300)];
      case PlatformType.youtube:
        return [const Color(0xFFFF0000), const Color(0xFFCC0000)];
      case PlatformType.tiktok:
        return [const Color(0xFF111111), const Color(0xFF222222)];
      case PlatformType.twitch:
        return [const Color(0xFF9146FF), const Color(0xFF6F2FD2)];
      case PlatformType.facebook:
        return [const Color(0xFF1877F2), const Color(0xFF145DBF)];
      case PlatformType.kick:
        return [const Color(0xFF53FC18), const Color(0xFF35B50F)];
      case PlatformType.linkedin:
        return [const Color(0xFF0A66C2), const Color(0xFF084A90)];
      case PlatformType.email:
        return [const Color(0xFFEA4335), const Color(0xFFFBBC05)];
    }
  }

  String? get logoAssetName {
    switch (this) {
      case PlatformType.twitter:
        return 'x';
      case PlatformType.email:
        return null;
      default:
        return name;
    }
  }

  String get inputHint {
    switch (this) {
      case PlatformType.whatsapp:
      case PlatformType.signal:
      case PlatformType.viber:
        return AppStrings.tr('enter_phone');
      case PlatformType.telegram:
      case PlatformType.wechat:
      case PlatformType.line:
      case PlatformType.messenger:
      case PlatformType.discord:
      case PlatformType.instagram:
      case PlatformType.twitter:
      case PlatformType.snapchat:
      case PlatformType.youtube:
      case PlatformType.tiktok:
      case PlatformType.twitch:
      case PlatformType.facebook:
      case PlatformType.kick:
      case PlatformType.linkedin:
        return AppStrings.tr('enter_username');
      case PlatformType.email:
        return AppStrings.tr('enter_email');
    }
  }

  bool get requiresUsername {
    return this == PlatformType.telegram ||
        this == PlatformType.wechat ||
        this == PlatformType.line ||
        this == PlatformType.messenger ||
        this == PlatformType.discord ||
        this == PlatformType.instagram ||
        this == PlatformType.twitter ||
        this == PlatformType.snapchat ||
        this == PlatformType.youtube ||
        this == PlatformType.tiktok ||
        this == PlatformType.twitch ||
        this == PlatformType.facebook ||
        this == PlatformType.kick ||
        this == PlatformType.linkedin;
  }

  bool get requiresPhoneNumber {
    return this == PlatformType.whatsapp ||
        this == PlatformType.signal ||
        this == PlatformType.viber;
  }

  bool get requiresEmail {
    return this == PlatformType.email;
  }

  PlatformCategory get category {
    switch (this) {
      case PlatformType.whatsapp:
      case PlatformType.telegram:
      case PlatformType.signal:
      case PlatformType.viber:
      case PlatformType.wechat:
      case PlatformType.line:
      case PlatformType.messenger:
        return PlatformCategory.chat;
      case PlatformType.discord:
      case PlatformType.instagram:
      case PlatformType.twitter:
      case PlatformType.snapchat:
      case PlatformType.youtube:
      case PlatformType.tiktok:
      case PlatformType.twitch:
      case PlatformType.facebook:
      case PlatformType.kick:
      case PlatformType.linkedin:
        return PlatformCategory.social;
      case PlatformType.email:
        return PlatformCategory.utility;
    }
  }
}

enum PlatformCategory {
  chat,
  social,
  utility;

  String get displayName {
    switch (this) {
      case PlatformCategory.chat:
        return AppStrings.tr('chat_apps');
      case PlatformCategory.social:
        return AppStrings.tr('social_media');
      case PlatformCategory.utility:
        return AppStrings.tr('utilities');
    }
  }

  IconData get icon {
    switch (this) {
      case PlatformCategory.chat:
        return Icons.chat_bubble_outline;
      case PlatformCategory.social:
        return Icons.people_outline;
      case PlatformCategory.utility:
        return Icons.build_outlined;
    }
  }
}
