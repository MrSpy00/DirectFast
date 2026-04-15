import 'package:url_launcher/url_launcher.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/services.dart';
import '../constants/platform_type.dart';
import '../constants/app_constants.dart';
import '../../shared/constants/app_strings.dart';

class UrlLauncherService {
  /// Launch chat based on platform and contact - WITH ROBUST FALLBACK
  static Future<LaunchResult> launchChat({
    required PlatformType platform,
    required String contact,
  }) async {
    try {
      // Special handling for Discord
      if (platform == PlatformType.discord) {
        return await _handleDiscord(contact);
      }

      // Special handling for WeChat
      if (platform == PlatformType.wechat) {
        return await _handleWeChat(contact);
      }

      // Clean contact based on platform
      final cleanedContact = _sanitizeContact(contact, platform);

      // Try app-specific URL first, then fallback to web
      return await _tryLaunchWithFallback(platform, cleanedContact);
    } catch (e) {
      return LaunchResult(
        success: false,
        error: AppStrings.tr('unexpected_error', args: [e.toString()]),
      );
    }
  }

  /// Try launching with app scheme first, fallback to web (NUCLEAR-PROOF VERSION)
  static Future<LaunchResult> _tryLaunchWithFallback(
    PlatformType platform,
    String contact,
  ) async {
    // Build both app and web URLs
    final appUrl = _buildAppUrl(platform, contact);
    final webUrl = _buildWebUrl(platform, contact);

    // Try app URL first
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
      } on PlatformException {
        // App not installed or launch failed, continue to web fallback
      } catch (_) {
        // Any other error, continue to web fallback
      }
    }

    // Fallback to web URL
    if (webUrl != null) {
      try {
        final webUri = Uri.parse(webUrl);

        // First try: Check canLaunchUrl
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
        } catch (checkError) {
          // Silently continue to force launch
        }

        // NUCLEAR OPTION: Force launch without checking canLaunchUrl
        // This bypasses Android 11+ visibility restrictions
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
        } catch (forceError) {
          // Continue to last resort
        }

        // LAST RESORT: Try with platformDefault mode
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
        } catch (lastResortError) {
          // Silent failure, will return error below
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

  /// Build app-specific URL (scheme://...)
  static String? _buildAppUrl(PlatformType platform, String contact) {
    switch (platform) {
      case PlatformType.whatsapp:
        // WhatsApp app scheme
        return 'whatsapp://send?phone=$contact';

      case PlatformType.telegram:
        // Telegram app scheme
        return 'tg://resolve?domain=$contact';

      case PlatformType.signal:
        // Signal app scheme
        return 'sgnl://signal.me/#p/$contact';

      case PlatformType.viber:
        // Viber app scheme
        return '${AppConstants.viberUrlTemplate}$contact';

      case PlatformType.wechat:
        // Handled separately
        return null;

      case PlatformType.line:
        return 'line://ti/p/~$contact';

      case PlatformType.messenger:
        // Messenger ID scheme varies; web fallback is more reliable
        return null;

      case PlatformType.instagram:
        // Instagram app scheme
        return 'instagram://user?username=$contact';

      case PlatformType.twitter:
        // Twitter/X app scheme
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
        // Email (no app URL, use web directly)
        return null;

      case PlatformType.discord:
        // Handled separately
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
        // Signal web doesn't have public profiles
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

  /// Special handler for Discord
  static Future<LaunchResult> _handleDiscord(String username) async {
    try {
      // Copy username to clipboard for user convenience
      await FlutterClipboard.copy(username);

      // Try Discord app first
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
        // App launch failed, try web
      }

      // Fallback to Discord web
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

  /// Special handler for WeChat.
  ///
  /// WeChat does not provide a consistent public user-profile deep link,
  /// so we copy the identifier and open the app (or website fallback).
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
      } catch (_) {
        // Continue to web fallback
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

    // Remove HTML tags
    sanitized = sanitized.replaceAll(RegExp('<[^>]*>'), '');

    // Platform-specific cleaning
    if (platform.requiresPhoneNumber) {
      // For phone numbers: allow +, digits, spaces, dashes, parentheses
      sanitized = sanitized.replaceAll(RegExp(r'[^\d+\s\-()]'), '');
      // Remove spaces and dashes for clean number
      sanitized = sanitized.replaceAll(RegExp(r'[\s\-()]'), '');
    } else if (platform.requiresUsername) {
      // Remove @ if present
      if (sanitized.startsWith('@')) {
        sanitized = sanitized.substring(1);
      }
      // For usernames: allow alphanumeric, underscore, dot, hyphen
      sanitized = sanitized.replaceAll(RegExp('[^a-zA-Z0-9_.-]'), '');
    } else if (platform.requiresEmail) {
      // For email: allow alphanumeric, @, dot, underscore, dash
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
        // Validate phone number format
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
        // Validate username (3-30 characters)
        return sanitized.length >= 2 && sanitized.length <= 50;

      case PlatformType.email:
        // Basic email validation
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
