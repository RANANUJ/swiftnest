import 'package:dio/dio.dart';
import '../../config/app_config.dart';
import '../auth/token_storage.dart';

/// HTTP client using Dio with token management
/// Handles:
/// - Base URL configuration
/// - JWT token injection
/// - Token refresh on 401
/// - Error interceptors
/// - Retry logic
class ApiClient {
  late Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage {
    _initializeDio();
  }

  /// Initialize Dio instance with interceptors
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        sendTimeout: AppConfig.apiTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _TokenInterceptor(_tokenStorage, _dio),
      _ErrorInterceptor(),
      _LoggingInterceptor(),
    ]);
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
  }) async {
    try {
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        lengthHeader: lengthHeader,
        data: data,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Upload file with progress
  Future<Response<T>> upload<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? formData,
    ProgressCallback? onSendProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final multipartFile = await MultipartFile.fromFile(filePath);
      final data = FormData.fromMap({
        fieldName: multipartFile,
        ...?formData,
      });

      return await _dio.post<T>(
        path,
        data: data,
        onSendProgress: onSendProgress,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Set authorization header
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Clear authorization header
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Close Dio instance
  void close({bool force = false}) {
    _dio.close(force: force);
  }
}

// ============================================================================
// INTERCEPTORS
// ============================================================================

/// Interceptor for JWT token management and refresh
class _TokenInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;

  _TokenInterceptor(this._tokenStorage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add token to all requests
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      print('[API] Token added to request: ${options.path}');
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 - Token expired
    if (err.response?.statusCode == 401) {
      print('[API] Got 401, attempting token refresh...');

      try {
        // Don't retry for login/signup endpoints
        if (_isAuthEndpoint(err.requestOptions.path)) {
          return handler.next(err);
        }

        // Try to refresh token
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final newTokenResponse = await _dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
            options: Options(
              headers: {
                'Authorization': null, // Don't include expired token
              },
            ),
          );

          if (newTokenResponse.statusCode == 200) {
            final newToken = newTokenResponse.data['accessToken'];
            await _tokenStorage.saveAccessToken(newToken);
            print('[API] Token refreshed successfully');

            // Retry original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
            return handler.resolve(
              await _dio.request(
                err.requestOptions.path,
                options: Options(
                  method: err.requestOptions.method,
                  headers: err.requestOptions.headers,
                ),
                data: err.requestOptions.data,
                queryParameters: err.requestOptions.queryParameters,
              ),
            );
          }
        }
      } catch (e) {
        print('[API] Token refresh failed: $e');
      }
    }

    return handler.next(err);
  }

  /// Check if path is an auth endpoint
  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/');
  }
}

/// Interceptor for error logging and response handling
class _ErrorInterceptor extends Interceptor {
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    print('[API Error] ${err.requestOptions.method} ${err.requestOptions.path}');
    print('[API Error] Status: ${err.response?.statusCode}');
    print('[API Error] Message: ${err.message}');

    if (err.response != null) {
      print('[API Error] Response: ${err.response?.data}');
    }

    return handler.next(err);
  }
}

/// Interceptor for request/response logging
class _LoggingInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('═══════════════════════════════════════');
    print('[API Request] ${options.method} ${options.path}');
    if (options.queryParameters.isNotEmpty) {
      print('[API] Query: ${options.queryParameters}');
    }
    if (options.data != null) {
      print('[API] Body: ${options.data}');
    }
    print('═══════════════════════════════════════');

    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    print('═══════════════════════════════════════');
    print('[API Response] ${response.requestOptions.method} ${response.requestOptions.path}');
    print('[API] Status: ${response.statusCode}');
    print('[API] Data: ${response.data}');
    print('═══════════════════════════════════════');

    return handler.next(response);
  }
}
