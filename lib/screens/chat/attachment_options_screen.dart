import 'package:flutter/material.dart';

class AttachmentOptionsScreen extends StatelessWidget {
  final Function(String) onAttachmentSelected;

  const AttachmentOptionsScreen({
    super.key,
    required this.onAttachmentSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentCyan = Color(0xFF00BCD4);

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF1A2332) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Column(
            children: [
              Text(
                'Share Attachment',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'END-TO-END ENCRYPTED TUNNEL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: accentCyan,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 28),

          // Attachment Options Grid
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              _buildAttachmentOption(
                context: context,
                icon: Icons.camera_alt,
                label: 'Camera',
                isDark: isDark,
                accentCyan: accentCyan,
                onTap: () {
                  onAttachmentSelected('camera');
                  Navigator.pop(context);
                },
              ),
              _buildAttachmentOption(
                context: context,
                icon: Icons.image,
                label: 'Gallery',
                isDark: isDark,
                accentCyan: accentCyan,
                onTap: () {
                  onAttachmentSelected('gallery');
                  Navigator.pop(context);
                },
              ),
              _buildAttachmentOption(
                context: context,
                icon: Icons.description,
                label: 'Document',
                isDark: isDark,
                accentCyan: accentCyan,
                onTap: () {
                  onAttachmentSelected('document');
                  Navigator.pop(context);
                },
              ),
              _buildAttachmentOption(
                context: context,
                icon: Icons.location_on,
                label: 'Location',
                isDark: isDark,
                accentCyan: accentCyan,
                onTap: () {
                  onAttachmentSelected('location');
                  Navigator.pop(context);
                },
              ),
              _buildAttachmentOption(
                context: context,
                icon: Icons.people,
                label: 'Contact',
                isDark: isDark,
                accentCyan: accentCyan,
                onTap: () {
                  onAttachmentSelected('contact');
                  Navigator.pop(context);
                },
              ),
              _buildAttachmentOption(
                context: context,
                icon: Icons.mic,
                label: 'Audio',
                isDark: isDark,
                accentCyan: accentCyan,
                onTap: () {
                  onAttachmentSelected('audio');
                  Navigator.pop(context);
                },
              ),
            ],
          ),

          SizedBox(height: 8),

          // Footer note
          Container(
            padding: EdgeInsets.only(top: 16, bottom: 8),
            child: Text(
              'ALL ATTACHMENTS ARE ENCRYPTED BEFORE SENDING',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isDark,
    required Color accentCyan,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentCyan.withValues(alpha: 0.15),
              border: Border.all(
                color: accentCyan.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: accentCyan,
              size: 28,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
