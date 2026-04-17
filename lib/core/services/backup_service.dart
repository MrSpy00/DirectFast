import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;

import '../../data/models/chat_history_item.dart';
import '../../data/models/template_item.dart';
import 'storage_service.dart';

enum BackupErrorType {
  invalidPayload,
  unsupportedFormat,
  passphraseRequired,
  wrongPassphrase,
}

class BackupException implements Exception {
  BackupException(this.type, this.message);

  final BackupErrorType type;
  final String message;

  @override
  String toString() => 'BackupException($type): $message';
}

class BackupImportResult {
  const BackupImportResult({
    required this.historyCount,
    required this.templateCount,
    required this.wasEncrypted,
  });

  final int historyCount;
  final int templateCount;
  final bool wasEncrypted;
}

class BackupService {
  const BackupService._();

  static const String _plainType = 'directfast_backup';
  static const String _encryptedType = 'directfast_backup_encrypted';
  static const int _version = 1;

  static bool looksEncrypted(String payload) {
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map<String, dynamic> &&
          decoded['type'] == _encryptedType;
    } catch (_) {
      return false;
    }
  }

  static Future<String> exportPlainBackup() async {
    final payload = _buildPlainPayload();
    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  static Future<String> exportEncryptedBackup({
    required String passphrase,
  }) async {
    final normalizedPassphrase = passphrase.trim();
    if (normalizedPassphrase.length < 4) {
      throw BackupException(
        BackupErrorType.passphraseRequired,
        'Passphrase must contain at least 4 characters.',
      );
    }

    final plainPayload = _buildPlainPayload();
    final plainJson = jsonEncode(plainPayload);

    final salt = _randomBytes(16);
    final iv = _randomBytes(16);
    final key = _deriveKey(normalizedPassphrase, salt);

    final encrypter = encrypt_lib.Encrypter(
      encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(
      plainJson,
      iv: encrypt_lib.IV(Uint8List.fromList(iv)),
    );

    final envelope = <String, dynamic>{
      'type': _encryptedType,
      'version': _version,
      'createdAt': DateTime.now().toIso8601String(),
      'kdf': 'sha256',
      'salt': base64Encode(salt),
      'iv': base64Encode(iv),
      'data': encrypted.base64,
    };

    return const JsonEncoder.withIndent('  ').convert(envelope);
  }

  static Future<BackupImportResult> importBackup({
    required String payload,
    String? passphrase,
    bool restoreSettings = false,
  }) async {
    final normalizedPayload = payload.trim();
    if (normalizedPayload.isEmpty) {
      throw BackupException(
        BackupErrorType.invalidPayload,
        'Backup payload is empty.',
      );
    }

    final root = _decodeRootObject(normalizedPayload);
    final bool encrypted = root['type'] == _encryptedType;

    final Map<String, dynamic> plainPayload;
    if (encrypted) {
      plainPayload = _decryptPayload(root, passphrase);
    } else if (root['type'] == _plainType) {
      plainPayload = root;
    } else {
      throw BackupException(
        BackupErrorType.unsupportedFormat,
        'Unsupported backup format.',
      );
    }

    final data = plainPayload['data'];
    if (data is! Map<String, dynamic>) {
      throw BackupException(
        BackupErrorType.invalidPayload,
        'Backup data section is invalid.',
      );
    }

    final history = _decodeHistory(data['history']);
    final templates = _decodeTemplates(data['templates']);

    await StorageService.replaceHistory(history);
    await StorageService.replaceTemplates(templates);

    if (restoreSettings) {
      await _restoreSettings(data['settings']);
    }

    return BackupImportResult(
      historyCount: history.length,
      templateCount: templates.length,
      wasEncrypted: encrypted,
    );
  }

  static Map<String, dynamic> _buildPlainPayload() {
    final history = StorageService.getAllHistory();
    final templates = StorageService.getAllTemplates();

    return <String, dynamic>{
      'type': _plainType,
      'version': _version,
      'createdAt': DateTime.now().toIso8601String(),
      'data': <String, dynamic>{
        'history': history.map((item) => item.toJson()).toList(),
        'templates': templates.map((item) => item.toJson()).toList(),
        'settings': <String, dynamic>{
          'themeMode': StorageService.getThemeMode(),
          'themeColorId': StorageService.getThemeColorId(),
          'customThemeColor': StorageService.getCustomThemeColorValue(),
          'locale': StorageService.getLocale(),
          'onboardingCompleted': StorageService.isOnboardingCompleted(),
        },
      },
    };
  }

  static Map<String, dynamic> _decodeRootObject(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Parsed below with a structured BackupException.
    }

    throw BackupException(
      BackupErrorType.invalidPayload,
      'Backup payload is not valid JSON.',
    );
  }

  static Map<String, dynamic> _decryptPayload(
    Map<String, dynamic> envelope,
    String? passphrase,
  ) {
    final normalizedPassphrase = passphrase?.trim() ?? '';
    if (normalizedPassphrase.isEmpty) {
      throw BackupException(
        BackupErrorType.passphraseRequired,
        'Encrypted backup requires a passphrase.',
      );
    }

    final String? saltB64 = envelope['salt'] as String?;
    final String? ivB64 = envelope['iv'] as String?;
    final String? encryptedB64 = envelope['data'] as String?;

    if (saltB64 == null || ivB64 == null || encryptedB64 == null) {
      throw BackupException(
        BackupErrorType.invalidPayload,
        'Encrypted backup payload is missing required fields.',
      );
    }

    try {
      final salt = base64Decode(saltB64);
      final iv = base64Decode(ivB64);
      final key = _deriveKey(normalizedPassphrase, salt);

      final encrypter = encrypt_lib.Encrypter(
        encrypt_lib.AES(key, mode: encrypt_lib.AESMode.cbc),
      );

      final plainJson = encrypter.decrypt64(
        encryptedB64,
        iv: encrypt_lib.IV(Uint8List.fromList(iv)),
      );

      final decoded = jsonDecode(plainJson);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      throw BackupException(
        BackupErrorType.wrongPassphrase,
        'Passphrase is invalid or backup content is corrupted.',
      );
    }

    throw BackupException(
      BackupErrorType.invalidPayload,
      'Encrypted backup content is invalid.',
    );
  }

  static List<ChatHistoryItem> _decodeHistory(dynamic raw) {
    if (raw is! List) {
      return <ChatHistoryItem>[];
    }

    final output = <ChatHistoryItem>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        try {
          output.add(ChatHistoryItem.fromJson(item));
        } catch (_) {
          // Skip malformed item instead of failing whole import.
        }
      }
    }

    output.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return output;
  }

  static List<TemplateItem> _decodeTemplates(dynamic raw) {
    if (raw is! List) {
      return <TemplateItem>[];
    }

    final output = <TemplateItem>[];
    for (final item in raw) {
      if (item is Map<String, dynamic>) {
        try {
          output.add(TemplateItem.fromJson(item));
        } catch (_) {
          // Skip malformed item instead of failing whole import.
        }
      }
    }

    output.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return output;
  }

  static Future<void> _restoreSettings(dynamic rawSettings) async {
    if (rawSettings is! Map<String, dynamic>) {
      return;
    }

    final themeMode = rawSettings['themeMode'];
    if (themeMode is String && themeMode.isNotEmpty) {
      await StorageService.setThemeMode(themeMode);
    }

    final themeColorId = rawSettings['themeColorId'];
    if (themeColorId is String && themeColorId.isNotEmpty) {
      await StorageService.setThemeColorId(themeColorId);
    }

    final customThemeColor = rawSettings['customThemeColor'];
    if (customThemeColor is int) {
      await StorageService.setCustomThemeColorValue(customThemeColor);
    } else {
      await StorageService.setCustomThemeColorValue(null);
    }

    final locale = rawSettings['locale'];
    if (locale is String && locale.isNotEmpty) {
      await StorageService.setLocale(locale);
    }

    final onboardingCompleted = rawSettings['onboardingCompleted'];
    if (onboardingCompleted is bool) {
      await StorageService.setOnboardingCompleted(onboardingCompleted);
    }
  }

  static encrypt_lib.Key _deriveKey(String passphrase, List<int> salt) {
    final bytes = utf8.encode('$passphrase:${base64Encode(salt)}');
    final digest = sha256.convert(bytes).bytes;
    return encrypt_lib.Key(Uint8List.fromList(digest));
  }

  static List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }
}
