import 'dart:convert';
import 'package:intl/intl.dart';
import '../../core/constants/platform_type.dart';
import '../../shared/constants/app_strings.dart';

class ChatHistoryItem {
  final String id;
  final String contact;
  final String platformName;
  final DateTime timestamp;
  final String? displayName;

  ChatHistoryItem({
    required this.id,
    required this.contact,
    required this.platformName,
    required this.timestamp,
    this.displayName,
  });

  PlatformType get platform {
    switch (platformName.toLowerCase()) {
      case 'whatsapp':
        return PlatformType.whatsapp;
      case 'telegram':
        return PlatformType.telegram;
      case 'signal':
        return PlatformType.signal;
      case 'viber':
        return PlatformType.viber;
      case 'wechat':
        return PlatformType.wechat;
      case 'line':
        return PlatformType.line;
      case 'messenger':
        return PlatformType.messenger;
      case 'discord':
        return PlatformType.discord;
      case 'instagram':
        return PlatformType.instagram;
      case 'x':
      case 'twitter':
        return PlatformType.twitter;
      case 'snapchat':
        return PlatformType.snapchat;
      case 'youtube':
        return PlatformType.youtube;
      case 'tiktok':
        return PlatformType.tiktok;
      case 'twitch':
        return PlatformType.twitch;
      case 'facebook':
        return PlatformType.facebook;
      case 'kick':
        return PlatformType.kick;
      case 'linkedin':
        return PlatformType.linkedin;
      case 'email':
        return PlatformType.email;
      default:
        // Fallback for legacy data or unknown platforms
        return PlatformType.whatsapp;
    }
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final locale = AppStrings.currentLocale;
    final time = DateFormat.Hm(locale).format(timestamp);

    if (difference.inDays == 0) {
      return '${AppStrings.tr('today')} $time';
    } else if (difference.inDays == 1) {
      return '${AppStrings.tr('yesterday')} $time';
    } else if (difference.inDays < 7) {
      return AppStrings.tr('days_ago', args: [difference.inDays.toString()]);
    } else {
      return DateFormat.yMd(locale).format(timestamp);
    }
  }

  ChatHistoryItem copyWith({
    String? id,
    String? contact,
    String? platformName,
    DateTime? timestamp,
    String? displayName,
  }) {
    return ChatHistoryItem(
      id: id ?? this.id,
      contact: contact ?? this.contact,
      platformName: platformName ?? this.platformName,
      timestamp: timestamp ?? this.timestamp,
      displayName: displayName ?? this.displayName,
    );
  }

  // JSON Serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contact': contact,
      'platformName': platformName,
      'timestamp': timestamp.toIso8601String(),
      'displayName': displayName,
    };
  }

  factory ChatHistoryItem.fromJson(Map<String, dynamic> json) {
    return ChatHistoryItem(
      id: json['id'] as String,
      contact: json['contact'] as String,
      platformName: json['platformName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      displayName: json['displayName'] as String?,
    );
  }

  // Encode list to JSON string
  static String encodeList(List<ChatHistoryItem> items) {
    return jsonEncode(items.map((item) => item.toJson()).toList());
  }

  // Decode JSON string to list
  static List<ChatHistoryItem> decodeList(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => ChatHistoryItem.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
