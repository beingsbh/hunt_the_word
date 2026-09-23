import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../storage/hive_storage_service.dart';
import 'api_endpoints.dart';

/// Standard response wrapper from Word Hunter Backend
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
    required this.statusCode,
  });

  bool get isSuccessful => success && statusCode >= 200 && statusCode < 300;
}

class ApiException implements Exception {
  final String message;
  final String? errorCode;
  final int statusCode;

  ApiException(this.message, {this.errorCode, this.statusCode = 500});

  @override
  String toString() => 'ApiException($statusCode, $errorCode): $message';
}

/// Robust HTTP client with Bearer token authentication, auto-refresh, and offline handling.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final http.Client _httpClient = http.Client();
  final HiveStorageService _storage = HiveStorageService();

  static const Duration defaultTimeout = Duration(seconds: 8);

  String? get _accessToken {
    final tokens = _storage.getAuthTokens();
    return tokens?['accessToken'] as String?;
  }

  String? get _refreshToken {
    final tokens = _storage.getAuthTokens();
    return tokens?['refreshToken'] as String?;
  }

  Map<String, String> _buildHeaders({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeAuth && _accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  /// Sends a GET request
  Future<ApiResponse<dynamic>> get(
    String url, {
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _sendWithRetry(
      () => _httpClient
          .get(
            Uri.parse(url),
            headers: {..._buildHeaders(includeAuth: requiresAuth), ...?headers},
          )
          .timeout(defaultTimeout),
      requiresAuth: requiresAuth,
    );
  }

  /// Sends a POST request
  Future<ApiResponse<dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _sendWithRetry(
      () => _httpClient
          .post(
            Uri.parse(url),
            headers: {..._buildHeaders(includeAuth: requiresAuth), ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(defaultTimeout),
      requiresAuth: requiresAuth,
    );
  }

  /// Sends a PUT request
  Future<ApiResponse<dynamic>> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool requiresAuth = true,
  }) async {
    return _sendWithRetry(
      () => _httpClient
          .put(
            Uri.parse(url),
            headers: {..._buildHeaders(includeAuth: requiresAuth), ...?headers},
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(defaultTimeout),
      requiresAuth: requiresAuth,
    );
  }

  /// Executes request with automatic 401 token refresh and offline fallback handling
  Future<ApiResponse<dynamic>> _sendWithRetry(
    Future<http.Response> Function() requestFn, {
    bool requiresAuth = true,
  }) async {
    try {
      var response = await requestFn();

      // If 401 Unauthorized and auth was required, attempt token refresh once
      if (response.statusCode == 401 && requiresAuth && _refreshToken != null) {
        final refreshed = await _attemptTokenRefresh();
        if (refreshed) {
          response = await requestFn();
        }
      }

      return _parseResponse(response);
    } catch (e) {
      // Network failure, timeout, or DNS resolution error
      return ApiResponse<dynamic>(
        success: false,
        message: 'Network connection unavailable: $e',
        errorCode: 'OFFLINE_OR_TIMEOUT',
        statusCode: 0,
      );
    }
  }

  ApiResponse<dynamic> _parseResponse(http.Response response) {
    dynamic parsedBody;
    try {
      parsedBody = jsonDecode(response.body);
    } catch (_) {
      parsedBody = null;
    }

    if (parsedBody is Map<String, dynamic>) {
      final success = (parsedBody['success'] as bool?) ??
          (response.statusCode >= 200 && response.statusCode < 300);
      return ApiResponse<dynamic>(
        success: success,
        data: parsedBody['data'],
        message: parsedBody['message'] as String?,
        errorCode: parsedBody['errorCode'] as String?,
        statusCode: response.statusCode,
      );
    }

    return ApiResponse<dynamic>(
      success: response.statusCode >= 200 && response.statusCode < 300,
      data: parsedBody,
      statusCode: response.statusCode,
    );
  }

  /// Refreshes accessToken using the stored refreshToken
  Future<bool> _attemptTokenRefresh() async {
    final token = _refreshToken;
    if (token == null) return false;

    try {
      final response = await _httpClient
          .post(
            Uri.parse(ApiEndpoints.refresh),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': token}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed is Map && parsed['data'] != null) {
          final data = parsed['data'] as Map<String, dynamic>;
          await _storage.saveAuthTokens(data);
          return true;
        }
      }
    } catch (_) {
      // Refresh failed
    }

    // If refresh failed definitively, clear tokens
    await _storage.clearAuthTokens();
    return false;
  }
}
