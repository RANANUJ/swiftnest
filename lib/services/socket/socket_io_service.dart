import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../config/app_config.dart';

/// Socket.IO Real-Time Communication Service
/// 
/// Handles:
/// - Message delivery (send/receive instant messages)
/// - Typing indicators
/// - Read receipts
/// - User presence (online/offline)
/// - Connection management with auto-reconnect
class SocketIOService {
  late IO.Socket _socket;
  final String _userId;
  final String _accessToken;

  // Callbacks for events
  Function(String messageId, String senderId, String content)? onMessageReceived;
  Function(String userId, String chatId)? onTypingStarted;
  Function(String userId, String chatId)? onTypingStopped;
  Function(String userId)? onUserOnline;
  Function(String userId)? onUserOffline;
  Function(String messageId, DateTime timestamp)? onMessageDelivered;
  Function(String messageId, DateTime timestamp)? onMessageRead;
  Function? onConnectionEstablished;
  Function? onConnectionLost;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  SocketIOService({
    required String userId,
    required String accessToken,
  })  : _userId = userId,
        _accessToken = accessToken;

  // ============================================================================
  // CONNECTION MANAGEMENT
  // ============================================================================

  /// Initialize socket connection
  Future<void> connect() async {
    try {
      print('[Socket.IO] Connecting for user $_userId...');

      _socket = IO.io(
        AppConfig.socketBaseUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableReconnection()
            .setReconnectionDelay(AppConfig.socketReconnectDelay.inMilliseconds)
            .setReconnectionDelayMax(10000)
            .setReconnectionAttempts(20)
            .enableAutoConnect()
            .setAuth({
              'token': _accessToken,
              'userId': _userId,
            })
            .build(),
      );

      // Setup event listeners
      _setupEventListeners();

      print('[Socket.IO] Connected successfully');
    } catch (e) {
      print('[Socket.IO] Connection error: $e');
      rethrow;
    }
  }

  /// Setup all socket event listeners
  void _setupEventListeners() {
    // Connection events
    _socket.on('connect', (_) {
      _isConnected = true;
      print('[Socket.IO] Connection established');
      onConnectionEstablished?.call();
    });

    _socket.on('disconnect', (_) {
      _isConnected = false;
      print('[Socket.IO] Connection lost');
      onConnectionLost?.call();
    });

    _socket.on('connect_error', (error) {
      print('[Socket.IO] Connection error: $error');
    });

    _socket.on('auth_error', (data) {
      print('[Socket.IO] Authentication error: $data');
    });

    // Message events
    _socket.on('message:received', (data) {
      print('[Socket.IO] Message received: $data');
      onMessageReceived?.call(
        data['messageId'] as String,
        data['senderId'] as String,
        data['content'] as String,
      );
    });

    _socket.on('message:delivered', (data) {
      print('[Socket.IO] Message delivered: ${data['messageId']}');
      onMessageDelivered?.call(
        data['messageId'] as String,
        DateTime.parse(data['timestamp'] as String),
      );
    });

    _socket.on('message:read', (data) {
      print('[Socket.IO] Message read: ${data['messageId']}');
      onMessageRead?.call(
        data['messageId'] as String,
        DateTime.parse(data['timestamp'] as String),
      );
    });

    // Typing indicators
    _socket.on('typing:started', (data) {
      print('[Socket.IO] User typing: ${data['userId']}');
      onTypingStarted?.call(
        data['userId'] as String,
        data['chatId'] as String,
      );
    });

    _socket.on('typing:stopped', (data) {
      print('[Socket.IO] User stopped typing: ${data['userId']}');
      onTypingStopped?.call(
        data['userId'] as String,
        data['chatId'] as String,
      );
    });

    // Presence events
    _socket.on('user:online', (data) {
      print('[Socket.IO] User online: ${data['userId']}');
      onUserOnline?.call(data['userId'] as String);
    });

    _socket.on('user:offline', (data) {
      print('[Socket.IO] User offline: ${data['userId']}');
      onUserOffline?.call(data['userId'] as String);
    });
  }

  /// Disconnect socket
  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
      _isConnected = false;
      print('[Socket.IO] Disconnected');
    }
  }

  /// Dispose resources
  void dispose() {
    disconnect();
  }

  // ============================================================================
  // MESSAGE EVENTS
  // ============================================================================

  /// Send a text message
  void sendMessage({
    required String messageId,
    required String chatId,
    required String content,
    String? replyToId,
  }) {
    if (!_isConnected) {
      print('[Socket.IO] Cannot send message - not connected');
      return;
    }

    _socket.emit('message:send', {
      'messageId': messageId,
      'chatId': chatId,
      'content': content,
      'replyToId': replyToId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('[Socket.IO] Message sent: $messageId');
  }

  /// Send media message
  void sendMediaMessage({
    required String messageId,
    required String chatId,
    required String mediaUrl,
    required String mediaType, // 'image', 'video', 'audio', 'document'
    String? caption,
    String? replyToId,
  }) {
    if (!_isConnected) {
      print('[Socket.IO] Cannot send media - not connected');
      return;
    }

    _socket.emit('message:send_media', {
      'messageId': messageId,
      'chatId': chatId,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'caption': caption,
      'replyToId': replyToId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    print('[Socket.IO] Media message sent: $messageId');
  }

  /// Mark message as delivered
  void markMessageDelivered(String messageId, String chatId) {
    if (!_isConnected) return;

    _socket.emit('message:mark_delivered', {
      'messageId': messageId,
      'chatId': chatId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Mark message as read
  void markMessageRead(String messageId, String chatId) {
    if (!_isConnected) return;

    _socket.emit('message:mark_read', {
      'messageId': messageId,
      'chatId': chatId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// React to a message
  void addReaction({
    required String messageId,
    required String chatId,
    required String emoji,
  }) {
    if (!_isConnected) return;

    _socket.emit('message:react', {
      'messageId': messageId,
      'chatId': chatId,
      'emoji': emoji,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Remove reaction from message
  void removeReaction({
    required String messageId,
    required String chatId,
    required String emoji,
  }) {
    if (!_isConnected) return;

    _socket.emit('message:unreact', {
      'messageId': messageId,
      'chatId': chatId,
      'emoji': emoji,
    });
  }

  /// Edit a message
  void editMessage({
    required String messageId,
    required String chatId,
    required String newContent,
  }) {
    if (!_isConnected) return;

    _socket.emit('message:edit', {
      'messageId': messageId,
      'chatId': chatId,
      'content': newContent,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Delete a message
  void deleteMessage(String messageId, String chatId) {
    if (!_isConnected) return;

    _socket.emit('message:delete', {
      'messageId': messageId,
      'chatId': chatId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ============================================================================
  // TYPING INDICATORS
  // ============================================================================

  /// Emit typing started event
  void sendTypingStarted(String chatId) {
    if (!_isConnected) return;

    _socket.emit('typing:start', {
      'chatId': chatId,
      'userId': _userId,
    });
  }

  /// Emit typing stopped event
  void sendTypingStopped(String chatId) {
    if (!_isConnected) return;

    _socket.emit('typing:stop', {
      'chatId': chatId,
      'userId': _userId,
    });
  }

  // ============================================================================
  // PRESENCE & STATUS
  // ============================================================================

  /// Update user status
  void updateUserStatus({
    required String status, // 'online', 'away', 'busy', 'offline'
    String? statusMessage,
  }) {
    if (!_isConnected) return;

    _socket.emit('user:status_update', {
      'status': status,
      'statusMessage': statusMessage,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Update last seen timestamp
  void updateLastSeen() {
    if (!_isConnected) return;

    _socket.emit('user:last_seen', {
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ============================================================================
  // CHAT EVENTS
  // ============================================================================

  /// Join a chat room (subscribe to updates)
  void joinChat(String chatId) {
    if (!_isConnected) return;

    _socket.emit('chat:join', {
      'chatId': chatId,
      'userId': _userId,
    });

    print('[Socket.IO] Joined chat: $chatId');
  }

  /// Leave a chat room
  void leaveChat(String chatId) {
    if (!_isConnected) return;

    _socket.emit('chat:leave', {
      'chatId': chatId,
      'userId': _userId,
    });

    print('[Socket.IO] Left chat: $chatId');
  }

  /// Create a new chat
  void createChat({
    required String chatId,
    required String type, // 'direct', 'group'
    required List<String> members,
    String? name,
    String? description,
  }) {
    if (!_isConnected) return;

    _socket.emit('chat:create', {
      'chatId': chatId,
      'type': type,
      'members': members,
      'name': name,
      'description': description,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ============================================================================
  // UTILITY
  // ============================================================================

  /// Reconnect to socket server
  void reconnect() {
    if (!_isConnected) {
      _socket.connect();
    }
  }

  /// Get raw socket instance (for advanced usage)
  IO.Socket get socket => _socket;
}
