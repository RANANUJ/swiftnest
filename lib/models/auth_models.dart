/// Authentication models for signup, login, OTP, and token management
/// 
/// Contains request/response DTOs for API communication,
/// error handling models, and state management models.

// ============================================================================
// REQUEST MODELS
// ============================================================================

/// Signup request payload
class SignupRequest {
  final String email;
  final String password;
  final String name;
  final String? phone;
  final String? avatar;

  SignupRequest({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    this.avatar,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      if (phone != null) 'phone': phone,
      if (avatar != null) 'avatar': avatar,
    };
  }
}

/// Login request payload
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// OTP send request
class SendOtpRequest {
  final String email;

  SendOtpRequest({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }
}

/// OTP verification request
class VerifyOtpRequest {
  final String email;
  final String code;

  VerifyOtpRequest({
    required this.email,
    required this.code,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'code': code,
    };
  }
}

/// Token refresh request
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() {
    return {'refreshToken': refreshToken};
  }
}

// ============================================================================
// RESPONSE MODELS
// ============================================================================

/// Auth response with tokens (returned from signup/login)
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final int expiresIn; // seconds until token expires

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    required this.expiresIn,
  });

  /// Create from JSON response
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
      expiresIn: json['expiresIn'] ?? 3600,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user.toJson(),
      'expiresIn': expiresIn,
    };
  }
}

/// User model (core user data)
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? avatar;
  final String? bio;
  final bool isVerified;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.avatar,
    this.bio,
    this.isVerified = false,
    this.isOnline = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      avatar: json['avatar'],
      bio: json['bio'],
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar': avatar,
      'bio': bio,
      'isVerified': isVerified,
      'isOnline': isOnline,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? avatar,
    String? bio,
    bool? isVerified,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user is valid
  bool get isValid => id.isNotEmpty && email.isNotEmpty;
}

/// OTP response (verification code sent)
class OtpResponse {
  final String message;
  final int expiresIn; // seconds until OTP expires (usually 5 minutes = 300s)

  OtpResponse({
    required this.message,
    required this.expiresIn,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      message: json['message'] ?? '',
      expiresIn: json['expiresIn'] ?? 300,
    );
  }
}

/// Token refresh response
class TokenRefreshResponse {
  final String accessToken;
  final int expiresIn;

  TokenRefreshResponse({
    required this.accessToken,
    required this.expiresIn,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      accessToken: json['accessToken'] ?? '',
      expiresIn: json['expiresIn'] ?? 3600,
    );
  }
}

// ============================================================================
// ERROR MODELS
// ============================================================================

/// API error response
class ApiError {
  final String message;
  final String? code;
  final int? statusCode;
  final Map<String, dynamic>? details;

  ApiError({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'An error occurred',
      code: json['code'],
      statusCode: json['statusCode'],
      details: json['details'],
    );
  }

  @override
  String toString() => 'ApiError: $message (code: $code, status: $statusCode)';
}

/// Auth-specific errors
enum AuthErrorType {
  invalidCredentials,
  userNotFound,
  emailAlreadyExists,
  weakPassword,
  networkError,
  serverError,
  tokenExpired,
  unauthorizedAccess,
  unknown,
}

/// Exception thrown during auth operations
class AuthException implements Exception {
  final AuthErrorType type;
  final String message;
  final dynamic originalError;

  AuthException({
    required this.type,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'AuthException: $message (type: $type)';
}

// ============================================================================
// STATE MODELS (For UI/State Management)
// ============================================================================

/// Auth state for UI
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Login state snapshot
class LoginState {
  final AuthState state;
  final UserModel? user;
  final String? errorMessage;
  final bool isLoading;

  LoginState({
    this.state = AuthState.initial,
    this.user,
    this.errorMessage,
    this.isLoading = false,
  });

  /// Create from JSON (for persistence)
  factory LoginState.fromJson(Map<String, dynamic> json) {
    return LoginState(
      state: AuthState.values.firstWhere(
        (e) => e.toString() == json['state'],
        orElse: () => AuthState.initial,
      ),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      errorMessage: json['errorMessage'],
      isLoading: json['isLoading'] ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'state': state.toString(),
      'user': user?.toJson(),
      'errorMessage': errorMessage,
      'isLoading': isLoading,
    };
  }

  /// Create a copy with updated fields
  LoginState copyWith({
    AuthState? state,
    UserModel? user,
    String? errorMessage,
    bool? isLoading,
  }) {
    return LoginState(
      state: state ?? this.state,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
