import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/auth_models.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/chat/conversation_screen.dart';
import '../screens/home/chat_list_screen.dart';
import '../screens/splash/splash_screen.dart';

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

        // Login route
        GoRoute(
          path: '/login',
          name: 'login',
          builder: (context, state) => const LoginScreen(),
          routes: [
            // Signup route (nested under login for UX)
            GoRoute(
              path: 'signup',
              name: 'signup',
              builder: (context, state) => const SignupScreen(),
            ),
          ],
        ),

        // Home route (chat list)
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const ChatListScreen(),
          routes: [
            // Conversation route (nested under home)
            GoRoute(
              path: 'chat/:chatId',
              name: 'conversation',
              builder: (context, state) {
                final chatId = state.pathParameters['chatId'] ?? '';
                final userName = state.uri.queryParameters['name'] ?? 'Chat';
                
                return ConversationScreen(
                  chatId: chatId,
                  userName: userName,
                );
              },
            ),
          ],
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
