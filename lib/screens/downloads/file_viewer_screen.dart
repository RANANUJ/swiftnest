import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_config.dart';

/// File Viewer Screen - View and manage encrypted files with auto-destruct
class FileViewerScreen extends ConsumerStatefulWidget {
  final String? fileName;
  final String? fileSize;

  const FileViewerScreen({
    super.key,
    this.fileName,
    this.fileSize,
  });

  @override
  ConsumerState<FileViewerScreen> createState() => _FileViewerScreenState();
}

class _FileViewerScreenState extends ConsumerState<FileViewerScreen> {
  bool _autoDestructEnabled = false;
  int _autoDestructDays = 7;
  int _selectedTab = 0; // 0: All, 1: Images, 2: Videos, 3: Documents

  final List<FileItem> availableFiles = [
    FileItem(
      name: 'Editorial...',
      status: 'INCOMPLETE',
      size: '8.2 MB',
      date: 'Jan 15',
      icon: '📄',
    ),
    FileItem(
      name: 'Security...',
      status: 'INCOMPLETE',
      size: '14.5 MB',
      date: 'Jan 12',
      icon: '🔐',
    ),
    FileItem(
      name: 'Encryption...',
      status: 'INCOMPLETE',
      size: '25.1 MB',
      date: 'Jan 10',
      icon: '🗝️',
    ),
    FileItem(
      name: 'Voice_M...',
      status: 'INCOMPLETE',
      size: '12.8 MB',
      date: 'Jan 8',
      icon: '🎵',
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
            icon: Icon(Icons.more_vert, color: primaryColor),
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
                            '124.4 GB of 512 MB storage used',
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
                        width: MediaQuery.of(context).size.width * 0.75,
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Auto-Destruct Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto-Destruct',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: inputFillColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Auto delete old files',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Files older than ${_autoDestructDays} days will be automatically deleted',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: secondaryTextColor,
                                          fontSize: 11,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _autoDestructEnabled,
                              onChanged: (value) {
                                setState(
                                    () => _autoDestructEnabled = value);
                              },
                              activeColor: accentColor,
                            ),
                          ],
                        ),
                        if (_autoDestructEnabled)
                          Column(
                            children: [
                              const SizedBox(height: 12),
                              Divider(
                                color:
                                    primaryColor.withValues(alpha: 0.1),
                                height: 1,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Days until auto-delete:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: accentColor
                                          .withValues(alpha: 0.15),
                                      borderRadius:
                                          BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$_autoDestructDays days',
                                      style: TextStyle(
                                        color: accentColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Auto-destruct settings saved')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Configure',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Category Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryTab('ALL', 0, isDark, accentColor, primaryColor,
                      inputFillColor),
                  _buildCategoryTab('IMAGES', 1, isDark, accentColor, primaryColor,
                      inputFillColor),
                  _buildCategoryTab('VIDEOS', 2, isDark, accentColor, primaryColor,
                      inputFillColor),
                  _buildCategoryTab('DOCUMENTS', 3, isDark, accentColor,
                      primaryColor, inputFillColor),
                ],
              ),
            ),

            // Available Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'AVAILABLE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: secondaryTextColor,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),
            ),

            // Files List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: availableFiles.length,
              itemBuilder: (context, index) {
                final file = availableFiles[index];
                return _buildFileItem(
                  file: file,
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
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? accentColor.withValues(alpha: 0.2) : inputFillColor,
            borderRadius: BorderRadius.circular(6),
            border: isSelected
                ? Border.all(color: accentColor, width: 1)
                : null,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isSelected ? accentColor : primaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem({
    required FileItem file,
    required bool isDark,
    required Color primaryColor,
    required Color accentColor,
    required Color inputFillColor,
    required Color secondaryTextColor,
  }) {
    return GestureDetector(
      onTap: () {},
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
                  file.icon,
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
                    file.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C)
                              .withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          file.status,
                          style: TextStyle(
                            color: const Color(0xFFE74C3C),
                            fontWeight: FontWeight.w600,
                            fontSize: 9,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${file.size} • ${file.date}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                              color: secondaryTextColor,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action button
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File options opened')),
                );
              },
              child: Icon(
                Icons.more_vert,
                color: secondaryTextColor,
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
                final isSelected = index == 3; // Vault tab

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

class FileItem {
  final String name;
  final String status;
  final String size;
  final String date;
  final String icon;

  FileItem({
    required this.name,
    required this.status,
    required this.size,
    required this.date,
    required this.icon,
  });
}
