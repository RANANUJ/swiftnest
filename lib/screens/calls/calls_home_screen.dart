import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Calls Home Screen - View and manage recent calls
class CallsHomeScreen extends ConsumerStatefulWidget {
  const CallsHomeScreen({super.key});

  @override
  ConsumerState<CallsHomeScreen> createState() => _CallsHomeScreenState();
}

class _CallsHomeScreenState extends ConsumerState<CallsHomeScreen> {
  final _searchController = TextEditingController();
  final List<CallRecord> recentCalls = [
    CallRecord(
      name: 'Elena Vance',
      avatar: '👩',
      callType: CallType.video,
      duration: 'Missed Call',
      timestamp: '11:45 AM',
      isIncoming: false,
    ),
    CallRecord(
      name: 'Julian Thorne',
      avatar: '👨',
      callType: CallType.audio,
      duration: 'Incoming Call',
      timestamp: '10:30 AM',
      isIncoming: true,
    ),
    CallRecord(
      name: 'Marcus Chen',
      avatar: '👨',
      callType: CallType.audio,
      duration: 'Outgoing Call',
      timestamp: 'YESTERDAY',
      isIncoming: false,
    ),
    CallRecord(
      name: 'Sarah Jenkins',
      avatar: '👩',
      callType: CallType.video,
      duration: '(12m)',
      timestamp: '3:45 PM',
      isIncoming: true,
    ),
    CallRecord(
      name: 'Development Sync',
      avatar: '👥',
      callType: CallType.audio,
      duration: 'Group Calling • 4 participants',
      timestamp: '02:30 PM',
      isIncoming: false,
      isGroup: true,
    ),
    CallRecord(
      name: 'Arthur Morgan',
      avatar: '👨',
      callType: CallType.video,
      duration: 'Missed • 02:43',
      timestamp: '12:15 PM',
      isIncoming: false,
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
        title: const Text('Calls'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vacated contacts...',
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

          // Recent Calls Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RECENT CALLS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: secondaryTextColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                ),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Call history cleared')),
                    );
                  },
                  child: Text(
                    'Clear History',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Recent Calls List
          Expanded(
            child: ListView.builder(
              itemCount: recentCalls.length,
              itemBuilder: (context, index) {
                final call = recentCalls[index];
                return _buildCallItem(
                  call: call,
                  isDark: isDark,
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                  inputFillColor: inputFillColor,
                  secondaryTextColor: secondaryTextColor,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(
        isDark: isDark,
        primaryColor: primaryColor,
        accentColor: accentColor,
        backgroundColor: isDark ? const Color(0xFF252F3F) : const Color(0xFFF5F5F5),
      ),
    );
  }

  Widget _buildCallItem({
    required CallRecord call,
    required bool isDark,
    required Color primaryColor,
    required Color accentColor,
    required Color inputFillColor,
    required Color secondaryTextColor,
  }) {
    return GestureDetector(
      onTap: () {
        // Initiate call
        GoRouter.of(context).pushNamed(
          'incoming-call',
          extra: {
            'callerName': call.name,
            'callerAvatar': call.avatar,
            'callType': call.callType.name,
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
                color: (call.isGroup ? accentColor : primaryColor)
                    .withValues(alpha: 0.2),
              ),
              child: Center(
                child: Text(
                  call.avatar,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Call info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    call.duration,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: secondaryTextColor,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),

            // Timestamp and action buttons
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  call.timestamp,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: secondaryTextColor,
                        fontSize: 11,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Audio call with ${call.name} initiated')),
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          Icons.phone,
                          size: 16,
                          color: accentColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Video call with ${call.name} initiated')),
                        );
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withValues(alpha: 0.2),
                        ),
                        child: Icon(
                          Icons.videocam,
                          size: 16,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
  }) {
    final items = [
      ('CHATS', Icons.message),
      ('CALLS', Icons.call),
      ('CONTACTS', Icons.people),
      ('VAULT', Icons.note),
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
                final isSelected = index == 1; // Calls tab

                return GestureDetector(
                  onTap: () {},
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

enum CallType { audio, video }

class CallRecord {
  final String name;
  final String avatar;
  final CallType callType;
  final String duration;
  final String timestamp;
  final bool isIncoming;
  final bool isGroup;

  CallRecord({
    required this.name,
    required this.avatar,
    required this.callType,
    required this.duration,
    required this.timestamp,
    required this.isIncoming,
    this.isGroup = false,
  });
}
