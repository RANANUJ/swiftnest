import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationSettingScreen extends ConsumerStatefulWidget {
  const NotificationSettingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationSettingScreen> createState() =>
      _NotificationSettingScreenState();
}

class _NotificationSettingScreenState
    extends ConsumerState<NotificationSettingScreen> {
  bool _smartMessages = false;
  bool _showPreviews = true;
  bool _mentions = false;
  bool _differentAlerts = true;
  bool _threadNotices = true;
  bool _groupNotifications = false;
  bool _allActivities = true;
  bool _soundVibration = true;

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
            // Notifications Section
            _buildSectionTitle('NOTIFICATIONS', isDark),

            _buildNotificationToggle(
              icon: Icons.message_outlined,
              title: 'Messages',
              subtitle: 'Smart Messages',
              value: _smartMessages,
              onChanged: (v) => setState(() => _smartMessages = v),
              isDark: isDark,
            ),

            _buildNotificationToggle(
              icon: Icons.preview_outlined,
              title: 'Show Previews',
              subtitle: '',
              value: _showPreviews,
              onChanged: (v) => setState(() => _showPreviews = v),
              isDark: isDark,
            ),

            _buildNotificationToggle(
              icon: Icons.alternate_email,
              title: 'Mentions',
              subtitle: 'Show notification',
              value: _mentions,
              onChanged: (v) => setState(() => _mentions = v),
              isDark: isDark,
            ),

            _buildNotificationToggle(
              icon: Icons.notifications_outlined,
              title: 'Different Alerts',
              subtitle: '',
              value: _differentAlerts,
              onChanged: (v) => setState(() => _differentAlerts = v),
              isDark: isDark,
            ),

            _buildNotificationToggle(
              icon: Icons.notification_important_outlined,
              title: 'Thread Notices',
              subtitle: '',
              value: _threadNotices,
              onChanged: (v) => setState(() => _threadNotices = v),
              isDark: isDark,
            ),

            // Group Notifications
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GROUP NOTIFICATIONS',
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF252F3F) : Colors.white,
                      border: Border.all(
                        color:
                            isDark ? Colors.grey[800]! : Colors.grey[200]!,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customize behavior for community chats and channels',
                          style: TextStyle(
                            color:
                                isDark ? Colors.grey[300] : Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'These settings will apply to new groups you create.',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildToggle(
                    value: _groupNotifications,
                    onChanged: (v) => setState(() => _groupNotifications = v),
                  ),
                ],
              ),
            ),

            // Other Activities
            _buildNotificationToggle(
              icon: Icons.list_alt_outlined,
              title: 'All Activities',
              subtitle: '',
              value: _allActivities,
              onChanged: (v) => setState(() => _allActivities = v),
              isDark: isDark,
            ),

            // Sound & Vibration
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SOUND & VIBRATION',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),

            _buildNotificationToggle(
              icon: Icons.volume_up_outlined,
              title: 'Breeze Ukulele',
              subtitle: 'Default Notification Tone',
              value: _soundVibration,
              onChanged: (v) => setState(() => _soundVibration = v),
              isDark: isDark,
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

  Widget _buildNotificationToggle({
    required IconData icon,
    required String title,
    required String subtitle,
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
                if (subtitle.isNotEmpty) ...[
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
          _buildToggle(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildToggle({
    required bool value,
    required Function(bool) onChanged,
  }) {
    return GestureDetector(
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
    );
  }
}
