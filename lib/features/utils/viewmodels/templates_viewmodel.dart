import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/template_item.dart';

final templatesProvider =
    StateNotifierProvider<TemplatesNotifier, List<TemplateItem>>((ref) {
  return TemplatesNotifier();
});

class TemplatesNotifier extends StateNotifier<List<TemplateItem>> {
  TemplatesNotifier() : super([]) {
    _load();
  }

  void _load() {
    state = StorageService.getAllTemplates();
  }

  Future<void> addTemplate({
    required String name,
    required String message,
  }) async {
    final item = TemplateItem(
      id: const Uuid().v4(),
      name: name,
      message: message,
      createdAt: DateTime.now(),
    );
    await StorageService.addTemplate(item);
    _load();
  }

  Future<void> deleteTemplate(String id) async {
    await StorageService.deleteTemplate(id);
    _load();
  }

  void reload() {
    _load();
  }
}
