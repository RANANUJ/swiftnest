import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatSettingScreen extends ConsumerStatefulWidget {
  const ChatSettingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatSettingScreen> createState() => _ChatSettingScreenState();
}

class _ChatSettingScreenState extends ConsumerState<ChatSettingScreen> {
  int _appearance = 0; // 0: Light, 1: Dark, 2: System
  double _fontSize = 1.0;
  bool _autoDownloadPhotos = true;
  bool _autoDownloadVideos = false;
  bool _autoDownloadDocs = true;

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
          Icon(
            Icons.verified,
            color: const Color(0xFF00BCD4),
            size: 20,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Appearance Section
            _buildSectionTitle('Appearance', isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _buildAppearanceOption('Light', 0, isDark),
                  const SizedBox(height: 8),
                  _buildAppearanceOption('Dark', 1, isDark),
                  const SizedBox(height: 8),
                  _buildAppearanceOption('System', 2, isDark),
                ],
              ),
            ),

            // Wallpaper Section
            _buildSectionTitle('Wallpaper', isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 20,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nature Material',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Change your chat wallpaper',
                          style: TextStyle(
                            color:
                                isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Font Size Section
            _buildSectionTitle('Font Size', isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(
                    'A',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Slider(
                      value: _fontSize,
                      onChanged: (value) => setState(() => _fontSize = value),
                      min: 0.8,
                      max: 1.4,
                      activeColor: primaryColor,
                      inactiveColor: primaryColor.withOpacity(0.2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'A',
                    style: TextStyle(
                      color: isDark ? Colors.grey[200] : Colors.grey[800],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // Media Auto-Download Section
            _buildSectionTitle('Media Auto-Download', isDark),
            _buildToggleSetting(
              icon: Icons.image_outlined,
              title: 'Photos & Videos',
              value: _autoDownloadPhotos,
              onChanged: (value) =>
                  setState(() => _autoDownloadPhotos = value),
              isDark: isDark,
            ),
            _buildToggleSetting(
              icon: Icons.videocam_outlined,
              title: 'Video Content',
              value: _autoDownloadVideos,
              onChanged: (value) =>
                  setState(() => _autoDownloadVideos = value),
              isDark: isDark,
            ),
            _buildToggleSetting(
              icon: Icons.description_outlined,
              title: 'Documents & Files',
              value: _autoDownloadDocs,
              onChanged: (value) => setState(() => _autoDownloadDocs = value),
              isDark: isDark,
            ),

            // Chat Backup Section
            _buildSectionTitle('Security & Privacy', isDark),
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
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          size: 20,
                          color: const Color(0xFF00BCD4),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Chat Backup',
                          style: TextStyle(
                            color: const Color(0xFF00BCD4),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Securely back up your chats and view them from other devices.',
                      style: TextStyle(
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00BCD4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Back Up Now',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceOption(String label, int value, bool isDark) {
    final isSelected = _appearance == value;
    return GestureDetector(
      onTap: () => setState(() => _appearance = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252F3F) : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0088CC)
                : (isDark ? Colors.grey[800]! : Colors.grey[200]!),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF0088CC),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF0088CC),
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleSetting({
    required IconData icon,
    required String title,
    required bool value,
    required Function(bool) onChanged,
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
