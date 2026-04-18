import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/services.dart';
import '../constants/platform_type.dart';
import '../constants/app_constants.dart';
import '../../shared/constants/app_strings.dart';

class UrlLauncherService {
  /// Launch a chat link and fall back to web when needed.
  static Future<LaunchResult> launchChat({
    required PlatformType platform,
    required String contact,
  }) async {
    try {
      if (platform == PlatformType.discord) {
        return await _handleDiscord(contact);
      }

      if (platform == PlatformType.wechat) {
        return await _handleWeChat(contact);
      }

      final cleanedContact = _sanitizeContact(contact, platform);

      return await _tryLaunchWithFallback(platform, cleanedContact);
    } catch (e) {
      return LaunchResult(
        success: false,
        error: AppStrings.tr('unexpected_error', args: [e.toString()]),
      );
    }
  }

  /// Try app scheme first, then fall back to web URL.
  static Future<LaunchResult> _tryLaunchWithFallback(
    PlatformType platform,
    String contact,
  ) async {
    final appUrl = _buildAppUrl(platform, contact);
    final webUrl = _buildWebUrl(platform, contact);

    if (appUrl != null) {
      try {
        final appUri = Uri.parse(appUrl);
        final canLaunchApp = await canLaunchUrl(appUri);

        if (canLaunchApp) {
          final launched = await launchUrl(
            appUri,
            mode: LaunchMode.externalApplication,
          );

          if (launched) {
            return LaunchResult(
              success: true,
              message: AppStrings.tr(
                'opening_app',
                args: [platform.displayName],
              ),
            );
          }
        }
      } on PlatformException catch (e) {
        _ignoreError(e);
      } catch (e) {
        _ignoreError(e);
      }
    }

    if (webUrl != null) {
      try {
        final webUri = Uri.parse(webUrl);

        try {
          final canLaunchWeb = await canLaunchUrl(webUri);

          if (canLaunchWeb) {
            final launched = await launchUrl(
              webUri,
              mode: LaunchMode.externalApplication,
            );

            if (launched) {
              return LaunchResult(
                success: true,
                message: AppStrings.tr(
                  'opening_in_browser',
                  args: [platform.displayName],
                ),
              );
            }
          }
        } catch (e) {
          _ignoreError(e);
        }

        try {
          final forceLaunched = await launchUrl(
            webUri,
            mode: LaunchMode.externalApplication,
          );

          if (forceLaunched) {
            return LaunchResult(
              success: true,
              message: AppStrings.tr(
                'opening_in_browser',
                args: [platform.displayName],
              ),
            );
          }
        } catch (e) {
          _ignoreError(e);
        }

        try {
          final lastResortLaunched = await launchUrl(
            webUri,
          );

          if (lastResortLaunched) {
            return LaunchResult(
              success: true,
              message: AppStrings.tr(
                'opening',
                args: [platform.displayName],
              ),
            );
          }
        } catch (e) {
          _ignoreError(e);
        }
      } on PlatformException catch (e) {
        return LaunchResult(
          success: false,
          error: AppStrings.tr(
            'failed_to_open_platform',
            args: [platform.displayName, e.message ?? '-'],
          ),
        );
      } catch (e) {
        return LaunchResult(
          success: false,
          error: AppStrings.tr(
            'failed_to_open_platform',
            args: [platform.displayName, e.toString()],
          ),
        );
      }
    }

    return LaunchResult(
      success: false,
      error: AppStrings.tr(
        'could_not_open_platform_retry',
        args: [platform.displayName],
      ),
    );
  }

  /// Build app-specific URL.
  static String? _buildAppUrl(PlatformType platform, String contact) {
    switch (platform) {
      case PlatformType.whatsapp:
        return 'whatsapp://send?phone=$contact';

      case PlatformType.telegram:
        return 'tg://resolve?domain=$contact';

      case PlatformType.signal:
        return 'sgnl://signal.me/#p/$contact';

      case PlatformType.viber:
        return '${AppConstants.viberUrlTemplate}$contact';

      case PlatformType.wechat:
        return null;

      case PlatformType.line:
        return 'line://ti/p/~$contact';

      case PlatformType.messenger:
        return null;

      case PlatformType.instagram:
        return 'instagram://user?username=$contact';

      case PlatformType.twitter:
        return 'twitter://user?screen_name=$contact';

      case PlatformType.snapchat:
        return 'snapchat://add/$contact';

      case PlatformType.youtube:
        return null;

      case PlatformType.tiktok:
        return null;

      case PlatformType.twitch:
        return 'twitch://stream/$contact';

      case PlatformType.facebook:
        return 'fb://facewebmodal/f?href=https://www.facebook.com/$contact';

      case PlatformType.kick:
        return null;

      case PlatformType.linkedin:
        return 'linkedin://in/$contact';

      case PlatformType.email:
        return null;

      case PlatformType.discord:
        return null;
    }
  }

  /// Build web fallback URL
  static String? _buildWebUrl(PlatformType platform, String contact) {
    switch (platform) {
      case PlatformType.whatsapp:
        return '${AppConstants.whatsappUrlTemplate}$contact';

      case PlatformType.telegram:
        return '${AppConstants.telegramUrlTemplate}$contact';

      case PlatformType.signal:
        return null;

      case PlatformType.viber:
        return 'https://www.viber.com/';

      case PlatformType.wechat:
        return 'https://www.wechat.com/';

      case PlatformType.line:
        return 'https://line.me/R/ti/p/~$contact';

      case PlatformType.messenger:
        return 'https://m.me/$contact';

      case PlatformType.instagram:
        return 'https://instagram.com/$contact';

      case PlatformType.twitter:
        return 'https://x.com/$contact';

      case PlatformType.snapchat:
        return 'https://www.snapchat.com/add/$contact';

      case PlatformType.youtube:
        return 'https://www.youtube.com/@$contact';

      case PlatformType.tiktok:
        return 'https://www.tiktok.com/@$contact';

      case PlatformType.twitch:
        return 'https://www.twitch.tv/$contact';

      case PlatformType.facebook:
        return 'https://www.facebook.com/$contact';

      case PlatformType.kick:
        return 'https://kick.com/$contact';

      case PlatformType.linkedin:
        return 'https://www.linkedin.com/in/$contact';

      case PlatformType.email:
        return 'mailto:$contact';

      case PlatformType.discord:
        return 'https://discord.com/users/$contact';
    }
  }

  /// Handle Discord by copying username and opening the app/site.
  static Future<LaunchResult> _handleDiscord(String username) async {
    try {
      await FlutterClipboard.copy(username);

      try {
        final discordUri = Uri.parse('discord://');
        final canLaunch = await canLaunchUrl(discordUri);

        if (canLaunch) {
          final launched = await launchUrl(
            discordUri,
            mode: LaunchMode.externalApplication,
          );

          if (launched) {
            return LaunchResult(
              success: true,
              message: AppStrings.tr('discord_copied_opened'),
              specialAction: 'discord_copy',
            );
          }
        }
      } catch (e) {
        _ignoreError(e);
      }

      const webUrl = 'https://discord.com';
      final webUri = Uri.parse(webUrl);
      final launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        return LaunchResult(
          success: true,
          message: AppStrings.tr('discord_copied_browser'),
          specialAction: 'discord_copy',
        );
      }

      return LaunchResult(
        success: false,
        error: AppStrings.tr('could_not_open_platform', args: ['Discord']),
      );
    } catch (e) {
      return LaunchResult(
        success: false,
        error: AppStrings.tr('platform_error', args: ['Discord', e.toString()]),
      );
    }
  }

  /// Handle WeChat by copying username and opening the app/site.
  static Future<LaunchResult> _handleWeChat(String username) async {
    try {
      await FlutterClipboard.copy(username);

      try {
        final wechatUri = Uri.parse('weixin://');
        final canLaunch = await canLaunchUrl(wechatUri);

        if (canLaunch) {
          final launched = await launchUrl(
            wechatUri,
            mode: LaunchMode.externalApplication,
          );

          if (launched) {
            return LaunchResult(
              success: true,
              message: AppStrings.tr('wechat_copied_opened'),
              specialAction: 'wechat_copy',
            );
          }
        }
      } catch (e) {
        _ignoreError(e);
      }

      final webUri = Uri.parse('https://www.wechat.com/');
      final launched = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );

      if (launched) {
        return LaunchResult(
          success: true,
          message: AppStrings.tr('wechat_copied_browser'),
          specialAction: 'wechat_copy',
        );
      }

      return LaunchResult(
        success: false,
        error: AppStrings.tr('could_not_open_platform', args: ['WeChat']),
      );
    } catch (e) {
      return LaunchResult(
        success: false,
        error: AppStrings.tr('platform_error', args: ['WeChat', e.toString()]),
      );
    }
  }

  /// Sanitize contact input
  static String _sanitizeContact(String contact, PlatformType platform) {
    String sanitized = contact.trim();

    sanitized = sanitized.replaceAll(RegExp('<[^>]*>'), '');

    if (platform.requiresPhoneNumber) {
      sanitized = sanitized.replaceAll(RegExp(r'[^\d+\s\-()]'), '');
      sanitized = sanitized.replaceAll(RegExp(r'[\s\-()]'), '');
    } else if (platform.requiresUsername) {
      if (sanitized.startsWith('@')) {
        sanitized = sanitized.substring(1);
      }
      sanitized = sanitized.replaceAll(RegExp('[^a-zA-Z0-9_.-]'), '');
    } else if (platform.requiresEmail) {
      sanitized = sanitized.replaceAll(RegExp(r'[^a-zA-Z0-9@._\-]'), '');
    }

    return sanitized;
  }

  /// Validate contact
  static bool validateContact({
    required PlatformType platform,
    required String contact,
  }) {
    final sanitized = _sanitizeContact(contact, platform);

    if (sanitized.isEmpty) {
      return false;
    }

    switch (platform) {
      case PlatformType.whatsapp:
      case PlatformType.signal:
      case PlatformType.viber:
        final cleanNumber = sanitized.replaceAll(RegExp(r'[+\s\-()]'), '');
        return cleanNumber.length >= 7 && cleanNumber.length <= 15;

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
        return sanitized.length >= 2 && sanitized.length <= 50;

      case PlatformType.email:
        return AppConstants.emailRegex.hasMatch(sanitized);
    }
  }

  /// Get validation error message
  static String? getValidationError({
    required PlatformType platform,
    required String contact,
  }) {
    if (contact.isEmpty) {
      if (platform.requiresPhoneNumber) {
        return AppStrings.tr('enter_phone_required');
      } else if (platform.requiresEmail) {
        return AppStrings.tr('enter_email_required');
      } else {
        return AppStrings.tr('enter_username_required');
      }
    }

    if (!validateContact(platform: platform, contact: contact)) {
      if (platform.requiresPhoneNumber) {
        return AppStrings.tr('enter_valid_phone');
      } else if (platform.requiresEmail) {
        return AppStrings.tr('enter_valid_email');
      } else {
        return AppStrings.tr('enter_valid_username');
      }
    }

    return null;
  }

  static void _ignoreError(Object _) {}
}

class LaunchResult {
  final bool success;
  final String? error;
  final String? message;
  final String? specialAction;

  LaunchResult({
    required this.success,
    this.error,
    this.message,
    this.specialAction,
  });
}
