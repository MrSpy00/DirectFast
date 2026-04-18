import 'dart:convert';
import '../../core/constants/platform_type.dart';
import '../../core/utils/date_formatting.dart';
import '../../shared/constants/app_strings.dart';

class ChatHistoryItem {
  static const Map<String, PlatformType> _platformLookup = {
    'whatsapp': PlatformType.whatsapp,
    'telegram': PlatformType.telegram,
    'signal': PlatformType.signal,
    'viber': PlatformType.viber,
    'wechat': PlatformType.wechat,
    'line': PlatformType.line,
    'messenger': PlatformType.messenger,
    'discord': PlatformType.discord,
    'instagram': PlatformType.instagram,
    'x': PlatformType.twitter,
    'twitter': PlatformType.twitter,
    'snapchat': PlatformType.snapchat,
    'youtube': PlatformType.youtube,
    'tiktok': PlatformType.tiktok,
    'twitch': PlatformType.twitch,
    'facebook': PlatformType.facebook,
    'kick': PlatformType.kick,
    'linkedin': PlatformType.linkedin,
    'email': PlatformType.email,
  };

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
    return _platformLookup[platformName.toLowerCase()] ?? PlatformType.whatsapp;
  }

  String get formattedDate {
    try {
      final now = DateTime.now();
      final nowDate = DateTime(now.year, now.month, now.day);
      final itemDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
      final dayDifference = nowDate.difference(itemDate).inDays;
      final locale = AppStrings.currentLocale;
      final time = _formatTime(locale);

      if (dayDifference <= 0) {
        return '${AppStrings.tr('today')} $time';
      }

      if (dayDifference == 1) {
        return '${AppStrings.tr('yesterday')} $time';
      }

      if (dayDifference < 7) {
        return AppStrings.tr('days_ago', args: [dayDifference.toString()]);
      }

      return _formatDate(locale);
    } catch (_) {
      return _manualTimestampLabel();
    }
  }

  String _formatTime(String locale) {
    return formatTimeHm(timestamp, locale);
  }

  String _formatDate(String locale) {
    return formatDateYMd(timestamp, locale);
  }

  String _manualTimestampLabel() {
    final date = formatDateYMd(timestamp, AppStrings.fallbackLocale);
    final time = formatTimeHm(timestamp, AppStrings.fallbackLocale);
    return '$date $time';
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
