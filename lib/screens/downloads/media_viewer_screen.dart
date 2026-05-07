import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';

/// Media Viewer Screen - View and manage media files with encryption info
class MediaViewerScreen extends ConsumerStatefulWidget {
  final String? fileName;
  final String? fileSize;
  final String? timestamp;

  const MediaViewerScreen({
    super.key,
    this.fileName,
    this.fileSize,
    this.timestamp,
  });

  @override
  ConsumerState<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends ConsumerState<MediaViewerScreen> {
  int _selectedCategory = 0; // 0: Images, 1: Videos, 2: Documents
  bool _isFavorited = false;

  final List<MediaItem> mediaItems = [
    MediaItem(
      name: 'Architecture Building',
      resolution: '4000 x 3000',
      size: '16.2 MB',
      date: 'Jan 15, 2023',
      type: 'image',
    ),
    MediaItem(
      name: 'Conference Recording',
      resolution: '1920 x 1080',
      size: '245 MB',
      date: 'Jan 10, 2023',
      type: 'video',
    ),
    MediaItem(
      name: 'Project Proposal',
      resolution: 'N/A',
      size: '8.4 MB',
      date: 'Jan 8, 2023',
      type: 'document',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);
    const accentColor = Color(0xFF00BCD4);
    final backgroundColor = isDark ? const Color(0xFF1A2332) : Colors.white;
    final inputFillColor =
        isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5);
    final secondaryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.6)
        : const Color(0xFF1A2332).withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.2),
              ),
              child: Icon(
                Icons.shield,
                size: 14,
                color: accentColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppConfig.appName,
              style: TextStyle(
                color: primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorited ? Icons.favorite : Icons.favorite_outline,
              color: _isFavorited ? Colors.red : primaryColor,
            ),
            onPressed: () {
              setState(() => _isFavorited = !_isFavorited);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(_isFavorited
                        ? 'Added to favorites'
                        : 'Removed from favorites')),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: primaryColor),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share via encrypted link')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encryption Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: accentColor.withValues(alpha: 0.1),
              child: Center(
                child: Text(
                  'DOUBLE TAP TO DECRYPT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            // Media Display
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: inputFillColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Placeholder image
                      Container(
                        height: 300,
                        color: inputFillColor,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image,
                                size: 64,
                                color: primaryColor.withValues(
                                    alpha: 0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Media Content',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Playback/Navigation buttons
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Previous media')),
                              );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor.withValues(
                                    alpha: 0.9),
                              ),
                              child: const Icon(
                                Icons.chevron_left,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Next media')),
                              );
                            },
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: accentColor.withValues(
                                    alpha: 0.9),
                              ),
                              child: const Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Media Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '4000 x 3000',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '16.2 MB',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: secondaryTextColor,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Jan 15, 2023',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'MODIFICATION',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: secondaryTextColor,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Category Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTabButton('IMAGES', 0, isDark, accentColor,
                      primaryColor, inputFillColor),
                  _buildTabButton('VIDEOS', 1, isDark, accentColor,
                      primaryColor, inputFillColor),
                  _buildTabButton('DOCUMENTS', 2, isDark, accentColor,
                      primaryColor, inputFillColor),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Media disabled')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE74C3C),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'DISABLED',
                            style: TextStyle(
                              color: const Color(0xFFE74C3C),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Media deleted')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE74C3C),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'DELETED',
                            style: TextStyle(
                              color: const Color(0xFFE74C3C),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, int index, bool isDark,
      Color accentColor, Color primaryColor, Color inputFillColor) {
    final isSelected = _selectedCategory == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.2) : inputFillColor,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: accentColor, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected ? accentColor : primaryColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
        ),
      ),
    );
  }
}

class MediaItem {
  final String name;
  final String resolution;
  final String size;
  final String date;
  final String type;

  MediaItem({
    required this.name,
    required this.resolution,
    required this.size,
    required this.date,
    required this.type,
  });
}
