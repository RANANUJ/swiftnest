import 'package:drift/drift.dart';
import '../drift_database.dart';
part 'downloaded_media_dao.g.dart';

/// Data Access Object for DownloadedMedia table
/// Handles cached media files and their metadata
@DriftAccessor(tables: [DownloadedMedia])
class DownloadedMediaDao extends DatabaseAccessor<SwiftNestDatabase>
    with _$DownloadedMediaDaoMixin {
  DownloadedMediaDao(SwiftNestDatabase db) : super(db);

  /// Get downloaded media by ID
  Future<DownloadedMediaData?> getMediaById(String id) {
    return (select(downloadedMedia)
      ..where((d) => d.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get downloaded media by URL
  Future<DownloadedMediaData?> getMediaByUrl(String url) {
    return (select(downloadedMedia)
      ..where((d) => d.url.equals(url)))
        .getSingleOrNull();
  }

  /// Get downloaded media by local path
  Future<DownloadedMediaData?> getMediaByLocalPath(String localPath) {
    return (select(downloadedMedia)
      ..where((d) => d.localPath.equals(localPath)))
        .getSingleOrNull();
  }

  /// Get all complete downloads
  Future<List<DownloadedMediaData>> getCompleteDownloads() {
    return (select(downloadedMedia)
      ..where((d) => d.isComplete.equals(true))
      ..orderBy([(d) => OrderingTerm(expression: d.downloadedAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get incomplete downloads (in progress)
  Future<List<DownloadedMediaData>> getIncompleteDownloads() {
    return (select(downloadedMedia)
      ..where((d) => d.isComplete.equals(false))
      ..orderBy([(d) => OrderingTerm(expression: d.downloadedAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get media for a message
  Future<DownloadedMediaData?> getMediaForMessage(String messageId) {
    return (select(downloadedMedia)
      ..where((d) => d.messageId.equals(messageId)))
        .getSingleOrNull();
  }

  /// Get media by type
  Future<List<DownloadedMediaData>> getMediaByType(String mediaType) {
    return (select(downloadedMedia)
      ..where((d) => d.mediaType.equals(mediaType))
      ..orderBy([(d) => OrderingTerm(expression: d.downloadedAt, mode: OrderingMode.desc)]))
        .get();
  }

  /// Get recently accessed media
  Future<List<DownloadedMediaData>> getRecentlyAccessedMedia({
    int limit = 20,
  }) {
    return (select(downloadedMedia)
      ..orderBy([(d) => OrderingTerm(expression: d.lastAccessedAt, mode: OrderingMode.desc)])
      ..limit(limit))
        .get();
  }

  /// Insert or update media record
  Future<void> upsertMedia(DownloadedMediaCompanion media) async {
    await into(downloadedMedia).insert(media, mode: InsertMode.insertOrReplace);
  }

  /// Update download progress
  Future<void> updateDownloadProgress(
    String id,
    int progress, {
    bool isComplete = false,
  }) {
    return (update(downloadedMedia)
      ..where((d) => d.id.equals(id)))
        .write(DownloadedMediaCompanion(
          downloadProgress: Value(progress),
          isComplete: Value(isComplete),
          downloadedAt: isComplete ? Value(DateTime.now()) : const Value.absent(),
        ));
  }

  /// Mark download as complete
  Future<void> markDownloadComplete(String id) {
    return (update(downloadedMedia)
      ..where((d) => d.id.equals(id)))
        .write(DownloadedMediaCompanion(
          isComplete: Value(true),
          downloadProgress: Value(100),
          downloadedAt: Value(DateTime.now()),
        ));
  }

  /// Update last accessed time
  Future<void> updateLastAccessed(String id) {
    return (update(downloadedMedia)
      ..where((d) => d.id.equals(id)))
        .write(DownloadedMediaCompanion(
          lastAccessedAt: Value(DateTime.now()),
        ));
  }

  /// Set expiration date for media
  Future<void> setExpirationDate(String id, DateTime expiresAt) {
    return (update(downloadedMedia)
      ..where((d) => d.id.equals(id)))
        .write(DownloadedMediaCompanion(
          expiresAt: Value(expiresAt),
        ));
  }

  /// Delete media record
  Future<int> deleteMedia(String id) {
    return (delete(downloadedMedia)
      ..where((d) => d.id.equals(id)))
        .go();
  }

  /// Delete expired media
  Future<int> deleteExpiredMedia() {
    final now = DateTime.now();
    return (delete(downloadedMedia)
      ..where((d) => d.expiresAt.isSmallerThanValue(now)))
        .go();
  }

  /// Delete media by URL (cleanup)
  Future<int> deleteMediaByUrl(String url) {
    return (delete(downloadedMedia)
      ..where((d) => d.url.equals(url)))
        .go();
  }

  /// Delete all media of a type
  Future<int> deleteMediaByType(String mediaType) {
    return (delete(downloadedMedia)
      ..where((d) => d.mediaType.equals(mediaType)))
        .go();
  }

  /// Count total downloaded files
  Future<int> countDownloadedMedia() async {
    final count = await customSelect(
      'SELECT COUNT(*) as count FROM downloaded_media WHERE is_complete = 1',
      readsFrom: {downloadedMedia},
    ).map((row) => row.read<int>('count')).getSingle();
    return count;
  }

  /// Get total size of all cached media
  Future<int> getTotalCacheSize() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(size), 0) as total FROM downloaded_media WHERE is_complete = 1',
      readsFrom: {downloadedMedia},
    ).map((row) => row.read<int>('total')).getSingleOrNull();
    return result ?? 0;
  }

  /// Get cache size by media type
  Future<Map<String, int>> getCacheSizeByType() async {
    final results = await customSelect(
      'SELECT media_type, COALESCE(SUM(size), 0) as total FROM downloaded_media WHERE is_complete = 1 GROUP BY media_type',
      readsFrom: {downloadedMedia},
    ).get();

    final map = <String, int>{};
    for (final row in results) {
      final type = row.read<String>('media_type');
      final size = row.read<int>('total');
      map[type] = size;
    }
    return map;
  }

  /// Clean up old media (older than maxAge)
  Future<int> cleanupOldMedia(Duration maxAge) {
    final cutoffDate = DateTime.now().subtract(maxAge);
    return (delete(downloadedMedia)
      ..where((d) => d.lastAccessedAt.isSmallerThanValue(cutoffDate)))
        .go();
  }

  /// Clean up to target cache size (keep newest files)
  Future<int> cleanupToTargetSize(int targetSizeBytes) async {
    final totalSize = await getTotalCacheSize();

    if (totalSize <= targetSizeBytes) {
      return 0;
    }

    // Get all media ordered by last accessed (oldest first)
    final allMedia = await (select(downloadedMedia)
      ..where((d) => d.isComplete.equals(true))
      ..orderBy([(d) => OrderingTerm(expression: d.lastAccessedAt)]))
        .get();

    var currentSize = totalSize;
    var deletedCount = 0;

    for (final media in allMedia) {
      if (currentSize <= targetSizeBytes) break;

      currentSize -= media.size;
      await deleteMedia(media.id);
      deletedCount++;
    }

    return deletedCount;
  }

  /// Get media statistics
  Future<Map<String, dynamic>> getMediaStats() async {
    final total = await countDownloadedMedia();
    final totalSize = await getTotalCacheSize();
    final cacheByType = await getCacheSizeByType();

    final incomplete = await (select(downloadedMedia)
      ..where((d) => d.isComplete.equals(false)))
        .get()
        .then((v) => v.length);

    return {
      'total': total,
      'totalSize': totalSize,
      'incomplete': incomplete,
      'byType': cacheByType,
    };
  }

  /// Find potentially duplicate media (same URL)
  Future<List<DownloadedMediaData>> findDuplicates() async {
    final duplicateUrls = await customSelect(
      'SELECT url FROM downloaded_media GROUP BY url HAVING COUNT(*) > 1',
      readsFrom: {downloadedMedia},
    ).map((row) => row.read<String>('url')).get();

    if (duplicateUrls.isEmpty) return [];

    return (select(downloadedMedia)..where((d) => d.url.isIn(duplicateUrls)))
        .get();
  }

  /// Check if media is cached
  Future<bool> isCached(String url) async {
    final media = await getMediaByUrl(url);
    return media != null && media.isComplete;
  }
}
