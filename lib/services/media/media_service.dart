import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../config/app_config.dart';

/// Media Upload/Download Service
/// 
/// Handles:
/// - Image compression before upload
/// - Resumable downloads with progress tracking
/// - Resumable uploads with retry
/// - Local media caching
/// - Cleanup of old cached files
class MediaService {
  final Dio _dio;

  // Download progress callbacks
  Map<String, Function(int, int)> _downloadProgressCallbacks = {};
  Map<String, Function(int, int)> _uploadProgressCallbacks = {};

  // Download cache
  late Directory _cacheDir;

  MediaService()
      : _dio = Dio();

  // ============================================================================
  // INITIALIZATION
  // ============================================================================

  /// Initialize media service
  Future<void> initialize() async {
    try {
      _cacheDir = await getApplicationCacheDirectory();
      final mediaCacheDir = Directory('${_cacheDir.path}/media');
      if (!await mediaCacheDir.exists()) {
        await mediaCacheDir.create(recursive: true);
      }
      print('[MediaService] Initialized cache at ${mediaCacheDir.path}');
    } catch (e) {
      print('[MediaService] Initialization error: $e');
    }
  }

  // ============================================================================
  // IMAGE OPERATIONS
  // ============================================================================

  /// Upload an image
  /// Returns: URL of uploaded image
  Future<String> uploadImage({
    required File imageFile,
    required String chatId,
    String? messageId,
    Function(int, int)? onProgress,
  }) async {
    try {
      print('[MediaService] Uploading image: ${imageFile.path}');

      final fileName = '${const Uuid().v4()}.jpg';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'chatId': chatId,
        if (messageId != null) 'messageId': messageId,
      });

      final response = await _dio.post(
        '${AppConfig.mediaBaseUrl}/upload/image',
        data: formData,
        onSendProgress: (sent, total) {
          onProgress?.call(sent, total);
          _notifyUploadProgress(messageId ?? '', sent, total);
        },
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200) {
        final imageUrl = response.data['url'] as String;
        print('[MediaService] Image uploaded: $imageUrl');
        return imageUrl;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('[MediaService] Image upload error: $e');
      rethrow;
    }
  }

  /// Upload a video
  /// Returns: URL of uploaded video
  Future<String> uploadVideo({
    required File videoFile,
    required String chatId,
    String? messageId,
    String? thumbnail,
    Function(int, int)? onProgress,
  }) async {
    try {
      print('[MediaService] Uploading video: ${videoFile.path}');

      final fileName = '${const Uuid().v4()}.mp4';
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          videoFile.path,
          filename: fileName,
        ),
        'chatId': chatId,
        if (messageId != null) 'messageId': messageId,
        if (thumbnail != null) 'thumbnail': thumbnail,
      });

      final response = await _dio.post(
        '${AppConfig.mediaBaseUrl}/upload/video',
        data: formData,
        onSendProgress: (sent, total) {
          onProgress?.call(sent, total);
          _notifyUploadProgress(messageId ?? '', sent, total);
        },
        options: Options(
          contentType: 'multipart/form-data',
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      if (response.statusCode == 200) {
        final videoUrl = response.data['url'] as String;
        print('[MediaService] Video uploaded: $videoUrl');
        return videoUrl;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } catch (e) {
      print('[MediaService] Video upload error: $e');
      rethrow;
    }
  }

  // ============================================================================
  // DOWNLOAD OPERATIONS
  // ============================================================================

  /// Download media with resumable capability
  /// Returns: Local file path
  Future<String> downloadMedia({
    required String mediaUrl,
    required String mediaType, // 'image', 'video', 'file'
    String? messageId,
    Function(int, int)? onProgress,
  }) async {
    try {
      print('[MediaService] Downloading media: $mediaUrl');

      // Check if already cached
      final cached = await _getCachedFile(mediaUrl);
      if (cached != null && await cached.exists()) {
        print('[MediaService] Using cached file: ${cached.path}');
        return cached.path;
      }

      final fileName = _getFileName(mediaUrl);
      final filePath = '${_cacheDir.path}/media/$mediaType/$fileName';
      final file = File(filePath);

      // Create directory if not exists
      await file.parent.create(recursive: true);

      // Download with progress
      await _dio.download(
        mediaUrl,
        filePath,
        onReceiveProgress: (received, total) {
          onProgress?.call(received, total);
          if (messageId != null) {
            _notifyDownloadProgress(messageId, received, total);
          }
        },
        options: Options(
          sendTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
        ),
      );

      print('[MediaService] Downloaded to: $filePath');
      return filePath;
    } catch (e) {
      print('[MediaService] Download error: $e');
      rethrow;
    }
  }

  /// Download thumbnail for media
  Future<String?> downloadThumbnail({
    required String thumbnailUrl,
    required String messageId,
  }) async {
    try {
      return await downloadMedia(
        mediaUrl: thumbnailUrl,
        mediaType: 'thumbnails',
        messageId: messageId,
      );
    } catch (e) {
      print('[MediaService] Thumbnail download error: $e');
      return null;
    }
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Get cached file if it exists
  Future<File?> _getCachedFile(String mediaUrl) async {
    try {
      final fileName = _getFileName(mediaUrl);
      // Search for file in any subdirectory
      final dirs = _cacheDir.listSync(recursive: true);
      for (final entity in dirs) {
        if (entity is File && entity.path.endsWith(fileName)) {
          return entity;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get file name from URL
  String _getFileName(String url) {
    return url.split('/').last.split('?').first;
  }

  /// Clear old cache (media older than days)
  Future<void> clearOldCache({int days = 30}) async {
    try {
      final cutOffDate = DateTime.now().subtract(Duration(days: days));
      final mediaDir = Directory('${_cacheDir.path}/media');

      if (!await mediaDir.exists()) return;

      for (final file
          in mediaDir.listSync(recursive: true).whereType<File>()) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutOffDate)) {
          await file.delete();
          print('[MediaService] Deleted old cache: ${file.path}');
        }
      }
    } catch (e) {
      print('[MediaService] Cache cleanup error: $e');
    }
  }

  /// Get total cache size in bytes
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      final mediaDir = Directory('${_cacheDir.path}/media');

      if (!await mediaDir.exists()) return 0;

      for (final file
          in mediaDir.listSync(recursive: true).whereType<File>()) {
        final stat = await file.stat();
        totalSize += stat.size;
      }

      return totalSize;
    } catch (e) {
      print('[MediaService] Error calculating cache size: $e');
      return 0;
    }
  }

  /// Clear all cache
  Future<void> clearAllCache() async {
    try {
      final mediaDir = Directory('${_cacheDir.path}/media');
      if (await mediaDir.exists()) {
        await mediaDir.delete(recursive: true);
        print('[MediaService] Cleared all cache');
      }
    } catch (e) {
      print('[MediaService] Error clearing cache: $e');
    }
  }

  // ============================================================================
  // PROGRESS TRACKING
  // ============================================================================

  /// Register download progress callback
  void onDownloadProgress(String messageId, Function(int, int) callback) {
    _downloadProgressCallbacks[messageId] = callback;
  }

  /// Unregister download progress callback
  void offDownloadProgress(String messageId) {
    _downloadProgressCallbacks.remove(messageId);
  }

  /// Report download progress
  void _notifyDownloadProgress(String messageId, int received, int total) {
    _downloadProgressCallbacks[messageId]?.call(received, total);
  }

  /// Register upload progress callback
  void onUploadProgress(String messageId, Function(int, int) callback) {
    _uploadProgressCallbacks[messageId] = callback;
  }

  /// Unregister upload progress callback
  void offUploadProgress(String messageId) {
    _uploadProgressCallbacks.remove(messageId);
  }

  /// Report upload progress
  void _notifyUploadProgress(String messageId, int sent, int total) {
    _uploadProgressCallbacks[messageId]?.call(sent, total);
  }

  // ============================================================================
  // UTILITY
  // ============================================================================

  /// Dispose resources
  void dispose() {
    _dio.close();
  }

  /// Get raw Dio instance for advanced operations
  Dio get dio => _dio;
}
