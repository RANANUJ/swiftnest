import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'socket_io_service.dart';
import '../auth/token_storage.dart';
import '../database/drift_database.dart' show Message;

/// Socket.IO service provider
/// Manages real-time communication connection
final socketIOServiceProvider =
    FutureProvider<SocketIOService>((ref) async {
  final tokenStorage = ref.watch(tokenStorageProvider);
  final accessToken = await tokenStorage.getAccessToken();

  if (accessToken == null || accessToken.isEmpty) {
    throw Exception('No access token available for Socket.IO connection');
  }

  // Get user ID from token or another source
  // For now, we'll use a placeholder - integrate with auth provider
  const userId = 'current_user_id';

  final service = SocketIOService(
    userId: userId,
    accessToken: accessToken,
  );

  await service.connect();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Token storage provider (dependency)
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

/// Socket connection state provider
final socketConnectionStateProvider = StateProvider<bool>((ref) {
  return false;
});

/// User typing state - tracks which users are typing in which chats
final userTypingStateProvider = StateProvider<Map<String, Set<String>>>((ref) {
  return {}; // chatId -> Set of userIds typing
});

/// Last received message provider
final lastMessageProvider = StateProvider<Message?>(
  (ref) => null,
);
