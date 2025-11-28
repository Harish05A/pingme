# Developer Documentation

## Project Overview

PingMe is a Flutter-based student productivity app with Firebase backend. This document provides technical details for developers working on the project.

---

## Architecture

### State Management

**Provider Pattern**: Used throughout the app for state management.

**Key Providers**:
- `AuthProvider`: Authentication state and user management
- `FocusProvider`: Focus session management and statistics
- `ReminderProvider`: Reminder CRUD operations

### Project Structure

```
lib/
├── config/
│   └── app_theme.dart          # Theme configuration
├── models/
│   ├── user_model.dart         # User data model
│   ├── reminder_model.dart     # Reminder data model
│   ├── focus_session_model.dart # Focus session model
│   └── achievement_model.dart  # Achievement definitions
├── providers/
│   ├── auth_provider.dart      # Authentication logic
│   ├── focus_provider.dart     # Focus mode logic
│   └── reminder_provider.dart  # Reminder logic
├── screens/
│   ├── auth/                   # Login, signup screens
│   ├── student/                # Student-specific screens
│   └── faculty/                # Faculty-specific screens
├── services/
│   ├── firestore_service.dart  # Firestore operations
│   ├── notification_service.dart # Local notifications
│   ├── app_detector_service.dart # App usage monitoring
│   └── overlay_service.dart    # Overlay management
├── utils/
│   ├── error_handler.dart      # Error handling utilities
│   ├── input_validator.dart    # Input validation
│   └── motivational_quotes.dart # Quote management
└── widgets/
    ├── loading_widget.dart     # Reusable loading state
    └── empty_state_widget.dart # Reusable empty state
```

---

## Key Services

### FirestoreService

Handles all Firestore database operations.

**Collections**:
- `users`: User profiles
- `reminders`: Faculty-created reminders
- `focus_sessions`: Student focus sessions

**Key Methods**:
```dart
Future<void> createUser(UserModel user)
Future<UserModel?> getUser(String uid)
Future<void> saveFocusSession(FocusSessionModel session)
Future<Map<String, dynamic>> getFocusStats(String userId)
Future<Map<String, int>> calculateStreaks(String userId)
```

### NotificationService

Manages local notifications using `flutter_local_notifications`.

**Features**:
- Schedule notifications
- Show immediate notifications
- Cancel notifications
- Handle notification taps

**Key Methods**:
```dart
Future<void> initialize()
Future<void> showNotification(String title, String body)
Future<void> scheduleNotification(DateTime time, String title, String body)
```

### AppDetectorService

Monitors app usage for focus mode blocking.

**Features**:
- Detect currently running app
- Check if app is in block list
- Monitor in background

**Key Methods**:
```dart
Future<String?> getCurrentApp()
Future<bool> isAppBlocked(String packageName)
void startMonitoring(Function(String) onBlockedApp)
void stopMonitoring()
```

---

## Data Models

### UserModel

```dart
class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final String role; // 'student' or 'faculty'
  final String department;
  final DateTime createdAt;
}
```

### FocusSessionModel

```dart
class FocusSessionModel {
  final String id;
  final String userId;
  final int plannedDurationMinutes;
  final int actualDurationMinutes;
  final DateTime startTime;
  final DateTime? endTime;
  final bool wasSuccessful;
  final int distractionCount;
}
```

### ReminderModel

```dart
class ReminderModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'assignment', 'event', 'exam', 'meeting'
  final String priority; // 'low', 'medium', 'high'
  final DateTime deadline;
  final String createdBy; // Faculty UID
  final List<String> targetStudents; // Empty = all students
  final DateTime createdAt;
}
```

---

## Firebase Configuration

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Students can read/write their own sessions
    match /focus_sessions/{sessionId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
    
    // Faculty can create reminders
    match /reminders/{reminderId} {
      allow create: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'faculty';
      allow read: if request.auth != null;
    }
  }
}
```

### Firestore Indexes

Required composite indexes:
- `focus_sessions`: `userId` ASC, `startTime` DESC
- `reminders`: `targetStudents` ARRAY, `deadline` ASC

---

## Testing

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/utils/input_validator_test.dart
```

### Test Structure

```
test/
├── utils/
│   ├── input_validator_test.dart
│   ├── error_handler_test.dart
│   └── motivational_quotes_test.dart
└── widgets/
    ├── loading_widget_test.dart
    └── empty_state_widget_test.dart
```

### Writing Tests

**Unit Test Example**:
```dart
test('Valid email should pass', () {
  expect(InputValidator.validateEmail('test@example.com'), null);
});
```

**Widget Test Example**:
```dart
testWidgets('Should display loading indicator', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: LoadingWidget()),
  );
  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

---

## Performance Optimization

### Best Practices

1. **Use const constructors** where possible
2. **Implement pagination** for large lists
3. **Cache expensive computations**
4. **Optimize Firestore queries** with indexes
5. **Use `ListView.builder`** for long lists

### Firestore Query Optimization

```dart
// Good: Limited query
final sessions = await FirebaseFirestore.instance
  .collection('focus_sessions')
  .where('userId', isEqualTo: uid)
  .orderBy('startTime', descending: true)
  .limit(10)
  .get();

// Bad: Fetching all data
final sessions = await FirebaseFirestore.instance
  .collection('focus_sessions')
  .where('userId', isEqualTo: uid)
  .get();
```

---

## Common Issues

### Issue: App blocking not working

**Solution**: Check permissions
```dart
// Request overlay permission
await FlutterOverlayWindow.requestPermission();

// Request usage stats permission
await UsageStats.checkUsagePermission();
```

### Issue: Notifications not showing

**Solution**: Check notification permissions
```dart
final settings = await NotificationService.requestPermissions();
if (!settings.authorizationStatus.isAuthorized) {
  // Show permission dialog
}
```

### Issue: Firestore permission denied

**Solution**: Verify security rules and user authentication

---

## Adding New Features

### 1. Create Model

```dart
// lib/models/new_feature_model.dart
class NewFeatureModel {
  final String id;
  final String data;
  
  NewFeatureModel({required this.id, required this.data});
  
  Map<String, dynamic> toMap() => {'id': id, 'data': data};
  factory NewFeatureModel.fromMap(Map<String, dynamic> map) =>
    NewFeatureModel(id: map['id'], data: map['data']);
}
```

### 2. Add Service Methods

```dart
// lib/services/firestore_service.dart
Future<void> saveNewFeature(NewFeatureModel feature) async {
  await _firestore.collection('new_features').doc(feature.id).set(feature.toMap());
}
```

### 3. Create Provider

```dart
// lib/providers/new_feature_provider.dart
class NewFeatureProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  
  Future<void> addFeature(NewFeatureModel feature) async {
    await _firestoreService.saveNewFeature(feature);
    notifyListeners();
  }
}
```

### 4. Add UI Screen

```dart
// lib/screens/new_feature_screen.dart
class NewFeatureScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('New Feature')),
      body: Consumer<NewFeatureProvider>(
        builder: (context, provider, child) {
          return ListView(...);
        },
      ),
    );
  }
}
```

### 5. Write Tests

```dart
// test/providers/new_feature_provider_test.dart
test('Should add feature', () async {
  final provider = NewFeatureProvider(mockService);
  await provider.addFeature(testFeature);
  expect(provider.features.length, 1);
});
```

---

## Code Style Guide

### Naming Conventions

- **Classes**: PascalCase (`UserModel`, `FocusProvider`)
- **Variables**: camelCase (`userId`, `focusTime`)
- **Constants**: UPPER_SNAKE_CASE (`MAX_DURATION`)
- **Files**: snake_case (`focus_mode_screen.dart`)

### Documentation

```dart
/// Validates email format
///
/// Returns null if valid, error message if invalid
String? validateEmail(String? value) {
  // Implementation
}
```

### Formatting

```bash
# Format all files
flutter format .

# Check formatting
flutter format --set-exit-if-changed .
```

---

## Debugging

### Enable Debug Logging

```dart
// main.dart
void main() {
  if (kDebugMode) {
    print('Debug mode enabled');
  }
  runApp(MyApp());
}
```

### Firebase Debugging

```dart
// Enable Firestore logging
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### Performance Profiling

```bash
# Run with performance overlay
flutter run --profile

# Analyze performance
flutter analyze
```

---

## Deployment

See [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) for detailed deployment instructions.

---

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design](https://material.io/design)

---

**Happy Coding! 🚀**
