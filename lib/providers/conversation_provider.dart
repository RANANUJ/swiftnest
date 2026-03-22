import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../services/database/drift_database.dart';
import '../services/database/database_service.dart';
import '../services/database/providers.dart'
    show databaseServiceProvider;
import '../services/socket/socket_io_service.dart';
import '../services/socket/socket_io_provider.dart';
import '../services/sync/sync_engine.dart';
import '../services/sync/sync_engine_provider.dart' show syncEngineProvider;
import '../config/app_config.dart';
import 'package:drift/drift.dart' as drift;

/// Conversation state model
class ConversationState {
  final List<Message> messages;
  final bool isLoadingMore;
  final bool hasMoreMessages;
  final String typingIndicator; // Empty string if no one is typing
  final int unreadCount;
  final bool isError;
  final String errorMessage;

  const ConversationState({
    this.messages = const [],
    this.isLoadingMore = false,
    this.hasMoreMessages = true,
    this.typingIndicator = '',
    this.unreadCount = 0,
    this.isError = false,
    this.errorMessage = '',
  });

  ConversationState copyWith({
    List<Message>? messages,
    bool? isLoadingMore,
    bool? hasMoreMessages,
    String? typingIndicator,
    int? unreadCount,
    bool? isError,
    String? errorMessage,
  }) {
    return ConversationState(
      messages: messages ?? this.messages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      typingIndicator: typingIndicator ?? this.typingIndicator,
      unreadCount: unreadCount ?? this.unreadCount,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// State notifier for managing messages in a conversation
class ConversationNotifier extends StateNotifier<ConversationState> {
  final String chatId;
  final DatabaseService _databaseService;
  final SocketIOService _socketIOService;
  final SyncEngine _syncEngine;

  int _messageOffset = 0;

  ConversationNotifier({
    required this.chatId,
    required DatabaseService databaseService,
    required SocketIOService socketIOService,
    required SyncEngine syncEngine,
  })  : _databaseService = databaseService,
        _socketIOService = socketIOService,
        _syncEngine = syncEngine,
        super(const ConversationState()) {
    _initialize();
  }

  /// Initialize: Load initial messages and setup listeners
  void _initialize() async {
    try {
      print('[ConversationNotifier] Initializing for chat $chatId...');

      // Join chat room
      _socketIOService.joinChat(chatId);

      // Load initial messages
      await loadMessages();

      // Setup Socket.IO listeners
      _setupSocketListeners();

      print('[ConversationNotifier] Initialized');
    } catch (e) {
      print('[ConversationNotifier] Error initializing: $e');
      state = state.copyWith(
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Setup Socket.IO event listeners
  void _setupSocketListeners() {
    _socketIOService.onMessageReceived =
        (messageId, senderId, content) async {
      // Message received from another user - sync will handle DB storage
      await loadMessages();
    };

    _socketIOService.onTypingStarted = (userId, chatIdTyping) {
      if (chatIdTyping == chatId && userId != 'current_user_id') {
        // Show typing indicator
        state = state.copyWith(typingIndicator: '$userId is typing...');
      }
    };

    _socketIOService.onTypingStopped = (userId, chatIdTyping) {
      if (chatIdTyping == chatId) {
        state = state.copyWith(typingIndicator: '');
      }
    };
  }

  /// Load messages with pagination
  Future<void> loadMessages({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        state = state.copyWith(isLoadingMore: true);
        _messageOffset = 0;
      }

      final messages = await _databaseService.getMessagesForChat(
        chatId,
        limit: AppConfig.messageBatchSize,
        offset: _messageOffset,
      );

      if (loadMore) {
        final currentMessages = state.messages;
        state = state.copyWith(
          messages: [...currentMessages, ...messages],
          isLoadingMore: false,
          hasMoreMessages: messages.length == AppConfig.messageBatchSize,
        );
      } else {
        state = state.copyWith(
          messages: messages,
          isLoadingMore: false,
          hasMoreMessages: messages.length == AppConfig.messageBatchSize,
        );
      }

      // Mark as read in database
      await _databaseService.resetUnreadCount(chatId);

      _messageOffset += messages.length;
      print('[ConversationNotifier] Loaded ${messages.length} messages');
    } catch (e) {
      print('[ConversationNotifier] Error loading messages: $e');
      state = state.copyWith(
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Load more messages (pagination)
  Future<void> loadMoreMessages() async {
    if (!state.hasMoreMessages || state.isLoadingMore) return;
    await loadMessages(loadMore: true);
  }

  /// Send a text message
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    try {
      print('[ConversationNotifier] Sending message...');

      final messageId = const Uuid().v4();
      final now = DateTime.now();

      // Create message locally
      final message = MessagesCompanion(
        id: drift.Value(messageId),
        chatId: drift.Value(chatId),
        senderId: drift.Value('current_user_id'),
        senderName: const drift.Value('You'),
        content: drift.Value(content),
        status: const drift.Value('pending'),
        createdAt: drift.Value(now),
        updatedAt: drift.Value(now),
      );

      // Save to database
      await _databaseService.insertMessage(message);

      // Queue for sync engine
      await _syncEngine.queueMessage(
        messageId: messageId,
        chatId: chatId,
        senderId: 'current_user_id',
        content: content,
      );

      // Update UI with new message
      final newMessage = Message(
        id: messageId,
        chatId: chatId,
        senderId: 'current_user_id',
        senderName: 'You',
        senderAvatar: null,
        content: content,
        type: 'text',
        mediaUrl: null,
        localMediaPath: null,
        status: 'pending',
        isEdited: false,
        editedAt: null,
        replyToId: null,
        reactionCount: 0,
        reactions: null,
        createdAt: now,
        updatedAt: now,
      );

      state = state.copyWith(
        messages: [newMessage, ...state.messages],
      );

      print('[ConversationNotifier] Message queued: $messageId');
    } catch (e) {
      print('[ConversationNotifier] Error sending message: $e');
      state = state.copyWith(
        isError: true,
        errorMessage: e.toString(),
      );
    }
  }

  /// Send typing indicator
  void notifyTypingStarted() {
    _socketIOService.sendTypingStarted(chatId);
  }

  /// Stop typing indicator
  void notifyTypingStopped() {
    _socketIOService.sendTypingStopped(chatId);
  }

  /// Edit a message
  Future<void> editMessage(String messageId, String newContent) async {
    try {
      print('[ConversationNotifier] Editing message: $messageId');

      await _databaseService.markMessageAsEdited(messageId, newContent);
      _socketIOService.editMessage(
        messageId: messageId,
        chatId: chatId,
        newContent: newContent,
      );

      await loadMessages();
      print('[ConversationNotifier] Message edited: $messageId');
    } catch (e) {
      print('[ConversationNotifier] Error editing message: $e');
    }
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    try {
      print('[ConversationNotifier] Deleting message: $messageId');

      await _databaseService.deleteMessage(messageId);
      _socketIOService.deleteMessage(messageId, chatId);

      final updatedMessages = state.messages
          .where((msg) => msg.id != messageId)
          .toList();

      state = state.copyWith(messages: updatedMessages);
      print('[ConversationNotifier] Message deleted: $messageId');
    } catch (e) {
      print('[ConversationNotifier] Error deleting message: $e');
    }
  }

  /// React to a message
  Future<void> reactToMessage(String messageId, String emoji) async {
    try {
      _socketIOService.addReaction(
        messageId: messageId,
        chatId: chatId,
        emoji: emoji,
      );
      print('[ConversationNotifier] Reacted to message: $messageId');
    } catch (e) {
      print('[ConversationNotifier] Error reacting to message: $e');
    }
  }

  /// Cleanup on dispose
  @override
  void dispose() {
    _socketIOService.leaveChat(chatId);
    super.dispose();
  }
}

/// Conversation provider - scoped to a specific chat
final conversationProvider = StateNotifierProvider.family<ConversationNotifier,
    ConversationState, String>((ref, chatId) {
  final databaseServiceAsync = ref.watch(databaseServiceProvider);
  final socketIOServiceAsync = ref.watch(socketIOServiceProvider);
  final syncEngineAsync = ref.watch(syncEngineProvider);

  return databaseServiceAsync.when(
    data: (databaseService) {
      return socketIOServiceAsync.when(
        data: (socketIOService) {
          return syncEngineAsync.when(
            data: (syncEngine) {
              return ConversationNotifier(
                chatId: chatId,
                databaseService: databaseService,
                socketIOService: socketIOService,
                syncEngine: syncEngine,
              );
            },
            loading: () {
              return ConversationNotifier(
                chatId: chatId,
                databaseService: databaseService,
                socketIOService: socketIOService,
                syncEngine: throw Exception('SyncEngine not initialized'),
              );
            },
            error: (error, stack) {
              throw error;
            },
          );
        },
        loading: () {
          throw Exception('Services not initialized');
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

