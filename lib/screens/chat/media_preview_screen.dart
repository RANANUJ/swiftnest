import 'package:flutter/material.dart';

class MediaPreviewScreen extends StatefulWidget {
  final String mediaType; // 'image', 'video'
  final String? mediaPath;

  const MediaPreviewScreen({
    super.key,
    required this.mediaType,
    this.mediaPath,
  });

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  late TextEditingController _captionController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentCyan = Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121A2A) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF1A2332) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.mediaType == 'video' ? 'Video' : 'Photo',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Media Preview Area
            Container(
              height: 300,
              color: Colors.black,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Media placeholder
                  Container(
                    color: Colors.black87,
                    child: Center(
                      child: Icon(
                        widget.mediaType == 'video'
                            ? Icons.videocam
                            : Icons.image,
                        size: 64,
                        color: Colors.white30,
                      ),
                    ),
                  ),

                  // Editing Toolbar
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white10,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildEditButton(
                            icon: Icons.close,
                            onTap: () {},
                            isDark: isDark,
                          ),
                          SizedBox(width: 12),
                          _buildEditButton(
                            icon: Icons.crop,
                            onTap: () {},
                            isDark: isDark,
                          ),
                          SizedBox(width: 12),
                          _buildEditButton(
                            icon: Icons.text_fields,
                            onTap: () {},
                            isDark: isDark,
                          ),
                          SizedBox(width: 12),
                          _buildEditButton(
                            icon: Icons.draw,
                            onTap: () {},
                            isDark: isDark,
                          ),
                          SizedBox(width: 12),
                          _buildEditButton(
                            icon: Icons.emoji_emotions,
                            onTap: () {},
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Play button (if video)
                  if (widget.mediaType == 'video')
                    GestureDetector(
                      onTap: () {
                        setState(() => _isPlaying = !_isPlaying);
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 36,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content Area
            Container(
              color: isDark ? Color(0xFF1A2332) : Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption Input
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF252F3F) : Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isDark ? Color(0xFF3A4556) : Color(0xFFE0E0E0),
                      ),
                    ),
                    padding: EdgeInsets.all(12),
                    child: TextField(
                      controller: _captionController,
                      decoration: InputDecoration(
                        hintText: 'Add a caption...',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.grey[500]
                              : Colors.grey[500],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),

                  SizedBox(height: 16),

                  // Encryption Info
                  Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: accentCyan,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'End-to-End Encrypted',
                        style: TextStyle(
                          fontSize: 12,
                          color: accentCyan,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Send Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Media sent${_captionController.text.isNotEmpty ? ' with caption' : ''}')),
                        );
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.send, size: 20),
                      label: Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentCyan,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        child: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}
