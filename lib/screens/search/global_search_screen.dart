import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GlobalSearchScreen> createState() =>
      _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  int _selectedTab = 3; // VAULT tab selected by default (Index 3)

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFF0088CC);
    final accentColor = const Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1F2E) : const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [
            // Search Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      Icons.arrow_back,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Global Search (Lightning fast)',
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor:
                            isDark ? const Color(0xFF252F3F) : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.grey[700]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      // More options
                    },
                    child: Icon(
                      Icons.more_vert,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            // Filter Tags
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterTag(
                    label: '#project',
                    isDark: isDark,
                    primaryColor: primaryColor,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  // Recent Searches
                  if (_searchQuery.isEmpty) ...[
                    _buildSectionHeader('Recent Searches', isDark, primaryColor),
                    _buildRecentSearchItem('Project Obsidian', isDark),
                    _buildRecentSearchItem('Sarah Jenkins', isDark),
                    _buildRecentSearchItem('Budget 2024', isDark),
                  ],

                  // People & Groups
                  const SizedBox(height: 24),
                  _buildSectionHeader('People & Groups', isDark, primaryColor),
                  _buildPersonItem(
                    name: 'Sarah Jenkins',
                    subtitle: 'Head of Operations',
                    avatar: '👨‍💼',
                    isDark: isDark,
                  ),
                  _buildPersonItem(
                    name: 'Marcus Vee',
                    subtitle: 'Senior Developer',
                    avatar: '👨‍💻',
                    isDark: isDark,
                  ),
                  _buildGroupItem(
                    name: 'Global Strategy 2024',
                    members: '550 members, 2 admins',
                    avatar: 'G',
                    avatarColor: accentColor,
                    isDark: isDark,
                  ),

                  // Messages
                  const SizedBox(height: 24),
                  _buildSectionHeader('Messages', isDark, primaryColor),
                  _buildMessageItem(
                    title: 'PROJECT OBSIDIAN',
                    subtitle: 'DIRECT MESSAGE',
                    message: 'Sarah Jenkins: \'I shared the final drafts for...',
                    timestamp: '10:47 AM',
                    isDark: isDark,
                    avatar: '📋',
                  ),
                  _buildMessageItem(
                    title: 'Marcus Vee',
                    subtitle: 'DIRECT MESSAGE',
                    message: 'Marcus Vee: Need meeting for the upcoming plan...',
                    timestamp: '10:27 AM',
                    isDark: isDark,
                    avatar: '👨‍💼',
                  ),

                  // Files & Media
                  const SizedBox(height: 24),
                  _buildSectionHeader('Files & Media', isDark, primaryColor),
                  _buildFileItem(
                    name: 'Project_Obsidian.zip',
                    size: '47.3 MB',
                    isDark: isDark,
                  ),
                  _buildFileItem(
                    name: 'Project_Analysis_14...',
                    size: '2.1 MB',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(
        isDark: isDark,
        primaryColor: primaryColor,
        accentColor: accentColor,
        backgroundColor: isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5),
        selectedIndex: _selectedTab,
        onTap: (index) {
          setState(() => _selectedTab = index);

          // Navigate based on tab
          if (index == 0) {
            // Chats - go home
            Navigator.of(context).pop();
          } else if (index == 1) {
            // Calls
            // context.pushNamed('calls');
          } else if (index == 2) {
            // Groups
            // context.pushNamed('groups');
          } else if (index == 3) {
            // Downloads
            // context.pushNamed('downloads');
          } else if (index == 4) {
            // Profile
            // context.pushNamed('profile');
          }
        },
      ),
    );
  }

  Widget _buildFilterTag({
    required String label,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.2),
          border: Border.all(color: primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.close,
                size: 14,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool isDark,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          if (title != 'Recent Searches')
            Text(
              'CLEAR ALL',
              style: TextStyle(
                color: primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.history,
            size: 18,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Icon(
            Icons.arrow_outward,
            size: 16,
            color: isDark ? Colors.grey[500] : Colors.grey[400],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonItem({
    required String name,
    required String subtitle,
    required String avatar,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0088CC).withOpacity(0.2),
            ),
            child: Center(
              child: Text(avatar, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
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
            Icons.add_circle_outline,
            size: 20,
            color: const Color(0xFF00BCD4),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupItem({
    required String name,
    required String members,
    required String avatar,
    required Color avatarColor,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarColor.withOpacity(0.3),
            ),
            child: Center(
              child: Text(
                avatar,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  members,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.add_circle_outline,
            size: 20,
            color: avatarColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem({
    required String title,
    required String subtitle,
    required String message,
    required String timestamp,
    required bool isDark,
    required String avatar,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0088CC).withOpacity(0.2),
            ),
            child: Center(
              child: Text(avatar, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      timestamp,
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: const Color(0xFF00BCD4),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileItem({
    required String name,
    required String size,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF252F3F) : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.file_present,
                size: 24,
                color: const Color(0xFF00BCD4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  size,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav({
    required bool isDark,
    required Color primaryColor,
    required Color accentColor,
    required Color backgroundColor,
    required int selectedIndex,
    required Function(int) onTap,
  }) {
    final List<Map<String, dynamic>> navItems = [
      {'icon': Icons.chat_bubble_outline, 'label': 'CHATS'},
      {'icon': Icons.phone_outlined, 'label': 'CALLS'},
      {'icon': Icons.group_outlined, 'label': 'GROUPS'},
      {'icon': Icons.download_outlined, 'label': 'DOWNLOADS'},
      {'icon': Icons.person_outline, 'label': 'PROFILE'},
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
