# Deployment Guide

## Prerequisites

Before deploying PingMe, ensure you have:
- Flutter SDK installed and configured
- Firebase project set up
- Android Studio (for Android deployment)
- Xcode (for iOS deployment - optional)

---

## Firebase Configuration

### 1. Firestore Security Rules

Deploy the security rules:

```bash
firebase deploy --only firestore:rules
```

Verify rules are active in Firebase Console.

### 2. Firebase Indexes

Deploy indexes:

```bash
firebase deploy --only firestore:indexes
```

### 3. Test Firebase Connection

Run the app and verify:
- Authentication works
- Data saves to Firestore
- Notifications are received

---

## Android Deployment

### Step 1: Generate Release Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**Important**: Save the passwords securely!

### Step 2: Configure Keystore

Create `android/key.properties`:

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=C:/Users/YourName/upload-keystore.jks
```

Add to `.gitignore`:
```
android/key.properties
*.jks
```

### Step 3: Update build.gradle

File: `android/app/build.gradle`

Already configured with:
- Keystore signing
- ProGuard rules
- Minification enabled

### Step 4: Build Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Step 5: Build App Bundle (Recommended)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Step 6: Test Release Build

```bash
flutter install --release
```

Test all features on a physical device.

---

## Google Play Store Deployment

### 1. Create Play Console Account

- Go to [Google Play Console](https://play.google.com/console)
- Pay $25 one-time registration fee
- Complete account setup

### 2. Create App Listing

**App Details**:
- App name: PingMe
- Short description: Student productivity and focus management
- Full description: (See below)
- Category: Productivity
- Tags: Focus, Study, Productivity, Students

**Full Description**:
```
PingMe helps students stay focused and productive with:

🎯 FOCUS MODE
• Custom focus sessions (1-180 minutes)
• Pomodoro technique support
• App blocking during focus
• Break timer with activity suggestions

📊 PRODUCTIVITY INSIGHTS
• Track total focus time
• View success rate and streaks
• Productivity score (0-100)
• Session history and analytics

🏆 ACHIEVEMENTS
• 11 unlockable badges
• Streak tracking
• Milestone celebrations
• Progress visualization

✨ FEATURES
• Motivational quotes
• Break activity suggestions
• Beautiful, modern UI
• Completely free, no ads

Perfect for students who want to:
✓ Reduce distractions
✓ Build focus habits
✓ Track productivity
✓ Achieve academic goals

Download PingMe and start your focus journey today!
```

### 3. Prepare Assets

**App Icon**: 512x512 PNG (already created)

**Feature Graphic**: 1024x500 PNG
- Purple gradient background
- "PingMe" text
- Focus icon

**Screenshots** (Required: 2-8 screenshots):
1. Focus Mode screen
2. Statistics dashboard
3. Achievements screen
4. Break timer
5. Student home screen

**Privacy Policy**: Required (create at privacy-policy-generator.com)

### 4. Upload App Bundle

1. Go to "Production" → "Create new release"
2. Upload `app-release.aab`
3. Add release notes:
   ```
   Initial release of PingMe!
   
   Features:
   - Focus mode with app blocking
   - Productivity statistics
   - Achievement system
   - Break timer
   - Motivational quotes
   ```

### 5. Content Rating

Complete questionnaire:
- Target audience: Everyone
- Contains ads: No
- In-app purchases: No

### 6. Pricing & Distribution

- Free app
- Available in: All countries
- Content rating: Everyone

### 7. Submit for Review

- Review takes 1-7 days
- Address any issues raised
- Once approved, app goes live!

---

## iOS Deployment (Optional)

### Step 1: Configure Xcode

```bash
cd ios
pod install
open Runner.xcworkspace
```

### Step 2: Update Bundle Identifier

In Xcode:
- Select Runner target
- Change Bundle Identifier: `com.pingme.app`

### Step 3: Configure Signing

- Select your Apple Developer account
- Enable "Automatically manage signing"

### Step 4: Build for Release

```bash
flutter build ios --release
```

### Step 5: Archive and Upload

1. Open Xcode
2. Product → Archive
3. Upload to App Store Connect
4. Submit for review

---

## Post-Deployment

### Monitor Crashes

Set up Firebase Crashlytics:

```yaml
# pubspec.yaml
dependencies:
  firebase_crashlytics: ^3.4.0
```

```dart
// main.dart
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
```

### Monitor Analytics

Firebase Analytics is already integrated. Monitor:
- Daily active users
- Session duration
- Feature usage
- Retention rate

### Respond to Reviews

- Monitor Play Store reviews
- Respond within 24-48 hours
- Address bugs quickly
- Thank users for positive feedback

### Plan Updates

Regular updates every 2-4 weeks:
- Bug fixes
- Performance improvements
- New features
- UI enhancements

---

## Troubleshooting

### Build Fails

```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Keystore Issues

Verify `key.properties` path is correct and passwords match.

### Firebase Issues

Check `google-services.json` is in `android/app/`

### App Crashes on Release

Enable ProGuard rules in `proguard-rules.pro`

---

## Checklist

Before submitting to Play Store:

- [ ] All tests passing
- [ ] No lint warnings
- [ ] Release build tested on device
- [ ] Firebase configured correctly
- [ ] App icon created (512x512)
- [ ] Screenshots prepared (2-8)
- [ ] Privacy policy created
- [ ] Store listing written
- [ ] Keystore generated and secured
- [ ] App bundle built
- [ ] Content rating completed
- [ ] Pricing set to Free

---

**Congratulations! Your app is ready for deployment! 🎉**
