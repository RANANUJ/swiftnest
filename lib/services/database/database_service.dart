import 'package:drift/drift.dart';
import 'drift_database.dart';

/// High-level database service for managing data operations
class DatabaseService {
  final SwiftNestDatabase _database;

  DatabaseService(this._database);

  // ============================================================================
  // USER OPERATIONS
  // ============================================================================

  /// Insert or update a user
  Future<void> insertUser(UsersCompanion user) async {
    await _database.into(_database.users).insert(user, mode: InsertMode.insertOrReplace);
  }

  /// Get a user by ID
  Future<User?> getUserById(String userId) async {
    return (_database.select(_database.users)
          ..where((tbl) => tbl.id.equals(userId)))
        .getSingleOrNull();
  }

  /// Get all users
  Future<List<User>> getAllUsers() async {
    return _database.select(_database.users).get();
  }

  /// Update user last seen time
  Future<void> updateUserLastSeen(String userId, DateTime lastSeen) async {
    await (_database.update(_database.users)
          ..where((tbl) => tbl.id.equals(userId)))
        .write(UsersCompanion(lastSeenAt: Value(lastSeen)));
  }

  /// Update user online status
  Future<void> updateUserOnlineStatus(String userId, bool isOnline) async {
    await (_database.update(_database.users)
          ..where((tbl) => tbl.id.equals(userId)))
        .write(UsersCompanion(isOnline: Value(isOnline)));
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    await (_database.delete(_database.users)
          ..where((tbl) => tbl.id.equals(userId)))
        .go();
  }

  // ============================================================================
  // CHAT OPERATIONS
  // ============================================================================

  /// Insert or update a chat
  Future<void> insertChat(ChatsCompanion chat) async {
    await _database.into(_database.chats).insert(chat, mode: InsertMode.insertOrReplace);
  }

  /// Get a chat by ID
  Future<Chat?> getChatById(String chatId) async {
    return (_database.select(_database.chats)
          ..where((tbl) => tbl.id.equals(chatId)))
        .getSingleOrNull();
  }

  /// Get all chats (excluding archived)
  Future<List<Chat>> getAllChats({bool includeArchived = false}) async {
    var query = _database.select(_database.chats);
    if (!includeArchived) {
      query = query..where((tbl) => tbl.isArchived.equals(false));
    }
    return query.get();
  }

  /// Get all active chats ordered by last message time
  Future<List<Chat>> getActiveChats() async {
    return (_database.select(_database.chats)
          ..where((tbl) => tbl.isArchived.equals(false))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.lastMessageAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Archive/unarchive a chat
  Future<void> setArchiveStatus(String chatId, bool archived) async {
    await (_database.update(_database.chats)
          ..where((tbl) => tbl.id.equals(chatId)))
        .write(ChatsCompanion(isArchived: Value(archived)));
  }

  /// Mute/unmute a chat
  Future<void> setMuteStatus(String chatId, bool muted) async {
    await (_database.update(_database.chats)
          ..where((tbl) => tbl.id.equals(chatId)))
        .write(ChatsCompanion(isMuted: Value(muted)));
  }

  /// Update chat last message info
  Future<void> updateChatLastMessage(
    String chatId, {
    required String messageId,
    required String preview,
    required String senderId,
    required DateTime timestamp,
    int? unreadCount,
  }) async {
    await (_database.update(_database.chats)
          ..where((tbl) => tbl.id.equals(chatId)))
        .write(ChatsCompanion(
          lastMessageId: Value(messageId),
          lastMessagePreview: Value(preview),
          lastMessageSenderId: Value(senderId),
          lastMessageAt: Value(timestamp),
          unreadCount: unreadCount != null ? Value(unreadCount) : const Value.absent(),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Reset unread count for a chat
  Future<void> resetUnreadCount(String chatId) async {
    await (_database.update(_database.chats)
          ..where((tbl) => tbl.id.equals(chatId)))
        .write(const ChatsCompanion(unreadCount: Value(0)));
  }

  /// Delete a chat
  Future<void> deleteChat(String chatId) async {
    await (_database.delete(_database.chats)
          ..where((tbl) => tbl.id.equals(chatId)))
        .go();
  }

  // ============================================================================
  // MESSAGE OPERATIONS
  // ============================================================================

  /// Insert a new message
  Future<void> insertMessage(MessagesCompanion message) async {
    await _database.into(_database.messages).insert(message, mode: InsertMode.insertOrReplace);
  }

  /// Get a message by ID
  Future<Message?> getMessageById(String messageId) async {
    return (_database.select(_database.messages)
          ..where((tbl) => tbl.id.equals(messageId)))
        .getSingleOrNull();
  }

  /// Get messages for a chat (paginated)
  Future<List<Message>> getMessagesForChat(
    String chatId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return (_database.select(_database.messages)
          ..where((tbl) => tbl.chatId.equals(chatId))
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.createdAt, mode: OrderingMode.desc)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get unread message count for a chat
  Future<int> getUnreadMessageCount(String chatId) async {
    final countExp = _database.messages.id.count();
    final result = await (_database.selectOnly(_database.messages)
          ..addColumns([countExp])
          ..where(_database.messages.chatId.equals(chatId) &
              _database.messages.status.equals('unread')))
        .map((row) => row.read(countExp) ?? 0)
        .getSingleOrNull();

    return result ?? 0;
  }

  /// Update message status
  Future<void> updateMessageStatus(String messageId, String status) async {
    await (_database.update(_database.messages)
          ..where((tbl) => tbl.id.equals(messageId)))
        .write(MessagesCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Mark message as edited
  Future<void> markMessageAsEdited(String messageId, String newContent) async {
    await (_database.update(_database.messages)
          ..where((tbl) => tbl.id.equals(messageId)))
        .write(MessagesCompanion(
          content: Value(newContent),
          isEdited: const Value(true),
          editedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    await (_database.delete(_database.messages)
          ..where((tbl) => tbl.id.equals(messageId)))
        .go();
  }

  /// Delete all messages for a chat
  Future<void> deleteMessagesForChat(String chatId) async {
    await (_database.delete(_database.messages)
          ..where((tbl) => tbl.chatId.equals(chatId)))
        .go();
  }

  // ============================================================================
  // PENDING MESSAGE OPERATIONS
  // ============================================================================

  /// Insert a pending message
  Future<void> insertPendingMessage(PendingMessagesCompanion message) async {
    await _database.into(_database.pendingMessages).insert(message);
  }

  /// Get all pending messages
  Future<List<PendingMessage>> getPendingMessages() async {
    return _database.select(_database.pendingMessages).get();
  }

  /// Get pending messages for a specific chat
  Future<List<PendingMessage>> getPendingMessagesForChat(String chatId) async {
    return (_database.select(_database.pendingMessages)
          ..where((tbl) => tbl.chatId.equals(chatId)))
        .get();
  }

  /// Update pending message retry count
  Future<void> updatePendingMessageRetry(String messageId, int retryCount) async {
    await (_database.update(_database.pendingMessages)
          ..where((tbl) => tbl.id.equals(messageId)))
        .write(PendingMessagesCompanion(
          retryCount: Value(retryCount),
          lastRetryAt: Value(DateTime.now()),
        ));
  }

  /// Remove a pending message (when it's successfully sent)
  Future<void> removePendingMessage(String messageId) async {
    await (_database.delete(_database.pendingMessages)
          ..where((tbl) => tbl.id.equals(messageId)))
        .go();
  }

  // ============================================================================
  // DOWNLOADED MEDIA OPERATIONS
  // ============================================================================

  /// Insert or update downloaded media
  Future<void> insertDownloadedMedia(DownloadedMediaCompanion media) async {
    await _database.into(_database.downloadedMedia).insert(media, mode: InsertMode.insertOrReplace);
  }

  /// Get downloaded media by ID
  Future<DownloadedMediaData?> getDownloadedMediaById(String mediaId) async {
    return (_database.select(_database.downloadedMedia)
          ..where((tbl) => tbl.id.equals(mediaId)))
        .getSingleOrNull();
  }

  /// Get all cached media for a message
  Future<List<DownloadedMediaData>> getMediaForMessage(String messageId) async {
    return (_database.select(_database.downloadedMedia)
          ..where((tbl) => tbl.messageId.equals(messageId)))
        .get();
  }

  /// Get all completed downloads
  Future<List<DownloadedMediaData>> getCompletedDownloads() async {
    return (_database.select(_database.downloadedMedia)
          ..where((tbl) => tbl.isComplete.equals(true)))
        .get();
  }

  /// Get oldest cached media (for cleanup)
  Future<DownloadedMediaData?> getOldestCachedMedia() async {
    return (_database.select(_database.downloadedMedia)
          ..orderBy([(tbl) => OrderingTerm(expression: tbl.lastAccessedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Update download progress
  Future<void> updateDownloadProgress(
    String mediaId,
    int downloadProgress,
    bool isComplete,
  ) async {
    await (_database.update(_database.downloadedMedia)
          ..where((tbl) => tbl.id.equals(mediaId)))
        .write(DownloadedMediaCompanion(
          downloadProgress: Value(downloadProgress),
          isComplete: Value(isComplete),
          downloadedAt: isComplete ? Value(DateTime.now()) : const Value.absent(),
          lastAccessedAt: Value(DateTime.now()),
        ));
  }

  /// Delete downloaded media
  Future<void> deleteDownloadedMedia(String mediaId) async {
    await (_database.delete(_database.downloadedMedia)
          ..where((tbl) => tbl.id.equals(mediaId)))
        .go();
  }

  /// Cleanup old media (delete media older than specified days)
  Future<int> cleanupOldMedia(int daysOld) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    return (_database.delete(_database.downloadedMedia)
          ..where((tbl) => tbl.lastAccessedAt.isSmallerThanValue(cutoffDate)))
        .go();
  }

  // ============================================================================
  // UTILITY OPERATIONS
  // ============================================================================

  /// Get database statistics
  Future<Map<String, int>> getDatabaseStats() async {
    return _database.getStats();
  }

  /// Get total cached media size in bytes
  Future<int> getTotalCachedMediaSize() async {
    return _database.getTotalMediaSize();
  }

  /// Clear all data (useful for logout)
  Future<void> clearAllData() async {
    await _database.clearAllData();
  }

  /// Get database instance (for advanced operations)
  SwiftNestDatabase get database => _database;
}
