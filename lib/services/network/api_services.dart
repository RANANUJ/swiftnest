import 'package:dio/dio.dart';
import 'api_endpoints.dart';

/// User API Service - Handles all user-related API calls
class UserApiService {
  final Dio _dio;

  UserApiService(this._dio);

  /// Get user profile by ID
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.userById(userId)}',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Search users
  Future<List<dynamic>> searchUsers(String query) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.userSearch}',
        queryParameters: {'q': query},
      );
      return response.data['results'] ?? [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get all contacts
  Future<List<dynamic>> getContacts() async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.userContacts}',
      );
      return response.data['contacts'] ?? [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Sync contacts from device
  Future<Map<String, dynamic>> syncContacts(List<String> phoneNumbers) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.userSyncContacts}',
        data: {'phoneNumbers': phoneNumbers},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? e.message ?? 'An error occurred';
    }
    return e.message ?? 'Network error';
  }
}

/// Conversation API Service - Handles conversation-related API calls
class ConversationApiService {
  final Dio _dio;

  ConversationApiService(this._dio);

  /// Get all conversations
  Future<List<dynamic>> getConversations() async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.conversations}',
      );
      return response.data['conversations'] ?? [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get conversation by ID
  Future<Map<String, dynamic>> getConversation(String conversationId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.conversationById(conversationId)}',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get conversation messages
  Future<List<dynamic>> getMessages(String conversationId, {int page = 1}) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.conversationMessages(conversationId)}',
        queryParameters: {'page': page, 'limit': 50},
      );
      return response.data['messages'] ?? [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Send message
  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String content, {
    List<String>? attachments,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.conversationMessages(conversationId)}',
        data: {
          'content': content,
          if (attachments != null) 'attachments': attachments,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? e.message ?? 'An error occurred';
    }
    return e.message ?? 'Network error';
  }
}

/// Group API Service - Handles group-related API calls
class GroupApiService {
  final Dio _dio;

  GroupApiService(this._dio);

  /// Get all groups
  Future<List<dynamic>> getGroups() async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.groups}',
      );
      return response.data['groups'] ?? [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get group by ID
  Future<Map<String, dynamic>> getGroup(String groupId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.groupById(groupId)}',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create new group
  Future<Map<String, dynamic>> createGroup({
    required String name,
    required List<String> memberIds,
    String? description,
    String? avatarUrl,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.groupCreate}',
        data: {
          'name': name,
          'memberIds': memberIds,
          if (description != null) 'description': description,
          if (avatarUrl != null) 'avatarUrl': avatarUrl,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get group members
  Future<List<dynamic>> getGroupMembers(String groupId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.groupMembers(groupId)}',
      );
      return response.data['members'] ?? [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Add member to group
  Future<Map<String, dynamic>> addMember(
    String groupId,
    String userId,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.groupAddMember(groupId)}',
        data: {'userId': userId},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? e.message ?? 'An error occurred';
    }
    return e.message ?? 'Network error';
  }
}

/// Call API Service - Handles call-related API calls
class CallApiService {
  final Dio _dio;

  CallApiService(this._dio);

  /// Get call history
  Future<List<dynamic>> getCallHistory({int limit = 50}) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.callHistory}',
        queryParameters: {'limit': limit},
      );
      return response.data['calls'] ?? [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Start a call
  Future<Map<String, dynamic>> startCall({
    required String recipientId,
    required String callType, // 'audio' or 'video'
  }) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.callStart}',
        data: {
          'recipientId': recipientId,
          'callType': callType,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// End a call
  Future<Map<String, dynamic>> endCall(String callId) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.callEnd}',
        data: {'callId': callId},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? e.message ?? 'An error occurred';
    }
    return e.message ?? 'Network error';
  }
}

/// Media API Service - Handles media-related API calls
class MediaApiService {
  final Dio _dio;

  MediaApiService(this._dio);

  /// Upload media file
  Future<Map<String, dynamic>> uploadMedia(
    String filePath, {
    String? mediaType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          contentType: DioMediaType.parse('application/octet-stream'),
        ),
        if (mediaType != null) 'mediaType': mediaType,
      });

      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.mediaUpload}',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Download media file
  Future<void> downloadMedia(
    String mediaId,
    String savePath,
  ) async {
    try {
      await _dio.download(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.mediaDownload(mediaId)}',
        savePath,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? e.message ?? 'An error occurred';
    }
    return e.message ?? 'Network error';
  }
}

/// Admin API Service - Handles admin-related API calls
class AdminApiService {
  final Dio _dio;

  AdminApiService(this._dio);

  /// Get dashboard data
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.adminDashboard}',
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get analytics data
  Future<Map<String, dynamic>> getAnalytics({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.adminAnalytics}',
        queryParameters: {
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Send broadcast message
  Future<Map<String, dynamic>> sendBroadcast({
    required String title,
    required String content,
    String? scheduledFor,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.adminBroadcast}',
        data: {
          'title': title,
          'content': content,
          if (scheduledFor != null) 'scheduledFor': scheduledFor,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  String _handleDioException(DioException e) {
    if (e.response != null) {
      return e.response?.data['message'] ?? e.message ?? 'An error occurred';
    }
    return e.message ?? 'Network error';
  }
}
