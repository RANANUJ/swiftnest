import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../../models/auth_models.dart';
import '../network/api_client.dart';
import 'token_storage.dart';

/// Main authentication service
/// Handles signup, login, logout, and token refresh
class AuthService {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  // Current user session
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  AuthService({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage;

  /// Initialize auth service (check for existing session)
  Future<void> initialize() async {
    try {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // Try to load current user from cache or API
        // For now, just mark as authenticated
        print('[Auth] Found existing token');
      }
    } catch (e) {
      print('[Auth] Error initializing: $e');
    }
  }

  // =========================================================================
  // SIGNUP
  // =========================================================================

  /// User signup with email and password
  /// Returns AuthResponse with tokens if successful
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? avatar,
  }) async {
    try {
      print('[Auth] Starting signup for $email');

      final request = SignupRequest(
        email: email,
        password: password,
        name: name,
        phone: phone,
        avatar: avatar,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.signup,
        data: request.toJson(),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data ?? {});

        // Save tokens
        await _tokenStorage.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        // Save user ID
        await _tokenStorage.saveUserId(authResponse.user.id);

        // Update current user
        _currentUser = authResponse.user;

        print('[Auth] Signup successful! User: ${authResponse.user.email}');
        return authResponse;
      } else {
        throw AuthException(
          type: AuthErrorType.serverError,
          message: 'Signup failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('[Auth] Signup DioException: ${e.message}');
      _handleDioError(e, 'Signup failed');
      rethrow;
    } catch (e) {
      print('[Auth] Signup error: $e');
      throw AuthException(
        type: AuthErrorType.unknown,
        message: 'Signup error: $e',
        originalError: e,
      );
    }
  }

  // =========================================================================
  // LOGIN
  // =========================================================================

  /// User login with email and password
  /// Returns AuthResponse with tokens if successful
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      print('[Auth] Starting login for $email');

      final request = LoginRequest(
        email: email,
        password: password,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.login,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data ?? {});

        // Save tokens
        await _tokenStorage.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        // Save user ID
        await _tokenStorage.saveUserId(authResponse.user.id);

        // Update current user
        _currentUser = authResponse.user;

        print('[Auth] Login successful! User: ${authResponse.user.email}');
        return authResponse;
      } else {
        throw AuthException(
          type: AuthErrorType.serverError,
          message: 'Login failed with status ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('[Auth] Login DioException: ${e.message}');
      _handleDioError(e, 'Login failed');
      rethrow;
    } catch (e) {
      print('[Auth] Login error: $e');
      throw AuthException(
        type: AuthErrorType.unknown,
        message: 'Login error: $e',
        originalError: e,
      );
    }
  }

  // =========================================================================
  // EMAIL VERIFICATION via OTP
  // =========================================================================

  /// Send OTP to email address
  Future<OtpResponse> sendOtp({required String email}) async {
    try {
      print('[Auth] Sending OTP to $email');

      final request = SendOtpRequest(email: email);

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.sendOtp,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final otpResponse = OtpResponse.fromJson(response.data ?? {});
        print('[Auth] OTP sent successfully. Expires in ${otpResponse.expiresIn}s');
        return otpResponse;
      } else {
        throw AuthException(
          type: AuthErrorType.serverError,
          message: 'Failed to send OTP',
        );
      }
    } catch (e) {
      print('[Auth] Send OTP error: $e');
      rethrow;
    }
  }

  /// Verify OTP code
  Future<AuthResponse> verifyOtp({
    required String email,
    required String code,
  }) async {
    try {
      print('[Auth] Verifying OTP for $email');

      final request = VerifyOtpRequest(
        email: email,
        code: code,
      );

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.verifyOtp,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(response.data ?? {});

        // Save tokens
        await _tokenStorage.saveTokens(
          accessToken: authResponse.accessToken,
          refreshToken: authResponse.refreshToken,
        );

        // Save user ID
        await _tokenStorage.saveUserId(authResponse.user.id);

        // Update current user
        _currentUser = authResponse.user;

        print('[Auth] OTP verified successfully!');
        return authResponse;
      } else {
        throw AuthException(
          type: AuthErrorType.serverError,
          message: 'OTP verification failed',
        );
      }
    } catch (e) {
      print('[Auth] OTP verification error: $e');
      rethrow;
    }
  }

  // =========================================================================
  // TOKEN MANAGEMENT
  // =========================================================================

  /// Refresh access token using refresh token
  Future<TokenRefreshResponse> refreshAccessToken() async {
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw AuthException(
          type: AuthErrorType.tokenExpired,
          message: 'No refresh token available',
        );
      }

      print('[Auth] Refreshing access token');

      final request = RefreshTokenRequest(refreshToken: refreshToken);

      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.refreshToken,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        final tokenResponse = TokenRefreshResponse.fromJson(response.data ?? {});

        // Save new access token
        await _tokenStorage.saveAccessToken(tokenResponse.accessToken);

        print('[Auth] Access token refreshed successfully');
        return tokenResponse;
      } else {
        throw AuthException(
          type: AuthErrorType.tokenExpired,
          message: 'Token refresh failed',
        );
      }
    } catch (e) {
      print('[Auth] Token refresh error: $e');
      rethrow;
    }
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return await _tokenStorage.getAccessToken();
  }

  /// Check if user has valid token
  Future<bool> isTokenValid() async {
    return await _tokenStorage.hasValidToken();
  }

  // =========================================================================
  // LOGOUT
  // =========================================================================

  /// Logout user (clear tokens)
  Future<void> logout() async {
    try {
      print('[Auth] Logging out');

      // Call logout API endpoint
      try {
        await _apiClient.post(ApiEndpoints.logout);
      } catch (e) {
        // If API call fails, still clear local tokens
        print('[Auth] Logout API error: $e');
      }

      // Clear all tokens locally
      await _tokenStorage.clearTokens();

      // Clear current user
      _currentUser = null;

      print('[Auth] Logout successful');
    } catch (e) {
      print('[Auth] Logout error: $e');
      throw AuthException(
        type: AuthErrorType.unknown,
        message: 'Logout failed: $e',
        originalError: e,
      );
    }
  }

  // =========================================================================
  // HELPER METHODS
  // =========================================================================

  /// Handle Dio exceptions and map to AuthException
  void _handleDioError(DioException error, String context) {
    print('[Auth] DioException in $context: ${error.message}');
    print('[Auth] Error type: ${error.type}');
    print('[Auth] Status code: ${error.response?.statusCode}');

    AuthErrorType errorType = AuthErrorType.unknown;
    String message = context;

    // Parse error response
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? context;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        errorType = AuthErrorType.networkError;
        message = ErrorMessages.networkError;
        break;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        if (statusCode == 401) {
          errorType = AuthErrorType.unauthorizedAccess;
          message = ErrorMessages.unauthorized;
        } else if (statusCode == 400) {
          // Check error code from response
          if (responseData is Map<String, dynamic>) {
            final errorCode = responseData['code'];
            if (errorCode == 'INVALID_CREDENTIALS') {
              errorType = AuthErrorType.invalidCredentials;
              message = ErrorMessages.invalidCredentials;
            } else if (errorCode == 'EMAIL_EXISTS') {
              errorType = AuthErrorType.emailAlreadyExists;
              message = 'Email already registered';
            } else if (errorCode == 'WEAK_PASSWORD') {
              errorType = AuthErrorType.weakPassword;
              message = 'Password is too weak';
            }
          }
        } else if (statusCode >= 500) {
          errorType = AuthErrorType.serverError;
          message = ErrorMessages.serverError;
        }
        break;

      case DioExceptionType.unknown:
        errorType = AuthErrorType.networkError;
        message = ErrorMessages.networkError;
        break;

      default:
        errorType = AuthErrorType.unknown;
    }

    throw AuthException(
      type: errorType,
      message: message,
      originalError: error,
    );
  }
}
