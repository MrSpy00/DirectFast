import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/backup_service.dart';
import '../../../shared/constants/app_strings.dart';
import '../../../core/features/history/providers/history_provider.dart';
import '../../utils/viewmodels/templates_viewmodel.dart';

class DataBackupScreen extends ConsumerStatefulWidget {
  const DataBackupScreen({super.key});

  @override
  ConsumerState<DataBackupScreen> createState() => _DataBackupScreenState();
}

class _DataBackupScreenState extends ConsumerState<DataBackupScreen> {
  final TextEditingController _payloadController = TextEditingController();
  bool _isBusy = false;
  bool _restoreSettings = false;
  BackupImportResult? _lastImport;

  @override
  void dispose() {
    _payloadController.dispose();
    super.dispose();
  }

  Future<void> _exportPlain() async {
    setState(() => _isBusy = true);
    try {
      final payload = await BackupService.exportPlainBackup();
      await Clipboard.setData(ClipboardData(text: payload));
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr('backup_exported'))),
      );

      await SharePlus.instance.share(
        ShareParams(
          text: payload,
          subject: 'DirectFast Backup',
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _exportEncrypted() async {
    final passphrase = await _askPassphrase();
    if (passphrase == null || passphrase.isEmpty) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      final payload = await BackupService.exportEncryptedBackup(
        passphrase: passphrase,
      );

      await Clipboard.setData(ClipboardData(text: payload));
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr('backup_exported'))),
      );

      await SharePlus.instance.share(
        ShareParams(
          text: payload,
          subject: 'DirectFast Encrypted Backup',
        ),
      );
    } on BackupException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageForBackupError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _importPayload() async {
    final payload = _payloadController.text.trim();
    if (payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr('backup_payload_required'))),
      );
      return;
    }

    String? passphrase;
    if (BackupService.looksEncrypted(payload)) {
      passphrase = await _askPassphrase();
      if (passphrase == null || passphrase.isEmpty) {
        return;
      }
    }

    setState(() => _isBusy = true);
    try {
      final result = await BackupService.importBackup(
        payload: payload,
        passphrase: passphrase,
        restoreSettings: _restoreSettings,
      );

      ref.read(historyProvider.notifier).loadHistory();
      ref.read(templatesProvider.notifier).reload();

      if (!mounted) {
        return;
      }

      setState(() => _lastImport = result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.tr('backup_imported'))),
      );
    } on BackupException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_messageForBackupError(e))),
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<String?> _askPassphrase() async {
    final controller = TextEditingController();
    final value = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppStrings.tr('enter_passphrase')),
          content: TextField(
            controller: controller,
            obscureText: true,
            decoration: InputDecoration(
              hintText: AppStrings.tr('passphrase_hint'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppStrings.tr('cancel')),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: Text(AppStrings.tr('confirm')),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return value;
  }

  String _messageForBackupError(BackupException e) {
    switch (e.type) {
      case BackupErrorType.passphraseRequired:
        return AppStrings.tr('passphrase_required');
      case BackupErrorType.wrongPassphrase:
        return AppStrings.tr('wrong_passphrase');
      case BackupErrorType.invalidPayload:
      case BackupErrorType.unsupportedFormat:
        return AppStrings.tr('backup_invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final templates = ref.watch(templatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.tr('data_backup')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('data_backup_subtitle'),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${AppStrings.tr('history_entries')}: ${history.length}  •  '
                    '${AppStrings.tr('template_entries')}: ${templates.length}',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: _isBusy ? null : _exportPlain,
                        icon: const Icon(Icons.download_rounded),
                        label: Text(AppStrings.tr('export_json')),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isBusy ? null : _exportEncrypted,
                        icon: const Icon(Icons.lock_rounded),
                        label: Text(AppStrings.tr('export_encrypted_backup')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.tr('import_backup'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(AppStrings.tr('restore_overwrite_warning')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _payloadController,
                    minLines: 8,
                    maxLines: 12,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: AppStrings.tr('backup_payload_hint'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _restoreSettings,
                    onChanged: _isBusy
                        ? null
                        : (value) {
                            setState(() => _restoreSettings = value);
                          },
                    title: Text(AppStrings.tr('restore_settings')),
                    subtitle: Text(AppStrings.tr('restore_settings_subtitle')),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _isBusy ? null : _importPayload,
                    icon: const Icon(Icons.upload_rounded),
                    label: Text(AppStrings.tr('import_backup')),
                  ),
                ],
              ),
            ),
          ),
          if (_lastImport != null) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded),
                title: Text(AppStrings.tr('backup_imported')),
                subtitle: Text(
                  '${AppStrings.tr('history_entries')}: ${_lastImport!.historyCount}, '
                  '${AppStrings.tr('template_entries')}: ${_lastImport!.templateCount}, '
                  '${AppStrings.tr('encrypted')}: '
                  '${_lastImport!.wasEncrypted ? AppStrings.tr('yes') : AppStrings.tr('no')}',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
