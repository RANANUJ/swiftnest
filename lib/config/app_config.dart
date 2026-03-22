/// SwiftNest Application Configuration
/// Central place for all app constants, API endpoints, and limits
class AppConfig {
  // App Meta
  static const String appName = 'SwiftNest';
  static const String appVersion = '0.1.0';

  // API Endpoints
  static const String apiBaseUrl = 'https://api.swiftnest.com';
  static const String socketBaseUrl = 'https://socket.swiftnest.com';
  static const String mediaBaseUrl = 'https://media.swiftnest.com';

  // Timeouts (milliseconds)
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration socketConnectTimeout = Duration(seconds: 5);
  static const Duration socketReconnectDelay = Duration(seconds: 3);
  static const Duration databaseTimeout = Duration(seconds: 10);

  // Message & Content Limits
  static const int maxMessageLength = 5000;
  static const int maxGroupNameLength = 100;
  static const int maxBioLength = 500;
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int maxVideoSize = 50 * 1024 * 1024; // 50MB
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB

  // Pagination & Batching
  static const int messageBatchSize = 50;
  static const int chatListPageSize = 20;
  static const int groupMemberPageSize = 50;
  static const int searchResultsLimit = 30;

  // Cache Configuration
  static const int imageMemoryCacheSize = 50 * 1024 * 1024; // 50MB
  static const int thumbnailCacheLimit = 100;
  static const int maxCachedMessages = 500;
  static const Duration cacheExpireTime = Duration(days: 30);

  // Database Configuration
  static const String databaseName = 'swiftnest_app.db';
  static const int databaseVersion = 1;

  // Sync Configuration
  static const Duration syncInterval = Duration(minutes: 5);
  static const int maxSyncRetries = 3;
  static const Duration syncRetryBackoff = Duration(seconds: 2);
  static const int pendingQueueBatchSize = 10;

  // Media Configuration
  static const String imageCompression = 'jpeg';
  static const int imageQuality = 85;
  static const String videoCodec = 'h264';
  static const int videoQuality = 720;

  // Security
  static const int tokenRefreshThreshold = 5 * 60; // 5 minutes before expiry
  static const Duration otpExpiry = Duration(minutes: 5);
  static const int maxLoginAttempts = 5;
  static const Duration loginAttemptLockout = Duration(minutes: 15);

  // Socket.IO Configuration
  static const bool socketAutoConnect = true;
  static const bool socketReconnection = true;
  static const int socketReconnectionDelay = 1000; // ms
  static const int socketReconnectionDelayMax = 5000; // ms
  static const int socketReconnectionAttempts = 10;

  // Notification Configuration
  static const String notificationChannelId = 'swiftnest_messages';
  static const String notificationChannelName = 'SwiftNest Messages';

  // Performance Targets
  static const Duration appStartupTarget = Duration(milliseconds: 500);
  static const Duration openChatTarget = Duration(milliseconds: 300);
  static const Duration sendMessageTarget = Duration(milliseconds: 100);
  static const Duration loadThumbnailTarget = Duration(milliseconds: 200);
  static const Duration offlineSyncTarget = Duration(seconds: 2);

  // Feature Flags
  static const bool enableOfflineMode = true;
  static const bool enableMediaCompression = true;
  static const bool enableLocalNotifications = true;
  static const bool enableDetailedLogs = false; // Set to true in debug
  static const bool enableAnalytics = false;

  // Environment
  static const String environment = 'production'; // development, staging, production
  static const bool isProduction = environment == 'production';
  static const bool isDevelopment = environment == 'development';

  /// Get API token from secure storage key
  static const String tokenStorageKey = 'swiftnest_jwt_token';
  static const String refreshTokenStorageKey = 'swiftnest_refresh_token';
  static const String userIdStorageKey = 'swiftnest_user_id';
}

/// Socket.IO Event Names
class SocketEvents {
  // Connection
  static const String connect = 'connect';
  static const String disconnect = 'disconnect';
  static const String reconnect = 'reconnect';

  // Messages
  static const String messageSend = 'message:send';
  static const String messageReceived = 'message:received';
  static const String messageRead = 'message:read';
  static const String messageDelete = 'message:delete';
  static const String messageEdit = 'message:edit';

  // Typing
  static const String typingStart = 'typing:start';
  static const String typingEnd = 'typing:end';

  // User Presence
  static const String userOnline = 'user:online';
  static const String userOffline = 'user:offline';

  // Errors
  static const String error = 'error';
  static const String unauthorized = 'unauthorized';
}

/// API Endpoints
class ApiEndpoints {
  // Auth
  static const String signup = '/auth/signup';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';

  // User Profile
  static const String getCurrentUser = '/users/me';
  static const String updateProfile = '/users/me';
  static const String getUser = '/users/:userId';
  static const String searchUsers = '/users/search';
  static const String blockUser = '/users/:userId/block';
  static const String unblockUser = '/users/:userId/unblock';

  // Chats
  static const String getChats = '/chats';
  static const String createChat = '/chats';
  static const String getChat = '/chats/:chatId';
  static const String deleteChat = '/chats/:chatId';
  static const String getMessages = '/chats/:chatId/messages';
  static const String sendMessage = '/chats/:chatId/messages';

  // Media
  static const String getUploadSignature = '/media/signature';
  static const String getMediaMetadata = '/media/:mediaId';

  // Groups
  static const String createGroup = '/groups';
  static const String getGroup = '/groups/:groupId';
  static const String updateGroup = '/groups/:groupId';
  static const String addMember = '/groups/:groupId/members';
  static const String removeMember = '/groups/:groupId/members/:userId';

  // Notifications
  static const String getNotifications = '/notifications';
}

/// Error Messages
class ErrorMessages {
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorized = 'Unauthorized. Please log in again.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String userNotFound = 'User not found.';
  static const String chatNotFound = 'Chat not found.';
  static const String messageNotFound = 'Message not found.';
  static const String fileTooLarge = 'File is too large. Maximum size: 50MB.';
  static const String unsupportedFileType = 'Unsupported file type.';
}

/// Success Messages
class SuccessMessages {
  static const String messageSent = 'Message sent';
  static const String profileUpdated = 'Profile updated successfully';
  static const String chatCreated = 'Chat created';
  static const String groupCreated = 'Group created successfully';
}
