# Quran Sheikh App

A comprehensive Flutter mobile application designed for Quran sheikhs to manage courses, students, and track Quran memorization (Hifz) and review progress. Built with modern architecture, real-time notifications, and enterprise-grade features.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Dart](https://img.shields.io/badge/Dart-3.0+-blue.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

## 🎯 Overview

Quran Sheikh App is a mobile solution for Islamic institutions managing Quran memorization programs. Sheikhs can efficiently manage multiple courses, track student progress, record hifz/review sessions, and receive real-time notifications. The app integrates with a robust Laravel backend for data persistence and provides enterprise-grade security with token-based authentication.

## ✨ Key Features

### 📚 Course Management
- Create and manage multiple Quran courses
- Organize students into groups
- Track course progress and completion rates
- Manage course sheikhs and assignments

### 👥 Student Management
- View all enrolled students
- Track student details and progress
- Manage student enrollments
- View student history and statistics

### 📝 Hifz & Review Logging
- Record hifz (memorization) sessions with:
  - Surah and ayah ranges
  - Evaluation ratings (Excellent, Very Good, Good, Needs Improvement, Poor)
  - Notes and observations
- Record review sessions for memorized content
- Search and filter logs by date, student, or course
- Edit and delete log entries

### 🔔 Real-Time Notifications
- Receive notifications for:
  - Student enrollments
  - Course updates
  - Schedule changes
  - Custom broadcasts from admin
- Push notifications via Firebase Cloud Messaging

### 👨‍💼 Admin Activity Logging
- Track all admin actions:
  - Course creation/updates/deletion
  - Notification broadcasts
  - Enrollment approvals
  - Sheikh assignments
- View detailed activity history with before/after data
- Export activity logs to CSV

### 🔐 Security & Authentication
- Secure login with email/password
- Token-based authentication (Sanctum)
- Automatic token refresh
- Session restoration on app restart
- Role-based access control

### 🔄 Automatic Version Control
- Forced app updates when new versions are required
- Seamless version checking on login
- Direct app store links for updates

### 🌙 UI/UX
- Beautiful dark/light mode support
- Arabic-first localization (RTL support)
- Smooth animations and transitions
- Responsive design for all screen sizes
- Gold and navy color scheme with cream accents

## 🏗️ Project Structure

```
lib/
├── config/
│   └── dependency_injection.dart          # Service locator setup
├── core/
│   ├── constants/                         # App constants
│   ├── errors/                            # Error handling
│   ├── network/                           # API client
│   └── usecases/                          # Base usecase classes
├── data/
│   ├── datasources/
│   │   ├── local/                         # SharedPreferences
│   │   └── remote/                        # API calls
│   ├── models/                            # Data models
│   └── repositories/                      # Repository implementations
├── domain/
│   ├── entities/                          # Domain entities
│   ├── repositories/                      # Repository interfaces
│   └── usecases/                          # Business logic
├── presentation/
│   ├── navigation/                        # GoRouter setup
│   ├── providers/                         # Riverpod providers
│   ├── screens/                           # App screens
│   └── widgets/                           # Reusable widgets
├── services/                              # Utility services
├── shared/                                # Shared resources
│   └── theme/                             # Theme definitions
└── main.dart                              # App entry point
```

## 🏛️ Architecture

The app follows **Clean Architecture** with **Repository Pattern**:

```
Presentation Layer (UI)
        ↓
Domain Layer (Business Logic)
        ↓
Data Layer (Data Management)
```

**Key Components:**
- **Entities:** Pure domain objects (no dependencies)
- **Repositories:** Abstractions for data access
- **UseCases:** Business logic encapsulation
- **Providers:** Riverpod for state management
- **Models:** Data transfer objects (DTOs)
- **DataSources:** Local and remote data access

## 🛠️ Tech Stack

### Frontend
- **Flutter 3.0+** - UI framework
- **Dart 3.0+** - Programming language
- **Riverpod 2.4+** - State management
- **Go Router 12.1+** - Navigation
- **Dio 5.4+** - HTTP client

### Backend Integration
- **Laravel Sanctum** - API authentication
- **Sanctum tokens** - Secure API calls
- **Firebase FCM** - Push notifications

### Local Storage
- **SharedPreferences** - Key-value storage
- **Get It** - Service locator

### UI Libraries
- **Cached Network Image** - Image caching
- **Image Picker** - Photo selection
- **URL Launcher** - Open links/stores
- **Package Info Plus** - App version info
- **Pub Semver** - Version comparison

### Development
- **Flutter Lints** - Code quality
- **Intl** - Internationalization

## 📦 Dependencies

See `pubspec.yaml` for complete list:
```yaml
flutter_riverpod: ^2.4.9      # State management
go_router: ^12.1.3             # Navigation
dio: ^5.4.0                    # HTTP client
dartz: ^0.10.1                 # Functional programming
equatable: ^2.0.5              # Value equality
get_it: ^8.0.3                 # Service locator
shared_preferences: ^2.2.2     # Local storage
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio or Xcode
- A running Laravel backend API

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/quran-sheikh-app.git
cd quran-sheikh-app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Generate localization files** (if needed)
```bash
flutter gen-l10n
```

4. **Configure API endpoint**
Edit `lib/config/dependency_injection.dart`:
```dart
final apiClient = ApiClient(
  baseUrl: 'https://your-api.com/api',
);
```

5. **Run the app**
```bash
flutter run
```

### Building for Release

**Android:**
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 Supported Platforms

- ✅ Android 5.0+ (API 21+)
- ✅ iOS 11.0+
- 📱 Tablets (optimized)

## 🔐 Authentication Flow

```
Login Screen
    ↓
POST /login (email, password)
    ↓
Backend validates & returns token
    ↓
Save token to SharedPreferences
    ↓
Save user to SharedPreferences
    ↓
Redirect to Home Screen
    ↓
Subsequent requests include token in headers
```

## 📝 API Integration

### Authentication Headers
```dart
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
  'Accept': 'application/json',
}
```

### Example Endpoints Used
- `POST /login` - User authentication
- `GET /profile` - Get user profile
- `GET /sheikh/courses` - List courses
- `GET /sheikh/students` - List students
- `POST /sheikh/hifz-logs` - Create hifz log
- `GET /sheikh/hifz-logs` - List hifz logs
- `POST /sheikh/review-logs` - Create review log
- `GET /sheikh/review-logs` - List review logs

## 🔄 Version Control

The app automatically checks for required updates:

1. **During login**, backend returns `minimum_required_version`
2. **App compares** current version with required version
3. **If outdated**, shows a blocking dialog
4. **User must update** before continuing
5. **Direct links** to App Store / Google Play

## 🌐 Localization

Currently supported languages:
- 🇸🇦 **Arabic** (RTL) - Default
- 🇬🇧 **English** (LTR)

Add more languages in `lib/l10n/`:
- `app_en.arb` - English strings
- `app_ar.arb` - Arabic strings

## 🎨 Theme

The app uses a premium gold/navy theme:
- **Primary:** Gold (`#D4A843`)
- **Dark:** Navy (`#0B1120`)
- **Accent:** Cream (`#F5EDD8`)

Customize in `lib/shared/theme/app_theme.dart`

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📊 State Management with Riverpod

Key providers:
```dart
// Authentication
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>

// Version checking
final versionProvider = StateNotifierProvider<VersionNotifier, VersionState>

// Hifz logs
final hifzLogsProvider = FutureProvider.family<List<HifzLogEntity>, HifzLogsParams>

// Review logs
final reviewLogsProvider = FutureProvider.family<List<ReviewLogEntity>, HifzLogsParams>
```

## 🐛 Troubleshooting

### App crashes on login
- Check API endpoint is correct
- Verify backend is running
- Check network connectivity

### Dialog not showing on update check
- Verify backend returns `minimum_required_version`
- Check app version in `pubspec.yaml`
- Ensure navigator context is available

### Push notifications not working
- Configure Firebase project
- Add google-services.json (Android)
- Add GoogleService-Info.plist (iOS)
- Enable FCM in Firebase Console

## 📚 Documentation

- [Flutter Documentation](https://flutter.dev/docs)
- [Riverpod Guide](https://riverpod.dev)
- [Go Router Guide](https://pub.dev/packages/go_router)
- [Dio Documentation](https://github.com/flutterchina/dio)

## 📝 Project Requirements

### Completed Features ✅
- [x] Notifications system
- [x] Teacher can change session date
- [x] Fix delete log logout bug (soft deletes)
- [x] Searchable filters with Select2 (backend)
- [x] Admin activity logging (backend)
- [x] Force app updates
- [x] Enhanced student logs screen
- [x] Hifz/Review log tracking

### In Progress 🔄
- [ ] Student registration UI message
- [ ] Teacher app redesign
- [ ] Code refactoring

## 🤝 Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Created for Markaz Al-Furqan Islamic Institution

## 📞 Support

For issues and questions:
- Open an issue on GitHub
- Contact the development team

## 🙏 Acknowledgments

- Flutter community
- Riverpod contributors
- All contributors and testers

---

**Last Updated:** April 2026

**Current Version:** 2.0.0

Built with ❤️ for Quran memorization programs
