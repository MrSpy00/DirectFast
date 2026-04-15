class AppStrings {
  // Supported locales
  static const String turkish = 'tr';
  static const String english = 'en';

  // Current locale
  static String _currentLocale = turkish;

  static void setLocale(String locale) {
    _currentLocale = locale;
  }

  static String get currentLocale => _currentLocale;

  // Translations map
  static final Map<String, Map<String, String>> _translations = {
    // App Name & General
    'app_name': {
      'tr': 'DirectFast',
      'en': 'DirectFast',
    },
    'quick_connect': {
      'tr': 'Hızlı Bağlantı',
      'en': 'Quick Connect',
    },
    'chat_without_saving': {
      'tr': 'Numarayı yaz, platformu seç, anında bağlantı kur.',
      'en': 'Enter a contact, choose a platform, and connect instantly.',
    },

    // Navigation
    'home': {
      'tr': 'Ana Sayfa',
      'en': 'Home',
    },
    'history': {
      'tr': 'Geçmiş',
      'en': 'History',
    },
    'settings': {
      'tr': 'Ayarlar',
      'en': 'Settings',
    },

    // Categories
    'chat_apps': {
      'tr': 'Sohbet',
      'en': 'Chat',
    },
    'social_media': {
      'tr': 'Sosyal Medya',
      'en': 'Social Media',
    },
    'utilities': {
      'tr': 'Araçlar',
      'en': 'Utilities',
    },

    // Platforms
    'whatsapp': {
      'tr': 'WhatsApp',
      'en': 'WhatsApp',
    },
    'telegram': {
      'tr': 'Telegram',
      'en': 'Telegram',
    },
    'signal': {
      'tr': 'Signal',
      'en': 'Signal',
    },
    'discord': {
      'tr': 'Discord',
      'en': 'Discord',
    },
    'instagram': {
      'tr': 'Instagram',
      'en': 'Instagram',
    },
    'twitter': {
      'tr': 'X (Twitter)',
      'en': 'X (Twitter)',
    },
    'email': {
      'tr': 'E-posta',
      'en': 'Email',
    },

    // Actions
    'select_platform': {
      'tr': 'Platform Seç',
      'en': 'Select Platform',
    },
    'open': {
      'tr': 'Aç',
      'en': 'Open',
    },
    'open_platform': {
      'tr': '%s Aç',
      'en': 'Open %s',
    },
    'clear_all': {
      'tr': 'Tümünü Temizle',
      'en': 'Clear All',
    },
    'delete': {
      'tr': 'Sil',
      'en': 'Delete',
    },
    'cancel': {
      'tr': 'İptal',
      'en': 'Cancel',
    },
    'confirm': {
      'tr': 'Onayla',
      'en': 'Confirm',
    },
    'use': {
      'tr': 'Kullan',
      'en': 'Use',
    },
    'copy': {
      'tr': 'Kopyala',
      'en': 'Copy',
    },
    'share': {
      'tr': 'Paylaş',
      'en': 'Share',
    },
    'generate': {
      'tr': 'Oluştur',
      'en': 'Generate',
    },
    'save': {
      'tr': 'Kaydet',
      'en': 'Save',
    },

    // Input Hints
    'enter_phone': {
      'tr': 'Telefon numarası girin (ör: +905551234567)',
      'en': 'Enter phone number (e.g., +905551234567)',
    },
    'enter_username': {
      'tr': 'Kullanıcı adı girin (@ olmadan)',
      'en': 'Enter username (without @)',
    },
    'enter_email': {
      'tr': 'E-posta adresi girin',
      'en': 'Enter email address',
    },
    'enter_text': {
      'tr': 'Metin girin',
      'en': 'Enter text',
    },
    'enter_message': {
      'tr': 'Mesaj girin',
      'en': 'Enter message',
    },

    // Clipboard
    'from_clipboard': {
      'tr': 'Panodan',
      'en': 'From Clipboard',
    },
    'clipboard_copied': {
      'tr': 'Panoya kopyalandı',
      'en': 'Copied to clipboard',
    },
    'quick_paste': {
      'tr': 'Hızlı Yapıştır',
      'en': 'Quick Paste',
    },
    'smart_paste': {
      'tr': 'Akıllı Yapıştır',
      'en': 'Smart Paste',
    },
    'recent_contacts': {
      'tr': 'Son Kişiler',
      'en': 'Recent Contacts',
    },

    // QR Code
    'qr_generator': {
      'tr': 'QR Kod Oluşturucu',
      'en': 'QR Code Generator',
    },
    'qr_description': {
      'tr': 'Bilgileriniz için QR kod oluşturun',
      'en': 'Generate QR code for your info',
    },
    'your_info': {
      'tr': 'Bilgileriniz',
      'en': 'Your Information',
    },
    'save_qr': {
      'tr': 'QR Kaydet',
      'en': 'Save QR',
    },
    'save_to_gallery': {
      'tr': 'Galeriye Kaydet',
      'en': 'Save to Gallery',
    },
    'qr_saved': {
      'tr': 'QR kod galeriye kaydedildi',
      'en': 'QR code saved to gallery',
    },

    // Link Cleaner
    'link_cleaner': {
      'tr': 'Bağlantı Temizleyici',
      'en': 'Link Cleaner',
    },
    'link_cleaner_desc': {
      'tr': 'Takip parametrelerini kaldırın',
      'en': 'Remove tracking parameters',
    },
    'paste_link': {
      'tr': 'Bağlantı Yapıştır',
      'en': 'Paste Link',
    },
    'clean_link': {
      'tr': 'Temizle',
      'en': 'Clean',
    },
    'link_cleaned': {
      'tr': 'Bağlantı temizlendi ve panoya kopyalandı',
      'en': 'Link cleaned and copied to clipboard',
    },
    'enter_url': {
      'tr': 'URL girin',
      'en': 'Enter URL',
    },
    'cleaned_url': {
      'tr': 'Temizlenmiş URL',
      'en': 'Cleaned URL',
    },

    // Message Encryptor
    'message_encryptor': {
      'tr': 'Mesaj Şifreleyici',
      'en': 'Message Encryptor',
    },
    'encryptor_desc': {
      'tr': 'Mesajlarınızı güvenli bir şekilde şifreleyin',
      'en': 'Encrypt your messages securely',
    },
    'encrypt': {
      'tr': 'Şifrele',
      'en': 'Encrypt',
    },
    'decrypt': {
      'tr': 'Çöz',
      'en': 'Decrypt',
    },
    'enter_password': {
      'tr': 'Şifre girin',
      'en': 'Enter password',
    },
    'enter_message_to_encrypt': {
      'tr': 'Şifrelenecek mesajı girin',
      'en': 'Enter message to encrypt',
    },
    'enter_encrypted_message': {
      'tr': 'Şifrelenmiş mesajı girin',
      'en': 'Enter encrypted message',
    },
    'encrypted_message': {
      'tr': 'Şifrelenmiş Mesaj',
      'en': 'Encrypted Message',
    },
    'decrypted_message': {
      'tr': 'Çözülmüş Mesaj',
      'en': 'Decrypted Message',
    },
    'encryption_failed': {
      'tr': 'Şifreleme başarısız oldu',
      'en': 'Encryption failed',
    },
    'decryption_failed': {
      'tr': 'Şifre çözme başarısız. Yanlış şifre mi?',
      'en': 'Decryption failed. Wrong password?',
    },
    'copied_encrypted': {
      'tr': 'Şifrelenmiş mesaj panoya kopyalandı',
      'en': 'Encrypted message copied to clipboard',
    },
    'copied_decrypted': {
      'tr': 'Çözülmüş mesaj panoya kopyalandı',
      'en': 'Decrypted message copied to clipboard',
    },

    // Date Grouping
    'today': {
      'tr': 'Bugün',
      'en': 'Today',
    },
    'yesterday': {
      'tr': 'Dün',
      'en': 'Yesterday',
    },
    'older': {
      'tr': 'Daha Eski',
      'en': 'Older',
    },

    // Quick Templates
    'quick_templates': {
      'tr': 'Hızlı Şablonlar',
      'en': 'Quick Templates',
    },
    'templates': {
      'tr': 'Şablonlar',
      'en': 'Templates',
    },
    'add_template': {
      'tr': 'Şablon Ekle',
      'en': 'Add Template',
    },
    'template_name': {
      'tr': 'Şablon Adı',
      'en': 'Template Name',
    },
    'template_message': {
      'tr': 'Şablon Mesajı',
      'en': 'Template Message',
    },
    'no_templates': {
      'tr': 'Henüz şablon yok',
      'en': 'No templates yet',
    },
    'create_your_first': {
      'tr': 'İlk şablonunuzu oluşturun',
      'en': 'Create your first template',
    },

    // History
    'recent_connections': {
      'tr': 'Son Bağlantılar',
      'en': 'Recent Connections',
    },
    'no_history': {
      'tr': 'Henüz geçmiş yok',
      'en': 'No history yet',
    },
    'no_history_desc': {
      'tr': 'Birisiyle sohbet başlattığınızda burada görünecek',
      'en': 'Your connections will appear here',
    },
    'clear_history': {
      'tr': 'Geçmişi Temizle',
      'en': 'Clear History',
    },
    'clear_history_confirm': {
      'tr': 'Tüm geçmişi silmek istediğinizden emin misiniz?',
      'en': 'Are you sure you want to clear all history?',
    },
    'reopen': {
      'tr': 'Yeniden Aç',
      'en': 'Reopen',
    },
    'history_analytics': {
      'tr': 'İstatistikler',
      'en': 'Analytics',
    },
    'most_used': {
      'tr': 'En Çok Kullanılan',
      'en': 'Most Used',
    },
    'total_connections': {
      'tr': 'Toplam Bağlantı',
      'en': 'Total Connections',
    },

    // Settings
    'appearance': {
      'tr': 'Görünüm',
      'en': 'Appearance',
    },
    'language': {
      'tr': 'Dil',
      'en': 'Language',
    },
    'theme': {
      'tr': 'Tema',
      'en': 'Theme',
    },
    'light_mode': {
      'tr': 'Aydınlık Mod',
      'en': 'Light Mode',
    },
    'dark_mode': {
      'tr': 'Karanlık Mod',
      'en': 'Dark Mode',
    },
    'system_default': {
      'tr': 'Sistem Varsayılanı',
      'en': 'System Default',
    },
    'turkish': {
      'tr': 'Türkçe',
      'en': 'Turkish',
    },
    'english': {
      'tr': 'İngilizce',
      'en': 'English',
    },

    // About
    'about': {
      'tr': 'Hakkında',
      'en': 'About',
    },
    'version': {
      'tr': 'Sürüm',
      'en': 'Version',
    },
    'developed_by': {
      'tr': 'Geliştiren: %s',
      'en': 'Developed by %s',
    },
    'view_github': {
      'tr': 'GitHub\'da Görüntüle',
      'en': 'View on GitHub',
    },
    'buy_coffee': {
      'tr': 'aegis\'e Kahve Ismarla',
      'en': 'Buy aegis a Coffee',
    },
    'privacy_notice': {
      'tr':
          'Gizliliğiniz önemlidir. Tüm veriler cihazınızda yerel olarak saklanır.',
      'en': 'Your privacy matters. All data is stored locally on your device.',
    },
    'copyright': {
      'tr': '© 2026 %s',
      'en': '© 2026 %s',
    },
    'splash_tagline': {
      'tr': 'Işık hızında bağlantılar',
      'en': 'Lightning fast connections',
    },

    // Messages
    'opening': {
      'tr': '%s açılıyor',
      'en': 'Opening %s',
    },
    'failed_to_open': {
      'tr': '%s açılamadı. Uygulamanın yüklü olduğundan emin olun.',
      'en': 'Failed to open %s. Make sure the app is installed.',
    },
    'invalid_input': {
      'tr': 'Geçersiz giriş',
      'en': 'Invalid input',
    },
    'enter_valid_phone': {
      'tr': 'Geçerli bir telefon numarası girin (7-15 rakam)',
      'en': 'Please enter a valid phone number (7-15 digits)',
    },
    'enter_valid_username': {
      'tr': 'Geçerli bir kullanıcı adı girin (2-50 karakter)',
      'en': 'Please enter a valid username (2-50 characters)',
    },
    'enter_phone_required': {
      'tr': 'Lütfen telefon numarası girin',
      'en': 'Please enter a phone number',
    },
    'enter_email_required': {
      'tr': 'Lütfen bir e-posta adresi girin',
      'en': 'Please enter an email address',
    },
    'enter_username_required': {
      'tr': 'Lütfen bir kullanıcı adı girin',
      'en': 'Please enter a username',
    },
    'enter_valid_email': {
      'tr': 'Geçerli bir e-posta adresi girin',
      'en': 'Please enter a valid email address',
    },
    'could_not_open_link': {
      'tr': 'Bağlantı açılamadı',
      'en': 'Could not open link',
    },

    // Info
    'privacy_first': {
      'tr': 'Verileriniz güvende. Tüm sohbetler doğrudan uygulamada açılır.',
      'en':
          'Your data stays private. All chats are opened directly in the app.',
    },
    'discord_note': {
      'tr': 'Discord kullanıcı adı panoya kopyalandı',
      'en': 'Discord username copied to clipboard',
    },
    'template_saved': {
      'tr': 'Şablon kaydedildi',
      'en': 'Template saved',
    },
    'template_deleted': {
      'tr': 'Şablon silindi',
      'en': 'Template deleted',
    },

    // Utils Screen
    'utils_subtitle': {
      'tr': 'QR, Link, Şifreleme, Şablonlar ve Gmail oluşturucu',
      'en': 'QR, Links, Encryption, Templates, and Gmail composer',
    },
    'tab_qr': {
      'tr': 'QR',
      'en': 'QR',
    },
    'tab_links': {
      'tr': 'Linkler',
      'en': 'Links',
    },
    'tab_encrypt': {
      'tr': 'Şifrele',
      'en': 'Encrypt',
    },
    'tab_templates': {
      'tr': 'Şablonlar',
      'en': 'Templates',
    },
    'tab_gmail': {
      'tr': 'Gmail',
      'en': 'Gmail',
    },
    'gmail_sender': {
      'tr': 'Gmail Oluşturucu',
      'en': 'Gmail Composer',
    },
    'gmail_sender_desc': {
      'tr':
          'Alıcı, konu, mesaj ve isteğe bağlı CC/BCC alanlarıyla e-posta taslağı oluşturun',
      'en':
          'Create an email draft with recipient, subject, message, and optional CC/BCC fields',
    },
    'gmail_recipient_label': {
      'tr': 'Alıcı',
      'en': 'Recipient',
    },
    'gmail_cc_label': {
      'tr': 'CC (Opsiyonel)',
      'en': 'CC (Optional)',
    },
    'gmail_bcc_label': {
      'tr': 'BCC (Opsiyonel)',
      'en': 'BCC (Optional)',
    },
    'gmail_subject_label': {
      'tr': 'Konu',
      'en': 'Subject',
    },
    'gmail_body_label': {
      'tr': 'Mesaj',
      'en': 'Message',
    },
    'gmail_recipient_hint': {
      'tr': 'Alıcı e-posta adresi',
      'en': 'Recipient email address',
    },
    'gmail_cc_hint': {
      'tr': 'CC e-posta adresi',
      'en': 'CC email address',
    },
    'gmail_bcc_hint': {
      'tr': 'BCC e-posta adresi',
      'en': 'BCC email address',
    },
    'gmail_subject_hint': {
      'tr': 'Konu',
      'en': 'Subject',
    },
    'gmail_body_hint': {
      'tr': 'Mesaj metni',
      'en': 'Message body',
    },
    'gmail_send': {
      'tr': 'E-posta Taslağını Aç',
      'en': 'Open Email Draft',
    },
    'gmail_opened': {
      'tr': 'E-posta oluşturucu açıldı',
      'en': 'Email composer opened',
    },
    'opening_app': {
      'tr': '%s uygulaması açılıyor',
      'en': 'Opening %s app',
    },
    'opening_in_browser': {
      'tr': '%s tarayıcıda açılıyor',
      'en': 'Opening %s in browser',
    },
    'unexpected_error': {
      'tr': 'Beklenmeyen hata: %s',
      'en': 'Unexpected error: %s',
    },
    'could_not_open_platform': {
      'tr': '%s açılamadı',
      'en': 'Could not open %s',
    },
    'failed_to_open_platform': {
      'tr': '%s açılamadı: %s',
      'en': 'Failed to open %s: %s',
    },
    'platform_error': {
      'tr': '%s hatası: %s',
      'en': '%s error: %s',
    },
    'could_not_open_platform_retry': {
      'tr':
          '%s açılamadı. Uygulamanın yüklü olduğundan emin olup tekrar deneyin.',
      'en':
          'Could not open %s. Make sure the app is installed and try again.',
    },
    'discord_copied_opened': {
      'tr': 'Kullanıcı adı kopyalandı, Discord açıldı',
      'en': 'Username copied, Discord opened',
    },
    'discord_copied_browser': {
      'tr': 'Kullanıcı adı kopyalandı, Discord tarayıcıda açılıyor',
      'en': 'Username copied, opening Discord in browser',
    },
    'wechat_copied_opened': {
      'tr': 'WeChat ID kopyalandı, WeChat açıldı',
      'en': 'WeChat ID copied, WeChat opened',
    },
    'wechat_copied_browser': {
      'tr': 'WeChat ID kopyalandı, WeChat web sitesi açılıyor',
      'en': 'WeChat ID copied, opening WeChat website',
    },
    'fill_all_fields': {
      'tr': 'Lütfen tüm alanları doldurun',
      'en': 'Please fill all fields',
    },
    'error_sharing': {
      'tr': 'Paylaşma hatası',
      'en': 'Error sharing',
    },
    'error_saving': {
      'tr': 'Kaydetme hatası',
      'en': 'Error saving',
    },
    'invalid_url': {
      'tr': 'Geçersiz URL formatı',
      'en': 'Invalid URL format',
    },
    'qr_color': {
      'tr': 'QR Rengi',
      'en': 'QR Color',
    },

    // History
    'delete_this_chat': {
      'tr': 'Bu sohbet geçmişini silmek istiyor musunuz?',
      'en': 'Delete this chat history?',
    },

    // Analytics
    'connections': {
      'tr': 'Bağlantı',
      'en': 'Connections',
    },
    'platform_stats': {
      'tr': 'Platform İstatistikleri',
      'en': 'Platform Stats',
    },
  };

  // Get translated string
  static String get(String key, {List<String>? args}) {
    final translation = _translations[key]?[_currentLocale] ??
        _translations[key]?[english] ??
        key;

    if (args != null && args.isNotEmpty) {
      String result = translation;
      for (var arg in args) {
        result = result.replaceFirst('%s', arg);
      }
      return result;
    }

    return translation;
  }

  // Shorthand
  static String tr(String key, {List<String>? args}) => get(key, args: args);
}
