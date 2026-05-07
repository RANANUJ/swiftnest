import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StorageAndDataSettingScreen extends ConsumerStatefulWidget {
  const StorageAndDataSettingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StorageAndDataSettingScreen> createState() =>
      _StorageAndDataSettingScreenState();
}

class _StorageAndDataSettingScreenState
    extends ConsumerState<StorageAndDataSettingScreen> {
  bool _autoDownloadWifi = true;
  bool _autoDownloadMobileData = false;
  bool _darkSpeedMode = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);

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
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                'SwiftNest',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Storage Section
            _buildSectionTitle('NETWORK', isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Storage Used',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '1.6 GB',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.3,
                      minHeight: 6,
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        const Color(0xFF00BCD4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Cached Media
            _buildSectionTitle('STORAGE', isDark),
            _buildStorageItem(
              icon: Icons.image_outlined,
              title: 'Cached media and documents',
              size: '842 MB',
              isDark: isDark,
            ),

            // Auto Media Download
            _buildSectionTitle('AUTO-MEDIA DOWNLOAD', isDark),
            _buildStorageSetting(
              icon: Icons.wifi_outlined,
              title: 'When using Wi-Fi',
              value: _autoDownloadWifi,
              onChanged: (v) => setState(() => _autoDownloadWifi = v),
              isDark: isDark,
            ),
            _buildStorageSetting(
              icon: Icons.mobile_friendly_outlined,
              title: 'When using Media Data',
              value: _autoDownloadMobileData,
              onChanged: (v) => setState(() => _autoDownloadMobileData = v),
              isDark: isDark,
            ),

            // Efficiency & Privacy
            _buildSectionTitle('EFFICIENCY & PRIVACY', isDark),
            _buildStorageSetting(
              icon: Icons.speed_outlined,
              title: 'Dark Speed Mode',
              subtitle: 'Optimized for slow internet',
              value: _darkSpeedMode,
              onChanged: (v) => setState(() => _darkSpeedMode = v),
              isDark: isDark,
            ),
            _buildStorageItem(
              icon: Icons.security_outlined,
              title: 'Proxy Settings',
              size: '',
              isDark: isDark,
            ),

            // Data Privacy Banner
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFF00BCD4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your data is yours. Period.',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Every bit of data stored in your account is encrypted end-to-end. We don\'t have access to your conversations, media, or any personal information.',
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Learn More',
                        style: TextStyle(
                          color: const Color(0xFF00BCD4),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStorageItem({
    required IconData icon,
    required String title,
    required String size,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0088CC)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (size.isNotEmpty)
            Text(
              size,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 12,
              ),
            ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSetting({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0088CC)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: Container(
              width: 40,
              height: 24,
              decoration: BoxDecoration(
                color: value ? const Color(0xFF0088CC) : Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Align(
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
