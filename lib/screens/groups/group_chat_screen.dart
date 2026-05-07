import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Group Chat Screen - Chat interface for group conversations
class GroupChatScreen extends ConsumerStatefulWidget {
  final String? groupName;
  final String? groupId;

  const GroupChatScreen({
    super.key,
    this.groupName,
    this.groupId,
  });

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final _messageController = TextEditingController();
  final List<GroupMessage> messages = [];
  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.groupName ?? 'Group Chat',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 2),
            Text(
              '8 members',
              style: TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.call, color: accentColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.videocam, color: accentColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: primaryColor),
            onPressed: () {
              _showGroupOptions(context, isDark, primaryColor, backgroundColor);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages Area
          Expanded(
            child: messages.isEmpty && !_isTyping
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: isDark
                              ? Colors.grey[600]
                              : Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.grey[400]
                                : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start your group conversation',
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isOwn = message.isOwn;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: isOwn
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isOwn)
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, bottom: 4),
                                child: Text(
                                  message.senderName,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: accentColor,
                                  ),
                                ),
                              ),
                            Row(
                              mainAxisAlignment: isOwn
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                if (!isOwn)
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: accentColor.withValues(alpha: 0.2),
                                    ),
                                    child: Center(
                                      child: Text(
                                        message.senderAvatar,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ),
                                if (!isOwn) const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isOwn
                                          ? accentColor
                                          : inputFillColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      message.text,
                                      style: TextStyle(
                                        color: isOwn
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.white
                                                : Colors.black),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 0,
                              ),
                              child: Text(
                                message.timestamp,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Typing Indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Someone is typing',
                    style: TextStyle(
                      fontSize: 13,
                      color: secondaryTextColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 30,
                    height: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTypingDot(accentColor),
                        _buildTypingDot(accentColor),
                        _buildTypingDot(accentColor),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Message Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border(
                top: BorderSide(
                  color: primaryColor.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Attachment Button
                GestureDetector(
                  onTap: () {
                    context.pushNamed('attachment-options');
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryColor.withValues(alpha: 0.1),
                    ),
                    child: Icon(
                      Icons.add,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Message Input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: (value) {
                      setState(() {
                        _isTyping = value.isNotEmpty;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Message the group...',
                      hintStyle: TextStyle(color: secondaryTextColor),
                      filled: true,
                      fillColor: inputFillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                  ),
                ),
                const SizedBox(width: 12),

                // Send Button
                GestureDetector(
                  onTap: _messageController.text.isEmpty
                      ? null
                      : () {
                          setState(() {
                            messages.insert(
                              0,
                              GroupMessage(
                                text: _messageController.text,
                                senderName: 'You',
                                senderAvatar: '👤',
                                isOwn: true,
                                timestamp: 'now',
                              ),
                            );
                            _messageController.clear();
                            _isTyping = false;
                          });

                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) {
                              setState(() => _isTyping = true);
                            }
                          });

                          Future.delayed(const Duration(milliseconds: 1500), () {
                            if (mounted) {
                              setState(() => _isTyping = false);
                            }
                          });
                        },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _messageController.text.isEmpty
                          ? accentColor.withValues(alpha: 0.5)
                          : accentColor,
                    ),
                    child: Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  void _showGroupOptions(BuildContext context, bool isDark, Color primaryColor,
      Color backgroundColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.info_outline, color: primaryColor),
                      title: const Text('Group Info'),
                      onTap: () {
                        Navigator.pop(context);
                        context.pushNamed(
                          'group-info',
                          extra: {
                            'groupName': widget.groupName,
                            'groupId': widget.groupId,
                          },
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.notifications_off, color: primaryColor),
                      title: const Text('Mute Notifications'),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.exit_to_app, color: const Color(0xFFE74C3C)),
                      title: const Text('Leave Group'),
                      onTap: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Left the group')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GroupMessage {
  final String text;
  final String senderName;
  final String senderAvatar;
  final bool isOwn;
  final String timestamp;

  GroupMessage({
    required this.text,
    required this.senderName,
    required this.senderAvatar,
    required this.isOwn,
    required this.timestamp,
  });
}
