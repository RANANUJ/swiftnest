import 'package:drift/drift.dart';
import '../drift_database.dart';
part 'chats_dao.g.dart';

/// Data Access Object for Chats table
@DriftAccessor(tables: [Chats, Messages])
class ChatsDao extends DatabaseAccessor<SwiftNestDatabase>
    with _$ChatsDaoMixin {
  ChatsDao(SwiftNestDatabase db) : super(db);

  /// Get chat by ID
  Future<Chat?> getChatById(String chatId) {
    return (select(chats)..where((c) => c.id.equals(chatId)))
        .getSingleOrNull();
  }

  /// Get all chats ordered by last message time
  Future<List<Chat>> getAllChats({bool excludeArchived = true}) {
    var query = select(chats);
    if (excludeArchived) {
      query = query..where((c) => c.isArchived.equals(false));
    }
    return (query..orderBy([(c) => OrderingTerm(expression: c.lastMessageAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get chats with pagination
  Future<List<Chat>> getChatsPaginated({
    required int limit,
    required int offset,
    bool excludeArchived = true,
  }) {
    var query = select(chats);
    if (excludeArchived) {
      query = query..where((c) => c.isArchived.equals(false));
    }
    return (query
          ..orderBy([(c) => OrderingTerm(expression: c.lastMessageAt, mode: OrderingMode.desc)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Get chats with unread messages
  Future<List<Chat>> getUnreadChats() {
    return (select(chats)
      ..where((c) => c.unreadCount.isBiggerThanValue(0))
      ..orderBy([(c) => OrderingTerm(expression: c.lastMessageAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Count unread messages across all chats
  Future<int> getTotalUnreadCount() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(unread_count), 0) as total FROM chats WHERE is_archived = 0',
      readsFrom: {chats},
    ).map((row) => row.read<int>('total')).getSingleOrNull();

    return result ?? 0;
  }

  /// Insert or update chat
  Future<void> upsertChat(ChatsCompanion chat) async {
    await into(chats).insert(chat, mode: InsertMode.insertOrReplace);
  }

  /// Update chat unread count
  Future<void> updateUnreadCount(String chatId, int count) {
    return (update(chats)..where((c) => c.id.equals(chatId)))
        .write(ChatsCompanion(
          unreadCount: Value(count),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Mark chat as read
  Future<void> markChatAsRead(String chatId) {
    return (update(chats)..where((c) => c.id.equals(chatId)))
        .write(ChatsCompanion(
          unreadCount: Value(0),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Update last message info
  Future<void> updateLastMessage({
    required String chatId,
    required String messageId,
    required String preview,
    required String senderId,
    required DateTime timestamp,
  }) {
    return (update(chats)..where((c) => c.id.equals(chatId)))
        .write(ChatsCompanion(
          lastMessageId: Value(messageId),
          lastMessagePreview: Value(preview),
          lastMessageSenderId: Value(senderId),
          lastMessageAt: Value(timestamp),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Archive chat
  Future<void> archiveChat(String chatId) {
    return (update(chats)..where((c) => c.id.equals(chatId)))
        .write(ChatsCompanion(
          isArchived: Value(true),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Unarchive chat
  Future<void> unarchiveChat(String chatId) {
    return (update(chats)..where((c) => c.id.equals(chatId)))
        .write(ChatsCompanion(
          isArchived: Value(false),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Mute chat notifications
  Future<void> muteChat(String chatId) {
    return (update(chats)..where((c) => c.id.equals(chatId)))
        .write(ChatsCompanion(
          isMuted: Value(true),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Unmute chat notifications
  Future<void> unmuteChat(String chatId) {
    return (update(chats)..where((c) => c.id.equals(chatId)))
        .write(ChatsCompanion(
          isMuted: Value(false),
          updatedAt: Value(DateTime.now()),
        ));
  }

  /// Delete chat
  Future<int> deleteChat(String chatId) {
    return (delete(chats)..where((c) => c.id.equals(chatId)))
        .go();
  }

  /// Search chats by name
  Future<List<Chat>> searchChats(String query) {
    return (select(chats)
      ..where((c) => c.name.like('%$query%'))
      ..orderBy([(c) => OrderingTerm(expression: c.lastMessageAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get group chats
  Future<List<Chat>> getGroupChats() {
    return (select(chats)
      ..where((c) => c.type.equals('group'))
      ..orderBy([(c) => OrderingTerm(expression: c.lastMessageAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get direct message chats
  Future<List<Chat>> getDirectChats() {
    return (select(chats)
      ..where((c) => c.type.equals('direct'))
      ..orderBy([(c) => OrderingTerm(expression: c.lastMessageAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Count total chats
  Future<int> countChats({bool excludeArchived = false}) async {
    var query = select(chats);
    if (excludeArchived) {
      query = query..where((c) => c.isArchived.equals(false));
    }
    final count = await (query.get()).then((list) => list.length);
    return count;
  }
}
