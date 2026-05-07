import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_config.dart';

/// Chat List Screen - Main home screen with pinned and recent conversations
class ChatListScreenNew extends ConsumerStatefulWidget {
  const ChatListScreenNew({super.key});

  @override
  ConsumerState<ChatListScreenNew> createState() => _ChatListScreenNewState();
}

class _ChatListScreenNewState extends ConsumerState<ChatListScreenNew>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  int _selectedTab = 0; // 0: Chats, 1: Calls, 2: Groups, 3: Downloads, 4: Profile

  final List<PinnedContact> pinnedContacts = [
    PinnedContact(
      name: 'Alex Rivera',
      avatar: '👤',
      hasMessage: true,
    ),
    PinnedContact(
      name: 'Julian Chen',
      avatar: '👨',
      hasMessage: false,
    ),
    PinnedContact(
      name: 'Design Vault',
      avatar: '👥',
      hasMessage: false,
      isGroup: true,
    ),
  ];

  final List<ChatMessage> recentMessages = [
    ChatMessage(
      name: 'Sarah Jenkins',
      avatar: '👩',
      message: 'The architectural renderers are taki...',
      time: '12:45 PM',
      hasAttachment: false,
      isRead: false,
    ),
    ChatMessage(
      name: 'Marcus Wright',
      avatar: '👨',
      message: '✓ Sent the files to the secure ser...',
      time: 'Yesterday',
      hasAttachment: false,
      isRead: true,
    ),
    ChatMessage(
      name: 'Elena Rodriguez',
      avatar: '🎤',
      message: 'Voice message (0:24)',
      time: '09:12 AM',
      hasAttachment: true,
      isRead: false,
    ),
    ChatMessage(
      name: 'Tech Meetup Group',
      avatar: '👥',
      message: 'Dave: Anyone up for coffee?',
      time: 'Monday',
      hasAttachment: false,
      isRead: true,
      isGroup: true,
    ),
    ChatMessage(
      name: 'Robert Fox',
      avatar: '👶',
      message: 'Let me know when you\'re avai...',
      time: 'Oct 12',
      hasAttachment: false,
      isRead: true,
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
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.people,
                size: 16,
                color: primaryColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppConfig.appName,
              style: TextStyle(
                color: primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: primaryColor),
            onPressed: () {
              context.pushNamed('global-search');
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: secondaryTextColor),
            onPressed: () {
              // TODO: Show menu
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  filled: true,
                  fillColor: inputFillColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search, color: secondaryTextColor),
                  suffixIcon: Icon(Icons.close, color: secondaryTextColor),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pinned Priority section
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PINNED PRIORITY',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                          ),
                          Icon(
                            Icons.more_horiz,
                            size: 16,
                            color: secondaryTextColor,
                          ),
                        ],
                      ),
                    ),

                    // Pinned contacts horizontal scroll
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: pinnedContacts.length,
                        itemBuilder: (context, index) {
                          final contact = pinnedContacts[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: _buildPinnedContact(
                              contact: contact,
                              isDark: isDark,
                              primaryColor: primaryColor,
                              accentColor: accentColor,
                              backgroundColor: backgroundColor,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recent Messages section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        isDark ? 'RECENTS' : 'RECENT MESSAGES',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Recent messages list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentMessages.length,
                      itemBuilder: (context, index) {
                        final message = recentMessages[index];
                        return _buildChatItem(
                          message: message,
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
          if (index == 1) { // Calls tab
            context.pushNamed('calls');
          } else if (index == 2) { // Groups tab
            context.pushNamed('groups');
          } else if (index == 3) { // Downloads tab
            context.pushNamed('downloads');
          }
        },
      ),
    );
  }

  Widget _buildPinnedContact({
    required PinnedContact contact,
    required bool isDark,
    required Color primaryColor,
    required Color accentColor,
    required Color backgroundColor,
  }) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'conversation',
          extra: {
            'contactName': contact.name,
            'isOnline': true,
          },
        );
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: contact.isGroup
                      ? accentColor.withValues(alpha: 0.2)
                      : primaryColor.withValues(alpha: 0.15),
                  border: Border.all(
                    color: (contact.isGroup ? accentColor : primaryColor)
                        .withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    contact.avatar,
                    style: const TextStyle(fontSize: 36),
                  ),
                ),
              ),
              if (contact.hasMessage)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor,
                      border: Border.all(
                        color: backgroundColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 80,
            child: Text(
              contact.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem({
    required ChatMessage message,
    required bool isDark,
    required Color primaryColor,
    required Color accentColor,
    required Color inputFillColor,
    required Color secondaryTextColor,
  }) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'conversation',
          extra: {
            'contactName': message.name,
            'isOnline': true,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: message.isGroup
                    ? accentColor.withValues(alpha: 0.2)
                    : primaryColor.withValues(alpha: 0.1),
                border: Border.all(
                  color: (message.isGroup ? accentColor : primaryColor)
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Center(
                child: Text(
                  message.avatar,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and time row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        message.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        message.time,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: secondaryTextColor,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Message preview
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          message.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: message.isRead
                                    ? secondaryTextColor
                                    : (isDark
                                        ? Colors.white
                                        : const Color(0xFF1A2332)),
                                fontWeight: message.isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                              ),
                        ),
                      ),
                      if (message.hasAttachment)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.attach_file,
                            size: 14,
                            color: accentColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Unread indicator or action
            if (!message.isRead)
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                ),
              )
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.15),
                ),
                child: Icon(
                  Icons.message,
                  size: 16,
                  color: accentColor,
                ),
              ),
          ],
        ),
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
    final items = [
      ('CHATS', Icons.message),
      ('CALLS', Icons.call),
      ('GROUPS', Icons.group),
      ('DOWNLOADS', Icons.download),
      ('PROFILE', Icons.person),
    ];

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: primaryColor.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) {
                final (label, icon) = items[index];
                final isSelected = index == selectedIndex;

                return GestureDetector(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: isSelected ? accentColor : primaryColor,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isSelected ? accentColor : primaryColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              fontSize: 10,
                            ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class PinnedContact {
  final String name;
  final String avatar;
  final bool hasMessage;
  final bool isGroup;

  PinnedContact({
    required this.name,
    required this.avatar,
    required this.hasMessage,
    this.isGroup = false,
  });
}

class ChatMessage {
  final String name;
  final String avatar;
  final String message;
  final String time;
  final bool hasAttachment;
  final bool isRead;
  final bool isGroup;

  ChatMessage({
    required this.name,
    required this.avatar,
    required this.message,
    required this.time,
    required this.hasAttachment,
    required this.isRead,
    this.isGroup = false,
  });
}
