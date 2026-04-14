# DirectFast

<div align="center">

  <h3>🚀 Quick Connect to Your Contacts</h3>
  <p>Chat on messaging platforms without saving contacts</p>

  ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
  ![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white)

</div>

---

## ✨ Features

- **Multiple Platforms**: WhatsApp, Telegram, Viber, and Signal support
- **No Contact Saving**: Directly open chats without cluttering your contacts
- **Smart Clipboard**: Automatic detection of phone numbers and usernames
- **Beautiful UI**: Material 3 design with glassmorphism effects
- **Chat History**: Track your recent conversations
- **Dark Mode**: Full dark/light theme support
- **Privacy First**: All data stored locally on your device

---

## 🏗️ Architecture

This app follows **Clean Architecture** principles with **MVVM** pattern:

```
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

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Storage**: Hive
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

2. Install dependencies:
```bash
flutter pub get
```

3. Generate code (Hive adapters):
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

---

## 📱 Supported Platforms

| Platform  | Input Type    | Status |
|-----------|---------------|--------|
| WhatsApp  | Phone Number  | ✅     |
| Telegram  | Username      | ✅     |
| Viber     | Phone Number  | ✅     |
| Signal    | Phone Number  | ✅     |

---

## 🎨 Screenshots

> Add your app screenshots here after building

---

## 🔒 Privacy & Security

- **No External Servers**: All data stays on your device
- **Input Sanitization**: Protection against XSS and injection attacks
- **Local Storage**: History stored with Hive encryption
- **No Tracking**: Zero analytics or telemetry

---

## 📝 License

This project is open source and available under the MIT License.

---

## 👨‍💻 Developer

**Developed by Aegis**

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

<div align="center">
  <p>Made with ❤️ using Flutter</p>
  <p>© 2024 Aegis</p>
</div>
