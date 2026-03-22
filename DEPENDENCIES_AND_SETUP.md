# SwiftNest - Dependencies & Quick Start Setup

## Phase 1: Required Dependencies for Stages 2-6

Add these to your `pubspec.yaml` to get started:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management (Local-First)
  riverpod: ^2.4.0
  flutter_riverpod: ^2.4.0
  riverpod_generator: ^2.3.0
  
  # HTTP & Networking
  dio: ^5.3.0
  dio_smart_retry: ^6.0.0  # Automatic retry on failure
  
  # Real-Time Communication
  socket_io_client: ^2.0.0
  
  # Local Database (SQLite)
  drift: ^2.14.0
  sqlite3_flutter_libs: ^0.5.0
  
  # Local Storage (Secure Token Storage)
  flutter_secure_storage: ^9.0.0
  
  # Firebase (Notifications)
  firebase_core: ^2.24.0
  firebase_messaging: ^14.6.0
  
  # Image & Media Handling
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0
  video_player: ^2.7.0
  
  # JSON Serialization
  json_annotation: ^4.8.0
  
  # Utilities
  uuid: ^4.0.0
  intl: ^0.19.0
  connectivity_plus: ^5.0.0  # Detect network changes
  
  # UI/UX
  google_fonts: ^6.1.0
  lottie: ^3.1.0  # Smooth animations

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

## Installation Steps

```bash
# 1. Navigate to project root
cd d:\Flutter\flutter dev\projects\swiftnest

# 2. Add all dependencies
flutter pub add riverpod flutter_riverpod riverpod_generator dio dio_smart_retry socket_io_client drift sqlite3_flutter_libs flutter_secure_storage firebase_core firebase_messaging cached_network_image image_picker video_player json_annotation uuid intl connectivity_plus google_fonts lottie

# 3. Add dev dependencies
flutter pub add --dev build_runner drift_dev riverpod_generator json_serializable

# 4. Get all packages
flutter pub get

# 5. Generate code (Drift models, Riverpod annotations)
dart run build_runner build
```

---

## Folder Structure to Create

After dependencies, set up this structure:


lib/
├── main.dart                          # App entry point
├── config/
│   ├── app_config.dart               # App constants, theme
│   └── theme.dart                    # Material theme, colors
├── models/
│   ├── user_model.dart
│   ├── chat_model.dart
│   ├── message_model.dart
│   ├── media_model.dart
│   └── sync_metadata.dart
├── services/
│   ├── auth/
│   │   ├── auth_service.dart
│   │   └── token_storage.dart
│   ├── database/
│   │   ├── drift_database.dart       # Local SQLite
│   │   ├── database_migrations.dart
│   │   └── dao/                      # Data Access Objects
│   │       ├── chat_dao.dart
│   │       ├── message_dao.dart
│   │       └── media_dao.dart
│   ├── network/
│   │   ├── api_client.dart           # Dio + interceptors
│   │   └── socket_service.dart       # Socket.IO manager
│   ├── sync/
│   │   ├── sync_engine.dart          # Offline sync logic
│   │   └── pending_queue.dart        # Queue pending messages
│   ├── media/
│   │   ├── media_manager.dart
│   │   └── download_manager.dart
│   └── notification/
│       └── notification_service.dart # FCM setup
├── providers/                         # Riverpod state providers
│   ├── auth_provider.dart
│   ├── chat_provider.dart
│   ├── message_provider.dart
│   ├── user_provider.dart
│   └── sync_provider.dart
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── auth/
│   │   ├── signup_screen.dart
│   │   ├── login_screen.dart
│   │   └── otp_screen.dart
│   ├── home/
│   │   ├── chat_list_screen.dart
│   │   └── home_screen.dart
│   ├── chat/
│   │   ├── conversation_screen.dart
│   │   └── media_viewer_screen.dart
│   ├── profile/
│   │   ├── profile_screen.dart
│   │   └── settings_screen.dart
│   └── components/
│       ├── chat_list_item.dart
│       ├── message_bubble.dart
│       ├── media_thumbnail.dart
│       └── typing_indicator.dart
├── widgets/
│   ├── custom_appbar.dart
│   ├── loading_spinner.dart
│   ├── error_widget.dart
│   ├── network_status.dart
│   └── offline_banner.dart
├── utils/
│   ├── constants.dart
│   ├── extensions.dart
│   ├── validators.dart
│   └── logger.dart
└── routes/
    └── app_routing.dart              # GoRouter setup
```

---

## Immediate Next Steps (Priority 1)

### Step 1: Create Folder Structure
```bash
mkdir lib\config lib\models lib\services lib\services\auth ...
(or create via IDE)
```

### Step 2: Set Up Theme & Constants
Create `lib/config/app_config.dart`:
```dart
class AppConfig {
  static const String appName = 'SwiftNest';
  static const String apiBaseUrl = 'https://api.swiftnest.com';
  static const String socketBaseUrl = 'https://socket.swiftnest.com';
  
  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration socketConnectTimeout = Duration(seconds: 5);
  
  // Limits
  static const int maxMessageLength = 5000;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  
  // Cache sizes
  static const int messageBatchSize = 50;
  static const int thumbnailCacheLimit = 100;
}
```

### Step 3: Create Drift Database Schema
Create `lib/services/database/drift_database.dart`:
```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'drift_database.g.dart';

// Database tables
@DataClassName('ChatData')
class Chats extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // ONE_TO_ONE, GROUP
  TextColumn get members => text()(); // JSON array
  TextColumn get lastMessage => text().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MessageData')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get tempId => text().nullable()(); // For offline messages
  TextColumn get chatId => text()();
  TextColumn get senderId => text()();
  TextColumn get type => text().withDefault(const Constant('TEXT'))(); // TEXT, IMAGE, VIDEO
  TextColumn get text => text().nullable()();
  TextColumn get mediaUrl => text().nullable()();
  TextColumn get thumbUrl => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('PENDING'))(); // Message status
  TextColumn get replyToId => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get editedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<Index> get indexes => [
    Index('messages_chat_id', {chatId}),
    Index('messages_created_at', {createdAt}),
  ];
}

@DataClassName('PendingMessageData')
class PendingMessages extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get chatId => text()();
  TextColumn get localPath => text().nullable()();
  TextColumn get payload => text()(); // JSON
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DownloadedMediaData')
class DownloadedMedia extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text().unique()();
  TextColumn get localPath => text()();
  TextColumn get mimeType => text()();
  IntColumn get size => integer()();
  DateTimeColumn get downloadedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserData')
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get avatar => text().nullable()();
  TextColumn get bio => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SyncMetadataData')
class SyncMetadata extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

// Main Database
@DriftDatabase(tables: [
  Chats,
  Messages,
  PendingMessages,
  DownloadedMedia,
  Users,
  SyncMetadata,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'swiftnest_app');
  }
}
```

### Step 4: Set Up Main.dart Entry Point
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiftnest/config/app_config.dart';
import 'package:swiftnest/config/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text('SwiftNest - Loading...'),
        ),
      ),
    );
  }
}
```

---

## Verification Checklist

After setup:

- [ ] `flutter pub get` completes without errors
- [ ] `dart run build_runner build` completes successfully
- [ ] `flutter analyze` shows no errors
- [ ] Folder structure matches above
- [ ] `lib/config/app_config.dart` created
- [ ] `lib/services/database/drift_database.dart` created
- [ ] `lib/main.dart` updated with Riverpod
- [ ] Project builds successfully: `flutter build` (web or apk)

---

## What Each Dependency Does

| Package | Purpose | Why Essential |
|---------|---------|---------------|
| **riverpod** | State management | Local-first architecture, reactive updates |
| **dio** | HTTP client | Resumable upload/download, interceptors |
| **socket_io_client** | Real-time messaging | Instant message delivery |
| **drift** | Local database | SQLite abstraction, type-safe queries |
| **flutter_secure_storage** | Secure token storage | Never store JWT in plain shared prefs |
| **firebase_messaging** | Push notifications | Background message delivery |
| **cached_network_image** | Image caching | Thumbnail-first, fast rendering |
| **connectivity_plus** | Network detection | Know when device goes offline |
| **image_picker** | Media selection | Upload photos/videos from gallery |

---

## Testing the Setup

```bash
# Create a simple test
flutter create --platforms=android,ios .

# Run build_runner to generate code
dart run build_runner build

# Run app
flutter run

# Check for errors
flutter analyze
```

---

## Database Migration Notes

Drift automatically creates tables on first run. If you need to modify schema:

1. Update table definition in `drift_database.dart`
2. Increment `schemaVersion` in `_$AppDatabase`
3. Add migration logic:

```dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) {
    return m.createAll();
  },
  onUpgrade: (Migrator m, int from, int to) async {
    if (from == 1) {
      // Migration from v1 to v2
    }
  },
);
```

---

## Next Document to Read

1. **ARCHITECTURE_ANALYSIS.md** - Detailed system design
2. **ARCHITECTURE_FLOWS.md** - Data flow diagrams
3. (THIS) **DEPENDENCIES_AND_SETUP.md** - Installation & structure
4. **STAGE_BY_STAGE_IMPLEMENTATION.md** (coming) - Detailed stage guides

---

## Quick Reference: Development Command

```bash
# Watch mode (rebuilds on file changes)
flutter run

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Generate code after schema changes
dart run build_runner build

# Clean and rebuild
flutter clean
flutter pub get
dart run build_runner build
flutter run
```

---

**Status**: Ready to implement! ✅  
**Next Action**: Add dependencies to pubspec.yaml, run `flutter pub get`, then create folder structure.
