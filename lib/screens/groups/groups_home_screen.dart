import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Groups Home Screen - Browse and manage groups
class GroupsHomeScreen extends ConsumerStatefulWidget {
  const GroupsHomeScreen({super.key});

  @override
  ConsumerState<GroupsHomeScreen> createState() => _GroupsHomeScreenState();
}

class _GroupsHomeScreenState extends ConsumerState<GroupsHomeScreen> {
  final _searchController = TextEditingController();
  final List<GroupItem> pinnedGroups = [
    GroupItem(
      name: 'Design Guild',
      avatar: '🎨',
      memberCount: 12,
      isPinned: true,
      isPinned_: true,
    ),
    GroupItem(
      name: 'Launch Squad',
      avatar: '🚀',
      memberCount: 8,
      isPinned: true,
      isPinned_: true,
    ),
  ];

  final List<GroupItem> allGroups = [
    GroupItem(
      name: 'Engineering Team',
      avatar: '⚙️',
      memberCount: 24,
      lastMessage: 'Alex: The PR is ready for the vault core...',
      time: '10:45 AM',
      isPinned: false,
      isPinned_: false,
    ),
    GroupItem(
      name: 'Social Hour',
      avatar: '☕',
      memberCount: 15,
      lastMessage: 'Sarah: Who\'s up for coffee later?',
      time: 'Yesterday',
      isPinned: false,
      isPinned_: false,
    ),
    GroupItem(
      name: 'Marketing Strategy',
      avatar: '📊',
      memberCount: 6,
      lastMessage: 'You: See the assets for the Q4 c...',
      time: 'Monday',
      isPinned: false,
      isPinned_: false,
    ),
    GroupItem(
      name: 'Gaming Nights',
      avatar: '🎮',
      memberCount: 18,
      lastMessage: 'Anyone online for a game?',
      time: 'Today',
      isPinned: false,
      isPinned_: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        title: const Text('Groups'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search groups...',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  prefixIcon: Icon(
                    Icons.search,
                    color: secondaryTextColor,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),

            // Pinned Groups Section
            if (pinnedGroups.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 20, bottom: 12),
                child: Text(
                  'PINNED GROUPS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
              ),

            // Pinned groups grid
            if (pinnedGroups.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: pinnedGroups.length,
                  itemBuilder: (context, index) {
                    final group = pinnedGroups[index];
                    return _buildPinnedGroupCard(
                      group: group,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      accentColor: accentColor,
                      backgroundColor: backgroundColor,
                    );
                  },
                ),
              ),

            const SizedBox(height: 24),

            // All Groups Section
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ALL GROUPS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {},
                      child: Text(
                        'Filter',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // All groups list
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allGroups.length,
              itemBuilder: (context, index) {
                final group = allGroups[index];
                return _buildGroupListItem(
                  group: group,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: accentColor,
        onPressed: () {
          context.pushNamed('create-group');
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildPinnedGroupCard({
    required GroupItem group,
    required bool isDark,
    required Color primaryColor,
    required Color accentColor,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'group-chat',
          extra: {
            'groupName': group.name,
            'groupId': 'group_${group.name.toLowerCase().replaceAll(' ', '_')}',
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              accentColor.withValues(alpha: 0.15),
              accentColor.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.2),
              ),
              child: Center(
                child: Text(
                  group.avatar,
                  style: const TextStyle(fontSize: 36),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              group.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${group.memberCount} members',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : const Color(0xFF1A2332).withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupListItem({
    required GroupItem group,
    required bool isDark,
    required Color primaryColor,
    required Color accentColor,
    required Color inputFillColor,
    required Color secondaryTextColor,
  }) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'group-chat',
          extra: {
            'groupName': group.name,
            'groupId': 'group_${group.name.toLowerCase().replaceAll(' ', '_')}',
          },
        );
      },
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
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.2),
              ),
              child: Center(
                child: Text(
                  group.avatar,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Group info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.memberCount} members',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Color.fromARGB(255, 128, 128, 128),
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),

            // Icon
            Icon(
              Icons.chevron_right,
              color: accentColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class GroupItem {
  final String name;
  final String avatar;
  final int memberCount;
  final String? lastMessage;
  final String? time;
  final bool isPinned;
  final bool isPinned_;

  GroupItem({
    required this.name,
    required this.avatar,
    required this.memberCount,
    this.lastMessage,
    this.time,
    required this.isPinned,
    required this.isPinned_,
  });
}
