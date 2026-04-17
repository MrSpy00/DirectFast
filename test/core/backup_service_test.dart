import 'package:directfast/core/services/backup_service.dart';
import 'package:directfast/core/services/storage_service.dart';
import 'package:directfast/data/models/chat_history_item.dart';
import 'package:directfast/data/models/template_item.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await StorageService.init();
  });

  test('exports and imports plain backup payload', () async {
    await StorageService.addToHistory(
      ChatHistoryItem(
        id: 'h-1',
        contact: '+905551234567',
        platformName: 'whatsapp',
        timestamp: DateTime.now(),
      ),
    );

    await StorageService.addTemplate(
      TemplateItem(
        id: 't-1',
        name: 'Greeting',
        message: 'Hello there',
        createdAt: DateTime.now(),
      ),
    );

    final payload = await BackupService.exportPlainBackup();

    await StorageService.clearAllHistory();
    await StorageService.replaceTemplates(<TemplateItem>[]);

    final result = await BackupService.importBackup(payload: payload);

    expect(result.wasEncrypted, isFalse);
    expect(result.historyCount, 1);
    expect(result.templateCount, 1);
    expect(StorageService.getAllHistory().length, 1);
    expect(StorageService.getAllTemplates().length, 1);
  });

  test('fails encrypted import with wrong passphrase', () async {
    final payload = await BackupService.exportEncryptedBackup(
      passphrase: 'correct-pass',
    );

    expect(
      () => BackupService.importBackup(
        payload: payload,
        passphrase: 'wrong-pass',
      ),
      throwsA(isA<BackupException>()),
    );
  });
}
