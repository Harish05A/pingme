# PingMe - Student Productivity & Focus Management App

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## 📱 Overview

**PingMe** is a comprehensive student productivity application designed to help students manage their focus, track their progress, and achieve their academic goals. Built with Flutter and Firebase, it offers a seamless experience across Android and iOS platforms.

## ✨ Features

### 🎯 Focus Mode
- **Custom Duration**: Set focus sessions from 1-180 minutes
- **Presets**: Pomodoro (25min), Short Break (5min), Long Break (15min), Deep Work (90min)
- **App Blocking**: Real-time blocking of distracting apps during focus sessions
- **Break Timer**: Automatic break reminders with activity suggestions
- **Motivational Quotes**: 20+ inspiring quotes to keep you motivated

### 📊 Productivity Insights
- **Statistics Dashboard**: Track total focus time, sessions, and success rate
- **Productivity Score**: 0-100 score based on focus quality and distractions
- **Session History**: View recent sessions with detailed metrics
- **Session Breakdown**: Visual representation of successful vs incomplete sessions

### 🏆 Gamification
- **Streak Tracking**: Current and longest streak tracking
- **11 Achievements**: Unlock badges for milestones
  - First Step, Getting Started, Dedicated, Century Club
  - On Fire, Streak Master, Unstoppable
  - 10 Hour Club, Focus Scholar, Zen Master
  - Perfect Day
- **Progress Tracking**: Visual progress bars for each achievement

### 👥 Dual User Roles
- **Students**: Focus mode, statistics, achievements, profile management
- **Faculty**: Student monitoring, department analytics, focus insights

### 🔔 Smart Notifications
- Break reminders
- Session completion alerts
- Achievement unlocks
- Streak milestones

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Dart SDK (2.17 or higher)
- Android Studio / VS Code
- Firebase account

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/pingme.git
cd pingme
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**
   - Create a new Firebase project
   - Add Android/iOS apps to your Firebase project
   - Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Place them in the appropriate directories

4. **Run the app**
```bash
flutter run
```

## 🏗️ Project Structure

```
lib/
├── config/           # App configuration (theme, constants)
├── models/           # Data models
├── providers/        # State management (Provider pattern)
├── screens/          # UI screens
│   ├── auth/        # Authentication screens
│   ├── student/     # Student-specific screens
│   └── faculty/     # Faculty-specific screens
├── services/         # Backend services (Firebase, notifications)
├── utils/            # Utility functions and helpers
└── widgets/          # Reusable widgets
```

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **Backend**: Firebase (Firestore, Authentication)
- **State Management**: Provider
- **Local Storage**: Shared Preferences
- **Notifications**: Flutter Local Notifications
- **App Detection**: Device Apps (Android)

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  cloud_firestore: ^4.13.0
  firebase_auth: ^4.15.0
  provider: ^6.1.1
  shared_preferences: ^2.2.2
  flutter_local_notifications: ^16.2.0
  device_apps: ^2.2.0
  flutter_overlay_window: ^0.5.0
```

## 🔐 Security

- Firestore security rules implemented
- User authentication required
- Role-based access control
- Input validation on all forms
- Secure data storage

## 🧪 Testing

Run tests:
```bash
flutter test
```

Run with coverage:
```bash
flutter test --coverage
```

## 📱 Build & Release

### Android

1. **Generate keystore**
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. **Build APK**
```bash
flutter build apk --release
```

3. **Build App Bundle**
```bash
flutter build appbundle --release
```

### iOS

1. **Build**
```bash
flutter build ios --release
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Authors

- **Your Name** - Initial work

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- All contributors and testers

## 📞 Support

For support, email support@pingme.app or open an issue in the repository.

## 🗺️ Roadmap

- [ ] iOS app release
- [ ] Dark mode support
- [ ] Ambient sounds/white noise
- [ ] Session notes and tags
- [ ] Data export (CSV/PDF)
- [ ] Cross-device sync
- [ ] Social features

---

**Made with ❤️ for students, by students**
