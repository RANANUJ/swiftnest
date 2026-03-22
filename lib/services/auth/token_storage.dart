import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/app_config.dart';

/// Secure token storage using flutter_secure_storage
/// Tokens are stored in:
/// - Android: EncryptedSharedPreferences
/// - iOS: Keychain
/// - Web: SessionStorage (encrypted)
class TokenStorage {
  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save JWT access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(
      key: AppConfig.tokenStorageKey,
      value: token,
    );
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(
      key: AppConfig.refreshTokenStorageKey,
      value: token,
    );
  }

  /// Save both tokens at once
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConfig.tokenStorageKey);
  }

  /// Get current refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConfig.refreshTokenStorageKey);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(
      key: AppConfig.userIdStorageKey,
      value: userId,
    );
  }

  /// Get saved user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: AppConfig.userIdStorageKey);
  }

  /// Check if user is logged in
  Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if token is about to expire (within 5 minutes)
  /// In production, decode JWT to check actual expiry
  Future<bool> shouldRefreshToken() async {
    // This is a simplified check
    // In production, decode the JWT payload to get exp timestamp
    final token = await getAccessToken();
    if (token == null) return false;

    try {
      // For now, just check if token exists
      // JWT decoding would be done with a library like 'dart_jwt'
      // This is where you'd decode and check the 'exp' claim
      return false; // Token is valid
    } catch (e) {
      return true; // Token is invalid, needs refresh
    }
  }

  /// Clear all saved tokens (logout)
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConfig.tokenStorageKey),
      _storage.delete(key: AppConfig.refreshTokenStorageKey),
      _storage.delete(key: AppConfig.userIdStorageKey),
    ]);
  }

  /// Delete access token only (for logout)
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: AppConfig.tokenStorageKey);
  }

  /// Delete refresh token only
  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: AppConfig.refreshTokenStorageKey);
  }
}
