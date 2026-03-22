import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/conversation_provider.dart';

/// Conversation Screen
/// Displays messages with one user and message input
class ConversationScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String userName;

  const ConversationScreen({
    super.key,
    required this.chatId,
    required this.userName,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Stop typing indicator
    ref.read(conversationProvider(widget.chatId).notifier).notifyTypingStopped();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      // Load more messages when scrolled to bottom
      ref.read(conversationProvider(widget.chatId).notifier).loadMoreMessages();
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    ref.read(conversationProvider(widget.chatId).notifier).sendMessage(content);
    _messageController.clear();
    _isTyping = false;

    // Scroll to top
    Future.microtask(() {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _onMessageChanged(String value) {
    final typing = value.isNotEmpty;
    if (typing != _isTyping) {
      _isTyping = typing;
      if (typing) {
        ref
            .read(conversationProvider(widget.chatId).notifier)
            .notifyTypingStarted();
      } else {
        ref
            .read(conversationProvider(widget.chatId).notifier)
            .notifyTypingStopped();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationState = ref.watch(conversationProvider(widget.chatId));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.userName),
            Text(
              conversationState.typingIndicator.isNotEmpty
                  ? conversationState.typingIndicator
                  : 'Active now',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {
              // TODO: Voice call
            },
          ),
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {
              // TODO: Video call
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outlined),
            onPressed: () {
              // TODO: Show chat info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: conversationState.messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start the conversation',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: conversationState.messages.length,
                    itemBuilder: (context, index) {
                      final message = conversationState.messages[index];
                      final isOwn = message.senderId == 'current_user_id';
                      return _MessageBubble(
                        message: message.content,
                        isOwn: isOwn,
                        status: message.status,
                        time: _formatTime(message.createdAt),
                        onLongPress: isOwn
                            ? () => _showMessageMenu(
                                  context,
                                  message.id,
                                  message.content,
                                )
                            : null,
                      );
                    },
                  ),
          ),

          // Loading more indicator
          if (conversationState.isLoadingMore)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          // Divider
          const Divider(height: 1),

          // Message input area
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Media button
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppTheme.primaryColor,
                  onPressed: () {
                    // TODO: Show media picker
                  },
                ),

                // Message input
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onChanged: _onMessageChanged,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppTheme.dividerColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppTheme.dividerColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                  ),
                ),

                // Send button
                IconButton(
                  icon: const Icon(Icons.send),
                  color: AppTheme.primaryColor,
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageMenu(BuildContext context, String messageId, String content) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement edit
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () {
              ref
                  .read(conversationProvider(widget.chatId).notifier)
                  .deleteMessage(messageId);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _MessageBubble extends StatelessWidget {
  final String message;
  final bool isOwn;
  final String status;
  final String time;
  final VoidCallback? onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isOwn,
    required this.status,
    required this.time,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(
        alignment: isOwn ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: 8,
            left: isOwn ? 64 : 0,
            right: isOwn ? 0 : 64,
          ),
          child: Column(
            crossAxisAlignment:
                isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isOwn
                      ? AppTheme.sentBubbleColor
                      : AppTheme.receivedBubbleColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isOwn ? Colors.white : AppTheme.textPrimary,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      time,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.textTertiary,
                          ),
                    ),
                    if (isOwn) ...[
                      const SizedBox(width: 4),
                      Icon(
                        _statusIcon(status),
                        size: 12,
                        color: _statusColor(status),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'sent':
        return Icons.done;
      case 'delivered':
        return Icons.done_all;
      case 'read':
        return Icons.done_all;
      default:
        return Icons.schedule;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'sent':
        return Colors.grey;
      case 'delivered':
        return Colors.grey;
      case 'read':
        return AppTheme.primaryColor;
      default:
        return Colors.grey;
    }
  }
}
