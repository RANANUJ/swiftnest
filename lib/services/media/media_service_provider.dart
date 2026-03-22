import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'media_service.dart';
import '../network/api_client.dart';

/// Media service provider
/// Handles image/video uploads and downloads with caching
final mediaServiceProvider = FutureProvider<MediaService>((ref) async {
  final service = MediaService();
  await service.initialize();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// API Client provider (dependency)
final apiClientProvider = Provider<ApiClient>((ref) {
  // This should be provided from auth layer
  throw UnimplementedError('ApiClient provider must be implemented in auth layer');
});

/// Media download progress provider
final mediaDownloadProgressProvider =
    StateProvider<Map<String, (int, int)>>((ref) {
  return {}; // messageId -> (downloaded, total)
});

/// Media upload progress provider
final mediaUploadProgressProvider =
    StateProvider<Map<String, (int, int)>>((ref) {
  return {}; // messageId -> (uploaded, total)
});

/// Cache size provider
final cacheSizeProvider = FutureProvider<int>((ref) async {
  final mediaService = await ref.watch(mediaServiceProvider.future);
  return mediaService.getCacheSize();
});
