import 'package:drift/drift.dart';
import '../drift_database.dart';
part 'pending_messages_dao.g.dart';

/// Data Access Object for PendingMessages table
/// Handles messages that are waiting to be sent/delivered
@DriftAccessor(tables: [PendingMessages])
class PendingMessagesDao extends DatabaseAccessor<SwiftNestDatabase>
    with _$PendingMessagesDaoMixin {
  PendingMessagesDao(SwiftNestDatabase db) : super(db);

  /// Get pending message by ID
  Future<PendingMessage?> getPendingMessageById(String messageId) {
    return (select(pendingMessages)
      ..where((p) => p.id.equals(messageId)))
        .getSingleOrNull();
  }

  /// Get all pending messages for a chat
  Future<List<PendingMessage>> getPendingMessagesByChat(String chatId) {
    return (select(pendingMessages)
      ..where((p) => p.chatId.equals(chatId))
      ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]))
        .get();
  }

  /// Get all pending messages across all chats
  Future<List<PendingMessage>> getAllPendingMessages() {
    return (select(pendingMessages)
      ..orderBy([(p) => OrderingTerm(expression: p.createdAt)]))
        .get();
  }

  /// Get pending messages ready for retry
  Future<List<PendingMessage>> getPendingMessagesForRetry() {
    return (select(pendingMessages)
      ..where((p) => p.retryCount.isSmallerThan(p.maxRetries))
      ..orderBy([(p) => OrderingTerm(expression: p.lastRetryAt)]))
        .get();
  }

  /// Insert new pending message
  Future<void> addPendingMessage(PendingMessagesCompanion message) async {
    await into(pendingMessages).insert(message);
  }

  /// Insert multiple pending messages
  Future<void> addPendingMessages(List<PendingMessagesCompanion> messages) async {
    await batch((batch) {
      batch.insertAll(pendingMessages, messages);
    });
  }

  /// Update retry count and last retry time
  Future<void> incrementRetryCount(String messageId) {
    return transaction(() async {
      final pending = await getPendingMessageById(messageId);
      if (pending != null) {
        final newRetryCount = pending.retryCount + 1;
        await (update(pendingMessages)
          ..where((p) => p.id.equals(messageId)))
            .write(PendingMessagesCompanion(
              retryCount: Value(newRetryCount),
              lastRetryAt: Value(DateTime.now()),
            ));
      }
    });
  }

  /// Update pending message payload
  Future<void> updatePendingMessagePayload(
    String messageId,
    String payload,
  ) {
    return (update(pendingMessages)
      ..where((p) => p.id.equals(messageId)))
        .write(PendingMessagesCompanion(
          payload: Value(payload),
        ));
  }

  /// Update pending message media path
  Future<void> updatePendingMessageMediaPath(
    String messageId,
    String localMediaPath,
  ) {
    return (update(pendingMessages)
      ..where((p) => p.id.equals(messageId)))
        .write(PendingMessagesCompanion(
          localMediaPath: Value(localMediaPath),
        ));
  }

  /// Remove pending message (after successful send)
  Future<int> removePendingMessage(String messageId) {
    return (delete(pendingMessages)
      ..where((p) => p.id.equals(messageId)))
        .go();
  }

  /// Remove pending messages for a chat
  Future<int> removePendingMessagesByChat(String chatId) {
    return (delete(pendingMessages)
      ..where((p) => p.chatId.equals(chatId)))
        .go();
  }

  /// Remove all pending messages (cleanup)
  Future<int> removeAllPendingMessages() {
    return delete(pendingMessages).go();
  }

  /// Get pending messages that exceeded max retries
  Future<List<PendingMessage>> getFailedMessages() async {
    return (select(pendingMessages)
      ..where((p) => p.retryCount.isBiggerOrEqual(p.maxRetries)))
        .get();
  }

  /// Count pending messages
  Future<int> countPendingMessages() async {
    final count = await customSelect(
      'SELECT COUNT(*) as count FROM pending_messages',
      readsFrom: {pendingMessages},
    ).map((row) => row.read<int>('count')).getSingle();
    return count;
  }

  /// Count pending messages for a chat
  Future<int> countPendingMessagesByChat(String chatId) async {
    final count = await customSelect(
      'SELECT COUNT(*) as count FROM pending_messages WHERE chat_id = ?',
      variables: [Variable.withString(chatId)],
      readsFrom: {pendingMessages},
    ).map((row) => row.read<int>('count')).getSingle();
    return count;
  }

  /// Check if message is pending
  Future<bool> isPendingMessage(String messageId) async {
    final pending = await getPendingMessageById(messageId);
    return pending != null;
  }

  /// Get pending messages statistics
  Future<Map<String, dynamic>> getPendingStats() async {
    final total = await countPendingMessages();
    final failedCount = await getFailedMessages().then((v) => v.length);
    
    final totalSize = await customSelect(
      'SELECT COALESCE(SUM(LENGTH(payload)), 0) as total FROM pending_messages',
      readsFrom: {pendingMessages},
    ).map((row) => row.read<int>('total')).getSingle();

    return {
      'total': total,
      'failed': failedCount,
      'totalSize': totalSize,
      'readyForRetry': total - failedCount,
    };
  }

  /// Clean up old pending messages (older than specified duration)
  Future<int> cleanupOldPendingMessages(Duration maxAge) {
    final cutoffDate = DateTime.now().subtract(maxAge);
    return (delete(pendingMessages)
      ..where((p) => p.createdAt.isSmallerThanValue(cutoffDate)))
        .go();
  }
}
