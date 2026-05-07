import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SecuritySettingScreen extends ConsumerStatefulWidget {
  const SecuritySettingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SecuritySettingScreen> createState() =>
      _SecuritySettingScreenState();
}

class _SecuritySettingScreenState extends ConsumerState<SecuritySettingScreen> {
  bool _biometricLock = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);
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
            // Your Digital Vault Banner
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.storage,
                      size: 24,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Your Digital Vault',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'End-to-end encryption protects all your confidential data.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Two-Step Verification
            _buildSectionHeader('SECURITY', isDark),
            _buildSecurityItem(
              icon: Icons.shield_outlined,
              title: 'Two-step verification',
              subtitle: 'Add another layer of security',
              isDark: isDark,
            ),

            _buildSecurityItem(
              icon: Icons.face_outlined,
              title: 'Biometric lock',
              subtitle: 'Use face or touch to authenticate',
              isDark: isDark,
              hasToggle: true,
              value: _biometricLock,
              onChanged: (v) => setState(() => _biometricLock = v),
            ),

            // Active Sessions
            _buildSectionHeader('ACTIVE SESSIONS', isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '5 total',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'All other devices',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Logout all devices',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Device List
            _buildDeviceSession(
              icon: Icons.smartphone_outlined,
              name: 'iPhone 15 Pro',
              status: 'Signed in',
              isDark: isDark,
            ),
            _buildDeviceSession(
              icon: Icons.laptop_outlined,
              name: 'MacBook Pro 16"',
              status: 'Signed in',
              isDark: isDark,
            ),
            _buildDeviceSession(
              icon: Icons.tablet_outlined,
              name: 'iPad Air',
              status: 'Signed in',
              isDark: isDark,
            ),
            _buildDeviceSession(
              icon: Icons.desktop_windows_outlined,
              name: 'Others',
              status: 'Urgent',
              isDark: isDark,
              isUrgent: true,
            ),

            // Security Audit
            _buildSectionHeader('SECURITY AUDIT', isDark),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Wrap(
                spacing: 12,
                children: List.generate(
                  5,
                  (index) => Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: [
                        Colors.green,
                        Colors.blue,
                        Colors.orange,
                        Colors.cyan,
                        Colors.purple,
                      ][index],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
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

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    bool hasToggle = false,
    bool value = false,
    Function(bool)? onChanged,
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
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (hasToggle && onChanged != null)
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
            )
          else if (!hasToggle)
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
        ],
      ),
    );
  }

  Widget _buildDeviceSession({
    required IconData icon,
    required String name,
    required String status,
    required bool isDark,
    bool isUrgent = false,
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
                  name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    color: isUrgent
                        ? const Color(0xFFE74C3C)
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                    fontSize: 11,
                    fontWeight: isUrgent ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
