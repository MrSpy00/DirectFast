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
      final List<dynamic> list = jsonDecode(jsonString);
      return list.map((e) => TemplateItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }
}
