import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_models.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/token_storage.dart';
import '../services/network/api_client.dart';

// ============================================================================
// BASIC PROVIDERS (Dependencies)
// ============================================================================

/// Token storage provider
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

/// API client provider (depends on token storage)
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: tokenStorage);
});

/// Auth service provider (depends on API client and token storage)
final authServiceProvider = Provider<AuthService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);

  return AuthService(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
});

// ============================================================================
// STATE PROVIDERS (Authentication State)
// ============================================================================

/// Current user state
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return CurrentUserNotifier(authService);
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(null) {
    _loadCurrentUser();
  }

  /// Load current user from auth service
  Future<void> _loadCurrentUser() async {
    state = _authService.currentUser;
  }

  /// Update current user
  void setUser(UserModel user) {
    state = user;
  }

  /// Clear current user
  void clearUser() {
    state = null;
  }
}

/// Authentication state (login/logout state)
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(AuthState.initial) {
    _checkAuthStatus();
  }

  /// Check if user is authenticated
  Future<void> _checkAuthStatus() async {
    final isLoggedIn = await _authService.getAccessToken();
    state = isLoggedIn != null ? AuthState.authenticated : AuthState.unauthenticated;
  }

  /// Mark as loading
  void setLoading() {
    state = AuthState.loading;
  }

  /// Mark as authenticated
  void setAuthenticated() {
    state = AuthState.authenticated;
  }

  /// Mark as unauthenticated
  void setUnauthenticated() {
    state = AuthState.unauthenticated;
  }

  /// Mark as error
  void setError() {
    state = AuthState.error;
  }

  /// Mark as initial
  void setInitial() {
    state = AuthState.initial;
  }
}

// ============================================================================
// OPERATION PROVIDERS (Async operations with state)
// ============================================================================

/// Login operation
final loginProvider = StateNotifierProvider<LoginNotifier, AsyncValue<AuthResponse?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return LoginNotifier(authService, ref);
});

class LoginNotifier extends StateNotifier<AsyncValue<AuthResponse?>> {
  final AuthService _authService;
  final Ref _ref;

  LoginNotifier(this._authService, this._ref) : super(const AsyncValue.data(null));

  /// Perform login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = AsyncValue.loading();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      // Update user
      _ref.read(currentUserProvider.notifier).setUser(result.user);
      _ref.read(authStateProvider.notifier).setAuthenticated();

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _ref.read(authStateProvider.notifier).setError();
    }
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Signup operation
final signupProvider = StateNotifierProvider<SignupNotifier, AsyncValue<AuthResponse?>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SignupNotifier(authService, ref);
});

class SignupNotifier extends StateNotifier<AsyncValue<AuthResponse?>> {
  final AuthService _authService;
  final Ref _ref;

  SignupNotifier(this._authService, this._ref) : super(const AsyncValue.data(null));

  /// Perform signup - Creates account but does NOT authenticate yet
  /// User must verify OTP before access
  Future<void> signup({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? avatar,
  }) async {
    state = AsyncValue.loading();

    try {
      // IMPORTANT: Ensure no tokens are present from previous sessions
      // This prevents accidental auto-authentication
      await _authService.logout();
      
      final result = await _authService.signup(
        email: email,
        password: password,
        name: name,
        phone: phone,
        avatar: avatar,
      );

      // Verify that NO tokens were saved (security check)
      final hasToken = await _authService.getAccessToken();
      if (hasToken != null) {
        print('[Signup] WARNING: Token was saved during signup! Clearing it.');
        await _authService.logout();
      }

      // Store signup response but DO NOT authenticate
      // User must verify OTP first, then complete profile
      state = AsyncValue.data(result);
      
      print('[Signup] Account created. Token NOT saved. User must verify OTP before access.');
      _ref.read(authStateProvider.notifier).setUnauthenticated();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _ref.read(authStateProvider.notifier).setUnauthenticated();
    }
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Logout operation
final logoutProvider = FutureProvider<void>((ref) async {
  final authService = ref.watch(authServiceProvider);

  await authService.logout();

  // Clear user and update auth state
  ref.read(currentUserProvider.notifier).clearUser();
  ref.read(authStateProvider.notifier).setUnauthenticated();
});

/// Verify OTP operation
final verifyOtpProvider = StateNotifierProvider<VerifyOtpNotifier, AsyncValue<AuthResponse>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return VerifyOtpNotifier(authService, ref);
});

class VerifyOtpNotifier extends StateNotifier<AsyncValue<AuthResponse>> {
  final AuthService _authService;
  final Ref _ref;

  VerifyOtpNotifier(this._authService, this._ref) : super(const AsyncValue.loading());

  /// Verify OTP
  Future<void> verifyOtp({
    required String email,
    required String code,
  }) async {
    state = AsyncValue.loading();

    try {
      final result = await _authService.verifyOtp(
        email: email,
        code: code,
      );

      // Update user
      _ref.read(currentUserProvider.notifier).setUser(result.user);
      _ref.read(authStateProvider.notifier).setAuthenticated();

      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      _ref.read(authStateProvider.notifier).setError();
    }
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.loading();
  }
}

/// Send OTP operation
final sendOtpProvider = StateNotifierProvider<SendOtpNotifier, AsyncValue<OtpResponse>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return SendOtpNotifier(authService);
});

class SendOtpNotifier extends StateNotifier<AsyncValue<OtpResponse>> {
  final AuthService _authService;

  SendOtpNotifier(this._authService) : super(const AsyncValue.loading());

  /// Send OTP
  Future<void> sendOtp({required String email}) async {
    state = AsyncValue.loading();

    try {
      final result = await _authService.sendOtp(email: email);
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Reset state
  void reset() {
    state = const AsyncValue.loading();
  }
}

/// Token refresh operation
final refreshTokenProvider = FutureProvider<TokenRefreshResponse>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.refreshAccessToken();
});

/// Check if user is logged in
final isLoggedInProvider = Provider<Future<bool>>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.isTokenValid();
});

/// Get current access token
final accessTokenProvider = FutureProvider<String?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getAccessToken();
});

// ============================================================================
// UTILITY PROVIDERS
// ============================================================================

/// Get current user ID
final currentUserIdProvider = FutureProvider<String?>((ref) async {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return await tokenStorage.getUserId();
});

/// Check if token should be refreshed
final shouldRefreshTokenProvider = FutureProvider<bool>((ref) async {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return await tokenStorage.shouldRefreshToken();
});
