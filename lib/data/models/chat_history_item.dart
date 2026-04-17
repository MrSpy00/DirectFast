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
    final nowDate = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    final dayDifference = nowDate.difference(itemDate).inDays;
    final locale = AppStrings.currentLocale;
    final time = _formatTime(locale);

    if (dayDifference <= 0) {
      return '${AppStrings.tr('today')} $time';
    } else if (dayDifference == 1) {
      return '${AppStrings.tr('yesterday')} $time';
    } else if (dayDifference < 7) {
      return AppStrings.tr('days_ago', args: [dayDifference.toString()]);
    } else {
      return _formatDate(locale);
    }
  }

  String _formatTime(String locale) {
    try {
      return DateFormat.Hm(locale).format(timestamp);
    } catch (_) {
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }

  String _formatDate(String locale) {
    try {
      return DateFormat.yMd(locale).format(timestamp);
    } catch (_) {
      final day = timestamp.day.toString().padLeft(2, '0');
      final month = timestamp.month.toString().padLeft(2, '0');
      final year = timestamp.year.toString();
      return '$day/$month/$year';
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
    final rawTimestamp = (json['timestamp'] ?? '').toString();
    final parsedTimestamp = DateTime.tryParse(rawTimestamp);
    if (parsedTimestamp == null) {
      throw const FormatException('Invalid timestamp');
    }

    final id = (json['id'] ?? '').toString().trim();
    final contact = (json['contact'] ?? '').toString().trim();
    final platformName =
        (json['platformName'] ?? json['platform'] ?? '').toString().trim();

    if (id.isEmpty || contact.isEmpty) {
      throw const FormatException('Missing required history fields');
    }

    return ChatHistoryItem(
      id: id,
      contact: contact,
      platformName: platformName.isEmpty ? 'whatsapp' : platformName,
      timestamp: parsedTimestamp,
      displayName: json['displayName']?.toString(),
    );
  }

  // Encode list to JSON string
  static String encodeList(List<ChatHistoryItem> items) {
    return jsonEncode(items.map((item) => item.toJson()).toList());
  }

  // Decode JSON string to list
  static List<ChatHistoryItem> decodeList(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List) {
        return [];
      }

      final items = <ChatHistoryItem>[];
      for (final raw in decoded) {
        if (raw is! Map) {
          continue;
        }

        try {
          items.add(ChatHistoryItem.fromJson(Map<String, dynamic>.from(raw)));
        } catch (_) {
          // Skip malformed entries but keep valid history records.
        }
      }

      return items;
    } catch (_) {
      return [];
    }
  }
}
