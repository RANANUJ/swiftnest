import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

//  Part file for generated code
part 'drift_database.g.dart';

// ============================================================================
// TABLE DEFINITIONS
// ============================================================================

/// Users table - Stores user profile information
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().withLength(min: 1, max: 255)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get phone => text().nullable()();
  TextColumn get avatar => text().nullable()();
  TextColumn get bio => text().nullable()();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Chats table - Stores conversation metadata
class Chats extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get name => text().nullable()();
  TextColumn get avatar => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get lastMessageId => text().nullable()();
  TextColumn get lastMessagePreview => text().nullable()();
  TextColumn get lastMessageSenderId => text().nullable()();
  DateTimeColumn get lastMessageAt => dateTime().nullable()();
  IntColumn get unreadCount => integer().withDefault(const Constant(0))();
  IntColumn get memberCount => integer().withDefault(const Constant(2))();
  TextColumn get members => text()();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  BoolColumn get isMuted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Messages table - Stores messages for local caching
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get senderId => text()();
  TextColumn get senderName => text()();
  TextColumn get senderAvatar => text().nullable()();
  TextColumn get content => text()(); // Renamed from 'text' to avoid conflict 
  TextColumn get type => text().withDefault(const Constant('text'))();
  TextColumn get mediaUrl => text().nullable()();
  TextColumn get localMediaPath => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  BoolColumn get isEdited => boolean().withDefault(const Constant(false))();
  DateTimeColumn get editedAt => dateTime().nullable()();
  TextColumn get replyToId => text().nullable()();
  IntColumn get reactionCount => integer().withDefault(const Constant(0))();
  TextColumn get reactions => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// PendingMessages table - Stores messages awaiting delivery confirmation
class PendingMessages extends Table {
  TextColumn get id => text()();
  TextColumn get chatId => text()();
  TextColumn get senderId => text()();
  TextColumn get content => text()(); // Renamed from 'text' to avoid conflict
  TextColumn get type => text().withDefault(const Constant('text'))();
  TextColumn get localMediaPath => text().nullable()();
  TextColumn get payload => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();
  DateTimeColumn get lastRetryAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// DownloadedMedia table - Tracks cached media files
class DownloadedMedia extends Table {
  TextColumn get id => text()();
  TextColumn get messageId => text().nullable()();
  TextColumn get url => text()();
  TextColumn get localPath => text()();
  TextColumn get mimeType => text()();
  IntColumn get size => integer()();
  TextColumn get mediaType => text()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();
  IntColumn get downloadProgress => integer().withDefault(const Constant(0))();
  DateTimeColumn get downloadedAt => dateTime().nullable()();
  DateTimeColumn get lastAccessedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ============================================================================
// DATABASE CLASS
// ============================================================================

/// Main Drift database instance
@DriftDatabase(
  tables: [Users, Chats, Messages, PendingMessages, DownloadedMedia],
)
class SwiftNestDatabase extends _$SwiftNestDatabase {
  SwiftNestDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle schema migrations here when version changes
    },
  );

  /// Clear all data (useful for logout)
  Future<void> clearAllData() async {
    await delete(pendingMessages).go();
    await delete(messages).go();
    await delete(downloadedMedia).go();
    await delete(chats).go();
    await delete(users).go();
  }

  /// Get database statistics
  Future<Map<String, int>> getStats() async {
    final userCount = await select(users).get().then((v) => v.length);
    final chatCount = await select(chats).get().then((v) => v.length);
    final messageCount = await select(messages).get().then((v) => v.length);
    final pendingCount = await select(pendingMessages).get().then((v) => v.length);
    final mediaCount = await select(downloadedMedia).get().then((v) => v.length);

    return {
      'users': userCount,
      'chats': chatCount,
      'messages': messageCount,
      'pending_messages': pendingCount,
      'downloaded_media': mediaCount,
    };
  }

  /// Get total cached media size in bytes
  Future<int> getTotalMediaSize() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(size), 0) as total FROM downloaded_media WHERE is_complete = 1',
      readsFrom: {downloadedMedia},
    ).map((row) => row.read<int>('total')).getSingleOrNull();

    return result ?? 0;
  }
}

/// Open database connection
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'swiftnest.db'));

    return NativeDatabase.createInBackground(file);
  });
}
