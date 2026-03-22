import 'dart:async';
import 'package:drift/drift.dart' as drift;
import '../database/drift_database.dart';
import '../database/database_service.dart';
import '../socket/socket_io_service.dart';

/// Offline-First Sync Engine
/// 
/// Responsibilities:
/// - Queue pending messages when offline
/// - Retry failed messages with exponential backoff
/// - Sync messages when connection restored
/// - Handle conflicts and duplicates
/// - Manage sync state and progress
class SyncEngine {
  final DatabaseService _databaseService;
  final SocketIOService _socketIOService;

  // Configuration
  static const int initialRetryDelay = 1000; // 1 second
  static const int maxRetryDelay = 60000; // 1 minute
  static const int maxRetries = 10;

  // State
  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Timer? _retryTimer;
  Timer? _syncTimer;

  // Callbacks
  Function(String messageId)? onMessageSent;
  Function(String messageId, String error)? onMessageFailed;
  Function(int pendingCount)? onPendingCountChanged;

  SyncEngine({
    required DatabaseService databaseService,
    required SocketIOService socketIOService,
  })  : _databaseService = databaseService,
        _socketIOService = socketIOService;

  // ============================================================================
  // INITIALIZATION & LIFECYCLE
  // ============================================================================

  /// Initialize sync engine
  Future<void> initialize() async {
    print('[SyncEngine] Initializing...');

    // Setup Socket.IO event listeners
    _setupSocketListeners();

    // Start periodic sync timer
    _startPeriodicSync();

    // Process any pending messages
    await _processPendingMessages();

    print('[SyncEngine] Initialized');
  }

  /// Setup Socket.IO event listeners for sync
  void _setupSocketListeners() {
    _socketIOService.onConnectionEstablished = () {
      print('[SyncEngine] Connection established, syncing pending messages...');
      _processPendingMessages();
    };

    _socketIOService.onConnectionLost = () {
      print('[SyncEngine] Connection lost, will queue future messages');
    };

    _socketIOService.onMessageDelivered = (messageId, timestamp) {
      _handleMessageDelivered(messageId);
    };
  }

  /// Start periodic sync timer (every 30 seconds)
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isSyncing && _socketIOService.isConnected) {
        _processPendingMessages();
      }
    });
  }

  /// Dispose resources
  void dispose() {
    _retryTimer?.cancel();
    _syncTimer?.cancel();
    print('[SyncEngine] Disposed');
  }

  // ============================================================================
  // MESSAGE QUEUEING
  // ============================================================================

  /// Queue a message for sending
  Future<void> queueMessage({
    required String messageId,
    required String chatId,
    required String senderId,
    required String content,
    String type = 'text',
    String? localMediaPath,
  }) async {
    print('[SyncEngine] Queueing message: $messageId');

    try {
      final payload = {
        'messageId': messageId,
        'chatId': chatId,
        'content': content,
        'type': type,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final pendingMessage = PendingMessagesCompanion(
        id: drift.Value(messageId),
        chatId: drift.Value(chatId),
        senderId: drift.Value(senderId),
        content: drift.Value(content),
        type: drift.Value(type),
        localMediaPath: localMediaPath != null
            ? drift.Value(localMediaPath)
            : const drift.Value.absent(),
        payload: drift.Value(payload.toString()),
        retryCount: const drift.Value(0),
        maxRetries: const drift.Value(maxRetries),
        createdAt: drift.Value(DateTime.now()),
      );

      await _databaseService.insertPendingMessage(pendingMessage);
      print('[SyncEngine] Message queued: $messageId');

      // Try to send immediately if connected
      if (_socketIOService.isConnected) {
        await _sendPendingMessage(messageId, chatId, content);
      }

      _notifyPendingCountChanged();
    } catch (e) {
      print('[SyncEngine] Error queueing message: $e');
      onMessageFailed?.call(messageId, e.toString());
    }
  }

  // ============================================================================
  // MESSAGE PROCESSING & RETRY
  // ============================================================================

  /// Process all pending messages
  Future<void> _processPendingMessages() async {
    if (_isSyncing) return;

    _isSyncing = true;
    print('[SyncEngine] Processing pending messages...');

    try {
      final pendingMessages =
          await _databaseService.getPendingMessages();

      if (pendingMessages.isEmpty) {
        print('[SyncEngine] No pending messages');
        _isSyncing = false;
        return;
      }

      print('[SyncEngine] Found ${pendingMessages.length} pending messages');

      for (final pending in pendingMessages) {
        await _processPendingMessage(pending);
      }

      _notifyPendingCountChanged();
    } catch (e) {
      print('[SyncEngine] Error processing pending messages: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Process a single pending message
  Future<void> _processPendingMessage(PendingMessage pending) async {
    try {
      // Check if max retries exceeded
      if (pending.retryCount >= pending.maxRetries) {
        print(
            '[SyncEngine] Max retries exceeded for message ${pending.id}');
        onMessageFailed?.call(
          pending.id,
          'Max retries exceeded',
        );
        return;
      }

      // If not connected, skip for now
      if (!_socketIOService.isConnected) {
        print('[SyncEngine] Not connected, skipping message ${pending.id}');
        return;
      }

      // Send the message
      await _sendPendingMessage(
        pending.id,
        pending.chatId,
        pending.content,
      );
    } catch (e) {
      print('[SyncEngine] Error processing pending message ${pending.id}: $e');

      // Increment retry count
      final newRetryCount = pending.retryCount + 1;
      await _databaseService.updatePendingMessageRetry(
        pending.id,
        newRetryCount,
      );

      // Schedule retry with exponential backoff
      if (newRetryCount < pending.maxRetries) {
        _scheduleRetry(pending.id, newRetryCount);
      }

      onMessageFailed?.call(pending.id, e.toString());
    }
  }

  /// Send a pending message via Socket.IO
  Future<void> _sendPendingMessage(
    String messageId,
    String chatId,
    String content,
  ) async {
    print('[SyncEngine] Sending pending message: $messageId');

    _socketIOService.sendMessage(
      messageId: messageId,
      chatId: chatId,
      content: content,
    );

    // Message sent successfully, remove from pending queue
    // (listener will handle this on delivery confirmation)
  }

  /// Schedule retry with exponential backoff
  void _scheduleRetry(String messageId, int retryCount) {
    // Exponential backoff: 1s, 2s, 4s, 8s, 16s, etc.
    final delayMs = (initialRetryDelay * (1 << (retryCount - 1)))
        .clamp(0, maxRetryDelay).toInt();

    print(
        '[SyncEngine] Scheduling retry for message $messageId in ${delayMs}ms (attempt $retryCount)');

    Future.delayed(Duration(milliseconds: delayMs), () async {
      final pending = await _databaseService
          .getPendingMessages()
          .then((list) => list
              .where((p) => p.id == messageId)
              .firstOrNull);

      if (pending != null) {
        await _processPendingMessage(pending);
      }
    });
  }

  /// Handle message delivery confirmation
  void _handleMessageDelivered(String messageId) {
    print('[SyncEngine] Message delivered: $messageId');
    _databaseService.removePendingMessage(messageId);
    onMessageSent?.call(messageId);
    _notifyPendingCountChanged();
  }

  // ============================================================================
  // SYNC STATUS & NOTIFICATIONS
  // ============================================================================

  /// Notify pending message count changed
  void _notifyPendingCountChanged() {
    _databaseService.getPendingMessages().then((messages) {
      onPendingCountChanged?.call(messages.length);
    });
  }

  /// Get pending message count
  Future<int> getPendingCount() async {
    final pending = await _databaseService.getPendingMessages();
    return pending.length;
  }

  /// Manually trigger sync
  Future<void> syncNow() async {
    await _processPendingMessages();
  }

  /// Clear all pending messages (use with caution)
  Future<void> clearPending() async {
    print('[SyncEngine] Clearing all pending messages');
    final pending = await _databaseService.getPendingMessages();
    for (final message in pending) {
      await _databaseService.removePendingMessage(message.id);
    }
    _notifyPendingCountChanged();
  }
}
