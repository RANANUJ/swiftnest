import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyProfileScreen extends ConsumerStatefulWidget {
  const MyProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends ConsumerState<MyProfileScreen> {
  int _selectedTab = 3; // Profile tab selected

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);
    final accentColor = const Color(0xFF00BCD4);
    final backgroundColor = isDark ? const Color(0xFF1A1F2E) : const Color(0xFFFAFAFA);

    return Scaffold(
      backgroundColor: backgroundColor,
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
          'Profile',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.verified,
              color: accentColor,
              size: 24,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor,
                          width: 4,
                        ),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/avatar_1.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Text(
                            '👤',
                            style: TextStyle(fontSize: 60),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Name and Username
                    Text(
                      'Alexander Voss',
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@alexvoss',
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Digital architect focused on encrypted communication systems and high-fidelity user experience. Security is not an option. It\'s a foundation.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Security Vault Status
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF252F3F) : Colors.white,
                    border: Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.storage,
                            size: 20,
                            color: primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Security Vault Status',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black87,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: primaryColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.verified,
                                  size: 32,
                                  color: primaryColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'IDENTITY',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.shield,
                                  size: 32,
                                  color: accentColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'PROTECTION',
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Active',
                                  style: TextStyle(
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Settings Sections
              _buildSettingSection(
                title: 'Account',
                subtitle: 'Personal details and settings',
                icon: Icons.person,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () {},
              ),
              _buildSettingSection(
                title: 'Privacy',
                subtitle: 'Visibility and blocking',
                icon: Icons.privacy_tip_outlined,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () {},
              ),
              _buildSettingSection(
                title: 'Notifications',
                subtitle: 'Sound, vibration and alerts',
                icon: Icons.notifications_outlined,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () {},
              ),
              _buildSettingSection(
                title: 'Data & Storage',
                subtitle: 'Usage and backup settings',
                icon: Icons.storage_outlined,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () {},
              ),
              _buildSettingSection(
                title: 'Security',
                subtitle: 'Keys and encryption',
                icon: Icons.security,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () {},
              ),

              // Logout Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () {
                    // TODO: Logout
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE74C3C)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Logout Account',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFFE74C3C),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(
        isDark: isDark,
        primaryColor: const Color(0xFF0088CC),
        backgroundColor: isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5),
        selectedIndex: _selectedTab,
        onTap: (index) {
          setState(() => _selectedTab = index);
        },
      ),
    );
  }

  Widget _buildSettingSection({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
    required Color primaryColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 24, color: primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav({
    required bool isDark,
    required Color primaryColor,
    required Color backgroundColor,
    required int selectedIndex,
    required Function(int) onTap,
  }) {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.storage, 'label': 'VAULT'},
      {'icon': Icons.contacts_outlined, 'label': 'CONTACTS'},
      {'icon': Icons.security_outlined, 'label': 'SECURITY'},
      {'icon': Icons.person, 'label': 'PROFILE'},
    ];

    return Container(
      height: 65,
      color: backgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          navItems.length,
          (index) {
            final isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    navItems[index]['icon'],
                    size: 24,
                    color: isSelected
                        ? primaryColor
                        : (isDark ? Colors.grey[600] : Colors.grey[400]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    navItems[index]['label'],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? primaryColor
                          : (isDark ? Colors.grey[600] : Colors.grey[400]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
