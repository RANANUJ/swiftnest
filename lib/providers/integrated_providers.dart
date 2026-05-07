import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../services/network/api_services.dart';

// ============================================================================
// API SERVICE PROVIDERS (Dependencies)
// ============================================================================

/// User API Service provider
final userApiServiceProvider = Provider<UserApiService>((ref) {
  final dio = Dio();
  return UserApiService(dio);
});

/// Conversation API Service provider
final conversationApiServiceProvider = Provider<ConversationApiService>((ref) {
  final dio = Dio();
  return ConversationApiService(dio);
});

/// Group API Service provider
final groupApiServiceProvider = Provider<GroupApiService>((ref) {
  final dio = Dio();
  return GroupApiService(dio);
});

/// Call API Service provider
final callApiServiceProvider = Provider<CallApiService>((ref) {
  final dio = Dio();
  return CallApiService(dio);
});

/// Media API Service provider
final mediaApiServiceProvider = Provider<MediaApiService>((ref) {
  final dio = Dio();
  return MediaApiService(dio);
});

/// Admin API Service provider
final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  final dio = Dio();
  return AdminApiService(dio);
});

// ============================================================================
// USER PROVIDERS
// ============================================================================

/// User profile state notifier
class UserProfileNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final UserApiService _userApiService;

  UserProfileNotifier(this._userApiService) : super(const AsyncValue.loading());

  Future<void> loadUserProfile(String userId) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _userApiService.getUserProfile(userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// User profile provider
final userProfileProvider =
    StateNotifierProvider.family<UserProfileNotifier, AsyncValue<Map<String, dynamic>>, String>(
  (ref, userId) {
    final userService = ref.watch(userApiServiceProvider);
    return UserProfileNotifier(userService)..loadUserProfile(userId);
  },
);

/// User search results provider
final userSearchProvider =
    FutureProvider.family<List<dynamic>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final userService = ref.watch(userApiServiceProvider);
  return userService.searchUsers(query);
});

/// User contacts provider
final userContactsProvider = FutureProvider<List<dynamic>>((ref) async {
  final userService = ref.watch(userApiServiceProvider);
  return userService.getContacts();
});

// ============================================================================
// CONVERSATION PROVIDERS
// ============================================================================

/// Conversations list provider
final conversationsProvider = FutureProvider<List<dynamic>>((ref) async {
  final conversationService = ref.watch(conversationApiServiceProvider);
  return conversationService.getConversations();
});

/// Specific conversation provider
final conversationProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, conversationId) async {
  final conversationService = ref.watch(conversationApiServiceProvider);
  return conversationService.getConversation(conversationId);
});

/// Conversation messages provider
final conversationMessagesProvider = FutureProvider.family<List<dynamic>, String>(
  (ref, conversationId) async {
    final conversationService = ref.watch(conversationApiServiceProvider);
    return conversationService.getMessages(conversationId);
  },
);

/// Send message state notifier
class SendMessageNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final ConversationApiService _conversationApiService;

  SendMessageNotifier(this._conversationApiService) : super(const AsyncValue.data({}));

  Future<void> sendMessage(
    String conversationId,
    String content, {
    List<String>? attachments,
  }) async {
    state = const AsyncValue.loading();
    try {
      final message = await _conversationApiService.sendMessage(
        conversationId,
        content,
        attachments: attachments,
      );
      state = AsyncValue.data(message);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Send message provider
final sendMessageProvider = StateNotifierProvider
    .family<SendMessageNotifier, AsyncValue<Map<String, dynamic>>, String>(
  (ref, conversationId) {
    final conversationService = ref.watch(conversationApiServiceProvider);
    return SendMessageNotifier(conversationService);
  },
);

// ============================================================================
// GROUP PROVIDERS
// ============================================================================

/// Groups list provider
final groupsProvider = FutureProvider<List<dynamic>>((ref) async {
  final groupService = ref.watch(groupApiServiceProvider);
  return groupService.getGroups();
});

/// Specific group provider
final groupProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, groupId) async {
  final groupService = ref.watch(groupApiServiceProvider);
  return groupService.getGroup(groupId);
});

/// Group members provider
final groupMembersProvider =
    FutureProvider.family<List<dynamic>, String>((ref, groupId) async {
  final groupService = ref.watch(groupApiServiceProvider);
  return groupService.getGroupMembers(groupId);
});

/// Create group state notifier
class CreateGroupNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final GroupApiService _groupApiService;

  CreateGroupNotifier(this._groupApiService) : super(const AsyncValue.data({}));

  Future<void> createGroup({
    required String name,
    required List<String> memberIds,
    String? description,
    String? avatarUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final group = await _groupApiService.createGroup(
        name: name,
        memberIds: memberIds,
        description: description,
        avatarUrl: avatarUrl,
      );
      state = AsyncValue.data(group);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Create group provider
final createGroupProvider =
    StateNotifierProvider<CreateGroupNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final groupService = ref.watch(groupApiServiceProvider);
  return CreateGroupNotifier(groupService);
});

// ============================================================================
// CALL PROVIDERS
// ============================================================================

/// Call history provider
final callHistoryProvider = FutureProvider<List<dynamic>>((ref) async {
  final callService = ref.watch(callApiServiceProvider);
  return callService.getCallHistory();
});

/// Start call state notifier
class StartCallNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final CallApiService _callApiService;

  StartCallNotifier(this._callApiService) : super(const AsyncValue.data({}));

  Future<void> startCall({
    required String recipientId,
    required String callType,
  }) async {
    state = const AsyncValue.loading();
    try {
      final call = await _callApiService.startCall(
        recipientId: recipientId,
        callType: callType,
      );
      state = AsyncValue.data(call);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Start call provider
final startCallProvider =
    StateNotifierProvider<StartCallNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final callService = ref.watch(callApiServiceProvider);
  return StartCallNotifier(callService);
});

// ============================================================================
// MEDIA PROVIDERS
// ============================================================================

/// Upload media state notifier
class UploadMediaNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final MediaApiService _mediaApiService;

  UploadMediaNotifier(this._mediaApiService) : super(const AsyncValue.data({}));

  Future<void> uploadMedia(
    String filePath, {
    String? mediaType,
  }) async {
    state = const AsyncValue.loading();
    try {
      final media = await _mediaApiService.uploadMedia(
        filePath,
        mediaType: mediaType,
      );
      state = AsyncValue.data(media);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Upload media provider
final uploadMediaProvider =
    StateNotifierProvider<UploadMediaNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final mediaService = ref.watch(mediaApiServiceProvider);
  return UploadMediaNotifier(mediaService);
});

// ============================================================================
// ADMIN PROVIDERS
// ============================================================================

/// Admin dashboard provider
final adminDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final adminService = ref.watch(adminApiServiceProvider);
  return adminService.getDashboardData();
});

/// Admin analytics provider
final adminAnalyticsProvider =
    FutureProvider.family<Map<String, dynamic>, (String?, String?)>((ref, dates) async {
  final adminService = ref.watch(adminApiServiceProvider);
  return adminService.getAnalytics(
    startDate: dates.$1,
    endDate: dates.$2,
  );
});

/// Send broadcast state notifier
class SendBroadcastNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final AdminApiService _adminApiService;

  SendBroadcastNotifier(this._adminApiService) : super(const AsyncValue.data({}));

  Future<void> sendBroadcast({
    required String title,
    required String content,
    String? scheduledFor,
  }) async {
    state = const AsyncValue.loading();
    try {
      final broadcast = await _adminApiService.sendBroadcast(
        title: title,
        content: content,
        scheduledFor: scheduledFor,
      );
      state = AsyncValue.data(broadcast);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

/// Send broadcast provider
final sendBroadcastProvider =
    StateNotifierProvider<SendBroadcastNotifier, AsyncValue<Map<String, dynamic>>>((ref) {
  final adminService = ref.watch(adminApiServiceProvider);
  return SendBroadcastNotifier(adminService);
});
