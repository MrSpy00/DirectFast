import 'app_strings_i18n_generated.dart';

class AppStrings {
  // Supported locales
  static const String turkish = 'tr';
  static const String english = 'en';
  static const String spanish = 'es';
  static const String arabic = 'ar';
  static const String hindi = 'hi';
  static const String french = 'fr';
  static const String german = 'de';
  static const String russian = 'ru';
  static const String portuguese = 'pt';
  static const String chinese = 'zh';
  static const String japanese = 'ja';
  static const String korean = 'ko';
  static const String italian = 'it';
  static const String indonesian = 'id';
  static const String bengali = 'bn';
  static const String urdu = 'ur';
  static const String vietnamese = 'vi';
  static const String polish = 'pl';
  static const String dutch = 'nl';
  static const String thai = 'th';
  static const String persian = 'fa';
  static const String malay = 'ms';
  static const String telugu = 'te';
  static const String tamil = 'ta';
  static const String punjabi = 'pa';

  static const List<String> supportedLocales = [
    turkish,
    english,
    spanish,
    arabic,
    hindi,
    french,
    german,
    russian,
    portuguese,
    chinese,
    japanese,
    korean,
    italian,
    indonesian,
    bengali,
    urdu,
    vietnamese,
    polish,
    dutch,
    thai,
    persian,
    malay,
    telugu,
    tamil,
    punjabi,
  ];

  static const String fallbackLocale = english;

  static const Map<String, String> localeNativeNames = {
    turkish: 'Türkçe',
    english: 'English',
    spanish: 'Español',
    arabic: 'العربية',
    hindi: 'हिन्दी',
    french: 'Français',
    german: 'Deutsch',
    russian: 'Русский',
    portuguese: 'Português',
    chinese: '中文',
    japanese: '日本語',
    korean: '한국어',
    italian: 'Italiano',
    indonesian: 'Bahasa Indonesia',
    bengali: 'বাংলা',
    urdu: 'اردو',
    vietnamese: 'Tiếng Việt',
    polish: 'Polski',
    dutch: 'Nederlands',
    thai: 'ไทย',
    persian: 'فارسی',
    malay: 'Bahasa Melayu',
    telugu: 'తెలుగు',
    tamil: 'தமிழ்',
    punjabi: 'ਪੰਜਾਬੀ',
  };

  static const Map<String, List<String>> localeFallbackChains = {
    urdu: [arabic, hindi],
    persian: [arabic],
    malay: [indonesian],
    telugu: [hindi],
    tamil: [hindi],
    punjabi: [hindi],
    vietnamese: [spanish, french],
    polish: [german, french],
    dutch: [german, french],
    thai: [chinese, japanese],
  };

  // Current locale
  static String _currentLocale = turkish;

  static bool isSupportedLocale(String locale) {
    return supportedLocales.contains(locale);
  }

  static String normalizeLocale(String locale) {
    return isSupportedLocale(locale) ? locale : fallbackLocale;
  }

  static void setLocale(String locale) {
    _currentLocale = normalizeLocale(locale);
  }

  static String get currentLocale => _currentLocale;

  static String localeNativeName(String locale) {
    return localeNativeNames[locale] ?? locale;
  }

  static Iterable<String> translationLookupOrder(String locale) sync* {
    final normalized = normalizeLocale(locale);
    final emitted = <String>{};

    void emit(String candidate) {
      final normalizedCandidate = normalizeLocale(candidate);
      emitted.add(normalizedCandidate);
    }

    emit(normalized);
    final chain = localeFallbackChains[normalized] ?? const <String>[];
    for (final candidate in chain) {
      emit(candidate);
    }
    emit(fallbackLocale);
    emit(turkish);

    for (final value in emitted) {
      yield value;
    }
  }

  static String localeLabelKey(String locale) {
    switch (locale) {
      case turkish:
        return 'turkish';
      case english:
        return 'english';
      case spanish:
        return 'spanish';
      case arabic:
        return 'arabic';
      case hindi:
        return 'hindi';
      case french:
        return 'french';
      case german:
        return 'german';
      case russian:
        return 'russian';
      case portuguese:
        return 'portuguese';
      case chinese:
        return 'chinese';
      case japanese:
        return 'japanese';
      case korean:
        return 'korean';
      case italian:
        return 'italian';
      case indonesian:
        return 'indonesian';
      case bengali:
        return 'bengali';
      case urdu:
        return 'urdu';
      case vietnamese:
        return 'vietnamese';
      case polish:
        return 'polish';
      case dutch:
        return 'dutch';
      case thai:
        return 'thai';
      case persian:
        return 'persian';
      case malay:
        return 'malay';
      case telugu:
        return 'telugu';
      case tamil:
        return 'tamil';
      case punjabi:
        return 'punjabi';
      default:
        return 'english';
    }
  }

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
      'tr': 'Platformu seç, anında bağlantı kur.',
      'en': 'Choose a platform and connect instantly.',
    },
    'welcome_title': {
      'tr': 'DirectFast\'e Hoş Geldin',
      'en': 'Welcome to DirectFast',
      'es': 'Bienvenido a DirectFast',
      'ar': 'مرحبًا بك في DirectFast',
      'hi': 'DirectFast में आपका स्वागत है',
    },
    'welcome_subtitle': {
      'tr':
          'İlk kurulumunu birkaç adımda tamamla. Dilersen bu ayarları sonra değiştirebilirsin.',
      'en':
          'Complete your first setup in a few steps. You can change these settings later anytime.',
      'es':
          'Completa tu configuración inicial en unos pasos. Puedes cambiar estos ajustes después.',
      'ar':
          'أكمل الإعداد الأولي في بضع خطوات. يمكنك تغيير هذه الإعدادات لاحقًا في أي وقت.',
      'hi':
          'कुछ चरणों में प्रारंभिक सेटअप पूरा करें। आप इन सेटिंग्स को बाद में कभी भी बदल सकते हैं।',
    },
    'setup_language': {
      'tr': 'Dil Seçimi',
      'en': 'Language Selection',
      'es': 'Selección de Idioma',
      'ar': 'اختيار اللغة',
      'hi': 'भाषा चयन',
    },
    'setup_theme': {
      'tr': 'Tema Seçimi',
      'en': 'Theme Selection',
      'es': 'Selección de Tema',
      'ar': 'اختيار السمة',
      'hi': 'थीम चयन',
    },
    'setup_theme_color': {
      'tr': 'Tema Rengi Seçimi',
      'en': 'Theme Color Selection',
      'es': 'Selección de Color del Tema',
      'ar': 'اختيار لون السمة',
      'hi': 'थीम रंग चयन',
    },
    'continue_to_app': {
      'tr': 'Uygulamaya Devam Et',
      'en': 'Continue to App',
      'es': 'Continuar a la App',
      'ar': 'المتابعة إلى التطبيق',
      'hi': 'ऐप में जारी रखें',
    },
    'skip_for_now': {
      'tr': 'Şimdilik Geç',
      'en': 'Skip for now',
      'es': 'Omitir por ahora',
      'ar': 'تخطي الآن',
      'hi': 'अभी छोड़ें',
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
    'viber': {
      'tr': 'Viber',
      'en': 'Viber',
    },
    'wechat': {
      'tr': 'WeChat',
      'en': 'WeChat',
    },
    'line': {
      'tr': 'LINE',
      'en': 'LINE',
    },
    'messenger': {
      'tr': 'Messenger',
      'en': 'Messenger',
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
    'snapchat': {
      'tr': 'Snapchat',
      'en': 'Snapchat',
    },
    'youtube': {
      'tr': 'YouTube',
      'en': 'YouTube',
    },
    'tiktok': {
      'tr': 'TikTok',
      'en': 'TikTok',
    },
    'twitch': {
      'tr': 'Twitch',
      'en': 'Twitch',
    },
    'facebook': {
      'tr': 'Facebook',
      'en': 'Facebook',
    },
    'kick': {
      'tr': 'Kick',
      'en': 'Kick',
    },
    'linkedin': {
      'tr': 'LinkedIn',
      'en': 'LinkedIn',
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
    'clear': {
      'tr': 'Temizle',
      'en': 'Clear',
      'es': 'Limpiar',
      'ar': 'مسح',
      'hi': 'साफ़ करें',
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
      'es': 'Generador de QR',
      'ar': 'مولد QR',
      'hi': 'QR जनरेटर',
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
      'es': 'Guardar QR',
      'ar': 'حفظ رمز QR',
      'hi': 'QR सहेजें',
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
      'es': 'Encriptador',
      'ar': 'مشفر الرسائل',
      'hi': 'संदेश एन्क्रिप्टर',
    },
    'encryptor_desc': {
      'tr': 'Mesajlarınızı güvenli bir şekilde şifreleyin',
      'en': 'Encrypt your messages securely',
      'es': 'Encriptar Mensajes',
      'ar': 'مشفر الرسائل',
      'hi': 'संदेश एन्क्रिप्टर',
    },
    'encrypt': {
      'tr': 'Şifrele',
      'en': 'Encrypt',
      'es': 'Encriptar',
      'ar': 'تشفير',
      'hi': 'एन्क्रिप्ट',
    },
    'decrypt': {
      'tr': 'Çöz',
      'en': 'Decrypt',
      'es': 'Desencriptar',
      'ar': 'فك التشفير',
      'hi': 'डिक्रिप्ट',
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
    'days_ago': {
      'tr': '%s gün önce',
      'en': '%s days ago',
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
      'es': 'Apariencia',
      'ar': 'المظهر',
      'hi': 'रूप',
    },
    'language': {
      'tr': 'Dil',
      'en': 'Language',
      'es': 'Idioma',
      'ar': 'اللغة',
      'hi': 'भाषा',
    },
    'theme': {
      'tr': 'Tema',
      'en': 'Theme',
      'es': 'Tema',
      'ar': 'السمة',
      'hi': 'थीम',
    },
    'light_mode': {
      'tr': 'Aydınlık Mod',
      'en': 'Light Mode',
      'es': 'Modo Claro',
      'ar': 'الوضع الفاتح',
      'hi': 'लाइट मोड',
    },
    'dark_mode': {
      'tr': 'Karanlık Mod',
      'en': 'Dark Mode',
      'es': 'Modo Oscuro',
      'ar': 'الوضع الداكن',
      'hi': 'डार्क मोड',
    },
    'amoled_mode': {
      'tr': 'AMOLED Modu (Saf Siyah)',
      'en': 'AMOLED Mode (Pure Black)',
      'es': 'Modo AMOLED (Negro Puro)',
      'ar': 'وضع AMOLED (أسود نقي)',
      'hi': 'AMOLED मोड (शुद्ध काला)',
    },
    'system_default': {
      'tr': 'Sistem Varsayılanı',
      'en': 'System Default',
      'es': 'Predeterminado del Sistema',
      'ar': 'إعداد النظام',
      'hi': 'सिस्टम डिफ़ॉल्ट',
    },
    'theme_colors': {
      'tr': 'Tema Renkleri',
      'en': 'Theme Colors',
      'es': 'Colores del Tema',
      'ar': 'ألوان السمة',
      'hi': 'थीम रंग',
    },
    'choose_theme_color': {
      'tr': 'Uygulama ana rengini seçin',
      'en': 'Choose app accent color',
      'es': 'Elige el color principal de la app',
      'ar': 'اختر اللون الرئيسي للتطبيق',
      'hi': 'ऐप का मुख्य रंग चुनें',
    },
    'custom_color': {
      'tr': 'Özel Renk',
      'en': 'Custom Color',
      'es': 'Color Personalizado',
      'ar': 'لون مخصص',
      'hi': 'कस्टम रंग',
    },
    'pick_custom_color': {
      'tr': 'Özel Renk Paleti',
      'en': 'Open Custom Color Palette',
      'es': 'Abrir Paleta de Color Personalizada',
      'ar': 'فتح لوحة الألوان المخصصة',
      'hi': 'कस्टम रंग पैलेट खोलें',
    },
    'apply_color': {
      'tr': 'Rengi Uygula',
      'en': 'Apply Color',
      'es': 'Aplicar Color',
      'ar': 'تطبيق اللون',
      'hi': 'रंग लागू करें',
    },
    'turkish': {
      'tr': 'Türkçe',
      'en': 'Turkish',
      'es': 'Turco',
      'ar': 'التركية',
      'hi': 'तुर्की',
    },
    'english': {
      'tr': 'İngilizce',
      'en': 'English',
      'es': 'Inglés',
      'ar': 'الإنجليزية',
      'hi': 'अंग्रेज़ी',
    },
    'spanish': {
      'tr': 'İspanyolca',
      'en': 'Spanish',
      'es': 'Español',
      'ar': 'الإسبانية',
      'hi': 'स्पेनिश',
    },
    'arabic': {
      'tr': 'Arapça',
      'en': 'Arabic',
      'es': 'Árabe',
      'ar': 'العربية',
      'hi': 'अरबी',
    },
    'hindi': {
      'tr': 'Hintçe',
      'en': 'Hindi',
      'es': 'Hindi',
      'ar': 'الهندية',
      'hi': 'हिन्दी',
    },
    'french': {
      'tr': 'Fransızca',
      'en': 'French',
    },
    'german': {
      'tr': 'Almanca',
      'en': 'German',
    },
    'russian': {
      'tr': 'Rusça',
      'en': 'Russian',
    },
    'portuguese': {
      'tr': 'Portekizce',
      'en': 'Portuguese',
    },
    'chinese': {
      'tr': 'Çince',
      'en': 'Chinese',
    },
    'japanese': {
      'tr': 'Japonca',
      'en': 'Japanese',
    },
    'korean': {
      'tr': 'Korece',
      'en': 'Korean',
    },
    'italian': {
      'tr': 'İtalyanca',
      'en': 'Italian',
    },
    'indonesian': {
      'tr': 'Endonezce',
      'en': 'Indonesian',
    },
    'bengali': {
      'tr': 'Bengalce',
      'en': 'Bengali',
    },
    'urdu': {
      'tr': 'Urduca',
      'en': 'Urdu',
    },
    'vietnamese': {
      'tr': 'Vietnamca',
      'en': 'Vietnamese',
    },
    'polish': {
      'tr': 'Lehçe',
      'en': 'Polish',
    },
    'dutch': {
      'tr': 'Hollandaca',
      'en': 'Dutch',
    },
    'thai': {
      'tr': 'Tayca',
      'en': 'Thai',
    },
    'persian': {
      'tr': 'Farsça',
      'en': 'Persian',
    },
    'malay': {
      'tr': 'Malayca',
      'en': 'Malay',
    },
    'telugu': {
      'tr': 'Telugu',
      'en': 'Telugu',
    },
    'tamil': {
      'tr': 'Tamilce',
      'en': 'Tamil',
    },
    'punjabi': {
      'tr': 'Pencapça',
      'en': 'Punjabi',
    },
    'color_violet': {
      'tr': 'Menekşe',
      'en': 'Violet',
      'es': 'Violeta',
      'ar': 'بنفسجي',
      'hi': 'बैंगनी',
    },
    'color_blue': {
      'tr': 'Mavi',
      'en': 'Blue',
      'es': 'Azul',
      'ar': 'أزرق',
      'hi': 'नीला',
    },
    'color_teal': {
      'tr': 'Turkuaz',
      'en': 'Teal',
      'es': 'Verde Azulado',
      'ar': 'تركوازي',
      'hi': 'टील',
    },
    'color_green': {
      'tr': 'Yeşil',
      'en': 'Green',
      'es': 'Verde',
      'ar': 'أخضر',
      'hi': 'हरा',
    },
    'color_orange': {
      'tr': 'Turuncu',
      'en': 'Orange',
      'es': 'Naranja',
      'ar': 'برتقالي',
      'hi': 'नारंगी',
    },
    'color_red': {
      'tr': 'Kırmızı',
      'en': 'Red',
      'es': 'Rojo',
      'ar': 'أحمر',
      'hi': 'लाल',
    },
    'color_rose': {
      'tr': 'Gül',
      'en': 'Rose',
      'es': 'Rosa',
      'ar': 'وردي',
      'hi': 'गुलाबी',
    },
    'color_indigo': {
      'tr': 'İndigo',
      'en': 'Indigo',
      'es': 'Índigo',
      'ar': 'نيلي',
      'hi': 'इंडिगो',
    },
    'color_cyan': {
      'tr': 'Camgöbeği',
      'en': 'Cyan',
    },
    'color_mint': {
      'tr': 'Nane',
      'en': 'Mint',
    },
    'color_lime': {
      'tr': 'Lime',
      'en': 'Lime',
    },
    'color_amber': {
      'tr': 'Amber',
      'en': 'Amber',
    },
    'color_gold': {
      'tr': 'Altın',
      'en': 'Gold',
    },
    'color_magenta': {
      'tr': 'Magenta',
      'en': 'Magenta',
    },
    'color_purple': {
      'tr': 'Mor',
      'en': 'Purple',
    },
    'color_brown': {
      'tr': 'Kahverengi',
      'en': 'Brown',
    },
    'color_slate': {
      'tr': 'Arduvaz',
      'en': 'Slate',
    },
    'color_coral': {
      'tr': 'Mercan',
      'en': 'Coral',
    },

    // About
    'about': {
      'tr': 'Hakkında',
      'en': 'About',
      'es': 'Acerca de',
      'ar': 'حول',
      'hi': 'परिचय',
    },
    'version': {
      'tr': 'Sürüm',
      'en': 'Version',
      'es': 'Versión',
      'ar': 'الإصدار',
      'hi': 'संस्करण',
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
    'open_source_licenses': {
      'tr': 'Açık Kaynak Lisansları',
      'en': 'Open Source Licenses',
      'es': 'Licencias de Código Abierto',
      'ar': 'تراخيص المصادر المفتوحة',
      'hi': 'ओपन सोर्स लाइसेंस',
    },
    'open_source_notice': {
      'tr':
          'Uygulama, Flutter ekosistemindeki açık kaynak paketlerden yararlanır.',
      'en': 'This app uses open-source packages from the Flutter ecosystem.',
      'es':
          'Esta aplicación utiliza paquetes de código abierto del ecosistema Flutter.',
      'ar': 'يستخدم هذا التطبيق حزمًا مفتوحة المصدر من منظومة Flutter.',
      'hi': 'यह ऐप Flutter इकोसिस्टम के ओपन-सोर्स पैकेज का उपयोग करता है।',
    },
    'privacy_notice': {
      'tr':
          'Gizliliğiniz önemlidir. Tüm veriler cihazınızda yerel olarak saklanır.',
      'en': 'Your privacy matters. All data is stored locally on your device.',
    },
    'data_privacy': {
      'tr': 'Veri ve Gizlilik',
      'en': 'Data & Privacy',
    },
    'data_backup': {
      'tr': 'Veri Yedekleme',
      'en': 'Data Backup',
    },
    'data_backup_subtitle': {
      'tr':
          'Geçmiş ve şablonlarınızı JSON veya şifreli yedek olarak dışa aktarın, gerektiğinde içe aktarın.',
      'en':
          'Export your history and templates as JSON or encrypted backup, then import when needed.',
    },
    'data_backup_subtitle_short': {
      'tr': 'Yedek al, paylaş, geri yükle',
      'en': 'Backup, share, and restore',
    },
    'export_json': {
      'tr': 'JSON Dışa Aktar',
      'en': 'Export JSON',
    },
    'export_encrypted_backup': {
      'tr': 'Şifreli Yedek Dışa Aktar',
      'en': 'Export Encrypted Backup',
    },
    'import_backup': {
      'tr': 'Yedek İçe Aktar',
      'en': 'Import Backup',
    },
    'backup_exported': {
      'tr': 'Yedek panoya kopyalandı ve paylaşım açıldı.',
      'en': 'Backup copied to clipboard and share sheet opened.',
    },
    'backup_imported': {
      'tr': 'Yedek başarıyla içe aktarıldı.',
      'en': 'Backup imported successfully.',
    },
    'backup_payload_hint': {
      'tr': 'JSON veya şifreli yedek içeriğini buraya yapıştırın...',
      'en': 'Paste JSON or encrypted backup payload here...',
    },
    'backup_payload_required': {
      'tr': 'Yedek içeriği boş olamaz.',
      'en': 'Backup payload cannot be empty.',
    },
    'backup_invalid': {
      'tr': 'Yedek biçimi geçersiz veya bozuk.',
      'en': 'Backup format is invalid or corrupted.',
    },
    'restore_overwrite_warning': {
      'tr':
          'İçe aktarma işlemi mevcut geçmiş ve şablon verilerini üzerine yazar.',
      'en':
          'Import operation overwrites your current history and template data.',
    },
    'restore_settings': {
      'tr': 'Tema ve dil ayarlarını da geri yükle',
      'en': 'Also restore theme and language settings',
    },
    'restore_settings_subtitle': {
      'tr': 'Yedekte varsa tema modu, renk ve dil ayarları uygulanır.',
      'en':
          'If present in backup, theme mode, color, and language settings are applied.',
    },
    'enter_passphrase': {
      'tr': 'Parola Girin',
      'en': 'Enter Passphrase',
    },
    'passphrase_hint': {
      'tr': 'En az 4 karakter',
      'en': 'At least 4 characters',
    },
    'passphrase_required': {
      'tr': 'Şifreli yedek için parola gereklidir.',
      'en': 'Passphrase is required for encrypted backup.',
    },
    'wrong_passphrase': {
      'tr': 'Parola hatalı veya yedek bozuk.',
      'en': 'Passphrase is incorrect or backup is corrupted.',
    },
    'privacy_dashboard': {
      'tr': 'Gizlilik Panosu',
      'en': 'Privacy Dashboard',
    },
    'privacy_dashboard_subtitle': {
      'tr': 'Cihazda tutulan verilerin şeffaf özeti',
      'en': 'Transparent summary of locally stored data',
    },
    'local_only_storage': {
      'tr':
          'DirectFast verileri yalnızca cihazınızda saklar. Sunucuya gönderim yapılmaz.',
      'en':
          'DirectFast stores your data only on your device. Nothing is sent to servers.',
    },
    'history_entries': {
      'tr': 'Geçmiş Kayıtları',
      'en': 'History Entries',
    },
    'template_entries': {
      'tr': 'Şablon Kayıtları',
      'en': 'Template Entries',
    },
    'stored_keys': {
      'tr': 'Saklanan Anahtarlar',
      'en': 'Stored Keys',
    },
    'stored_keys_subtitle': {
      'tr': 'SharedPreferences içinde bulunan anahtar listesi',
      'en': 'Key list currently in SharedPreferences',
    },
    'history_preview': {
      'tr': 'Geçmiş Önizlemesi',
      'en': 'History Preview',
    },
    'history_preview_subtitle': {
      'tr': 'Son kayıtlar maskelenmiş şekilde gösterilir',
      'en': 'Recent entries shown in masked form',
    },
    'copy_privacy_report': {
      'tr': 'Gizlilik Raporunu Kopyala',
      'en': 'Copy Privacy Report',
    },
    'privacy_report_copied': {
      'tr': 'Gizlilik raporu panoya kopyalandı.',
      'en': 'Privacy report copied to clipboard.',
    },
    'no_data_available': {
      'tr': 'Veri bulunamadı',
      'en': 'No data available',
    },
    'onboarding_status': {
      'tr': 'Onboarding Durumu',
      'en': 'Onboarding Status',
    },
    'theme_mode': {
      'tr': 'Tema Modu',
      'en': 'Theme Mode',
    },
    'theme_color': {
      'tr': 'Tema Rengi',
      'en': 'Theme Color',
    },
    'encrypted': {
      'tr': 'Şifreli',
      'en': 'Encrypted',
    },
    'enabled': {
      'tr': 'Açık',
      'en': 'Enabled',
    },
    'disabled': {
      'tr': 'Kapalı',
      'en': 'Disabled',
    },
    'yes': {
      'tr': 'Evet',
      'en': 'Yes',
    },
    'no': {
      'tr': 'Hayır',
      'en': 'No',
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
      'tr': 'QR, Link, Şablon, Gmail ve Güvenlik araçları',
      'en': 'QR, Links, Templates, Gmail, and Security tools',
      'es': 'Herramientas de QR, enlaces, plantillas, Gmail y seguridad',
      'ar': 'أدوات QR والروابط والقوالب وGmail والأمان',
      'hi': 'QR, लिंक, टेम्पलेट, Gmail और सुरक्षा टूल',
      'fr': 'Outils QR, liens, modèles, Gmail et sécurité',
      'de': 'QR-, Link-, Vorlagen-, Gmail- und Sicherheitstools',
      'ru': 'Инструменты QR, ссылок, шаблонов, Gmail и безопасности',
      'pt': 'Ferramentas de QR, links, modelos, Gmail e segurança',
      'zh': '二维码、链接、模板、Gmail 和安全工具',
      'ja': 'QR・リンク・テンプレート・Gmail・セキュリティツール',
      'ko': 'QR, 링크, 템플릿, Gmail 및 보안 도구',
      'it': 'Strumenti QR, link, modelli, Gmail e sicurezza',
      'id': 'Alat QR, tautan, template, Gmail, dan keamanan',
      'bn': 'QR, লিংক, টেমপ্লেট, Gmail এবং সিকিউরিটি টুল',
    },
    'quick_switch': {
      'tr': 'Hızlı Geçiş',
      'en': 'Quick Switch',
      'es': 'Cambio Rápido',
      'ar': 'التبديل السريع',
      'hi': 'त्वरित स्विच',
      'fr': 'Basculement rapide',
      'de': 'Schnellwechsel',
      'ru': 'Быстрое переключение',
      'pt': 'Troca rápida',
      'zh': '快速切换',
      'ja': 'クイックスイッチ',
      'ko': '빠른 전환',
      'it': 'Cambio rapido',
      'id': 'Pindah cepat',
      'bn': 'দ্রুত পরিবর্তন',
    },
    'tab_qr': {
      'tr': 'QR',
      'en': 'QR',
      'es': 'QR',
      'ar': 'QR',
      'hi': 'QR',
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
    'tab_passwords': {
      'tr': 'Şifre',
      'en': 'Passwords',
    },
    'tab_security': {
      'tr': 'Güvenlik',
      'en': 'Security',
      'es': 'Seguridad',
      'ar': 'الأمان',
      'hi': 'सुरक्षा',
      'fr': 'Sécurité',
      'de': 'Sicherheit',
      'ru': 'Безопасность',
      'pt': 'Segurança',
      'zh': '安全',
      'ja': 'セキュリティ',
      'ko': '보안',
      'it': 'Sicurezza',
      'id': 'Keamanan',
      'bn': 'নিরাপত্তা',
    },
    'password_generator': {
      'tr': 'Gelişmiş Şifre Oluşturucu',
      'en': 'Advanced Password Generator',
      'es': 'Generador de contraseñas',
      'ar': 'مولد كلمات المرور',
      'hi': 'पासवर्ड जेनरेटर',
    },
    'password_generator_desc': {
      'tr': 'Güçlü ve güvenli şifreleri tek dokunuşla üretin',
      'en': 'Generate strong and secure passwords in one tap',
      'es': 'Crea contraseñas robustas',
      'ar': 'إنشاء كلمات المرور القوية',
      'hi': 'सुरक्षित पासवर्ड बनाएँ',
    },
    'password_length': {
      'tr': 'Şifre Uzunluğu',
      'en': 'Password Length',
    },
    'include_uppercase': {
      'tr': 'Büyük Harf (A-Z)',
      'en': 'Uppercase Letters (A-Z)',
    },
    'include_lowercase': {
      'tr': 'Küçük Harf (a-z)',
      'en': 'Lowercase Letters (a-z)',
    },
    'include_numbers': {
      'tr': 'Rakam (0-9)',
      'en': 'Numbers (0-9)',
    },
    'include_symbols': {
      'tr': 'Sembol (!@#...)',
      'en': 'Symbols (!@#...)',
    },
    'exclude_ambiguous_chars': {
      'tr': 'Benzer karakterleri hariç tut (O/0, I/l/1)',
      'en': 'Exclude ambiguous characters (O/0, I/l/1)',
    },
    'generated_password': {
      'tr': 'Oluşturulan Şifre',
      'en': 'Generated Password',
    },
    'copy_password': {
      'tr': 'Şifreyi Kopyala',
      'en': 'Copy Password',
    },
    'password_copied': {
      'tr': 'Şifre panoya kopyalandı',
      'en': 'Password copied to clipboard',
    },
    'entropy_bits': {
      'tr': 'Entropi: %s bit',
      'en': 'Entropy: %s bits',
    },
    'password_strength_weak': {
      'tr': 'Çok Zayıf',
      'en': 'Very Weak',
    },
    'password_strength_fair': {
      'tr': 'Orta',
      'en': 'Fair',
    },
    'password_strength_good': {
      'tr': 'İyi',
      'en': 'Good',
    },
    'password_strength_strong': {
      'tr': 'Güçlü',
      'en': 'Strong',
    },
    'password_strength_very_strong': {
      'tr': 'Çok Güçlü',
      'en': 'Very Strong',
    },
    'at_least_one_charset': {
      'tr': 'En az bir karakter grubu seçmelisiniz',
      'en': 'Select at least one character group',
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
      'en': 'Could not open %s. Make sure the app is installed and try again.',
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
    'encode': {
      'tr': 'Kodla',
      'en': 'Encode',
    },
    'decode': {
      'tr': 'Çöz',
      'en': 'Decode',
    },
    'security_toolkit': {
      'tr': 'Güvenlik Araçları',
      'en': 'Security Toolkit',
      'es': 'Kit de Seguridad',
      'ar': 'مجموعة أدوات الأمان',
      'hi': 'सिक्योरिटी टूलकिट',
      'fr': 'Boîte à outils de sécurité',
      'de': 'Sicherheits-Toolkit',
      'ru': 'Набор инструментов безопасности',
      'pt': 'Kit de segurança',
      'zh': '安全工具箱',
      'ja': 'セキュリティツールキット',
      'ko': '보안 툴킷',
      'it': 'Toolkit di sicurezza',
      'id': 'Toolkit keamanan',
      'bn': 'সিকিউরিটি টুলকিট',
    },
    'security_toolkit_desc': {
      'tr':
          'Hash üret, Base64/URL kodlama yap ve güvenli token oluşturmayı tek ekrandan yönet',
      'en':
          'Generate hashes, run Base64/URL transforms, and create secure tokens from one screen',
      'es':
          'Genera hash, ejecuta transformaciones Base64/URL y crea tokens seguros en una sola pantalla',
      'ar':
          'أنشئ التجزئات، ونفّذ تحويلات Base64/URL، وأنشئ رموزًا آمنة من شاشة واحدة',
      'hi':
          'एक ही स्क्रीन से हैश जनरेट करें, Base64/URL ट्रांसफॉर्म चलाएँ और सुरक्षित टोकन बनाएँ',
      'fr':
          'Générez des hash, appliquez des transformations Base64/URL et créez des jetons sécurisés depuis un seul écran',
      'de':
          'Hashes erstellen, Base64/URL-Umwandlungen ausführen und sichere Token auf einem Bildschirm erzeugen',
      'ru':
          'Создавайте хэши, выполняйте преобразования Base64/URL и генерируйте безопасные токены на одном экране',
      'pt':
          'Gere hashes, execute transformações Base64/URL e crie tokens seguros em uma única tela',
      'zh': '在一个页面中完成哈希生成、Base64/URL 转换和安全令牌创建',
      'ja': '1つの画面でハッシュ生成、Base64/URL 変換、安全なトークン作成を実行',
      'ko': '하나의 화면에서 해시 생성, Base64/URL 변환, 보안 토큰 생성을 수행',
      'it':
          'Genera hash, esegui trasformazioni Base64/URL e crea token sicuri da un’unica schermata',
      'id':
          'Buat hash, jalankan transformasi Base64/URL, dan buat token aman dari satu layar',
      'bn':
          'একটি স্ক্রিন থেকেই হ্যাশ তৈরি, Base64/URL রূপান্তর এবং সুরক্ষিত টোকেন তৈরি করুন',
    },
    'security_input': {
      'tr': 'Giriş Metni',
      'en': 'Input Text',
      'es': 'Texto de Entrada',
      'ar': 'نص الإدخال',
      'hi': 'इनपुट टेक्स्ट',
    },
    'security_input_hint': {
      'tr': 'İşlenecek metni girin',
      'en': 'Enter text to process',
      'es': 'Ingresa el texto a procesar',
      'ar': 'أدخل النص المراد معالجته',
      'hi': 'प्रोसेस करने के लिए टेक्स्ट दर्ज करें',
    },
    'hash_algorithm': {
      'tr': 'Hash Algoritması',
      'en': 'Hash Algorithm',
      'es': 'Algoritmo Hash',
      'ar': 'خوارزمية التجزئة',
      'hi': 'हैश एल्गोरिदम',
    },
    'hash_result': {
      'tr': 'Hash Sonucu',
      'en': 'Hash Result',
      'es': 'Resultado Hash',
      'ar': 'نتيجة التجزئة',
      'hi': 'हैश परिणाम',
    },
    'run_hash': {
      'tr': 'Hash Üret',
      'en': 'Generate Hash',
      'es': 'Generar Hash',
      'ar': 'إنشاء تجزئة',
      'hi': 'हैश जनरेट करें',
    },
    'transform_mode': {
      'tr': 'Dönüşüm Modu',
      'en': 'Transform Mode',
      'es': 'Modo de Transformación',
      'ar': 'وضع التحويل',
      'hi': 'ट्रांसफॉर्म मोड',
    },
    'base64_mode': {
      'tr': 'Base64',
      'en': 'Base64',
    },
    'url_mode': {
      'tr': 'URL',
      'en': 'URL',
    },
    'transformed_result': {
      'tr': 'Dönüşüm Sonucu',
      'en': 'Transform Result',
      'es': 'Resultado de Transformación',
      'ar': 'نتيجة التحويل',
      'hi': 'ट्रांसफॉर्म परिणाम',
    },
    'token_length': {
      'tr': 'Token Uzunluğu',
      'en': 'Token Length',
      'es': 'Longitud del Token',
      'ar': 'طول الرمز',
      'hi': 'टोकन लंबाई',
    },
    'generated_token': {
      'tr': 'Üretilen Token',
      'en': 'Generated Token',
      'es': 'Token Generado',
      'ar': 'الرمز المُنشأ',
      'hi': 'जनरेटेड टोकन',
    },
    'generate_token': {
      'tr': 'Token Üret',
      'en': 'Generate Token',
      'es': 'Generar Token',
      'ar': 'إنشاء رمز',
      'hi': 'टोकन जनरेट करें',
    },
    'token_copied': {
      'tr': 'Token panoya kopyalandı',
      'en': 'Token copied to clipboard',
      'es': 'Token copiado al portapapeles',
      'ar': 'تم نسخ الرمز إلى الحافظة',
      'hi': 'टोकन क्लिपबोर्ड पर कॉपी किया गया',
    },
    'security_operation_failed': {
      'tr': 'İşlem başarısız: %s',
      'en': 'Operation failed: %s',
      'es': 'Operación fallida: %s',
      'ar': 'فشلت العملية: %s',
      'hi': 'ऑपरेशन विफल: %s',
    },
    'qr_color': {
      'tr': 'QR Rengi',
      'en': 'QR Color',
      'es': 'Color QR',
      'ar': 'لون QR',
      'hi': 'QR रंग',
    },
    'qr_foreground': {
      'tr': 'Ön Plan Rengi',
      'en': 'Foreground Color',
      'es': 'Color de Primer Plano',
      'ar': 'لون المقدمة',
      'hi': 'फोरग्राउंड रंग',
    },
    'qr_background': {
      'tr': 'Arka Plan Rengi',
      'en': 'Background Color',
      'es': 'Color de Fondo',
      'ar': 'لون الخلفية',
      'hi': 'बैकग्राउंड रंग',
    },
    'qr_style': {
      'tr': 'QR Stil Ayarları',
      'en': 'QR Style Settings',
      'es': 'Configuración de Estilo QR',
      'ar': 'إعدادات نمط QR',
      'hi': 'QR स्टाइल सेटिंग्स',
    },
    'qr_error_level': {
      'tr': 'Hata Düzeltme Seviyesi',
      'en': 'Error Correction Level',
      'es': 'Nivel de Corrección de Errores',
      'ar': 'مستوى تصحيح الخطأ',
      'hi': 'एरर करेक्शन लेवल',
    },
    'qr_size': {
      'tr': 'QR Boyutu',
      'en': 'QR Size',
      'es': 'Tamaño QR',
      'ar': 'حجم QR',
      'hi': 'QR आकार',
    },
    'qr_padding': {
      'tr': 'İç Boşluk',
      'en': 'Inner Padding',
      'es': 'Relleno Interno',
      'ar': 'الحشو الداخلي',
      'hi': 'इनर पैडिंग',
    },
    'qr_smooth': {
      'tr': 'Modüller Arasında Boşluk Bırakma',
      'en': 'Seamless Modules',
      'es': 'Módulos sin Espacios',
      'ar': 'وحدات بدون فجوات',
      'hi': 'सीमलेस मॉड्यूल',
    },
    'qr_logo': {
      'tr': 'Ortaya Logo Ekle',
      'en': 'Embed Logo in Center',
      'es': 'Insertar Logo al Centro',
      'ar': 'تضمين شعار في المنتصف',
      'hi': 'बीच में लोगो एम्बेड करें',
    },
    'qr_center_image': {
      'tr': 'Merkez Görseli',
      'en': 'Center Image',
      'es': 'Imagen Central',
      'ar': 'صورة المنتصف',
      'hi': 'सेंटर इमेज',
    },
    'qr_center_none': {
      'tr': 'Yok',
      'en': 'None',
      'es': 'Ninguna',
      'ar': 'بدون',
      'hi': 'कोई नहीं',
    },
    'qr_center_logo': {
      'tr': 'Uygulama Logosu',
      'en': 'App Logo',
      'es': 'Logo de la App',
      'ar': 'شعار التطبيق',
      'hi': 'ऐप लोगो',
    },
    'qr_center_custom': {
      'tr': 'Özel Görsel',
      'en': 'Custom Image',
      'es': 'Imagen Personalizada',
      'ar': 'صورة مخصصة',
      'hi': 'कस्टम इमेज',
    },
    'qr_pick_image': {
      'tr': 'Galeriden Seç',
      'en': 'Pick from Gallery',
      'es': 'Elegir de la Galería',
      'ar': 'اختر من المعرض',
      'hi': 'गैलरी से चुनें',
    },
    'qr_change_image': {
      'tr': 'Görseli Değiştir',
      'en': 'Change Image',
      'es': 'Cambiar Imagen',
      'ar': 'تغيير الصورة',
      'hi': 'इमेज बदलें',
    },
    'qr_remove_image': {
      'tr': 'Görseli Kaldır',
      'en': 'Remove Image',
      'es': 'Quitar Imagen',
      'ar': 'إزالة الصورة',
      'hi': 'इमेज हटाएं',
    },
    'qr_no_custom_image': {
      'tr': 'Henüz özel görsel seçilmedi.',
      'en': 'No custom image selected yet.',
      'es': 'Aún no se seleccionó una imagen personalizada.',
      'ar': 'لم يتم اختيار صورة مخصصة بعد.',
      'hi': 'अभी तक कोई कस्टम इमेज नहीं चुनी गई है।',
    },
    'qr_image_selected': {
      'tr': 'Özel merkez görseli seçildi.',
      'en': 'Custom center image selected.',
      'es': 'Imagen central personalizada seleccionada.',
      'ar': 'تم اختيار صورة مخصصة للمنتصف.',
      'hi': 'कस्टम सेंटर इमेज चुन ली गई है।',
    },
    'qr_image_pick_failed': {
      'tr': 'Görsel seçme işlemi başarısız oldu',
      'en': 'Image selection failed',
      'es': 'Falló la selección de imagen',
      'ar': 'فشل اختيار الصورة',
      'hi': 'इमेज चयन विफल रहा',
    },
    'qr_image_pick_cancelled': {
      'tr': 'Görsel seçimi iptal edildi',
      'en': 'Image selection cancelled',
      'es': 'Selección de imagen cancelada',
      'ar': 'تم إلغاء اختيار الصورة',
      'hi': 'इमेज चयन रद्द किया गया',
    },
    'qr_center_image_hint': {
      'tr':
          'Tarama kalitesi için merkez görselini küçük tutun (%12-%28 önerilir).',
      'en': 'Keep center image small for scan quality (12%-28% recommended).',
      'es':
          'Mantén la imagen central pequeña para una mejor lectura (12%-28% recomendado).',
      'ar': 'حافظ على صورة المنتصف صغيرة لجودة مسح أفضل (موصى به 12%-28%).',
      'hi':
          'बेहतर स्कैन गुणवत्ता के लिए सेंटर इमेज छोटी रखें (12%-28% अनुशंसित)।',
    },
    'qr_content_length': {
      'tr': 'İçerik uzunluğu: %s karakter',
      'en': 'Content length: %s chars',
      'es': 'Longitud del contenido: %s caracteres',
      'ar': 'طول المحتوى: %s حرفًا',
      'hi': 'सामग्री की लंबाई: %s अक्षर',
    },
    'qr_reset_style': {
      'tr': 'Stili Sıfırla',
      'en': 'Reset Style',
      'es': 'Restablecer Estilo',
      'ar': 'إعادة ضبط النمط',
      'hi': 'स्टाइल रीसेट करें',
    },
    'pick_color': {
      'tr': 'Renk Seç',
      'en': 'Pick Color',
      'es': 'Elegir Color',
      'ar': 'اختر لونًا',
      'hi': 'रंग चुनें',
    },
    'copy_payload': {
      'tr': 'İçeriği Kopyala',
      'en': 'Copy Payload',
      'es': 'Copiar Contenido',
      'ar': 'نسخ المحتوى',
      'hi': 'पेलोड कॉपी करें',
    },
    'qr_payload_copied': {
      'tr': 'QR içeriği panoya kopyalandı',
      'en': 'QR payload copied to clipboard',
      'es': 'Contenido QR copiado al portapapeles',
      'ar': 'تم نسخ محتوى QR إلى الحافظة',
      'hi': 'QR पेलोड क्लिपबोर्ड पर कॉपी किया गया',
    },
    'qr_data_too_long': {
      'tr': 'QR içeriği çok uzun. Daha kısa bir metin deneyin.',
      'en': 'QR data is too long. Try a shorter text.',
      'es':
          'El contenido QR es demasiado largo. Intenta con un texto más corto.',
      'ar': 'بيانات QR طويلة جدًا. جرّب نصًا أقصر.',
      'hi': 'QR डेटा बहुत लंबा है। छोटा टेक्स्ट आज़माएँ।',
    },
    'qr_error_level_l': {
      'tr': 'L (%7)',
      'en': 'L (7%)',
      'es': 'L (7%)',
      'ar': 'L (7%)',
      'hi': 'L (7%)',
    },
    'qr_error_level_m': {
      'tr': 'M (%15)',
      'en': 'M (15%)',
      'es': 'M (15%)',
      'ar': 'M (15%)',
      'hi': 'M (15%)',
    },
    'qr_error_level_q': {
      'tr': 'Q (%25)',
      'en': 'Q (25%)',
      'es': 'Q (25%)',
      'ar': 'Q (25%)',
      'hi': 'Q (25%)',
    },
    'qr_error_level_h': {
      'tr': 'H (%30)',
      'en': 'H (30%)',
      'es': 'H (30%)',
      'ar': 'H (30%)',
      'hi': 'H (30%)',
    },
    'qr_eye_square': {
      'tr': 'Göz ■',
      'en': 'Eye ■',
      'es': 'Ojo ■',
      'ar': 'العين ■',
      'hi': 'आई ■',
    },
    'qr_eye_circle': {
      'tr': 'Göz ●',
      'en': 'Eye ●',
      'es': 'Ojo ●',
      'ar': 'العين ●',
      'hi': 'आई ●',
    },
    'qr_data_square': {
      'tr': 'Veri ■',
      'en': 'Data ■',
      'es': 'Datos ■',
      'ar': 'البيانات ■',
      'hi': 'डेटा ■',
    },
    'qr_data_circle': {
      'tr': 'Veri ●',
      'en': 'Data ●',
      'es': 'Datos ●',
      'ar': 'البيانات ●',
      'hi': 'डेटा ●',
    },
    'qr_logo_size': {
      'tr': 'Logo Boyutu',
      'en': 'Logo Size',
      'es': 'Tamaño del Logo',
      'ar': 'حجم الشعار',
      'hi': 'लोगो आकार',
    },
    'qr_export_quality': {
      'tr': 'Dışa Aktarım Kalitesi',
      'en': 'Export Quality',
      'es': 'Calidad de Exportación',
      'ar': 'جودة التصدير',
      'hi': 'एक्सपोर्ट क्वालिटी',
    },
    'qr_style_presets': {
      'tr': 'Stil Hazır Ayarları',
      'en': 'Style Presets',
      'es': 'Preajustes de Estilo',
      'ar': 'الإعدادات المسبقة للنمط',
      'hi': 'स्टाइल प्रीसेट',
    },
    'qr_preset_classic': {
      'tr': 'Klasik',
      'en': 'Classic',
      'es': 'Clásico',
      'ar': 'كلاسيكي',
      'hi': 'क्लासिक',
    },
    'qr_preset_modern': {
      'tr': 'Modern',
      'en': 'Modern',
      'es': 'Moderno',
      'ar': 'حديث',
      'hi': 'मॉडर्न',
    },
    'qr_preset_midnight': {
      'tr': 'Gece',
      'en': 'Midnight',
      'es': 'Medianoche',
      'ar': 'منتصف الليل',
      'hi': 'मिडनाइट',
    },
    'qr_preset_ocean': {
      'tr': 'Okyanus',
      'en': 'Ocean',
      'es': 'Océano',
      'ar': 'المحيط',
      'hi': 'ओशन',
    },
    'qr_preset_neon': {
      'tr': 'Neon',
      'en': 'Neon',
      'es': 'Neón',
      'ar': 'نيون',
      'hi': 'नियॉन',
    },
    'qr_preset_custom': {
      'tr': 'Özel',
      'en': 'Custom',
      'es': 'Personalizado',
      'ar': 'مخصص',
      'hi': 'कस्टम',
    },
    'qr_swap_colors': {
      'tr': 'Renkleri Değiştir',
      'en': 'Swap Colors',
      'es': 'Intercambiar Colores',
      'ar': 'تبديل الألوان',
      'hi': 'रंग बदलें',
    },
    'qr_corner_radius': {
      'tr': 'Köşe Yarıçapı',
      'en': 'Corner Radius',
      'es': 'Radio de Esquina',
      'ar': 'نصف قطر الزاوية',
      'hi': 'कॉर्नर रेडियस',
    },
    'qr_frame_width': {
      'tr': 'Çerçeve Kalınlığı',
      'en': 'Frame Width',
      'es': 'Grosor del Marco',
      'ar': 'سماكة الإطار',
      'hi': 'फ्रेम चौड़ाई',
    },
    'qr_frame_color': {
      'tr': 'Çerçeve Rengi',
      'en': 'Frame Color',
      'es': 'Color del Marco',
      'ar': 'لون الإطار',
      'hi': 'फ्रेम रंग',
    },
    'qr_frame_shadow': {
      'tr': 'Çerçeve Gölgesi',
      'en': 'Frame Shadow',
      'es': 'Sombra del Marco',
      'ar': 'ظل الإطار',
      'hi': 'फ्रेम शैडो',
    },
    'qr_contrast_good': {
      'tr': 'Kontrast iyi (%s:1). QR tarama için uygun.',
      'en': 'Contrast is good (%s:1). Suitable for scanning.',
      'es': 'El contraste es bueno (%s:1). Adecuado para escanear.',
      'ar': 'التباين جيد (%s:1). مناسب للمسح.',
      'hi': 'कॉन्ट्रास्ट अच्छा है (%s:1)। स्कैनिंग के लिए उपयुक्त।',
    },
    'qr_contrast_low': {
      'tr': 'Kontrast düşük (%s:1). Daha net renkler seçin.',
      'en': 'Contrast is low (%s:1). Choose clearer colors.',
      'es': 'El contraste es bajo (%s:1). Elige colores más claros.',
      'ar': 'التباين منخفض (%s:1). اختر ألوانًا أوضح.',
      'hi': 'कॉन्ट्रास्ट कम है (%s:1)। अधिक स्पष्ट रंग चुनें।',
    },
    'qr_template_url': {
      'tr': 'URL Şablonu',
      'en': 'URL Template',
      'es': 'Plantilla URL',
      'ar': 'قالب URL',
      'hi': 'URL टेम्पलेट',
    },
    'qr_template_email': {
      'tr': 'E-posta Şablonu',
      'en': 'Email Template',
      'es': 'Plantilla de Email',
      'ar': 'قالب البريد الإلكتروني',
      'hi': 'ईमेल टेम्पलेट',
    },
    'qr_template_phone': {
      'tr': 'Telefon Şablonu',
      'en': 'Phone Template',
      'es': 'Plantilla de Teléfono',
      'ar': 'قالب الهاتف',
      'hi': 'फोन टेम्पलेट',
    },
    'qr_template_sms': {
      'tr': 'SMS Şablonu',
      'en': 'SMS Template',
      'es': 'Plantilla SMS',
      'ar': 'قالب SMS',
      'hi': 'SMS टेम्पलेट',
    },
    'qr_template_wifi': {
      'tr': 'Wi-Fi Şablonu',
      'en': 'Wi-Fi Template',
      'es': 'Plantilla Wi-Fi',
      'ar': 'قالب Wi-Fi',
      'hi': 'Wi-Fi टेम्पलेट',
    },
    'qr_payload_builder': {
      'tr': 'Gelişmiş İçerik Oluşturucu',
      'en': 'Advanced Payload Builder',
      'es': 'Constructor de Contenido Avanzado',
      'ar': 'منشئ المحتوى المتقدم',
      'hi': 'एडवांस्ड पेलोड बिल्डर',
    },
    'qr_payload_type': {
      'tr': 'İçerik Türü',
      'en': 'Payload Type',
      'es': 'Tipo de Contenido',
      'ar': 'نوع المحتوى',
      'hi': 'पेलोड प्रकार',
    },
    'qr_payload_preview': {
      'tr': 'Önizleme',
      'en': 'Preview',
      'es': 'Vista previa',
      'ar': 'معاينة',
      'hi': 'प्रीव्यू',
    },
    'qr_payload_apply': {
      'tr': 'QR İçeriğine Uygula',
      'en': 'Apply to QR Content',
      'es': 'Aplicar al Contenido QR',
      'ar': 'تطبيق على محتوى QR',
      'hi': 'QR कंटेंट पर लागू करें',
    },
    'qr_payload_applied': {
      'tr': 'QR içeriği güncellendi',
      'en': 'QR payload updated',
      'es': 'Contenido QR actualizado',
      'ar': 'تم تحديث محتوى QR',
      'hi': 'QR पेलोड अपडेट किया गया',
    },
    'qr_payload_raw': {
      'tr': 'Serbest Metin',
      'en': 'Raw Text',
      'es': 'Texto Libre',
      'ar': 'نص حر',
      'hi': 'रॉ टेक्स्ट',
    },
    'qr_payload_url': {
      'tr': 'Web URL',
      'en': 'Web URL',
      'es': 'URL Web',
      'ar': 'رابط ويب',
      'hi': 'वेब URL',
    },
    'qr_payload_email': {
      'tr': 'E-posta',
      'en': 'Email',
      'es': 'Correo',
      'ar': 'بريد إلكتروني',
      'hi': 'ईमेल',
    },
    'qr_payload_phone': {
      'tr': 'Telefon',
      'en': 'Phone',
      'es': 'Teléfono',
      'ar': 'هاتف',
      'hi': 'फ़ोन',
    },
    'qr_payload_sms': {
      'tr': 'SMS',
      'en': 'SMS',
      'es': 'SMS',
      'ar': 'رسالة SMS',
      'hi': 'SMS',
    },
    'qr_payload_wifi': {
      'tr': 'Wi‑Fi',
      'en': 'Wi-Fi',
      'es': 'Wi-Fi',
      'ar': 'واي فاي',
      'hi': 'Wi‑Fi',
    },
    'qr_payload_vcard': {
      'tr': 'Kişi Kartı (vCard)',
      'en': 'Contact Card (vCard)',
      'es': 'Tarjeta de Contacto (vCard)',
      'ar': 'بطاقة جهة اتصال (vCard)',
      'hi': 'संपर्क कार्ड (vCard)',
    },
    'qr_payload_geo': {
      'tr': 'Konum (Geo)',
      'en': 'Location (Geo)',
      'es': 'Ubicación (Geo)',
      'ar': 'الموقع (Geo)',
      'hi': 'लोकेशन (Geo)',
    },
    'qr_payload_ssid': {
      'tr': 'Ağ Adı (SSID)',
      'en': 'Network Name (SSID)',
      'es': 'Nombre de Red (SSID)',
      'ar': 'اسم الشبكة (SSID)',
      'hi': 'नेटवर्क नाम (SSID)',
    },
    'qr_payload_password': {
      'tr': 'Ağ Şifresi',
      'en': 'Network Password',
      'es': 'Contraseña de Red',
      'ar': 'كلمة مرور الشبكة',
      'hi': 'नेटवर्क पासवर्ड',
    },
    'qr_payload_security': {
      'tr': 'Güvenlik Türü (WPA/WEP/None)',
      'en': 'Security Type (WPA/WEP/None)',
      'es': 'Tipo de Seguridad (WPA/WEP/None)',
      'ar': 'نوع الحماية (WPA/WEP/None)',
      'hi': 'सिक्योरिटी प्रकार (WPA/WEP/None)',
    },
    'qr_payload_name': {
      'tr': 'Ad Soyad',
      'en': 'Full Name',
      'es': 'Nombre Completo',
      'ar': 'الاسم الكامل',
      'hi': 'पूरा नाम',
    },
    'qr_payload_latitude': {
      'tr': 'Enlem',
      'en': 'Latitude',
      'es': 'Latitud',
      'ar': 'خط العرض',
      'hi': 'अक्षांश',
    },
    'qr_payload_longitude': {
      'tr': 'Boylam',
      'en': 'Longitude',
      'es': 'Longitud',
      'ar': 'خط الطول',
      'hi': 'देशांतर',
    },
    'qr_pick_source': {
      'tr': 'Görsel Kaynağı Seçin',
      'en': 'Select Image Source',
      'es': 'Seleccionar Fuente de Imagen',
      'ar': 'اختر مصدر الصورة',
      'hi': 'इमेज सोर्स चुनें',
    },
    'qr_pick_gallery': {
      'tr': 'Galeriden Seç',
      'en': 'Pick from Gallery',
      'es': 'Elegir de la Galería',
      'ar': 'اختر من المعرض',
      'hi': 'गैलरी से चुनें',
    },
    'qr_pick_camera': {
      'tr': 'Kamerayla Çek',
      'en': 'Take with Camera',
      'es': 'Tomar con Cámara',
      'ar': 'التقاط بالكاميرا',
      'hi': 'कैमरा से लें',
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
    final locale = normalizeLocale(_currentLocale);
    final manualTranslations = _translations[key];
    String translation = key;

    for (final lookup in translationLookupOrder(locale)) {
      final manual = manualTranslations?[lookup];
      if (manual != null && manual.isNotEmpty) {
        translation = manual;
        break;
      }

      final generated = kGeneratedLocaleTranslations[lookup]?[key];
      if (generated != null && generated.isNotEmpty) {
        translation = generated;
        break;
      }
    }

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
