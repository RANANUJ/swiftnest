 # SwiftNest Integration - Provider Reference Card

## 📋 Complete Provider Reference

Quick lookup for all available providers and how to use them.

---

## 👤 User Providers

### `userProfileProvider(userId: String)`
**Type**: `FutureProvider.family<Map<String, dynamic>, String>`

Get a single user's profile information.

```dart
final profile = ref.watch(userProfileProvider('user123'));

// Usage:
profile.when(
  data: (user) => Text(user['name']),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `userSearchProvider(query: String)`
**Type**: `FutureProvider.family<List<Map>, String>`

Search for users by name or email.

```dart
final results = ref.watch(userSearchProvider('john'));

results.when(
  data: (users) => ListView(
    children: users.map((u) => Text(u['name'])).toList(),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `userContactsProvider`
**Type**: `FutureProvider<List<Map<String, dynamic>>>`

Get current user's contacts.

```dart
final contacts = ref.watch(userContactsProvider);

contacts.when(
  data: (list) => ListView(children: [...]),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `currentUserProvider`
**Type**: `FutureProvider<Map<String, dynamic>>`

Get current logged-in user's profile.

```dart
final user = ref.watch(currentUserProvider);

user.when(
  data: (profile) => Text(profile['name']),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

---

## 💬 Conversation Providers

### `conversationsProvider`
**Type**: `FutureProvider<List<Map<String, dynamic>>>`

Get all conversations for current user (all chats).

```dart
final conversations = ref.watch(conversationsProvider);

conversations.when(
  data: (list) => ListView.builder(
    itemCount: list.length,
    itemBuilder: (ctx, idx) => ListTile(title: Text(list[idx]['name'])),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `conversationProvider(conversationId: String)`
**Type**: `FutureProvider.family<Map<String, dynamic>, String>`

Get details of a specific conversation.

```dart
final conversation = ref.watch(conversationProvider('conv123'));

conversation.when(
  data: (conv) => Text(conv['name']),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `conversationMessagesProvider(conversationId: String)`
**Type**: `FutureProvider.family<List<Map>, String>`

Get all messages in a conversation.

```dart
final messages = ref.watch(conversationMessagesProvider('conv123'));

messages.when(
  data: (list) => ListView.builder(
    itemCount: list.length,
    itemBuilder: (ctx, idx) => Text(list[idx]['text']),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `sendMessageProvider`
**Type**: `StateNotifierProvider<SendMessageNotifier, AsyncValue<void>>`

Send a message to a conversation.

```dart
// Get the notifier
final notifier = ref.read(sendMessageProvider.notifier);

// Send message
await notifier.sendMessage('conv123', 'Hello!');

// Watch the state for loading/error
final state = ref.watch(sendMessageProvider);
state.when(
  data: (_) => Text('Message sent'),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Failed: $err'),
);
```

---

## 👥 Group Providers

### `groupsProvider`
**Type**: `FutureProvider<List<Map<String, dynamic>>>`

Get all groups user is member of.

```dart
final groups = ref.watch(groupsProvider);

groups.when(
  data: (list) => ListView.builder(
    itemCount: list.length,
    itemBuilder: (ctx, idx) => Text(list[idx]['name']),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `groupProvider(groupId: String)`
**Type**: `FutureProvider.family<Map<String, dynamic>, String>`

Get details of a specific group.

```dart
final group = ref.watch(groupProvider('group123'));

group.when(
  data: (g) => Text(g['name']),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `groupMembersProvider(groupId: String)`
**Type**: `FutureProvider.family<List<Map>, String>`

Get all members of a group.

```dart
final members = ref.watch(groupMembersProvider('group123'));

members.when(
  data: (list) => ListView.builder(
    itemCount: list.length,
    itemBuilder: (ctx, idx) => Text(list[idx]['name']),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `createGroupProvider`
**Type**: `StateNotifierProvider<CreateGroupNotifier, AsyncValue<void>>`

Create a new group.

```dart
// Get the notifier
final notifier = ref.read(createGroupProvider.notifier);

// Create group
await notifier.createGroup(
  name: 'Project Team',
  members: ['user1', 'user2', 'user3'],
  description: 'My team for the project',
);

// Watch the state
final state = ref.watch(createGroupProvider);
state.when(
  data: (_) => Text('Group created'),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Failed: $err'),
);

// Refresh groups list after creation
ref.refresh(groupsProvider);
```

---

## ☎️ Call Providers

### `callHistoryProvider`
**Type**: `FutureProvider<List<Map<String, dynamic>>>`

Get user's call history.

```dart
final calls = ref.watch(callHistoryProvider);

calls.when(
  data: (list) => ListView.builder(
    itemCount: list.length,
    itemBuilder: (ctx, idx) => ListTile(
      title: Text(list[idx]['contactName']),
      subtitle: Text(list[idx]['timestamp']),
    ),
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `startCallProvider`
**Type**: `StateNotifierProvider<StartCallNotifier, AsyncValue<Map>>`

Start a new call (audio or video).

```dart
// Get the notifier
final notifier = ref.read(startCallProvider.notifier);

// Start call
await notifier.startCall(
  contactId: 'user456',
  callType: 'audio', // or 'video'
);

// Watch the state
final state = ref.watch(startCallProvider);
state.when(
  data: (callData) => Text('Call ID: ${callData['callId']}'),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Failed: $err'),
);
```

### `endCallProvider`
**Type**: `StateNotifierProvider<EndCallNotifier, AsyncValue<void>>`

End an active call.

```dart
// Get the notifier
final notifier = ref.read(endCallProvider.notifier);

// End call
await notifier.endCall(callId: 'call123');

// Refresh call history
ref.refresh(callHistoryProvider);
```

---

## 📁 Media Providers

### `uploadMediaProvider`
**Type**: `StateNotifierProvider<UploadMediaNotifier, AsyncValue<Map>>`

Upload a file/image/video.

```dart
// Get the notifier
final notifier = ref.read(uploadMediaProvider.notifier);

// Upload file
await notifier.uploadMedia(
  filePath: '/path/to/file.jpg',
  mediaType: 'image', // or 'video', 'document'
);

// Watch upload progress
final state = ref.watch(uploadMediaProvider);
state.when(
  data: (result) => Text('Uploaded: ${result['url']}'),
  loading: () => LinearProgressIndicator(),
  error: (err, st) => Text('Upload failed: $err'),
);
```

### `downloadMediaProvider(mediaId: String)`
**Type**: `FutureProvider.family<String, String>`

Download a file. Returns local file path.

```dart
final filePath = ref.watch(downloadMediaProvider('media123'));

filePath.when(
  data: (path) => Text('Downloaded to: $path'),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Download failed: $err'),
);
```

---

## 🛡️ Admin Providers

### `adminDashboardProvider`
**Type**: `FutureProvider<Map<String, dynamic>>`

Get admin dashboard stats and analytics.

```dart
final dashboard = ref.watch(adminDashboardProvider);

dashboard.when(
  data: (stats) => Column(
    children: [
      Text('Users: ${stats['totalUsers']}'),
      Text('Messages: ${stats['totalMessages']}'),
      Text('Active: ${stats['activeUsers']}'),
    ],
  ),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `adminAnalyticsProvider`
**Type**: `FutureProvider<Map<String, dynamic>>`

Get detailed system analytics.

```dart
final analytics = ref.watch(adminAnalyticsProvider);

analytics.when(
  data: (data) => Text('Avg response: ${data['avgResponseTime']}ms'),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Error: $err'),
);
```

### `sendBroadcastProvider`
**Type**: `StateNotifierProvider<SendBroadcastNotifier, AsyncValue<void>>`

Send a broadcast message to multiple users or groups.

```dart
// Get the notifier
final notifier = ref.read(sendBroadcastProvider.notifier);

// Send broadcast
await notifier.sendBroadcast(
  title: 'Important Update',
  message: 'Check the app for new features',
  recipientIds: ['user1', 'user2', 'user3'],
  scheduleTime: DateTime.now().add(Duration(hours: 1)),
);

// Watch the state
final state = ref.watch(sendBroadcastProvider);
state.when(
  data: (_) => Text('Broadcast sent'),
  loading: () => CircularProgressIndicator(),
  error: (err, st) => Text('Failed: $err'),
);
```

---

## 🔌 Service Providers (Low-level)

### `userApiServiceProvider`
**Type**: `Provider<UserApiService>`

Direct access to user API service.

```dart
// Only use if you need direct service access
final service = ref.watch(userApiServiceProvider);
```

### `conversationApiServiceProvider`
**Type**: `Provider<ConversationApiService>`

Direct access to conversation API service.

### `groupApiServiceProvider`
**Type**: `Provider<GroupApiService>`

Direct access to group API service.

### `callApiServiceProvider`
**Type**: `Provider<CallApiService>`

Direct access to call API service.

### `mediaApiServiceProvider`
**Type**: `Provider<MediaApiService>`

Direct access to media API service.

### `adminApiServiceProvider`
**Type**: `Provider<AdminApiService>`

Direct access to admin API service.

---

## 🎯 Common Patterns

### Loading + Error + Data
```dart
final data = ref.watch(someProvider);

data.when(
  loading: () => Center(child: CircularProgressIndicator()),
  error: (error, stackTrace) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Error: $error'),
        ElevatedButton(
          onPressed: () => ref.refresh(someProvider),
          child: const Text('Retry'),
        ),
      ],
    ),
  ),
  data: (content) => ListView(...),
);
```

### Sending Data (StateNotifier)
```dart
// Get notifier and send
final notifier = ref.read(sendMessageProvider.notifier);
await notifier.sendMessage('conv123', 'Hello');

// Optionally watch state
final state = ref.watch(sendMessageProvider);

// Refresh related provider
ref.refresh(conversationMessagesProvider('conv123'));
```

### Refresh Data
```dart
// Full refresh (makes new API call)
ref.refresh(someProvider);

// Invalidate cache (soft refresh)
ref.invalidate(someProvider);
```

### Parameterized Providers
```dart
// Access by parameter
final user1 = ref.watch(userProfileProvider('user1'));
final user2 = ref.watch(userProfileProvider('user2'));

// Each has separate cache
```

### Watch Multiple Providers
```dart
final user = ref.watch(currentUserProvider);
final conversations = ref.watch(conversationsProvider);

// Both load in parallel
```

---

## 🚨 Error Handling

```dart
// Always include error state
data.when(
  error: (error, stackTrace) {
    // Useful error properties:
    if (error is DioException) {
      // API error
      print('Status: ${error.response?.statusCode}');
      print('Message: ${error.message}');
    } else if (error is TimeoutException) {
      // Network timeout
    } else {
      // Other error
    }
    
    return Center(child: Text('Error: $error'));
  },
  // ...
);
```

---

## 📊 State Types

### AsyncValue States
- **Loading**: Data is being fetched
- **Error**: Error occurred during fetch
- **Data**: Successfully loaded data

```dart
// Check current state
if (data is AsyncLoading) { /* ... */ }
if (data is AsyncError) { /* ERROR: ${data.error} */ }
if (data is AsyncData) { /* data.value contains data */ }
```

---

## 🔄 Refresh Strategies

```dart
// Method 1: Manual refresh when needed
ElevatedButton(
  onPressed: () => ref.refresh(someProvider),
  child: Text('Reload'),
);

// Method 2: Pull to refresh
RefreshIndicator(
  onRefresh: () => ref.refresh(someProvider).future,
  child: ListView(...),
);

// Method 3: Periodic refresh
ref.listen(
  someProvider,
  (previous, next) {
    // Refresh every 30 seconds
    Future.delayed(Duration(seconds: 30), 
      () => ref.refresh(someProvider),
    );
  },
);
```

---

## 💾 Best Practices

1. **Use ConsumerWidget** for widgets that watch providers
2. **Watch, don't read** when building UI (updates automatically)
3. **Read from StateNotifier** when you need to call methods
4. **Always handle loading/error** states in UI
5. **Refresh after mutations** (create, update, delete)
6. **Use .family** for parameterized data
7. **Don't call .watch()** in event handlers - use .read() instead
8. **Cache data** - providers handle caching automatically

---

## 🧪 Quick Test Template

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/integrated_providers.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Test')),
        body: const TestScreen(),
      ),
    );
  }
}

class TestScreen extends ConsumerWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(conversationsProvider);
    
    return data.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
      data: (conversations) => ListView(
        children: conversations
            .map((c) => ListTile(title: Text(c['name'])))
            .toList(),
      ),
    );
  }
}
```

---

## 🔗 Related Files

- API Services: `lib/services/network/api_services.dart`
- API Endpoints: `lib/services/network/api_endpoints.dart`
- Providers: `lib/providers/integrated_providers.dart`
- Integration Guide: `BACKEND_INTEGRATION_SETUP.md`
- Screen Examples: `SCREEN_INTEGRATION_EXAMPLES.md`
- Manual Guide: `SCREEN_INTEGRATION_MANUAL.md`
