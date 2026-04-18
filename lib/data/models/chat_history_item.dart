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

  String get formattedDate => formattedDateForLocale(AppStrings.currentLocale);

  String formattedDateForLocale([String? locale]) {
    final activeLocale = _resolveLocale(locale);

    try {
      final now = DateTime.now();
      final nowDate = DateTime(now.year, now.month, now.day);
      final itemDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
      final dayDifference = nowDate.difference(itemDate).inDays;
      final time = formatTimeHm(timestamp, activeLocale);

      if (dayDifference <= 0) {
        return '${AppStrings.tr('today')} $time';
      }

      if (dayDifference == 1) {
        return '${AppStrings.tr('yesterday')} $time';
      }

      if (dayDifference < 7) {
        return AppStrings.tr('days_ago', args: [dayDifference.toString()]);
      }

      return formatDateYMd(timestamp, activeLocale);
    } catch (_) {
      return _manualTimestampLabel();
    }
  }

  String _resolveLocale(String? locale) {
    final candidate = (locale ?? '').trim();
    if (candidate.isEmpty) {
      return AppStrings.fallbackLocale;
    }
    return AppStrings.normalizeLocale(candidate);
  }

  String _manualTimestampLabel() {
    final day = timestamp.day.toString().padLeft(2, '0');
    final month = timestamp.month.toString().padLeft(2, '0');
    final year = timestamp.year.toString();
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');

    final date = '$day.$month.$year';
    final time = '$hour:$minute';
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

  static String encodeList(List<ChatHistoryItem> items) {
    return jsonEncode(items.map((item) => item.toJson()).toList());
  }

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
