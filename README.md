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
- **QR Generator**: Create and save QR codes for shareable contact details
- **Link Cleaner**: Remove tracking parameters from URLs
- **Message Encryptor**: Encrypt/decrypt messages locally on device
- **Beautiful UI**: Material 3 design with smooth animations
- **Chat History**: Track your recent conversations
- **Dark Mode & Localization**: Full dark/light support with Turkish/English language options
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
│   └── settings/        # Settings feature
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

## 🎨 Screenshots

[![DirectFast screenshot 1](https://i.hizliresim.com/l5k7aiz.jpeg)](https://i.hizliresim.com/l5k7aiz.jpeg) [![DirectFast screenshot 2](https://i.hizliresim.com/cs1iouy.jpeg)](https://i.hizliresim.com/cs1iouy.jpeg) [![DirectFast screenshot 3](https://i.hizliresim.com/kq3wjtg.jpeg)](https://i.hizliresim.com/kq3wjtg.jpeg)

[![DirectFast screenshot 4](https://i.hizliresim.com/mqbxypo.jpeg)](https://i.hizliresim.com/mqbxypo.jpeg) [![DirectFast screenshot 5](https://i.hizliresim.com/pzro3vn.jpeg)](https://i.hizliresim.com/pzro3vn.jpeg) [![DirectFast screenshot 6](https://i.hizliresim.com/qovrgyr.jpeg)](https://i.hizliresim.com/qovrgyr.jpeg)

---

## 🔒 Privacy & Security

- **No External Servers**: All data stays on your device
- **Input Sanitization**: Protection against XSS and injection attacks
- **Local Storage**: History and templates stored locally in SharedPreferences
- **No Tracking**: Zero analytics or telemetry

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
