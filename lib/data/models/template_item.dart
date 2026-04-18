import 'dart:convert';

class TemplateItem {
  final String id;
  final String name;
  final String message;
  final DateTime createdAt;

  const TemplateItem({
    required this.id,
    required this.name,
    required this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TemplateItem.fromJson(Map<String, dynamic> json) => TemplateItem(
        id: json['id'] as String,
        name: json['name'] as String,
        message: json['message'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  static String encodeList(List<TemplateItem> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<TemplateItem> decodeList(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! List<dynamic>) {
        return const <TemplateItem>[];
      }

      final items = <TemplateItem>[];
      for (final entry in decoded) {
        if (entry is! Map) {
          continue;
        }

        try {
          items.add(TemplateItem.fromJson(Map<String, dynamic>.from(entry)));
        } catch (_) {
          // Ignore malformed records and keep valid templates.
        }
      }

      return items;
    } catch (_) {
      return const <TemplateItem>[];
    }
  }
}
