# SwiftNest Screen Integration Guide - Step by Step

## Overview

This guide walks you through updating each screen in your SwiftNest app to use the integrated backend providers instead of mock data.

## ✅ Priority Order

1. **High Priority** (Core functionality)
   - Conversation Screen
   - Chat List Screen
   - Groups Screen
   - Calls Screen

2. **Medium Priority** (User features)
   - User Profile Screen
   - Edit Profile Screen
   - Search Screen

3. **Low Priority** (Admin/settings)
   - Admin Screens
   - Settings Screens

## 📋 General Integration Pattern

### Before (Mock Data)
```dart
class ConversationScreen extends StatefulWidget {
  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  List<Message> messages = []; // Mock data

  @override
  void initState() {
    super.initState();
    // Load mock messages
    _loadMessages();
  }

  void _loadMessages() {
    // Hardcoded mock data
    messages = [
      Message(id: '1', text: 'Hi there'),
      Message(id: '2', text: 'Hello!'),
    ];
  }
}
```

### After (With Providers)
```dart
class ConversationScreen extends ConsumerWidget {
  final String conversationId;

  const ConversationScreen({required this.conversationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(conversationMessagesProvider(conversationId));
    
    return messages.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
      data: (messageList) => ListView(
        children: messageList.map((msg) => MessageTile(message: msg)).toList(),
      ),
    );
  }
}
```

## 🔄 Step-by-Step Updates

### 1. Conversation Screen

**File**: `lib/screens/chat/conversation_screen.dart`

**Current State**: Displays messages from mock list

**Changes**:

```dart
// Add ConsumerWidget and watch provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/integrated_providers.dart';

class ConversationScreen extends ConsumerWidget {
  final String conversationId;
  final String conversationName;
  
  const ConversationScreen({
    required this.conversationId,
    required this.conversationName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch conversation messages
    final messagesAsync = ref.watch(
      conversationMessagesProvider(conversationId),
    );
    
    return Scaffold(
      appBar: AppBar(title: Text(conversationName)),
      body: messagesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading messages: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(
                  conversationMessagesProvider(conversationId),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (messages) => Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const Center(child: Text('No messages yet'))
                  : ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return MessageBubble(
                          message: message['text'] ?? '',
                          isOwn: message['senderId'] == getCurrentUserId(),
                          timestamp: message['timestamp'],
                        );
                      },
                    ),
            ),
            MessageInputField(
              onSendMessage: (text) async {
                // Use the send message provider
                final notifier = ref.read(sendMessageProvider.notifier);
                await notifier.sendMessage(conversationId, text);
                
                // Refresh messages list
                ref.invalidate(
                  conversationMessagesProvider(conversationId),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Chat List Screen

**File**: `lib/screens/chat/chat_list_screen.dart`

**Current State**: Shows hardcoded conversations

**Changes**:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/integrated_providers.dart';

class ChatListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch all conversations
    final conversationsAsync = ref.watch(conversationsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: conversationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(conversationsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (conversations) => conversations.isEmpty
            ? const Center(child: Text('No conversations yet'))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(conversationsProvider).future,
                child: ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    final conv = conversations[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(conv['name']?[0] ?? '?'),
                      ),
                      title: Text(conv['name'] ?? ''),
                      subtitle: Text(
                        conv['lastMessage']?['text'] ?? 'No messages',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConversationScreen(
                            conversationId: conv['id'],
                            conversationName: conv['name'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateConversationScreen()),
        ),
        child: const Icon(Icons.message),
      ),
    );
  }
}
```

### 3. Groups Screen

**File**: `lib/screens/chat/group_chat_screen.dart`

**Current State**: Mock group data and messages

**Changes**:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/integrated_providers.dart';

class GroupChatScreen extends ConsumerWidget {
  final String groupId;
  
  const GroupChatScreen({required this.groupId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch group details
    final groupAsync = ref.watch(groupProvider(groupId));
    final messagesAsync = ref.watch(conversationMessagesProvider(groupId));
    
    return Scaffold(
      appBar: groupAsync.when(
        data: (group) => AppBar(
          title: Text(group['name'] ?? ''),
          subtitle: Text(
            '${group['members']?.length ?? 0} members',
          ),
        ),
        loading: () => AppBar(title: const Text('Loading...')),
        error: (_, __) => AppBar(title: const Text('Error')),
      ),
      body: messagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(child: Text('Error: $error')),
        data: (messages) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return MessageBubble(
                    message: msg['text'] ?? '',
                    senderName: msg['senderName'] ?? '',
                    isOwn: msg['senderId'] == getCurrentUserId(),
                    timestamp: msg['timestamp'],
                  );
                },
              ),
            ),
            MessageInputField(
              onSendMessage: (text) async {
                final notifier = ref.read(sendMessageProvider.notifier);
                await notifier.sendMessage(groupId, text);
                ref.invalidate(conversationMessagesProvider(groupId));
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. Calls Screen

**File**: `lib/screens/calls/calls_home_screen.dart`

**Current State**: Mock call history

**Changes**:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/integrated_providers.dart';

class CallsHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callsAsync = ref.watch(callHistoryProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Calls')),
      body: callsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(callHistoryProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (calls) => calls.isEmpty
            ? const Center(child: Text('No calls yet'))
            : ListView.builder(
                itemCount: calls.length,
                itemBuilder: (context, index) {
                  final call = calls[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        call['type'] == 'incoming'
                            ? Icons.call_received
                            : Icons.call_made,
                      ),
                    ),
                    title: Text(call['contactName'] ?? ''),
                    subtitle: Text(
                      call['date'] ?? '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.call),
                      onPressed: () => _startCall(
                        context,
                        ref,
                        call['contactId'],
                        call['contactName'],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _startCall(
    BuildContext context,
    WidgetRef ref,
    String contactId,
    String contactName,
  ) async {
    final notifier = ref.read(startCallProvider.notifier);
    await notifier.startCall(contactId);
    // Navigate to call screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          contactId: contactId,
          contactName: contactName,
        ),
      ),
    );
  }
}
```

### 5. User Profile Screen

**File**: `lib/screens/profile/user_profile_screen.dart`

**Current State**: Mock user profile data

**Changes**:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/integrated_providers.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;
  
  const UserProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider(userId));
    
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileProvider(userId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) => SingleChildScrollView(
          child: Column(
            children: [
              // Profile Header
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(profile['avatar'] ?? ''),
              ),
              const SizedBox(height: 16),
              Text(
                profile['name'] ?? '',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                profile['email'] ?? '',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              
              // Profile Info
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Phone'),
                subtitle: Text(profile['phone'] ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Location'),
                subtitle: Text(profile['location'] ?? 'N/A'),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Bio'),
                subtitle: Text(profile['bio'] ?? 'N/A'),
              ),
              
              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _startCall(
                          context,
                          ref,
                          userId,
                          profile['name'],
                        ),
                        child: const Text('Call'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _sendMessage(
                          context,
                          ref,
                          userId,
                          profile['name'],
                        ),
                        child: const Text('Message'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startCall(
    BuildContext context,
    WidgetRef ref,
    String contactId,
    String contactName,
  ) {
    // Implement call start logic
  }

  void _sendMessage(
    BuildContext context,
    WidgetRef ref,
    String contactId,
    String contactName,
  ) {
    // Navigate to conversation or create new one
  }
}
```

### 6. Groups Home Screen

**File**: `lib/screens/chat/group_home_screen.dart`

**Current State**: Mock groups list

**Changes**:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/integrated_providers.dart';

class GroupsHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Groups')),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(groupsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (groups) => groups.isEmpty
            ? const Center(child: Text('No groups yet'))
            : RefreshIndicator(
                onRefresh: () => ref.refresh(groupsProvider).future,
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(group['name'][0].toUpperCase()),
                      ),
                      title: Text(group['name']),
                      subtitle: Text(
                        '${group['members']?.length ?? 0} members',
                      ),
                      trailing: PopupMenuButton(
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Text('View'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => GroupDetailsScreen(
                                  groupId: group['id'],
                                ),
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            child: const Text('Leave'),
                            onTap: () => _leaveGroup(
                              context,
                              ref,
                              group['id'],
                            ),
                          ),
                        ],
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GroupChatScreen(
                            groupId: group['id'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _leaveGroup(BuildContext context, WidgetRef ref, String groupId) {
    // Implement leave group logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Left group')),
    );
    ref.refresh(groupsProvider);
  }
}
```

## 🎯 Migration Checklist

For each screen update:

- [ ] Replace mock data list with provider watch
- [ ] Add `ConsumerWidget` instead of `StatefulWidget`
- [ ] Add `.when()` for loading/error/data states
- [ ] Update imports to include `integrated_providers.dart`
- [ ] Test with backend running (`npm run start:dev`)
- [ ] Add error boundary/retry functionality
- [ ] Add refresh indicators where appropriate
- [ ] Test data loading and updates
- [ ] Verify no console errors

## 🧪 Testing Each Update

After updating a screen:

1. **Start backend**: `cd backend && npm run start:dev`
2. **Run app**: `flutter run`
3. **Test loading**: Screen should show loading indicator initially
4. **Test data**: Real data from backend should appear
5. **Test errors**: Kill backend and verify error handling
6. **Test refresh**: Pull to refresh should reload data
7. **Test actions**: Send messages, create groups, etc.

## 🐛 Debugging Tips

### If data doesn't load:
```dart
// Check provider state in build method
print('State: $messagesAsync');
// Should show: AsyncValue<...>
```

### If errors occur:
```dart
// Check error details
error: (error, st) {
  print('Error: $error');
  print('Stack: $st');
  return Center(child: Text('$error', textDirection: TextDirection.rtl));
},
```

### If data isn't updating:
```dart
// Manually refresh provider
ref.refresh(someProvider);

// Or invalidate to force reload
ref.invalidate(someProvider);
```

## 📝 Notes

- Always wrap screens with `ConsumerWidget` not `StatefulWidget` when using providers
- Use `.family` modifier for parameterized providers (like `userProfileProvider(userId)`)
- Call `ref.refresh()` or `ref.invalidate()` after mutations to update UI
- Error states should include retry button using `ref.refresh()`
- Loading states should show `CircularProgressIndicator`

## 🚀 Next Phase

After updating all screens:
1. Set up Socket.IO for real-time messaging
2. Configure JWT token injection
3. Implement offline database sync
4. Add comprehensive error handling
5. Set up analytics tracking
