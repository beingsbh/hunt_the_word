import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/hive_storage_service.dart';

/// Repository managing user authentication, sessions, tokens, and identity.
class AuthRepository {
  final ApiClient _client;
  final HiveStorageService _storage;

  AuthRepository({ApiClient? client, HiveStorageService? storage})
      : _client = client ?? ApiClient(),
        _storage = storage ?? HiveStorageService();

  bool get isAuthenticated => _storage.getAuthTokens() != null;

  /// Authenticates with the backend as a guest user using the persistent device ID.
  Future<ApiResponse<dynamic>> guestLogin() async {
    final deviceId = _storage.getDeviceId();
    final response = await _client.post(
      ApiEndpoints.guest,
      body: {'deviceId': deviceId},
      requiresAuth: false,
    );

    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      if (data['tokens'] != null) {
        await _storage.saveAuthTokens(
          Map<String, dynamic>.from(data['tokens'] as Map),
        );
      }
      if (data['profile'] != null) {
        final profile = Map<String, dynamic>.from(data['profile'] as Map);
        await _storage.savePlayerProfile(profile);
      }
    }

    return response;
  }

  /// Authenticates using a third-party social provider (Google, Apple, etc.).
  Future<ApiResponse<dynamic>> socialLogin({
    required String provider,
    required String token,
  }) async {
    final deviceId = _storage.getDeviceId();
    final response = await _client.post(
      ApiEndpoints.social,
      body: {
        'provider': provider,
        'token': token,
        'deviceId': deviceId,
      },
      requiresAuth: false,
    );

    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      if (data['tokens'] != null) {
        await _storage.saveAuthTokens(
          Map<String, dynamic>.from(data['tokens'] as Map),
        );
      }
      if (data['profile'] != null) {
        final profile = Map<String, dynamic>.from(data['profile'] as Map);
        await _storage.savePlayerProfile(profile);
      }
    }

    return response;
  }

  /// Authenticates using email & password.
  Future<ApiResponse<dynamic>> login(String email, String password) async {
    final response = await _client.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      requiresAuth: false,
    );

    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      if (data['tokens'] != null) {
        await _storage.saveAuthTokens(
          Map<String, dynamic>.from(data['tokens'] as Map),
        );
      }
      if (data['profile'] != null) {
        final profile = Map<String, dynamic>.from(data['profile'] as Map);
        await _storage.savePlayerProfile(profile);
      }
    }

    return response;
  }

  /// Registers a new user account.
  Future<ApiResponse<dynamic>> register(
    String email,
    String password, {
    String? nickname,
  }) async {
    final body = <String, dynamic>{
      'email': email,
      'password': password,
    };
    if (nickname != null && nickname.isNotEmpty) {
      body['nickname'] = nickname;
    }

    final response = await _client.post(
      ApiEndpoints.register,
      body: body,
      requiresAuth: false,
    );

    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      if (data['tokens'] != null) {
        await _storage.saveAuthTokens(
          Map<String, dynamic>.from(data['tokens'] as Map),
        );
      }
      if (data['profile'] != null) {
        final profile = Map<String, dynamic>.from(data['profile'] as Map);
        await _storage.savePlayerProfile(profile);
      }
    }

    return response;
  }

  /// Clears local session and notifies the backend.
  Future<void> logout() async {
    try {
      await _client.post(ApiEndpoints.logout, requiresAuth: true);
    } catch (_) {}
    await _storage.clearAuthTokens();
  }
}
