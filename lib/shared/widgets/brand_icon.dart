import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandIcon extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? color;

  const BrandIcon({
    required this.iconName,
    super.key,
    this.size = 28.0,
    this.color,
  });

  static Widget asInputIcon({
    required String iconName,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: BrandIcon(iconName: iconName, size: 24, color: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: SvgPicture.asset(
        'assets/icons/$iconName.svg',
        width: size,
        height: size,
        colorFilter:
            color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
        placeholderBuilder: (_) => _MaterialFallback(
          iconName: iconName,
          size: size,
          color: color,
        ),
      ),
    );
  }
}

class _MaterialFallback extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? color;

  const _MaterialFallback({
    required this.iconName,
    required this.size,
    required this.color,
  });

  static IconData _iconFor(String name) {
    switch (name.toLowerCase()) {
      case 'whatsapp':
        return Icons.chat_bubble;
      case 'telegram':
        return Icons.send;
      case 'signal':
        return Icons.lock;
      case 'viber':
        return Icons.phone_in_talk;
      case 'wechat':
        return Icons.chat;
      case 'line':
        return Icons.chat_bubble;
      case 'messenger':
        return Icons.message;
      case 'discord':
        return Icons.forum;
      case 'instagram':
        return Icons.camera_alt;
      case 'twitter':
      case 'x':
        return Icons.tag;
      case 'snapchat':
        return Icons.camera;
      case 'youtube':
        return Icons.play_circle_fill;
      case 'tiktok':
        return Icons.music_note;
      case 'twitch':
        return Icons.live_tv;
      case 'facebook':
        return Icons.facebook;
      case 'kick':
        return Icons.sports_esports;
      case 'linkedin':
        return Icons.business_center;
      case 'gmail':
      case 'email':
        return Icons.email;
      default:
        return Icons.app_shortcut;
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Icon(
      _iconFor(iconName),
      size: size,
      color: color ?? Theme.of(ctx).colorScheme.primary,
    );
  }
}
