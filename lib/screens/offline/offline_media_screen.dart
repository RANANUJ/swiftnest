import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineMediaScreen extends ConsumerStatefulWidget {
  const OfflineMediaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<OfflineMediaScreen> createState() => _OfflineMediaScreenState();
}

class _OfflineMediaScreenState extends ConsumerState<OfflineMediaScreen> {
  String _selectedTab = 'Media';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = const Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1F2E) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF252F3F) : Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        title: Text(
          'SwiftNest',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Icon(
            Icons.downloading_outlined,
            color: accentColor,
            size: 20,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withOpacity(0.15),
                    ),
                    child: Icon(
                      Icons.storage,
                      size: 30,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Offline Media',
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your encrypted assets are cached and available for playback without a network connection.',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Storage Capacity Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF252F3F) : Colors.white,
                  border: Border.all(
                    color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'STORAGE CAPACITY',
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          '52.4 GB / 148.09 GB',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.35,
                        minHeight: 8,
                        backgroundColor: isDark
                            ? Colors.grey[800]
                            : Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'History grade 300-user encryption online',
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tab Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildTab('Media', isDark),
                  const SizedBox(width: 16),
                  _buildTab('Documents', isDark),
                  const SizedBox(width: 16),
                  _buildTab('Voice Notes', isDark),
                ],
              ),
            ),

            // Media Grid
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // First Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildMediaItem(
                              isDark,
                              title: 'Q3 Security Strategy Deep Dive',
                              isVideo: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMediaItem(
                              isDark,
                              title: 'System-wide Architecture Overview',
                              isImage: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Second Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildMediaItem(
                              isDark,
                              title: 'Cryptography Deep Dive',
                              isImage: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildMediaItem(
                              isDark,
                              title: 'Network Infrastructure Security',
                              isImage: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Third Row - Partial
                      Row(
                        children: [
                          Expanded(
                            child: _buildMediaItem(
                              isDark,
                              title: 'Quantum-safe Algorithms',
                              isImage: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: const SizedBox()),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isDark) {
    final isSelected = _selectedTab == label;
    final primaryColor = const Color(0xFF0088CC);

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : (isDark ? Colors.grey[400] : Colors.grey[600]),
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 8),
          if (isSelected)
            Container(
              height: 2,
              width: 20,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(
    bool isDark, {
    String title = 'Media Item',
    bool isImage = false,
    bool isVideo = false,
  }) {
    final accentColor = const Color(0xFF00BCD4);
    final primaryColor = const Color(0xFF0088CC);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
              ),
            ),
            child: Stack(
            alignment: Alignment.center,
            children: [
              // Background gradient (simulating image)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor.withOpacity(0.3),
                      accentColor.withOpacity(0.3),
                    ],
                  ),
                ),
              ),

              // Center Icon
              Icon(
                isVideo
                    ? Icons.play_circle_filled
                    : Icons.image_outlined,
                size: 32,
                color: accentColor,
              ),

              // Bottom decoration - Encryption badge
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.lock,
                        size: 8,
                        color: Colors.white,
                      ),
                      SizedBox(width: 2),
                      Text(
                        'ENCRYPTED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}
