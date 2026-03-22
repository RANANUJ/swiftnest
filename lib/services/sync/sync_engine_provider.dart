import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'sync_engine.dart';
import '../database/providers.dart';
import '../socket/socket_io_provider.dart';

/// Sync Engine provider - manages offline message queue
final syncEngineProvider = FutureProvider<SyncEngine>((ref) async {
  final databaseService = await ref.watch(databaseServiceProvider.future);
  final socketIOService = await ref.watch(socketIOServiceProvider.future);

  final syncEngine = SyncEngine(
    databaseService: databaseService,
    socketIOService: socketIOService,
  );

  await syncEngine.initialize();

  ref.onDispose(() {
    syncEngine.dispose();
  });

  return syncEngine;
});

/// Pending message count provider
final pendingCountProvider = StateProvider<int>((ref) {
  return 0;
});

/// Sync status provider
final syncStatusProvider = StateProvider<SyncStatus>((ref) {
  return const SyncStatus(isSyncing: false, pendingCount: 0);
});

/// Sync status model
class SyncStatus {
  final bool isSyncing;
  final int pendingCount;
  final String? lastError;
  final DateTime? lastSyncTime;

  const SyncStatus({
    required this.isSyncing,
    required this.pendingCount,
    this.lastError,
    this.lastSyncTime,
  });

  @override
  String toString() =>
      'SyncStatus(isSyncing: $isSyncing, pending: $pendingCount, lastSync: $lastSyncTime)';
}
