# SwiftNest Backend Integration Guide

## Overview

This guide explains how to integrate backend API services with Flutter screens using Riverpod providers.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Flutter Screens                     │
├─────────────────────────────────────────────────────┤
│              Riverpod Providers Layer                │
│  (integrated_providers.dart)                        │
├─────────────────────────────────────────────────────┤
│         API Service Layer (api_services.dart)        │
│  - UserApiService                                   │
│  - ConversationApiService                           │
│  - GroupApiService                                  │
│  - CallApiService                                   │
│  - MediaApiService                                  │
│  - AdminApiService                                  │
├─────────────────────────────────────────────────────┤
│         API Endpoints (api_endpoints.dart)           │
├─────────────────────────────────────────────────────┤
│            Dio HTTP Client                          │
├─────────────────────────────────────────────────────┤
│          Backend API (NestJS)                       │
│          :3000/api/{endpoint}                       │
└─────────────────────────────────────────────────────┘
```

## File Structure

```
lib/
├── providers/
│   ├── auth_provider.dart          # Authentication
│   ├── integrated_providers.dart    # All backend providers
│   ├── chat_list_provider.dart      # Chat list management
│   ├── conversation_provider.dart   # Conversation details
│   └── database_provider.dart       # Local database
│
├── services/
│   ├── network/
│   │   ├── api_client.dart         # HTTP client with auth
│   │   ├── api_endpoints.dart      # Centralized endpoints
│   │   └── api_services.dart       # Service implementations
│   │
│   ├── database/                   # Drift database
│   ├── socket/                     # Socket.IO real-time
│   ├── sync/                       # Offline sync
│   └── media/                      # Media handling
│
└── screens/
    ├── chat/
    ├── groups/
    ├── calls/
    ├── admin/
    └── ... (other screens)
```

## Usage Examples

### 1. Loading User Profile

```dart
class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the user profile provider
    final userProfile = ref.watch(userProfileProvider(userId));

    return userProfile.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
      data: (profile) => Column(
        children: [
          Text(profile['name']),
          Text(profile['email']),
          // ... display other profile data
        ],
      ),
    );
  }
}
```

### 2. Sending a Message

```dart
class ConversationScreen extends ConsumerWidget {
  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sendMessageNotifier = ref.read(sendMessageProvider(conversationId).notifier);

    void sendMessage(String content) async {
      await sendMessageNotifier.sendMessage(
        conversationId,
        content,
      );
      // Message sent - update UI
    }

    return Column(
      children: [
        // Message list
        MessageInput(
          onSend: sendMessage,
        ),
      ],
    );
  }
}
```

### 3. Creating a Group

```dart
class CreateGroupScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createGroupNotifier = ref.read(createGroupProvider.notifier);

    Future<void> createNewGroup({
      required String name,
      required List<String> memberIds,
    }) async {
      await createGroupNotifier.createGroup(
        name: name,
        memberIds: memberIds,
        description: 'Group description',
      );
      // Group created - navigate away
      if (context.mounted) Navigator.pop(context);
    }

    return Scaffold(
      body: Column(
        children: [
          // Form fields
          ElevatedButton(
            onPressed: () => createNewGroup(
              name: 'My Group',
              memberIds: ['user1', 'user2'],
            ),
            child: const Text('Create Group'),
          ),
        ],
      ),
    );
  }
}
```

### 4. Loading Call History

```dart
class CallsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callHistory = ref.watch(callHistoryProvider);

    return callHistory.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (calls) => ListView.builder(
        itemCount: calls.length,
        itemBuilder: (context, index) {
          final call = calls[index];
          return ListTile(
            title: Text(call['name']),
            subtitle: Text(call['duration']),
          );
        },
      ),
    );
  }
}
```

### 5. Admin Dashboard

```dart
class AdminDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(adminDashboardProvider);

    return dashboard.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (data) => Column(
        children: [
          Text('Total Users: ${data['totalUsers']}'),
          Text('Active Sessions: ${data['activeSessions']}'),
          Text('System Health: ${data['systemHealth']}'),
        ],
      ),
    );
  }
}
```

### 6. Sending Broadcast Message

```dart
class BroadcastScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final broadcastNotifier = ref.read(sendBroadcastProvider.notifier);

    Future<void> sendBroadcast(String title, String content) async {
      await broadcastNotifier.sendBroadcast(
        title: title,
        content: content,
        scheduledFor: null, // or a specific date
      );
      // Broadcast sent
    }

    return Scaffold(
      body: Column(
        children: [
          // Form fields
          ElevatedButton(
            onPressed: () => sendBroadcast(
              'Update',
              'New features available',
            ),
            child: const Text('Send Broadcast'),
          ),
        ],
      ),
    );
  }
}
```

## Backend API Endpoints

### Auth
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/verify-otp` - Verify OTP
- `POST /api/auth/refresh-token` - Refresh JWT token
- `POST /api/auth/logout` - Logout user

### Users
- `GET /api/users/{userId}` - Get user profile
- `GET /api/users/search?q=query` - Search users
- `GET /api/users/contacts` - Get all contacts
- `POST /api/users/sync-contacts` - Sync device contacts

### Conversations
- `GET /api/conversations` - Get all conversations
- `GET /api/conversations/{id}` - Get specific conversation
- `GET /api/conversations/{id}/messages?page=1` - Get messages
- `POST /api/conversations/{id}/messages` - Send message

### Groups
- `GET /api/groups` - Get all groups
- `POST /api/groups` - Create new group
- `GET /api/groups/{id}` - Get group details
- `GET /api/groups/{id}/members` - Get group members
- `POST /api/groups/{id}/add-member` - Add member
- `POST /api/groups/{id}/remove-member` - Remove member

### Calls
- `GET /api/calls/history?limit=50` - Get call history
- `POST /api/calls/start` - Start call
- `POST /api/calls/end` - End call

### Media
- `POST /api/media/upload` - Upload file
- `GET /api/media/{id}/download` - Download file
- `DELETE /api/media/{id}` - Delete media

### Admin
- `GET /api/admin/dashboard` - Get dashboard data
- `GET /api/admin/analytics` - Get analytics
- `POST /api/admin/broadcast` - Send broadcast
- `GET /api/admin/users` - Get all users
- `GET /api/admin/reports` - Get reports
- `GET /api/admin/moderation` - Get moderation queue

## Provider Patterns

### FutureProvider (Read-only data)
Use for fetching data that doesn't change frequently:
```dart
final userContactsProvider = FutureProvider<List<dynamic>>((ref) async {
  final userService = ref.watch(userApiServiceProvider);
  return userService.getContacts();
});
```

### StateNotifierProvider (Mutable data)
Use for operations that modify data:
```dart
final sendMessageProvider = StateNotifierProvider
    .family<SendMessageNotifier, AsyncValue<Map<String, dynamic>>, String>(
  (ref, conversationId) { ... }
);
```

### .family modifier
Use to scope providers by parameter:
```dart
// Without family - all users share same provider
/final userProvider = FutureProvider<Map>((ref) { ... });

// With family - each userId gets own provider
final userProvider = FutureProvider.family<Map, String>((ref, userId) { ... });
```

## Error Handling

```dart
final data = ref.watch(someProvider);

data.when(
  loading: () => LoadingWidget(),
  error: (error, stack) {
    // Error occurred
    debugPrintStack(stackTrace: stack);
    return ErrorWidget(error: error.toString());
  },
  data: (data) => DataWidget(data: data),
);
```

## Real-time Updates with Socket.IO

For real-time messaging and presence:

```dart
// Socket service is available in services/socket/
// Automatically syncs with REST API
// Supports:
// - Real-time messages
// - Typing indicators
// - Online/offline status
// - Call notifications
```

## Offline Support

Data is synced with local database for offline access:

```dart
// When offline:
// 1. Messages are queued locally
// 2. Changes are cached
// 3. When online, sync service uploads changes
// 4. Database automatically syncs with server

// Check offline status:
ref.watch(isOnlineProvider) // true if connected
```

## Performance Tips

1. **Use .family for list items** - Creates separate provider instances
2. **Use invalidate() to refresh** - Force provider update
3. **Cache at provider level** - Providers are cached by default
4. **Pagination** - Use page parameter in list providers
5. **Use watch() in build** - Automatic subscription/unsubscription

```dart
// Refresh data
ref.refresh(userProfileProvider(userId));

// Invalidate causing rebuild
ref.invalidate(userProfileProvider);
```

## Testing

```dart
test('load user profile', () async {
  final container = ProviderContainer();
  
  final userProfile = await container.read(userProfileProvider('123').future);
  
  expect(userProfile['name'], 'John Doe');
});
```

## Next Steps

1. Update all screens to use integrated providers
2. Set up error handling and loading states
3. Configure authentication token injection
4. Implement offline sync
5. Add real-time Socket.IO support
6. Set up analytics and crash reporting
