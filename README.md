# DirectFast

## TR

Mevcut sürüm: **v1.0.0**

## 🚀 Kişilerinize Hızlıca Bağlanın

Kişi kaydetmeden mesajlaşma platformlarında sohbet başlatın.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white)

---

## ✨ Özellikler

- **18 Platform Desteği**: WhatsApp, Telegram, Signal, Viber, WeChat, LINE, Messenger, Discord, Instagram, X, Snapchat, YouTube, TikTok, Twitch, Facebook, Kick, LinkedIn, Email
- **Kişi Kaydetmeden Kullanım**: Kişi listenizi kalabalıklaştırmadan sohbetleri doğrudan açın
- **Akıllı Pano**: Telefon numaralarını ve kullanıcı adlarını otomatik algılama
- **Pano Zekası Geliştirmesi**: Çoklu numara çıkarımı, URL/mention farkında kullanıcı adı ayrıştırma ve karışık metinlerden satır içi e-posta keşfi
- **Hızlı Şablonlar**: Sık gönderdiğiniz mesajları kaydedin ve yeniden kullanın
- **Özel Deep Link’ler**: `directfast://chat?...` ile DirectFast’i önceden doldurulmuş sohbet niyetiyle açın
- **Yedekleme ve Geri Yükleme**: Yerel verileri düz JSON veya şifreli payload olarak dışa aktarın, ardından ayar geri yükleme seçeneğiyle güvenle içe aktarın
- **Gizlilik Panosu**: Yerelde tam olarak ne tutulduğunu inceleyin (anahtarlar, sayılar, maskeli önizlemeler) ve gizlilik raporunu kopyalayın
- **Gelişmiş QR Stüdyosu**: Payload şablonları ve gelişmiş payload oluşturucu (Raw/URL/Email/Phone/SMS/Wi-Fi/vCard/Geo), ön plan/arka plan kontrolleri, modül/göz şekli, hata düzeltme, çerçeve/gölge ayarı, özel merkez görsel desteği (galeri/kamera), kontrast rehberi ve dışa aktarma kalite kontrolü ile yüksek düzeyde özelleştirilebilir QR üretimi
- **Link Temizleyici**: URL’lerden takip parametrelerini kaldırın
- **Güvenlik Araç Seti**: Hash alma, Base64/URL encode-decode, token üretimi, yerel encrypt/decrypt yardımcıları ve Gelişmiş Şifre Üretici tek bir yerde
- **Şık Arayüz**: Akıcı animasyonlar ve bileşenlerde uçtan uca tutarlı padding ile Material 3 tasarımı
- **Sohbet Geçmişi**: Son konuşmalarınızı takip edin
- **Yerelleştirme**: Zarif fallback sırası ve çekirdek manuel çevirilerle 25 dil altyapısı
- **İlk Açılış Hoş Geldin Kurulumu**: Yeni kurulumlar dil, tema ve tema rengi seçimi için hoş geldin akışıyla karşılanır
- **Akıllı Temalandırma**: Açık, Koyu, Sistem ve AMOLED modları + açılır menüden seçilebilir tema renkleri + özel RGB paleti
- **Daha Hızlı Araç Gezinmesi**: Önceki/sonraki kontrolleri, ortalanmış otomatik kaydırma ve daha belirgin aktif durum chip’leriyle geliştirilmiş hızlı geçiş çubuğu
- **Genişletilmiş Araç Yerelleştirmesi**: Güvenlik Araç Seti, hızlı geçiş etiketleri ve yeni eklenen QR payload oluşturucu akışları artık daha zengin dil kapsamına sahip
- **Önce Gizlilik**: Tüm veriler cihazınızda yerel olarak saklanır

---

## 🏗️ Mimari

Bu uygulama **MVVM** deseniyle birlikte **Clean Architecture** prensiplerini takip eder:

```text
lib/
├── core/
│   ├── constants/        # Uygulama sabitleri ve enum'lar
│   ├── services/         # Çekirdek servisler (Storage, URL launcher, Clipboard, Deep Link, Backup)
│   └── utils/            # Yardımcı araçlar ve yardımcı fonksiyonlar
├── data/
│   ├── models/           # Veri modelleri
│   └── repositories/     # Veri depoları
├── features/
│   ├── home/            # Ana ekran özelliği
│   ├── history/         # Geçmiş özelliği
│   ├── onboarding/      # İlk açılış hoş geldin kurulumu
│   ├── settings/        # Ayarlar özelliği
│   └── utils/           # Yardımcı araçlar özelliği
└── shared/
    ├── theme/           # Uygulama temalandırması
    └── widgets/         # Yeniden kullanılabilir bileşenler
```

---

## 🛠️ Teknoloji Yığını

- **Framework**: Flutter 3.38.x
- **Dil**: Dart
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Yerel Depolama**: SharedPreferences
- **Animasyonlar**: flutter_animate
- **Fontlar**: Google Fonts

---

## 🌍 Diller ve Temalar

- **Desteklenen Diller (25)**: Turkish, English, Spanish, Arabic, Hindi, French, German, Russian, Portuguese, Chinese, Japanese, Korean, Italian, Indonesian, Bengali, Urdu, Vietnamese, Polish, Dutch, Thai, Persian, Malay, Telugu, Tamil, Punjabi
- **Tema Modları**: Açık, Koyu, AMOLED, Sistem Varsayılanı
- **Tema Renkleri**: Çok renkli hazır palet + özel RGB paleti
- **Uygulama İçi Kontroller**: Dil, tema modu ve tema rengi Ayarlar’dan değiştirilebilir ve yerel olarak kalıcıdır

---

## 🔗 Deep Link Örnekleri

- `directfast://chat?platform=wa&phone=+905551234567`
- `directfast://chat?platform=telegram&username=my_handle`
- `directfast://chat/telegram/my_handle`

> Desteklenen kısaltmalar arasında `wa`, `tg`, `ig`, `x`, `fb` ve tam platform adları bulunur.

---

## 🚀 Başlangıç

### Ön Koşullar

- Flutter SDK (>=3.2.0)
- Dart SDK
- Android Studio / Xcode (mobil geliştirme için)

### Kurulum

1. Depoyu klonlayın:

```bash
git clone https://github.com/MrSpy00/DirectFast.git
cd DirectFast
```

1. Bağımlılıkları yükleyin:

```bash
flutter pub get
```

1. (Opsiyonel) Önceki derleme çıktılarını temizleyin:

```bash
flutter clean
flutter pub get
```

1. Uygulamayı çalıştırın:

```bash
flutter run
```

---

## 📱 Desteklenen Platformlar

| Platform  | Girdi Türü     | Durum |
|-----------|----------------|-------|
| WhatsApp  | Phone Number   | ✅    |
| Telegram  | Username       | ✅    |
| Signal    | Phone Number   | ✅    |
| Viber     | Phone Number   | ✅    |
| WeChat    | Username       | ✅    |
| LINE      | Username       | ✅    |
| Messenger | Username       | ✅    |
| Discord   | Username       | ✅    |
| Instagram | Username       | ✅    |
| X         | Username       | ✅    |
| Snapchat  | Username       | ✅    |
| YouTube   | Username       | ✅    |
| TikTok    | Username       | ✅    |
| Twitch    | Username       | ✅    |
| Facebook  | Username       | ✅    |
| Kick      | Username       | ✅    |
| LinkedIn  | Username       | ✅    |
| Email     | Email Address  | ✅    |

---

## 🔒 Gizlilik ve Güvenlik

- **Harici Sunucu Yok**: Tüm veriler cihazınızda kalır
- **Girdi Sanitizasyonu**: XSS ve enjeksiyon saldırılarına karşı koruma
- **Yerel Depolama**: Geçmiş ve şablonlar SharedPreferences içinde yerel olarak saklanır
- **Takip Yok**: Sıfır analitik veya telemetri

---

## 📚 Açık Kaynak Teşekkürleri

DirectFast, Flutter açık kaynak ekosistemi üzerine inşa edilmiştir.

- Çekirdek bağımlılık listesi ve atıf notları: [OPEN_SOURCE_NOTICES.md](OPEN_SOURCE_NOTICES.md)
- Tüm paket lisansları uygulama içinden doğrudan görüntülenebilir:
    Settings → About → Open Source Licenses

---

## 📝 Lisans

Bu proje açık kaynaklıdır ve MIT Lisansı altında sunulmaktadır.

---

## 👨‍💻 Geliştirici

Aegis tarafından geliştirilmiştir

- GitHub: [@MrSpy00](https://github.com/MrSpy00)

---

## 🤝 Katkıda Bulunma

Katkılar, issue’lar ve özellik istekleri memnuniyetle karşılanır!

1. Projeyi fork edin
2. Feature branch oluşturun (`git checkout -b feature/AmazingFeature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add some AmazingFeature'`)
4. Branch’i push edin (`git push origin feature/AmazingFeature`)
5. Pull Request açın

---

## ⭐ Desteğinizi Gösterin

Bu proje size yardımcı olduysa bir ⭐️ verin!

---

Flutter ile ❤️ yapıldı

© 2026 Aegis

---

## EN

Current release: **v1.0.0**

## 🚀 Quick Connect to Your Contacts

Chat on messaging platforms without saving contacts.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white)

---

## ✨ Features

- **18 Platform Support**: WhatsApp, Telegram, Signal, Viber, WeChat, LINE, Messenger, Discord, Instagram, X, Snapchat, YouTube, TikTok, Twitch, Facebook, Kick, LinkedIn, Email
- **No Contact Saving**: Directly open chats without cluttering your contacts
- **Smart Clipboard**: Automatic detection of phone numbers and usernames
- **Clipboard Intelligence Upgrade**: Multi-number extraction, URL/mention-aware username parsing, and inline email discovery from mixed text
- **Quick Templates**: Save and reuse frequently sent messages
- **Custom Deep Links**: Open DirectFast with prefilled chat intent via `directfast://chat?...`
- **Backup & Restore**: Export local data as plain JSON or encrypted payload, then import safely with optional settings restore
- **Privacy Dashboard**: Inspect exactly what is stored locally (keys, counts, masked previews) and copy a privacy report
- **Advanced QR Studio**: Highly customizable QR generation with payload templates and an advanced payload builder (Raw/URL/Email/Phone/SMS/Wi-Fi/vCard/Geo), foreground/background controls, module/eye shape, error correction, frame/shadow tuning, custom center image support (gallery/camera), contrast guidance, and export quality control
- **Link Cleaner**: Remove tracking parameters from URLs
- **Security Toolkit**: Hashing, Base64/URL encode-decode, token generation, local encrypt/decrypt utilities, and an Advanced Password Generator unified in one place
- **Beautiful UI**: Material 3 design with smooth animations and uniform edge-to-edge component padding
- **Chat History**: Track your recent conversations
- **Localization**: 25-language infrastructure with graceful fallback order and core manual translations
- **First-Run Welcome Setup**: New installations are greeted with a welcome flow for language, theme, and theme-color selection
- **Smart Theming**: Light, Dark, System, and AMOLED modes + theme colors selectable via dropdown + custom RGB palette
- **Faster Tool Navigation**: Refined quick-switch bar with previous/next controls, centered auto-scroll, and clearer active-state chips for effortless tool hopping
- **Expanded Utility Localization**: Security Toolkit, quick-switch labels, and newly added QR payload builder flows now include richer locale coverage
- **Privacy First**: All data stored locally on your device

---

## 🏗️ Architecture

This app follows **Clean Architecture** principles with **MVVM** pattern:

```text
lib/
├── core/
│   ├── constants/        # App constants and enums
│   ├── services/         # Core services (Storage, URL launcher, Clipboard, Deep Link, Backup)
│   └── utils/            # Utilities and helpers
├── data/
│   ├── models/           # Data models
│   └── repositories/     # Data repositories
├── features/
│   ├── home/            # Home screen feature
│   ├── history/         # History feature
│   ├── onboarding/      # First-run welcome setup
│   ├── settings/        # Settings feature
│   └── utils/           # Utility tools feature
└── shared/
    ├── theme/           # App theming
    └── widgets/         # Reusable widgets
```

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.38.x
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: SharedPreferences
- **Animations**: flutter_animate
- **Fonts**: Google Fonts

---

## 🌍 Languages & Themes

- **Supported Languages (25)**: Turkish, English, Spanish, Arabic, Hindi, French, German, Russian, Portuguese, Chinese, Japanese, Korean, Italian, Indonesian, Bengali, Urdu, Vietnamese, Polish, Dutch, Thai, Persian, Malay, Telugu, Tamil, Punjabi
- **Theme Modes**: Light, Dark, AMOLED, System Default
- **Theme Colors**: Multi-color preset palette + custom RGB palette
- **In-App Controls**: Language, theme mode, and theme color can be changed from Settings and are persisted locally

---

## 🔗 Deep Link Examples

- `directfast://chat?platform=wa&phone=+905551234567`
- `directfast://chat?platform=telegram&username=my_handle`
- `directfast://chat/telegram/my_handle`

> Supported aliases include `wa`, `tg`, `ig`, `x`, `fb`, and full platform names.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.2.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository:

```bash
git clone https://github.com/MrSpy00/DirectFast.git
cd DirectFast
```

1. Install dependencies:

```bash
flutter pub get
```

1. (Optional) Clean previous artifacts:

```bash
flutter clean
flutter pub get
```

1. Run the app:

```bash
flutter run
```

---

## 📱 Supported Platforms

| Platform  | Input Type    | Status |
|-----------|---------------|--------|
| WhatsApp  | Phone Number  | ✅     |
| Telegram  | Username      | ✅     |
| Signal    | Phone Number  | ✅     |
| Viber     | Phone Number  | ✅     |
| WeChat    | Username      | ✅     |
| LINE      | Username      | ✅     |
| Messenger | Username      | ✅     |
| Discord   | Username      | ✅     |
| Instagram | Username      | ✅     |
| X         | Username      | ✅     |
| Snapchat  | Username      | ✅     |
| YouTube   | Username      | ✅     |
| TikTok    | Username      | ✅     |
| Twitch    | Username      | ✅     |
| Facebook  | Username      | ✅     |
| Kick      | Username      | ✅     |
| LinkedIn  | Username      | ✅     |
| Email     | Email Address | ✅     |

---

## 🔒 Privacy & Security

- **No External Servers**: All data stays on your device
- **Input Sanitization**: Protection against XSS and injection attacks
- **Local Storage**: History and templates stored locally in SharedPreferences
- **No Tracking**: Zero analytics or telemetry

---

## 📚 Open Source Acknowledgements

DirectFast is built on top of the Flutter open-source ecosystem.

- Core dependency list and attribution notes: [OPEN_SOURCE_NOTICES.md](OPEN_SOURCE_NOTICES.md)
- Full package licenses can be viewed directly in app via:
    Settings → About → Open Source Licenses

---

## 📝 License

This project is open source and available under the MIT License.

---

## 👨‍💻 Developer

Developed by Aegis

- GitHub: [@MrSpy00](https://github.com/MrSpy00)

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## ⭐ Show Your Support

Give a ⭐️ if this project helped you!

---

Made with ❤️ using Flutter

© 2026 Aegis
