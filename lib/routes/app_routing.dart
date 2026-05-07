import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/auth_models.dart';
import '../screens/auth/auth_selection_screen.dart';
import '../screens/auth/login_screen_new.dart';
import '../screens/auth/signup_screen_new.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/profile/create_profile_screen.dart';
import '../screens/profile/contact_sync_screen.dart';
import '../screens/home/chat_list_screen_new.dart';
import '../screens/chat/conversation_screen.dart';
import '../screens/chat/attachment_options_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/groups/groups_home_screen.dart';
import '../screens/groups/create_group_screen.dart';
import '../screens/groups/group_chat_screen.dart';
import '../screens/groups/group_info_screen.dart';
import '../screens/groups/admin_controls_screen.dart';
import '../screens/calls/calls_home_screen.dart';
import '../screens/calls/incoming_call_screen.dart';
import '../screens/calls/ongoing_call_screen.dart';
import '../screens/downloads/downloads_manager_screen.dart';
import '../screens/downloads/media_viewer_screen.dart';
import '../screens/downloads/file_viewer_screen.dart';
import '../screens/search/global_search_screen.dart';
import '../screens/profile/my_profile_screen.dart';
import '../screens/profile/user_profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/account_setting_screen.dart';
import '../screens/settings/privacy_setting_screen.dart';
import '../screens/settings/chat_setting_screen.dart';
import '../screens/settings/notification_setting_screen.dart';
import '../screens/settings/storage_and_data_setting_screen.dart';
import '../screens/settings/security_setting_screen.dart';
import '../screens/settings/help_and_support_screen.dart';
import '../screens/settings/developer_settings_screen.dart';
import '../screens/security/biometric_lock_screen.dart';
import '../screens/security/two_factor_auth_screen.dart';
import '../screens/security/active_sessions_detail_screen.dart';
import '../screens/security/blocked_users_screen.dart';
import '../screens/security/privacy_actions_screen.dart';
import '../screens/offline/offline_mode_screen.dart';
import '../screens/offline/syncing_data_screen.dart';
import '../screens/offline/cached_chat_screen.dart';
import '../screens/offline/offline_media_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/empty_states/empty_state_no_chat_screen.dart';
import '../screens/empty_states/empty_state_no_group_screen.dart';
import '../screens/empty_states/empty_state_no_download_screen.dart';
import '../screens/empty_states/empty_state_no_notification_screen.dart';
import '../screens/empty_states/empty_state_no_search_result_screen.dart';

/// GoRouter configuration for SwiftNest navigation
/// 
/// Navigation flow:
/// - Splash (checks auth status)
/// - Login/Signup (public routes)
/// - Home (protected, requires auth)
/// - Conversation (protected, requires auth)
/// 
/// Uses route guards to prevent unauthorized access
class AppRouter {
  /// Create GoRouter instance with configured routes
  static GoRouter createRouter(AuthState authState) {
    return GoRouter(
      // Initial route based on auth state
      initialLocation: _getInitialRoute(authState),

      // List of routes
      routes: [
        // Splash screen
        GoRoute(
          path: '/',
          name: 'splash',
          builder: (context, state) => const SplashScreen(),
        ),

        // Onboarding route
        GoRoute(
          path: '/onboarding',
          name: 'onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),

        // Auth Selection route
        GoRoute(
          path: '/auth-selection',
          name: 'auth-selection',
          builder: (context, state) => const AuthSelectionScreen(),
        ),

        // Login route
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreenNew(),
        ),

        // Signup route
        GoRoute(
          path: '/signup',
          name: 'signup',
          builder: (context, state) => const SignupScreen(),
        ),

        // OTP Verification route
        GoRoute(
          path: '/otp-verification',
          name: 'otp-verification',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            return OtpVerificationScreen(
              email: args?['email'] as String?,
              phone: args?['phone'] as String?,
              type: args?['type'] as String? ?? 'signup',
            );
          },
        ),

        // Forgot Password route
        GoRoute(
          path: '/forgot-password',
          name: 'forgot-password',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            return ForgotPasswordScreen(
              isPhone: args?['isPhone'] as bool? ?? false,
            );
          },
        ),

        // Reset Password route
        GoRoute(
          path: '/reset-password',
          name: 'reset-password',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            return ResetPasswordScreen(
              emailOrPhone: args?['emailOrPhone'] as String? ?? '',
              isPhone: args?['isPhone'] as bool? ?? false,
            );
          },
        ),

        // Create Profile route
        GoRoute(
          path: '/create-profile',
          name: 'create-profile',
          builder: (context, state) => const CreateProfileScreen(),
        ),

        // Contact Sync route
        GoRoute(
          path: '/contact-sync',
          name: 'contact-sync',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            return ContactSyncScreen(
              fullName: args?['fullName'] as String?,
              username: args?['username'] as String?,
              bio: args?['bio'] as String?,
            );
          },
        ),

        // Home route (chat list)
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const ChatListScreenNew(),
          routes: [
            // Conversation route (nested under home)
            GoRoute(
              path: 'conversation',
              name: 'conversation',
              builder: (context, state) {
                final args = state.extra as Map<String, dynamic>?;
                final contactName = args?['contactName'] as String? ?? 'Contact';
                final isOnline = args?['isOnline'] as bool? ?? true;
                
                return ConversationScreen(
                  contactName: contactName,
                  isOnline: isOnline,
                );
              },
            ),
          ],
        ),

        // Groups Home route
        GoRoute(
          path: '/groups',
          name: 'groups',
          builder: (context, state) => const GroupsHomeScreen(),
        ),

        // Create Group route
        GoRoute(
          path: '/create-group',
          name: 'create-group',
          builder: (context, state) => const CreateGroupScreen(),
        ),

        // Group Chat route
        GoRoute(
          path: '/group-chat',
          name: 'group-chat',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final groupName = args?['groupName'] as String? ?? 'Group';
            final groupId = args?['groupId'] as String? ?? '';
            
            return GroupChatScreen(
              groupName: groupName,
              groupId: groupId,
            );
          },
        ),

        // Group Info route
        GoRoute(
          path: '/group-info',
          name: 'group-info',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final groupName = args?['groupName'] as String? ?? 'Group';
            final groupId = args?['groupId'] as String? ?? '';
            
            return GroupInfoScreen(
              groupName: groupName,
              groupId: groupId,
            );
          },
        ),

        // Admin Controls route
        GoRoute(
          path: '/admin-controls',
          name: 'admin-controls',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final groupName = args?['groupName'] as String? ?? 'Group';
            final groupId = args?['groupId'] as String? ?? '';
            
            return AdminControlsScreen(
              groupName: groupName,
              groupId: groupId,
            );
          },
        ),

        // Attachment Options route
        GoRoute(
          path: '/attachment-options',
          name: 'attachment-options',
          builder: (context, state) => AttachmentOptionsScreen(
            onAttachmentSelected: (attachment) {
              Navigator.pop(context, attachment);
            },
          ),
        ),

        // Calls Home route
        GoRoute(
          path: '/calls',
          name: 'calls',
          builder: (context, state) => const CallsHomeScreen(),
        ),

        // Incoming Call route
        GoRoute(
          path: '/incoming-call',
          name: 'incoming-call',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final callerName = args?['callerName'] as String? ?? 'Unknown';
            final callerAvatar = args?['callerAvatar'] as String? ?? '👤';
            final callType = args?['callType'] as String? ?? 'audio';
            
            return IncomingCallScreen(
              callerName: callerName,
              callerAvatar: callerAvatar,
              callType: callType,
            );
          },
        ),

        // Ongoing Call route
        GoRoute(
          path: '/ongoing-call',
          name: 'ongoing-call',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final callerName = args?['callerName'] as String? ?? 'Unknown';
            final callerAvatar = args?['callerAvatar'] as String? ?? '👤';
            final callType = args?['callType'] as String? ?? 'audio';
            
            return OngoingCallScreen(
              callerName: callerName,
              callerAvatar: callerAvatar,
              callType: callType,
            );
          },
        ),

        // Downloads Manager route
        GoRoute(
          path: '/downloads',
          name: 'downloads',
          builder: (context, state) => const DownloadsManagerScreen(),
        ),

        // Media Viewer route
        GoRoute(
          path: '/media-viewer',
          name: 'media-viewer',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final fileName = args?['fileName'] as String?;
            final fileSize = args?['fileSize'] as String?;
            final timestamp = args?['timestamp'] as String?;
            
            return MediaViewerScreen(
              fileName: fileName,
              fileSize: fileSize,
              timestamp: timestamp,
            );
          },
        ),

        // File Viewer route
        GoRoute(
          path: '/file-viewer',
          name: 'file-viewer',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final fileName = args?['fileName'] as String?;
            final fileSize = args?['fileSize'] as String?;
            
            return FileViewerScreen(
              fileName: fileName,
              fileSize: fileSize,
            );
          },
        ),

        // Global Search route
        GoRoute(
          path: '/global-search',
          name: 'global-search',
          builder: (context, state) => const GlobalSearchScreen(),
        ),

        // My Profile route
        GoRoute(
          path: '/my-profile',
          name: 'my-profile',
          builder: (context, state) => const MyProfileScreen(),
        ),

        // User Profile route
        GoRoute(
          path: '/user-profile',
          name: 'user-profile',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final userName = args?['userName'] as String? ?? 'User';
            final userUsername = args?['userUsername'] as String? ?? '@user';
            final userBio = args?['userBio'] as String?;
            
            return UserProfileScreen(
              userName: userName,
              userUsername: userUsername,
              userBio: userBio,
            );
          },
        ),

        // Edit Profile route
        GoRoute(
          path: '/edit-profile',
          name: 'edit-profile',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>?;
            final fullName = args?['fullName'] as String?;
            final username = args?['username'] as String?;
            final bio = args?['bio'] as String?;
            
            return EditProfileScreen(
              initialFullName: fullName,
              initialUsername: username,
              initialBio: bio,
            );
          },
        ),

        // Account Settings route
        GoRoute(
          path: '/account-settings',
          name: 'account-settings',
          builder: (context, state) => const AccountSettingScreen(),
        ),

        // Privacy Settings route
        GoRoute(
          path: '/privacy-settings',
          name: 'privacy-settings',
          builder: (context, state) => const PrivacySettingScreen(),
        ),

        // Chat Settings route
        GoRoute(
          path: '/chat-settings',
          name: 'chat-settings',
          builder: (context, state) => const ChatSettingScreen(),
        ),

        // Notification Settings route
        GoRoute(
          path: '/notification-settings',
          name: 'notification-settings',
          builder: (context, state) => const NotificationSettingScreen(),
        ),

        // Storage and Data Settings route
        GoRoute(
          path: '/storage-settings',
          name: 'storage-settings',
          builder: (context, state) => const StorageAndDataSettingScreen(),
        ),

        // Security Settings route
        GoRoute(
          path: '/security-settings',
          name: 'security-settings',
          builder: (context, state) => const SecuritySettingScreen(),
        ),

        // Help and Support route
        GoRoute(
          path: '/help-support',
          name: 'help-support',
          builder: (context, state) => const HelpAndSupportScreen(),
        ),

        // Developer Settings route
        GoRoute(
          path: '/developer-settings',
          name: 'developer-settings',
          builder: (context, state) => const DeveloperSettingsScreen(),
        ),

        // Biometric Lock route
        GoRoute(
          path: '/biometric-lock',
          name: 'biometric-lock',
          builder: (context, state) => const BiometricLockScreen(),
        ),

        // Two Factor Auth route
        GoRoute(
          path: '/two-factor-auth',
          name: 'two-factor-auth',
          builder: (context, state) => const TwoFactorAuthScreen(),
        ),

        // Active Sessions Detail route
        GoRoute(
          path: '/active-sessions-detail',
          name: 'active-sessions-detail',
          builder: (context, state) => const ActiveSessionsDetailScreen(),
        ),

        // Blocked Users route
        GoRoute(
          path: '/blocked-users',
          name: 'blocked-users',
          builder: (context, state) => const BlockedUsersScreen(),
        ),

        // Privacy Actions route
        GoRoute(
          path: '/privacy-actions',
          name: 'privacy-actions',
          builder: (context, state) => const PrivacyActionsScreen(),
        ),

        // Offline Mode route
        GoRoute(
          path: '/offline-mode',
          name: 'offline-mode',
          builder: (context, state) => const OfflineModeScreen(),
        ),

        // Syncing Data route
        GoRoute(
          path: '/syncing-data',
          name: 'syncing-data',
          builder: (context, state) => const SyncingDataScreen(),
        ),

        // Cached Chat route
        GoRoute(
          path: '/cached-chat',
          name: 'cached-chat',
          builder: (context, state) => const CachedChatScreen(),
        ),

        // Offline Media route
        GoRoute(
          path: '/offline-media',
          name: 'offline-media',
          builder: (context, state) => const OfflineMediaScreen(),
        ),

        // Notifications route
        GoRoute(
          path: '/notifications',
          name: 'notifications',
          builder: (context, state) => const NotificationsScreen(),
        ),

        // Empty State: No Chat
        GoRoute(
          path: '/empty-no-chat',
          name: 'empty-no-chat',
          builder: (context, state) => const EmptyStateNoChatScreen(),
        ),

        // Empty State: No Group
        GoRoute(
          path: '/empty-no-group',
          name: 'empty-no-group',
          builder: (context, state) => const EmptyStateNoGroupScreen(),
        ),

        // Empty State: No Download
        GoRoute(
          path: '/empty-no-download',
          name: 'empty-no-download',
          builder: (context, state) => const EmptyStateNoDownloadScreen(),
        ),

        // Empty State: No Notification
        GoRoute(
          path: '/empty-no-notification',
          name: 'empty-no-notification',
          builder: (context, state) => const EmptyStateNoNotificationScreen(),
        ),

        // Empty State: No Search Result
        GoRoute(
          path: '/empty-no-search-result',
          name: 'empty-no-search-result',
          builder: (context, state) => const EmptyStateNoSearchResultScreen(),
        ),
      ],

      // Handle 404
      errorPageBuilder: (context, state) => MaterialPage(
        child: _ErrorPage(error: state.error),
      ),
    );
  }

  /// Determine initial route based on auth state
  static String _getInitialRoute(AuthState authState) {
    switch (authState) {
      case AuthState.authenticated:
        return '/home';
      case AuthState.unauthenticated:
      case AuthState.error:
        return '/login';
      case AuthState.loading:
      case AuthState.initial:
        return '/';
    }
  }
}

/// Error page widget
class _ErrorPage extends StatelessWidget {
  final Exception? error;

  const _ErrorPage({this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            if (error != null)
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper extension for easier navigation
extension GoRouterExtension on BuildContext {
  /// Navigate to login
  void goToLogin() => go('/login');

  /// Navigate to signup
  void goToSignup() => go('/login/signup');

  /// Navigate to home/chat list
  void goToHome() => go('/home');

  /// Navigate to conversation
  void goToConversation({
    required String chatId,
    required String userName,
  }) {
    final encodedName = Uri.encodeComponent(userName);
    push('/home/chat/$chatId?name=$encodedName');
  }

  /// Navigate back
  void back() => pop();
}

/// Alternative route names (use with named routes)
class RouteNames {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String home = 'home';
  static const String conversation = 'conversation';
  static const String notFound = '404';
}

/// Result models for route returns
class ConversationResult {
  final String? messageId;
  final bool isSent;

  ConversationResult({
    this.messageId,
    this.isSent = false,
  });
}

class LoginResult {
  final bool success;
  final String? userId;
  final String? error;

  LoginResult({
    required this.success,
    this.userId,
    this.error,
  });
}
