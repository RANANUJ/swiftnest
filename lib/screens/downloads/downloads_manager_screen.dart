import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_config.dart';

/// Downloads Manager Screen - Manage downloaded files and vault storage
class DownloadsManagerScreen extends ConsumerStatefulWidget {
  const DownloadsManagerScreen({super.key});

  @override
  ConsumerState<DownloadsManagerScreen> createState() =>
      _DownloadsManagerScreenState();
}

class _DownloadsManagerScreenState extends ConsumerState<DownloadsManagerScreen> {
  int _selectedTab = 0; // 0: All, 1: Images, 2: Videos, 3: Files

  final List<DownloadItem> recentDownloads = [
    DownloadItem(
      name: 'Design_System_Final.zip',
      size: '24 MB',
      timestamp: '3 ago',
      icon: '📦',
      category: 'files',
      isEncrypted: true,
    ),
    DownloadItem(
      name: 'Presentation_Draft_V2.pptx',
      size: '12 MB',
      timestamp: 'Today 9:15 AM',
      icon: '📊',
      category: 'files',
      isEncrypted: true,
    ),
    DownloadItem(
      name: 'API_Documentation.pdf',
      size: '8 MB',
      timestamp: 'Yesterday',
      icon: '📄',
      category: 'files',
      isEncrypted: true,
    ),
    DownloadItem(
      name: 'Podcast_S04E12.mp3',
      size: '52 MB',
      timestamp: 'Oct 12',
      icon: '🎵',
      category: 'audio',
      isEncrypted: true,
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
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.shield,
                size: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppConfig.appName,
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: primaryColor),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vault Storage Section
            Padding(
              padding: const EdgeInsets.all(24),
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
                            'Vault Storage',
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '65.3 GB used of 128 GB',
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'ENCRYPTED',
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Storage Progress Bar
                  Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: inputFillColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        height: 8,
                        width: MediaQuery.of(context).size.width * 0.51,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Free 8.2 GB',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: secondaryTextColor,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),

            // Category Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryTab('ALL', 0, isDark, accentColor, primaryColor,
                      inputFillColor),
                  _buildCategoryTab('Images', 1, isDark, accentColor, primaryColor,
                      inputFillColor),
                  _buildCategoryTab('Videos', 2, isDark, accentColor, primaryColor,
                      inputFillColor),
                  _buildCategoryTab('Files', 3, isDark, accentColor, primaryColor,
                      inputFillColor),
                ],
              ),
            ),

            // Recent Downloads Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                'RECENT DOWNLOADS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),
            ),

            // Downloads List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentDownloads.length,
              itemBuilder: (context, index) {
                final download = recentDownloads[index];
                return _buildDownloadItem(
                  download: download,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                  inputFillColor: inputFillColor,
                  secondaryTextColor: secondaryTextColor,
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(
        isDark: isDark,
        primaryColor: primaryColor,
        accentColor: accentColor,
        backgroundColor: isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5),
      ),
    );
  }

  Widget _buildCategoryTab(String label, int index, bool isDark,
      Color accentColor, Color primaryColor, Color inputFillColor) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
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
                  fontSize: 12,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildDownloadItem({
    required DownloadItem download,
    required bool isDark,
    required Color primaryColor,
    required Color accentColor,
    required Color inputFillColor,
    required Color secondaryTextColor,
  }) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'media-viewer',
          extra: {
            'fileName': download.name,
            'fileSize': download.size,
            'timestamp': download.timestamp,
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: inputFillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.2),
              ),
              child: Center(
                child: Text(
                  download.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // File info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    download.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    download.size,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    download.timestamp,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: secondaryTextColor,
                          fontSize: 10,
                        ),
                  ),
                ],
              ),
            ),

            if (download.isEncrypted)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.lock,
                  color: accentColor,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav({
    required bool isDark,
    required Color primaryColor,
    required Color accentColor,
    required Color backgroundColor,
  }) {
    final items = [
      ('CHATS', Icons.message),
      ('CALLS', Icons.call),
      ('DOWNLOADS', Icons.download),
      ('VAULT', Icons.lock),
      ('PROFILE', Icons.person),
    ];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) {
                final (label, icon) = items[index];
                final isSelected = index == 2; // Downloads tab

                return GestureDetector(
                  onTap: () {},
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? accentColor : primaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected ? accentColor : primaryColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class DownloadItem {
  final String name;
  final String size;
  final String timestamp;
  final String icon;
  final String category;
  final bool isEncrypted;

  DownloadItem({
    required this.name,
    required this.size,
    required this.timestamp,
    required this.icon,
    required this.category,
    required this.isEncrypted,
  });
}
