import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database/drift_database.dart';
import '../services/database/database_service.dart';
import '../services/database/providers.dart'
    show databaseServiceProvider;
import '../services/socket/socket_io_service.dart';
import '../services/socket/socket_io_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' as drift;

/// State notifier for managing chat list
class ChatListNotifier extends StateNotifier<AsyncValue<List<Chat>>> {
  final DatabaseService _databaseService;
  final SocketIOService _socketIOService;

  ChatListNotifier({
    required DatabaseService databaseService,
    required SocketIOService socketIOService,
  })  : _databaseService = databaseService,
        _socketIOService = socketIOService,
        super(const AsyncValue.loading()) {
    _initialize();
  }

  /// Initialize: Load chats from database and setup listeners
  void _initialize() async {
    try {
      print('[ChatListNotifier] Initializing...');

      // Load initial chats from database
      final chats = await _databaseService.getActiveChats();
      state = AsyncValue.data(chats);

      // Setup Socket.IO listeners
      _setupSocketListeners();

      print('[ChatListNotifier] Loaded ${chats.length} chats');
    } catch (e) {
      print('[ChatListNotifier] Error initializing: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Setup Socket.IO event listeners
  void _setupSocketListeners() {
    _socketIOService.onMessageReceived =
        (messageId, senderId, content) async {
      // Message received - will be synced, just refresh list
      await refreshChats();
    };
  }

  /// Refresh chat list from database
  Future<void> refreshChats() async {
    try {
      final chats = await _databaseService.getActiveChats();
      state = AsyncValue.data(chats);
      print('[ChatListNotifier] Refreshed ${chats.length} chats');
    } catch (e) {
      print('[ChatListNotifier] Error refreshing: $e');
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Create a new chat
  Future<Chat?> createChat({
    required String recipientId,
    required String recipientName,
    String? recipientAvatar,
  }) async {
    try {
      print('[ChatListNotifier] Creating chat with $recipientId...');

      final chatId = const Uuid().v4();
      final now = DateTime.now();

      final chat = ChatsCompanion(
        id: drift.Value(chatId),
        type: const drift.Value('direct'),
        name: drift.Value(recipientName),
        avatar: recipientAvatar != null
            ? drift.Value(recipientAvatar)
            : const drift.Value.absent(),
        members: drift.Value('[$recipientId]'),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      );

      await _databaseService.insertChat(chat);

      // Notify server
      _socketIOService.createChat(
        chatId: chatId,
        type: 'direct',
        members: [recipientId],
      );

      await refreshChats();

      return await _databaseService.getChatById(chatId);
    } catch (e) {
      print('[ChatListNotifier] Error creating chat: $e');
      return null;
    }
  }

  /// Archive a chat
  Future<void> archiveChat(String chatId) async {
    try {
      await _databaseService.setArchiveStatus(chatId, true);
      await refreshChats();
      print('[ChatListNotifier] Archived chat: $chatId');
    } catch (e) {
      print('[ChatListNotifier] Error archiving chat: $e');
    }
  }

  /// Mute a chat
  Future<void> muteChat(String chatId) async {
    try {
      await _databaseService.setMuteStatus(chatId, true);
      await refreshChats();
      print('[ChatListNotifier] Muted chat: $chatId');
    } catch (e) {
      print('[ChatListNotifier] Error muting chat: $e');
    }
  }

  /// Mark all messages as read
  Future<void> markChatAsRead(String chatId) async {
    try {
      await _databaseService.resetUnreadCount(chatId);
      await refreshChats();

      // Notify server
      _socketIOService.markMessageRead('', chatId);

      print('[ChatListNotifier] Marked chat as read: $chatId');
    } catch (e) {
      print('[ChatListNotifier] Error marking as read: $e');
    }
  }

  /// Delete a chat
  Future<void> deleteChat(String chatId) async {
    try {
      await _databaseService.deleteChat(chatId);
      await _databaseService.deleteMessagesForChat(chatId);
      await refreshChats();
      print('[ChatListNotifier] Deleted chat: $chatId');
    } catch (e) {
      print('[ChatListNotifier] Error deleting chat: $e');
    }
  }

  /// Search chats
  Future<List<Chat>> searchChats(String query) async {
    try {
      final chats = await _databaseService.getAllChats();
      return chats
          .where((chat) =>
              (chat.name?.toLowerCase().contains(query.toLowerCase()) ?? false))
          .toList();
    } catch (e) {
      print('[ChatListNotifier] Error searching chats: $e');
      return [];
    }
  }
}

/// Chat list provider
final chatListProvider =
    StateNotifierProvider<ChatListNotifier, AsyncValue<List<Chat>>>((ref) {
  final databaseServiceAsync = ref.watch(databaseServiceProvider);
  final socketIOServiceAsync = ref.watch(socketIOServiceProvider);

  return databaseServiceAsync.when(
    data: (databaseService) {
      return socketIOServiceAsync.when(
        data: (socketIOService) {
          return ChatListNotifier(
            databaseService: databaseService,
            socketIOService: socketIOService,
          );
        },
        loading: () {
          return ChatListNotifier(
            databaseService: databaseService,
            socketIOService: throw Exception('Socket.IO not initialized'),
          );
        },
        error: (error, stack) {
          throw error;
        },
      );
    },
    loading: () {
      throw Exception('Database not initialized');
    },
    error: (error, stack) {
      throw error;
    },
  );
});
