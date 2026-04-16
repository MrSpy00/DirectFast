# DirectFast

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
- **Quick Templates**: Save and reuse frequently sent messages
- **Advanced QR Studio**: Highly customizable QR generation with payload templates (URL/Email/Phone/SMS/Wi-Fi), foreground/background controls, module/eye shape, error correction, logo scale, contrast guidance, and export quality control
- **Link Cleaner**: Remove tracking parameters from URLs
- **Security Toolkit**: Hashing, Base64/URL encode-decode, token generation, and local encrypt/decrypt utilities in one place
- **Beautiful UI**: Material 3 design with smooth animations
- **Chat History**: Track your recent conversations
- **Localization**: 25-language infrastructure with graceful fallback order and core manual translations
- **Smart Theming**: Light, Dark, System, and AMOLED modes + selectable preset colors and custom RGB color palette
- **Faster Tool Navigation**: Cleaner segmented quick-switch with adaptive multi-row layout
- **Privacy First**: All data stored locally on your device

---

## 🏗️ Architecture

This app follows **Clean Architecture** principles with **MVVM** pattern:

```text
lib/
├── core/
│   ├── constants/        # App constants and enums
│   ├── services/         # Core services (Storage, URL launcher, Clipboard)
│   └── utils/            # Utilities and helpers
├── data/
│   ├── models/           # Data models
│   └── repositories/     # Data repositories
├── features/
│   ├── home/            # Home screen feature
│   ├── history/         # History feature
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
