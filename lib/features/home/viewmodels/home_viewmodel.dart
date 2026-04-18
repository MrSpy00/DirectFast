import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../core/constants/platform_type.dart';
import '../../../core/services/url_launcher_service.dart';
import '../../../core/services/clipboard_service.dart';
import '../../history/viewmodels/history_viewmodel.dart';

final selectedPlatformProvider = StateProvider<PlatformType>((ref) {
  return PlatformType.whatsapp;
});

final selectedCategoryProvider = StateProvider<PlatformCategory>((ref) {
  return PlatformCategory.chat;
});

final contactInputProvider = StateProvider<String>((ref) {
  return '';
});

final pendingContactProvider = StateProvider<String?>((ref) {
  return null;
});

final clipboardSuggestionProvider = FutureProvider<String?>((ref) async {
  final selectedPlatform = ref.watch(selectedPlatformProvider);

  if (selectedPlatform.requiresPhoneNumber) {
    return ClipboardService.getPhoneNumber();
  } else if (selectedPlatform.requiresUsername) {
    return ClipboardService.getUsername();
  } else if (selectedPlatform.requiresEmail) {
    return ClipboardService.getEmail();
  }

  return null;
});

final chatLauncherProvider = Provider<ChatLauncher>((ref) {
  return ChatLauncher(ref);
});

class ChatLauncher {
  final Ref ref;

  ChatLauncher(this.ref);

  Future<LaunchResult> launchChat({
    required PlatformType platform,
    required String contact,
  }) async {
    final error = UrlLauncherService.getValidationError(
      platform: platform,
      contact: contact,
    );

    if (error != null) {
      return LaunchResult(success: false, error: error);
    }

    final result = await UrlLauncherService.launchChat(
      platform: platform,
      contact: contact,
    );

    if (result.success) {
      await ref.read(historyProvider.notifier).addHistoryItem(
            platform: platform,
            contact: contact,
          );
    }

    return result;
  }
}
