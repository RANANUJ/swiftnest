import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Admin Controls Screen - Manage group permissions and settings
class AdminControlsScreen extends ConsumerStatefulWidget {
  final String? groupName;
  final String? groupId;

  const AdminControlsScreen({
    super.key,
    this.groupName,
    this.groupId,
  });

  @override
  ConsumerState<AdminControlsScreen> createState() =>
      _AdminControlsScreenState();
}

class _AdminControlsScreenState extends ConsumerState<AdminControlsScreen> {
  bool _sendMessages = true;
  bool _editGroupInfo = false;
  bool _addMembers = true;
  bool _manageAdmins = false;

  final List<AdminRequest> memberRequests = [
    AdminRequest(
      name: 'Sarah Jenkins',
      avatar: '👩',
      action: 'Pending',
      isPending: true,
    ),
    AdminRequest(
      name: 'Marcus Chen',
      avatar: '👨',
      action: 'Promote',
      isPending: false,
    ),
  ];

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Admin Controls'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Permissions Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PERMISSIONS',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 16),

                  // Send Messages Toggle
                  _buildPermissionTile(
                    title: 'Send Messages',
                    subtitle:
                        'Allow members to send messages in the group',
                    value: _sendMessages,
                    onChanged: (value) {
                      setState(() => _sendMessages = value);
                    },
                    isDark: isDark,
                    inputFillColor: inputFillColor,
                    accentColor: accentColor,
                  ),

                  const SizedBox(height: 12),

                  // Edit Group Info Toggle
                  _buildPermissionTile(
                    title: 'Edit Group Info',
                    subtitle: 'Allow members to edit group name and description',
                    value: _editGroupInfo,
                    onChanged: (value) {
                      setState(() => _editGroupInfo = value);
                    },
                    isDark: isDark,
                    inputFillColor: inputFillColor,
                    accentColor: accentColor,
                  ),

                  const SizedBox(height: 12),

                  // Add Members Toggle
                  _buildPermissionTile(
                    title: 'Add Members',
                    subtitle: 'Allow members to add new people to the group',
                    value: _addMembers,
                    onChanged: (value) {
                      setState(() => _addMembers = value);
                    },
                    isDark: isDark,
                    inputFillColor: inputFillColor,
                    accentColor: accentColor,
                  ),

                  const SizedBox(height: 12),

                  // Manage Admins Toggle
                  _buildPermissionTile(
                    title: 'Manage Admins',
                    subtitle:
                        'Allow members to promote/demote group administrators',
                    value: _manageAdmins,
                    onChanged: (value) {
                      setState(() => _manageAdmins = value);
                    },
                    isDark: isDark,
                    inputFillColor: inputFillColor,
                    accentColor: accentColor,
                  ),
                ],
              ),
            ),

            Divider(
              color: primaryColor.withValues(alpha: 0.1),
              height: 1,
            ),

            // Member Requests Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'MEMBER REQUESTS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: secondaryTextColor,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE74C3C).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            color: const Color(0xFFE74C3C),
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: memberRequests.length,
                    itemBuilder: (context, index) {
                      final request = memberRequests[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMemberRequestTile(
                          request: request,
                          isDark: isDark,
                          inputFillColor: inputFillColor,
                          accentColor: accentColor,
                          primaryColor: primaryColor,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            Divider(
              color: primaryColor.withValues(alpha: 0.1),
              height: 1,
            ),

            // Danger Zone Section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danger Zone',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFFE74C3C),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFE74C3C).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: const Color(0xFFE74C3C),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Deleting this group will permanently remove',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    color: const Color(0xFFE74C3C),
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'all message history, shared files, and member access. This action cannot be undone.',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : Colors.black.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () {
                              _showDeleteConfirmation(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color(0xFFE74C3C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Delete Group',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
    required Color inputFillColor,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0088CC).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.6)
                            : Colors.black.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberRequestTile({
    required AdminRequest request,
    required bool isDark,
    required Color inputFillColor,
    required Color accentColor,
    required Color primaryColor,
  }) {
    return Container(
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.2),
            ),
            child: Center(
              child: Text(
                request.avatar,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                if (request.isPending)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE74C3C).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Pending',
                      style: TextStyle(
                        color: const Color(0xFFE74C3C),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      request.action,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (request.isPending)
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request rejected')),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE74C3C).withValues(alpha: 0.2),
                    ),
                    child: Icon(
                      Icons.close,
                      color: const Color(0xFFE74C3C),
                      size: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request approved')),
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
                      Icons.check,
                      color: accentColor,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1A2332) : Colors.white;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: const Text('Delete Group?'),
          content: RichText(
            text: TextSpan(
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: '${widget.groupName}?',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const TextSpan(
                  text:
                      '\n\nThis will permanently remove all message history, shared files, and member access. This action cannot be undone.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Group "${widget.groupName}" has been deleted')),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Color(0xFFE74C3C)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class AdminRequest {
  final String name;
  final String avatar;
  final String action;
  final bool isPending;

  AdminRequest({
    required this.name,
    required this.avatar,
    required this.action,
    required this.isPending,
  });
}
