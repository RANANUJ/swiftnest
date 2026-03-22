import 'package:drift/drift.dart';
import '../drift_database.dart';
part 'messages_dao.g.dart';

/// Data Access Object for Messages table
@DriftAccessor(tables: [Messages])
class MessagesDao extends DatabaseAccessor<SwiftNestDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(SwiftNestDatabase db) : super(db);

  /// Get message by ID
  Future<Message?> getMessageById(String messageId) {
    return (select(messages)..where((m) => m.id.equals(messageId)))
        .getSingleOrNull();
  }

  /// Get all messages for a chat ordered by creation time (newest first)
  Future<List<Message>> getMessagesByChatId(String chatId) {
    return (select(messages)
      ..where((m) => m.chatId.equals(chatId))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get messages with pagination (for lazy loading)
  Future<List<Message>> getMessagesByChatIdPaginated({
    required String chatId,
    required int limit,
    required int offset,
  }) {
    return (select(messages)
      ..where((m) => m.chatId.equals(chatId))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)])
      ..limit(limit, offset: offset))
        .get();
  }

  /// Get messages after a specific timestamp (for sync)
  Future<List<Message>> getMessagesAfter({
    required String chatId,
    required DateTime timestamp,
  }) {
    return (select(messages)
      ..where((m) => m.chatId.equals(chatId) & m.createdAt.isBiggerThanValue(timestamp))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt)]))
        .get();
  }

  /// Get undelivered messages
  Future<List<Message>> getUndeliveredMessages(String chatId) {
    return (select(messages)
      ..where((m) => m.chatId.equals(chatId) & 
          (m.status.equals('pending') | m.status.equals('sent')))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt)]))
        .get();
  }

  /// Get unread messages for a chat
  Future<List<Message>> getUnreadMessages(String chatId, String currentUserId) {
    return (select(messages)
      ..where((m) => m.chatId.equals(chatId) & 
          m.senderId.isNotValue(currentUserId) &
          m.status.isNotValue('read'))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt)]))
        .get();
  }

  /// Insert or update message
  Future<void> upsertMessage(MessagesCompanion message) async {
    await into(messages).insert(message, mode: InsertMode.insertOrReplace);
  }

  /// Insert multiple messages
  Future<void> insertMessages(List<MessagesCompanion> messageList) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(messages, messageList);
    });
  }

  /// Update message status
  Future<void> updateMessageStatus(String messageId, String status) {
    return (update(messages)..where((m) => m.id.equals(messageId)))
        .write(MessagesCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Update message statuses in batch
  Future<void> updateMessageStatusesByChat({
    required String chatId,
    required String status,
    required String currentUserId,
  }) {
    return (update(messages)
      ..where((m) => m.chatId.equals(chatId) & m.senderId.isNotValue(currentUserId)))
        .write(MessagesCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Mark all messages as read in a chat
  Future<void> markChatMessagesAsRead({
    required String chatId,
    required String currentUserId,
  }) {
    return updateMessageStatusesByChat(
      chatId: chatId,
      status: 'read',
      currentUserId: currentUserId,
    );
  }

  /// Update message media URL
  Future<void> updateMessageMediaUrl(String messageId, String mediaUrl) {
    return (update(messages)..where((m) => m.id.equals(messageId)))
        .write(MessagesCompanion(
          mediaUrl: Value(mediaUrl),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Update message local media path
  Future<void> updateMessageLocalMediaPath(
    String messageId,
    String localPath,
  ) {
    return (update(messages)..where((m) => m.id.equals(messageId)))
        .write(MessagesCompanion(
          localMediaPath: Value(localPath),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Edit message
  Future<void> editMessage(String messageId, String newText) {
    return (update(messages)..where((m) => m.id.equals(messageId)))
        .write(MessagesCompanion(
          content: Value(newText),
          isEdited: Value(true),
          editedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Add reaction to message
  Future<void> addReaction(String messageId, String reaction) {
    return transaction(() async {
      final message = await getMessageById(messageId);
      if (message != null) {
        // This is a simplified version - in production, parse JSON properly
        final updates = (update(messages)..where((m) => m.id.equals(messageId)));
        await updates.write(MessagesCompanion(
          reactionCount: Value((message.reactionCount) + 1),
          updatedAt: Value(DateTime.now()),
        ));
      }
    });
  }

  /// Delete message
  Future<int> deleteMessage(String messageId) {
    return (delete(messages)..where((m) => m.id.equals(messageId)))
        .go();
  }

  /// Delete messages from chat
  Future<int> deleteMessagesByChat(String chatId) {
    return (delete(messages)..where((m) => m.chatId.equals(chatId)))
        .go();
  }

  /// Count messages in a chat
  Future<int> countMessagesByChat(String chatId) async {
    final count = await customSelect(
      'SELECT COUNT(*) as count FROM messages WHERE chat_id = ?',
      variables: [Variable.withString(chatId)],
      readsFrom: {messages},
    ).map((row) => row.read<int>('count')).getSingle();
    return count;
  }

  /// Get latest message in a chat
  Future<Message?> getLatestMessage(String chatId) {
    return (select(messages)
      ..where((m) => m.chatId.equals(chatId))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)])
      ..limit(1))
        .getSingleOrNull();
  }

  /// Search messages in a chat
  Future<List<Message>> searchMessagesInChat({
    required String chatId,
    required String query,
  }) {
    return (select(messages)
      ..where((m) => m.chatId.equals(chatId) & m.content.like('%$query%'))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get message count stats
  Future<Map<String, int>> getMessageStats() async {
    final total = await customSelect(
      'SELECT COUNT(*) as count FROM messages',
      readsFrom: {messages},
    ).map((row) => row.read<int>('count')).getSingle();

    final pending = await customSelect(
      "SELECT COUNT(*) as count FROM messages WHERE status = 'pending'",
      readsFrom: {messages},
    ).map((row) => row.read<int>('count')).getSingle();

    final unRead = await customSelect(
      "SELECT COUNT(*) as count FROM messages WHERE status != 'read'",
      readsFrom: {messages},
    ).map((row) => row.read<int>('count')).getSingle();

    return {
      'total': total,
      'pending': pending,
      'unread': unRead,
    };
  }

  /// Get messages with media for download
  Future<List<Message>> getMessagesWithMedia(String chatId) {
    return (select(messages)
      ..where((m) => m.chatId.equals(chatId) & 
          (m.type.equals('image') | m.type.equals('video') | m.type.equals('audio')))
      ..orderBy([(m) => OrderingTerm(expression: m.createdAt)]))
        .get();
  }
}
