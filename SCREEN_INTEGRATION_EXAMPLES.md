# Screen Integration Examples

This file provides ready-to-use examples for integrating screens with backend services.

## 1. Chat List Screen Integration

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/integrated_providers.dart';

class ChatListScreenIntegrated extends ConsumerWidget {
  const ChatListScreenIntegrated({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final conversationsList = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A2332) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2332) : Colors.white,
        title: const Text('Chats'),
        elevation: 0,
      ),
      body: conversationsList.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
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
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Text(
                'No conversations yet',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final convo = conversations[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(convo['avatar'] ?? '👤'),
                ),
                title: Text(convo['name']),
                subtitle: Text(convo['lastMessage'] ?? 'No message'),
                trailing: Text(convo['time'] ?? ''),
                onTap: () {
                  // Navigate to conversation
                  Navigator.pushNamed(
                    context,
                    'conversation',
                    arguments: convo['id'],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

## 2. Group Creation Screen Integration

```dart
class CreateGroupScreenIntegrated extends ConsumerStatefulWidget {
  const CreateGroupScreenIntegrated({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateGroupScreenIntegrated> createState() =>
      _CreateGroupScreenIntegratedState();
}

class _CreateGroupScreenIntegratedState
    extends ConsumerState<CreateGroupScreenIntegrated> {
  final _nameController = TextEditingController();
  final List<String> _selectedMembers = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createGroup() async {
    if (!_formKey.currentState!.validate() || _selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one member')),
      );
      return;
    }

    final createGroupNotifier = ref.read(createGroupProvider.notifier);
    
    try {
      await createGroupNotifier.createGroup(
        name: _nameController.text,
        memberIds: _selectedMembers,
        description: 'New group',
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group created successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final createGroupState = ref.watch(createGroupProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Group')),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  label: Text('Group Name'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Enter group name';
                  return null;
                },
              ),
            ),
            Expanded(
              child: MemberSelector(
                onSelectionChanged: (members) {
                  setState(() => _selectedMembers.clear());
                  _selectedMembers.addAll(members);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: createGroupState.isLoading ? null : _createGroup,
                child: createGroupState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Create Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 3. Admin Dashboard Integration

```dart
class AdminDashboardScreenIntegrated extends ConsumerWidget {
  const AdminDashboardScreenIntegrated({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dashboard = ref.watch(adminDashboardProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1419) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1A2332) : Colors.white,
        title: const Text('Admin Dashboard'),
        elevation: 0,
      ),
      body: dashboard.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading dashboard: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(adminDashboardProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Grid
              Padding(
                padding: const EdgeInsets.all(16),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStatCard(
                      isDark,
                      'Total Users',
                      '${data['totalUsers']}',
                    ),
                    _buildStatCard(
                      isDark,
                      'Active Sessions',
                      '${data['activeSessions']}',
                    ),
                    _buildStatCard(
                      isDark,
                      'Pending Issues',
                      '${data['pendingIssues']}',
                    ),
                    _buildStatCard(
                      isDark,
                      'System Uptime',
                      '${data['systemUptime']}%',
                    ),
                  ],
                ),
              ),
              // Recent Activity
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (data['recentActivity'] != null)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (data['recentActivity'] as List).length,
                  itemBuilder: (context, index) {
                    final activity = data['recentActivity'][index];
                    return ListTile(
                      title: Text(activity['description']),
                      subtitle: Text(activity['timestamp']),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(bool isDark, String label, String value) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[900] : Colors.grey[50],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
```

## 4. User Search Integration

```dart
class UserSearchScreenIntegrated extends ConsumerWidget {
  const UserSearchScreenIntegrated({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = TextEditingController();
    final searchResults = ref.watch(
      userSearchProvider(searchController.text),
    );

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
          ),
          onChanged: (value) {
            ref.refresh(userSearchProvider(value));
          },
        ),
      ),
      body: searchController.text.isEmpty
          ? const Center(
              child: Text('Start typing to search users'),
            )
          : searchResults.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
              data: (users) {
                if (users.isEmpty) {
                  return const Center(
                    child: Text('No users found'),
                  );
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user['avatar'] ?? '👤'),
                      ),
                      title: Text(user['name']),
                      subtitle: Text(user['email']),
                      onTap: () {
                        // Navigate to user profile or start conversation
                        Navigator.pushNamed(
                          context,
                          'user-profile',
                          arguments: user['id'],
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
```

## 5. Broadcast Sending Integration

```dart
class BroadcastScreenIntegrated extends ConsumerStatefulWidget {
  const BroadcastScreenIntegrated({Key? key}) : super(key: key);

  @override
  ConsumerState<BroadcastScreenIntegrated> createState() =>
      _BroadcastScreenIntegratedState();
}

class _BroadcastScreenIntegratedState
    extends ConsumerState<BroadcastScreenIntegrated> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  DateTime? _scheduledFor;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _sendBroadcast() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final broadcastNotifier = ref.read(sendBroadcastProvider.notifier);
    
    try {
      await broadcastNotifier.sendBroadcast(
        title: _titleController.text,
        content: _contentController.text,
        scheduledFor: _scheduledFor?.toIso8601String(),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Broadcast sent successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final broadcastState = ref.watch(sendBroadcastProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Send Broadcast')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  label: Text('Broadcast Title'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  label: Text('Content'),
                  border: OutlineInputBorder(),
                ),
                minLines: 5,
                maxLines: 10,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _scheduledFor == null
                          ? 'Send immediately'
                          : 'Schedule: ${_scheduledFor!}',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final picked = await showDateTimePicker(context);
                      if (picked != null) {
                        setState(() => _scheduledFor = picked);
                      }
                    },
                    child: const Text('Schedule'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: broadcastState.isLoading ? null : _sendBroadcast,
                child: broadcastState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Broadcast'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> showDateTimePicker(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }
}
```

## Integration Checklist

- [ ] Update all screen imports to use `integrated_providers.dart`
- [ ] Replace mock data with provider watch calls
- [ ] Add error handling with `.when()` pattern
- [ ] Add loading states with CircularProgressIndicator
- [ ] Implement refresh with `ref.refresh()`
- [ ] Set up error notifications with SnackBar
- [ ] Test with backend running on `localhost:3000`
- [ ] Configure Dio interceptors for auth tokens
- [ ] Add retry logic for network errors
- [ ] Implement offline fallback to local database
- [ ] Set up real-time updates with Socket.IO
- [ ] Add analytics and error tracking

## Next Steps

1. Apply these patterns to all screens
2. Configure authentication interceptor in Dio
3. Set up Socket.IO for real-time messaging
4. Implement offline sync with local database
5. Add analytics and crash reporting
6. Deploy backend API to production
7. Update API endpoints for production
