# SwiftNest - Android & iOS Setup (Without Firebase)

## 📱 Your Tech Stack (Confirmed)

**Frontend**: Flutter + Riverpod + Dio + Socket.IO + Drift/SQLite  
**Backend**: NestJS + Socket.IO + MongoDB + Redis + S3/R2/MinIO  
**Push Notifications**: Custom Socket.IO implementation (no Firebase needed)

---

## 1. ANDROID CONFIGURATION

### Step 1.1: Update Android Package Name

**File**: `android/app/build.gradle.kts`

Change from:
```kotlin
applicationId = "com.example.swiftnest"
```

To a proper package name:
```kotlin
applicationId = "com.swiftnest.app"  // or your domain: com.company.swiftnest
```

### Step 1.2: Set Min/Target SDK

**File**: `android/app/build.gradle.kts`

**Current**: Uses Flutter defaults (should be fine)  
**Recommended for SwiftNest**:
- Min SDK: 21 (Android 5.0) - wider device support
- Target SDK: 34 (Android 14) - latest best practices

```kotlin
defaultConfig {
    applicationId = "com.swiftnest.app"
    minSdk = 21                    // Android 5.0+ support
    targetSdk = 34                 // Android 14
    versionCode = 1
    versionName = "1.0.0"
}
```

### Step 1.3: Add Required Permissions

Create/Update `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.swiftnest.app">
    
    <!-- Required for Socket.IO and Network -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
    
    <!-- Camera & Media (for chat images/videos) -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="28" />
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    <uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
    
    <!-- Microphone (for voice messages) -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    
    <!-- File Access (for downloads/uploads) -->
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32" />
    
    <application
        android:label="SwiftNest"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false">
        
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### Step 1.4: Configure Release Signing

**Create**: `android/key.properties`

```properties
storeFile=<path_to_keystore>.jks
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=swiftnest_key
```

**Update** `android/app/build.gradle.kts`:

```kotlin
// Load keystore properties
val keystoreFile = rootProject.file("key.properties")
val keystoreProperties = java.util.Properties()
if (keystoreFile.exists()) {
    keystoreProperties.load(keystoreFile.inputStream())
}

android {
    signingConfigs {
        release {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.release
        }
    }
}
```

### Step 1.5: Build Android APK

```bash
# Generate keystore (one-time, run from android/ folder)
cd android
keytool -genkey -v -keystore swiftnest.jks -keyalg RSA -keysize 2048 -validity 10000 -alias swiftnest_key

# Build APK
flutter build apk --release

# Build App Bundle for Google Play Store
flutter build appbundle --release
```

---

## 2. iOS CONFIGURATION

### Step 2.1: Update iOS Bundle Identifier

**File**: `ios/Runner.xcodeproj/project.pbxproj`

**Better way**: Use Xcode
```bash
open ios/Runner.xcworkspace
```

In Xcode:
1. Select **Runner** project (left sidebar)
2. Select **Runner** target
3. Go to **Build Settings**
4. Search for `Bundle Identifier`
5. Change to: `com.swiftnest.app` (or your domain)

### Step 2.2: Set iOS Deployment Target

In Xcode:
1. Build Settings → Search `iOS Deployment Target`
2. Set to **12.0** or higher (11.0 minimum)

### Step 2.3: Add Privacy Descriptions

**File**: `ios/Runner/Info.plist`

```xml
<dict>
    <!-- Existing properties -->
    
    <!-- Camera -->
    <key>NSCameraUsageDescription</key>
    <string>SwiftNest needs camera access to send photos and videos</string>
    
    <!-- Photo Library -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>SwiftNest needs photo library access to select images</string>
    <key>NSPhotoLibraryAddOnlyUsageDescription</key>
    <string>SwiftNest needs permission to save photos</string>
    
    <!-- Microphone -->
    <key>NSMicrophoneUsageDescription</key>
    <string>SwiftNest needs microphone access to record voice messages</string>
    
    <!-- Local Network (for Socket.IO connections) -->
    <key>NSBonjourServiceTypes</key>
    <array>
        <string>_swiftnest._tcp</string>
        <string>_swiftnest._udp</string>
    </array>
    <key>NSLocalNetworkUsageDescription</key>
    <string>SwiftNest needs local network access for real-time messaging</string>
    
</dict>
```

### Step 2.4: Configure CocoaPods

**File**: `ios/Podfile`

```ruby
platform :ios, '12.0'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

**Install dependencies**:
```bash
cd ios
pod install --repo-update
cd ..
```

### Step 2.5: App Transport Security

**File**: `ios/Runner/Info.plist`

Allow HTTP for development (but use HTTPS in production):

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <false/>
    <!-- Allow specific domains -->
    <key>NSExceptionDomains</key>
    <dict>
        <key>api.swiftnest.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <false/>
            <key>NSExceptionRequiresForwardSecrecy</key>
            <true/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.2</string>
        </dict>
    </dict>
</dict>
```

### Step 2.6: Build iOS App

```bash
# Clean and build
flutter clean
flutter pub get

# Test on iOS Simulator
flutter run

# Build for release (TestFlight/App Store)
flutter build ios --release
# Then open Xcode: open ios/Runner.xcworkspace
# Product > Archive > Distribute App
```

---

## 3. PUSH NOTIFICATIONS WITHOUT FIREBASE

Since you're not using Firebase, here are alternatives:

### Option A: Socket.IO Native Notifications (Recommended)

Since you're already using Socket.IO, leverage it for push notifications:

**Backend** (`NestJS`):
```typescript
// Push notification directly via Socket.IO
io.to(userId).emit('notification', {
  title: 'New Message',
  body: 'You have a new message from Alice',
  chatId: '123',
  type: 'CHAT'
});
```

**Frontend** (`Flutter`):
```dart
Socket.on('notification', (data) {
  // Handle notification
  // Show local notification (using flutter_local_notifications)
  _showLocalNotification(data);
});
```

### Option B: Use `flutter_local_notifications` (For App Foreground/Background)

Add to `pubspec.yaml`:
```yaml
dependencies:
  flutter_local_notifications: ^16.2.0
  flutter_timezone: ^0.0.0
```

**Setup for Android** (`android/app/build.gradle.kts`):
```kotlin
android {
    compileSdk 34
}
```

**Setup for iOS** (`ios/Podfile`):
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'NOTIFICATION_PLUGIN_SKIPS_VIEW_CONTROLLER_CHECK=1'
      ]
    end
  end
end
```

**Dart Implementation**:
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void initializeNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings =
      InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void showNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'swiftnest_channel',
    'SwiftNest Messages',
    importance: Importance.max,
    priority: Priority.high,
  );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}
```

### Option C: OneSignal (Free, No Backend Required)

If you need advanced push features:
- Supports both Android & iOS
- Free tier includes push notifications
- Handles device tokens automatically

Add to `pubspec.yaml`:
```yaml
dependencies:
  onesignal_flutter: ^4.0.0
```

---

## 4. DEPENDENCIES FOR YOUR TECH STACK

**File**: `pubspec.yaml`

```yaml
name: swiftnest
description: "High-performance chat app with offline support."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.8.1

dependencies:
  flutter:
    sdk: flutter

  # State Management
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  riverpod_generator: ^2.3.0
  
  # HTTP Client
  dio: ^5.3.0
  dio_smart_retry: ^6.0.0
  
  # Real-Time Communication
  socket_io_client: ^2.0.0
  
  # Local Database
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  
  # Secure Storage
  flutter_secure_storage: ^9.0.0
  
  # Push Notifications (Alternative to Firebase)
  flutter_local_notifications: ^16.2.0
  flutter_timezone: ^0.0.0
  
  # Media Handling
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0
  video_player: ^2.7.0
  uuid: ^4.0.0
  
  # UI
  google_fonts: ^6.1.0
  lottie: ^3.1.0
  
  # Utilities
  intl: ^0.19.0
  connectivity_plus: ^5.0.0
  json_annotation: ^4.8.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  
  # Code Generation
  build_runner: ^2.4.0
  drift_dev: ^2.14.0
  riverpod_generator: ^2.3.0
  json_serializable: ^6.7.0

flutter:
  uses-material-design: true
```

---

## 5. BUILD & TEST COMMANDS

### Android

```bash
# Install dependencies
flutter pub get

# Clean build
flutter clean
flutter pub get
dart run build_runner build

# Test on Android device/emulator
flutter run

# Build APK for distribution
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Build App Bundle for Google Play
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
# Install dependencies
cd ios && pod install --repo-update && cd ..

# Test on iOS simulator
flutter run

# Build for release
flutter build ios --release
# Then open Xcode: open ios/Runner.xcworkspace
# Product > Archive > Distribute App
```

---

## 6. CONFIGURATION CHECKLIST

### Android ✅
- [ ] Package name updated: `com.swiftnest.app`
- [ ] `minSdk = 21`, `targetSdk = 34`
- [ ] Permissions added (INTERNET, CAMERA, STORAGE, RECORD_AUDIO)
- [ ] Keystore created for release signing
- [ ] `key.properties` file created (not committed to git!)
- [ ] `flutter build apk --release` succeeds
- [ ] APK installs on Android device

### iOS ✅
- [ ] Bundle ID updated: `com.swiftnest.app`
- [ ] Deployment target: 12.0+
- [ ] Privacy descriptions added to Info.plist
- [ ] CocoaPods `pod install` succeeds
- [ ] `flutter build ios --release` succeeds
- [ ] App builds in Xcode

### Cross-Platform ✅
- [ ] Dependencies installed: `flutter pub get`
- [ ] Code generation complete: `dart run build_runner build`
- [ ] Socket.IO connection works
- [ ] Dio HTTP client works
- [ ] Drift database works
- [ ] Local notifications work
- [ ] `flutter analyze` shows no errors

---

## 7. BACKEND CONSIDERATIONS

### API Endpoints (Dio Integration)

Your backend should provide:

```typescript
// NestJS example

// Authentication
POST /auth/signup
POST /auth/login
POST /auth/refresh-token
POST /auth/logout

// Chats
GET /chats                    // List user's chats
GET /chats/:id/messages       // Get messages (paginated)
POST /chats/:id/messages      // Send message

// Users
GET /users/:id                // Get user profile
PUT /users/:id                // Update profile
GET /users/:id/avatar         // Get avatar

// Media
POST /media/upload-signature  // Get presigned URL for S3
GET /media/:id/url            // Get download URL
```

### Socket.IO Events

```typescript
// Client → Server
socket.emit('message', { chatId, text, mediaUrl });
socket.emit('typing', { chatId });
socket.emit('read', { messageId });

// Server → Client
socket.on('message', (msg) => { /* handle */ });
socket.on('typing', (data) => { /* handle */ });
socket.on('notification', (notification) => { /* handle */ });
socket.on('user:online', (userId) => { /* handle */ });
socket.on('user:offline', (userId) => { /* handle */ });
```

---

## 8. SECURITY NOTES

### Android
- ✅ `usesCleartextTraffic="false"` (HTTPS only in production)
- ✅ Keystore NOT committed to git
- ✅ API keys NOT hardcoded

### iOS
- ✅ HTTPS / TLS 1.2+ required
- ✅ App Transport Security enabled
- ✅ No hardcoded secrets

### Both
- ✅ JWT tokens stored in secure storage (not SharedPreferences)
- ✅ Use environment variables for API endpoints
- ✅ Validate SSL certificates

---

## 9. .gitignore Updates

Add to `.gitignore`:

```
# Security
android/key.properties
android/app/release/
ios/Runner/GoogleService-Info.plist
.env
.env.local

# Generated
.dart_tool/
build/
pubspec.lock
*.g.dart

# Flutter
.packages
flutter_version_management.txt
```

---

## NEXT STEPS

1. ✅ Update `android/app/build.gradle.kts` (package name, API levels)
2. ✅ Update `android/app/src/main/AndroidManifest.xml` (permissions)
3. ✅ Update `ios/Runner/Info.plist` (bundle ID, privacy descriptions)
4. ✅ Add to `pubspec.yaml` (all dependencies for your tech stack)
5. ✅ Run `flutter pub get`
6. ✅ Run `dart run build_runner build`
7. ✅ Test: `flutter run`
8. 📝 Begin Stage 2: UI/UX Design
9. 📝 Begin Stage 3: Backend Foundation (NestJS setup)
10. 📝 Begin Stage 4: Authentication

---

**Your app is ready for Android & iOS without Firebase!** 🚀
