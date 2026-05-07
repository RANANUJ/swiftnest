import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'attachment_options_screen.dart';
import 'media_preview_screen.dart';
import 'file_sharing_screen.dart';
import 'voice_note_screen.dart';

class Message {
  final String text;
  final DateTime timestamp;
  final bool isSent;
  final String senderName;

  Message({
    required this.text,
    required this.timestamp,
    required this.isSent,
    required this.senderName,
  });
}

class ConversationScreen extends StatefulWidget {
  final String contactName;
  final bool isOnline;

  const ConversationScreen({
    super.key,
    required this.contactName,
    this.isOnline = true,
  }) : super();

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  late TextEditingController _messageController;
  bool _isLoading = false;
  bool _isTyping = false;
  late List<Message> messages;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    // Start with empty messages list - no fake data
    messages = [];
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      messages.add(
        Message(
          text: _messageController.text,
          timestamp: DateTime.now(),
          isSent: true,
          senderName: 'You',
        ),
      );
    });

    _messageController.clear();

    await Future.delayed(Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isTyping = true;
    });

    await Future.delayed(Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      messages.add(
        Message(
          text:
              "That sounds great! Looking forward to reviewing those results.",
          timestamp: DateTime.now(),
          isSent: false,
          senderName: widget.contactName,
        ),
      );
    });
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MM/dd').format(time);
    }
  }

  void _handleAttachmentSelected(String type) {
    switch (type) {
      case 'camera':
      case 'gallery':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MediaPreviewScreen(
              mediaType: type == 'camera' ? 'image' : 'image',
              mediaPath: null,
            ),
          ),
        );
        break;
      case 'document':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FileSharingScreen(),
          ),
        );
        break;
      case 'audio':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceNoteScreen(),
          ),
        );
        break;
      case 'location':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location sharing coming soon')),
        );
        break;
      case 'contact':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact sharing coming soon')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentCyan = Color(0xFF00BCD4);

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121A2A) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Color(0xFF1A2332) : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.contactName,
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentCyan,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  widget.isOnline ? 'ONLINE' : 'OFFLINE',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.call,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Call feature coming soon')),
              );
            },
          ),
          IconButton(
            icon: Icon(
              Icons.videocam,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Video call feature coming soon')),
              );
            },
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('View Profile'),
              ),
              PopupMenuItem(
                child: Text('Mute Notifications'),
              ),
              PopupMenuItem(
                child: Text('Block Contact'),
              ),
              PopupMenuItem(
                child: Text('Clear Chat'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // End-to-End Encrypted Banner
          Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            color: isDark ? Color(0xFF1F3447) : Color(0xFFF0F8FF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: accentCyan,
                ),
                SizedBox(width: 8),
                Text(
                  'End-to-End Encrypted',
                  style: TextStyle(
                    color: accentCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Messages List
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
                        SizedBox(height: 16),
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
                        SizedBox(height: 8),
                        Text(
                          'Start your conversation',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.grey[500]
                                : Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount:
                        messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isTyping && index == messages.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                '${widget.contactName} is typing',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              SizedBox(width: 6),
                              SizedBox(
                                width: 24,
                                height: 12,
                                child: Stack(
                                  children: List.generate(3, (i) {
                                    return Positioned(
                                      left: i * 8.0,
                                      child: Container(
                                        width: 6,
                                        height: 6,
                                        decoration:
                                            BoxDecoration(
                                          shape:
                                              BoxShape.circle,
                                          color: isDark
                                              ? Colors
                                                  .grey[
                                                  400]
                                              : Colors
                                                  .grey[
                                                  600],
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final message = messages[index];
                      final isSent = message.isSent;
                      final prevMessage =
                          index > 0
                              ? messages[index -
                                  1]
                              : null;

                      final showTimestamp =
                          prevMessage ==
                              null ||
                              message
                                  .timestamp
                                  .difference(
                                      prevMessage
                                          .timestamp)
                                  .inMinutes >
                              5;

                      return Column(
                        crossAxisAlignment:
                            isSent
                                ? CrossAxisAlignment
                                    .end
                                : CrossAxisAlignment
                                    .start,
                        children: [
                          if (showTimestamp)
                            Padding(
                              padding:
                                  EdgeInsets
                                      .symmetric(
                                    vertical:
                                        8,
                                  ),
                              child: Text(
                                _formatTime(
                                    message
                                        .timestamp),
                                style:
                                    TextStyle(
                                  color: isDark
                                      ? Colors
                                          .grey[
                                          500]
                                      : Colors
                                          .grey[
                                          400],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Align(
                            alignment: isSent
                                ? Alignment
                                    .centerRight
                                : Alignment
                                    .centerLeft,
                            child: Container(
                              constraints:
                                  BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(
                                            context)
                                        .size
                                        .width *
                                    0.7,
                              ),
                              margin: EdgeInsets.symmetric(
                                  vertical: 4),
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      12,
                                  vertical:
                                      10),
                              decoration:
                                  BoxDecoration(
                                color: isSent
                                    ? accentCyan
                                    : (isDark
                                        ? Color(
                                            0xFF252F3F)
                                        : Color(
                                            0xFFF0F0F0)),
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            16),
                              ),
                              child: Text(
                                message.text,
                                style:
                                    TextStyle(
                                  color: isSent
                                      ? Colors
                                          .white
                                      : (isDark
                                          ? Colors
                                              .white
                                          : Color(
                                              0xFF333333)),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          // Input Area
          Container(
            padding: EdgeInsets.fromLTRB(12, 12, 12, 16),
            decoration: BoxDecoration(
              color: isDark ? Color(0xFF1A2332) : Colors.white,
              border: Border(
                top: BorderSide(
                  color:
                      isDark ? Color(0xFF252F3F) : Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Attachment Button
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (context) => AttachmentOptionsScreen(
                        onAttachmentSelected: _handleAttachmentSelected,
                      ),
                    );
                  },
                  child: Icon(
                    Icons.attachment,
                    color: isDark
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    size: 24,
                  ),
                ),
                SizedBox(width: 12),
                // Message Input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? Color(0xFF252F3F)
                          : Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isDark
                            ? Color(0xFF3A4556)
                            : Color(0xFFE0E0E0),
                      ),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: TextStyle(
                          color: isDark
                              ? Colors.grey[500]
                              : Colors.grey[500],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      style: TextStyle(
                        color:
                            isDark ? Colors.white : Colors.black,
                        fontSize: 14,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Send Button
                GestureDetector(
                  onTap: _isLoading ? null : _sendMessage,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentCyan,
                    ),
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.arrow_forward,
                              color: Colors.white,
                              size: 20,
                            ),
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
}
