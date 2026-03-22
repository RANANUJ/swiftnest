import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database/drift_database.dart';
import '../services/database/database_service.dart';
import '../services/database/dao/users_dao.dart';
import '../services/database/dao/chats_dao.dart';
import '../services/database/dao/messages_dao.dart';
import '../services/database/dao/pending_messages_dao.dart';
import '../services/database/dao/downloaded_media_dao.dart';

/// Riverpod provider for the Drift database instance
/// 
/// Usage:
/// ```dart
/// // In a widget
/// final db = ref.watch(databaseProvider);
/// 
/// // In a provider
/// final getUsersProvider = FutureProvider((ref) async {
///   final service = ref.watch(databaseServiceProvider);
///   return service.getAllUsers();
/// });
/// ```
final databaseProvider = Provider<SwiftNestDatabase>((ref) {
  return SwiftNestDatabase();
});

/// Provider for the DatabaseService (high-level API)
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  final db = ref.watch(databaseProvider);
  return DatabaseService(db);
});

/// DAO providers
final usersDaoProvider = Provider<UsersDao>((ref) {
  final db = ref.watch(databaseProvider);
  return UsersDao(db);
});

final chatsDaoProvider = Provider<ChatsDao>((ref) {
  final db = ref.watch(databaseProvider);
  return ChatsDao(db);
});

final messagesDaoProvider = Provider<MessagesDao>((ref) {
  final db = ref.watch(databaseProvider);
  return MessagesDao(db);
});

final pendingMessagesDaoProvider = Provider<PendingMessagesDao>((ref) {
  final db = ref.watch(databaseProvider);
  return PendingMessagesDao(db);
});

final downloadedMediaDaoProvider = Provider<DownloadedMediaDao>((ref) {
  final db = ref.watch(databaseProvider);
  return DownloadedMediaDao(db);
});

// ============================================================================
// USERS PROVIDERS
// ============================================================================

/// Provider to get all users
final getAllUsersProvider = FutureProvider((ref) async {
  final usersDao = ref.watch(usersDaoProvider);
  return usersDao.getAllUsers();
});

/// Provider to get user by ID
final getUserByIdProvider = FutureProvider.family<User?, String>((ref, userId) async {
  final usersDao = ref.watch(usersDaoProvider);
  return usersDao.getUserById(userId);
});

/// Provider to search users
final searchUsersProvider =
    FutureProvider.family<List<User>, String>((ref, query) async {
  final usersDao = ref.watch(usersDaoProvider);
  return usersDao.searchUsers(query);
});

// ============================================================================
// CHATS PROVIDERS
// ============================================================================

/// Provider to get all chats (non-archived)
final getAllChatsProvider = FutureProvider((ref) async {
  final chatsDao = ref.watch(chatsDaoProvider);
  return chatsDao.getAllChats(excludeArchived: true);
});

/// Provider to get chats with pagination
final getChatsPaginatedProvider =
    FutureProvider.family<List<Chat>, (int, int)>((ref, params) async {
  final (limit, offset) = params;
  final chatsDao = ref.watch(chatsDaoProvider);
  return chatsDao.getChatsPaginated(limit: limit, offset: offset);
});

/// Provider to get unread chats count
final getUnreadChatsCountProvider = FutureProvider((ref) async {
  final chatsDao = ref.watch(chatsDaoProvider);
  return chatsDao.getTotalUnreadCount();
});

/// Provider to get chat by ID
final getChatByIdProvider = FutureProvider.family<Chat?, String>((ref, chatId) async {
  final chatsDao = ref.watch(chatsDaoProvider);
  return chatsDao.getChatById(chatId);
});

/// Provider to search chats
final searchChatsProvider =
    FutureProvider.family<List<Chat>, String>((ref, query) async {
  final chatsDao = ref.watch(chatsDaoProvider);
  return chatsDao.searchChats(query);
});

// ============================================================================
// MESSAGES PROVIDERS
// ============================================================================

/// Provider to get messages for a chat
final getMessagesByChatProvider =
    FutureProvider.family<List<Message>, String>((ref, chatId) async {
  final messagesDao = ref.watch(messagesDaoProvider);
  return messagesDao.getMessagesByChatId(chatId);
});

/// Provider to get messages with pagination
final getMessagesPaginatedProvider = FutureProvider.family<List<Message>, (String, int, int)>(
  (ref, params) async {
    final (chatId, limit, offset) = params;
    final messagesDao = ref.watch(messagesDaoProvider);
    return messagesDao.getMessagesByChatIdPaginated(
      chatId: chatId,
      limit: limit,
      offset: offset,
    );
  },
);

/// Provider to get latest message in a chat
final getLatestMessageProvider =
    FutureProvider.family<Message?, String>((ref, chatId) async {
  final messagesDao = ref.watch(messagesDaoProvider);
  return messagesDao.getLatestMessage(chatId);
});

/// Provider to search messages in a chat
final searchMessagesProvider =
    FutureProvider.family<List<Message>, (String, String)>((ref, params) async {
  final (chatId, query) = params;
  final messagesDao = ref.watch(messagesDaoProvider);
  return messagesDao.searchMessagesInChat(chatId: chatId, query: query);
});

// ============================================================================
// PENDING MESSAGES PROVIDERS
// ============================================================================

/// Provider to get pending messages for a chat
final getPendingMessagesByChatProvider =
    FutureProvider.family<List<PendingMessage>, String>((ref, chatId) async {
  final pendingDao = ref.watch(pendingMessagesDaoProvider);
  return pendingDao.getPendingMessagesByChat(chatId);
});

/// Provider to get all pending messages
final getAllPendingMessagesProvider = FutureProvider((ref) async {
  final pendingDao = ref.watch(pendingMessagesDaoProvider);
  return pendingDao.getAllPendingMessages();
});

/// Provider to get pending messages statistics
final getPendingStatsProvider = FutureProvider((ref) async {
  final pendingDao = ref.watch(pendingMessagesDaoProvider);
  return pendingDao.getPendingStats();
});

// ============================================================================
// DOWNLOADED MEDIA PROVIDERS
// ============================================================================

/// Provider to get all complete downloads
final getCompleteDownloadsProvider = FutureProvider((ref) async {
  final mediaDao = ref.watch(downloadedMediaDaoProvider);
  return mediaDao.getCompleteDownloads();
});

/// Provider to get media statistics
final getMediaStatsProvider = FutureProvider((ref) async {
  final mediaDao = ref.watch(downloadedMediaDaoProvider);
  return mediaDao.getMediaStats();
});

/// Provider to get total cache size
final getTotalCacheSizeProvider = FutureProvider((ref) async {
  final mediaDao = ref.watch(downloadedMediaDaoProvider);
  return mediaDao.getTotalCacheSize();
});

/// Provider to check if content is cached
final isMediaCachedProvider =
    FutureProvider.family<bool, String>((ref, url) async {
  final mediaDao = ref.watch(downloadedMediaDaoProvider);
  return mediaDao.isCached(url);
});

// ============================================================================
// DATABASE OPERATIONS PROVIDERS
// ============================================================================

/// Provider for database statistics
final getDatabaseStatsProvider = FutureProvider((ref) async {
  final db = ref.watch(databaseProvider);
  return db.getStats();
});

/// StateNotifier for managing chat list state
class ChatListNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  final Ref ref;

  ChatListNotifier(this.ref) : super(const AsyncValue.loading());

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final chatsDao = ref.read(chatsDaoProvider);
      final chats = await chatsDao.getAllChats(excludeArchived: true);
      state = AsyncValue.data(chats);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// StateNotifier for managing messages state
class MessagesNotifier extends StateNotifier<AsyncValue<List<Message>>> {
  final Ref ref;
  final String chatId;

  MessagesNotifier(this.ref, this.chatId) : super(const AsyncValue.loading());

  Future<void> loadMessages() async {
    state = const AsyncValue.loading();
    try {
      final messagesDao = ref.read(messagesDaoProvider);
      final messages = await messagesDao.getMessagesByChatId(chatId);
      state = AsyncValue.data(messages);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addMessage(Message message) async {
    final current = state;
    if (current is AsyncData<List<Message>>) {
      final messages = [message, ...current.value];
      state = AsyncValue.data(messages);
    }
  }

  Future<void> updateMessage(Message message) async {
    final current = state;
    if (current is AsyncData<List<Message>>) {
      final messages = current.value
          .map((m) => m.id == message.id ? message : m)
          .toList();
      state = AsyncValue.data(messages);
    }
  }
}

/// Provider for chat list state management
final chatListProvider =
    StateNotifierProvider<ChatListNotifier, AsyncValue<List<Chat>>>((ref) {
  return ChatListNotifier(ref);
});

/// Provider for messages state management (family for each chat)
final messagesProvider = StateNotifierProvider.family<
    MessagesNotifier,
    AsyncValue<List<Message>>,
    String>((ref, chatId) {
  return MessagesNotifier(ref, chatId);
});

