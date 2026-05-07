/// API Endpoints for SwiftNest Backend
///
/// Centralized location for all API endpoint URLs

class ApiEndpoints {
  // Base URL
  static const String baseUrl = 'http://localhost:3000/api';

  // ====================================================================
  // Auth Endpoints
  // ====================================================================
  static const String auth = '/auth';
  static const String authSignup = '$auth/signup';
  static const String authLogin = '$auth/login';
  static const String authVerifyOtp = '$auth/verify-otp';
  static const String authRefreshToken = '$auth/refresh-token';
  static const String authLogout = '$auth/logout';
  static const String authChangePassword = '$auth/change-password';

  // ====================================================================
  // User Endpoints
  // ====================================================================
  static const String users = '/users';
  static String userById(String userId) => '$users/$userId';
  static const String userProfile = '$users/profile';
  static const String userSearch = '$users/search';
  static const String userContacts = '$users/contacts';
  static const String userSyncContacts = '$users/sync-contacts';

  // ====================================================================
  // Conversation Endpoints
  // ====================================================================
  static const String conversations = '/conversations';
  static String conversationById(String conversationId) => '$conversations/$conversationId';
  static String conversationMessages(String conversationId) => '$conversations/$conversationId/messages';
  static String conversationTyping(String conversationId) => '$conversations/$conversationId/typing';

  // ====================================================================
  // Group Endpoints
  // ====================================================================
  static const String groups = '/groups';
  static String groupById(String groupId) => '$groups/$groupId';
  static const String groupCreate = '$groups';
  static String groupMembers(String groupId) => '$groups/$groupId/members';
  static String groupAddMember(String groupId) => '$groups/$groupId/add-member';
  static String groupRemoveMember(String groupId) => '$groups/$groupId/remove-member';

  // ====================================================================
  // Call Endpoints
  // ====================================================================
  static const String calls = '/calls';
  static const String callStart = '$calls/start';
  static const String callEnd = '$calls/end';
  static const String callHistory = '$calls/history';

  // ====================================================================
  // Media Endpoints
  // ====================================================================
  static const String media = '/media';
  static const String mediaUpload = '$media/upload';
  static String mediaDownload(String mediaId) => '$media/$mediaId/download';
  static String mediaDelete(String mediaId) => '$media/$mediaId';

  // ====================================================================
  // Admin Endpoints
  // ====================================================================
  static const String admin = '/admin';
  static const String adminDashboard = '$admin/dashboard';
  static const String adminUsers = '$admin/users';
  static const String adminAnalytics = '$admin/analytics';
  static const String adminBroadcast = '$admin/broadcast';
  static const String adminReports = '$admin/reports';
  static const String adminModeration = '$admin/moderation';

  // ====================================================================
  // Settings Endpoints
  // ====================================================================
  static const String settings = '/settings';
  static const String settingsPrivacy = '$settings/privacy';
  static const String settingsSecurity = '$settings/security';
  static const String settingsNotification = '$settings/notification';
}
