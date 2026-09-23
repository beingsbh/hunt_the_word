import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/hive_storage_service.dart';

/// Repository managing player profile stats, nickname customization, and hint balance.
class ProfileRepository {
  final ApiClient _client;
  final HiveStorageService _storage;

  ProfileRepository({ApiClient? client, HiveStorageService? storage})
      : _client = client ?? ApiClient(),
        _storage = storage ?? HiveStorageService();

  /// Fetches player profile from server and updates local Hive cache.
  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _client.get(ApiEndpoints.profile);
    if (response.isSuccessful && response.data != null) {
      final profile = Map<String, dynamic>.from(response.data as Map);
      await _storage.savePlayerProfile(profile);
      return profile;
    }
    // Return cached local profile on network absence
    return _storage.getPlayerProfile();
  }

  /// Updates player nickname on server and updates local cache.
  Future<ApiResponse<dynamic>> updateNickname(String nickname) async {
    final response = await _client.put(
      ApiEndpoints.updateNickname,
      body: {'nickname': nickname},
    );

    if (response.isSuccessful && response.data != null) {
      final updated = Map<String, dynamic>.from(response.data as Map);
      await _storage.savePlayerProfile(updated);
    }

    return response;
  }

  /// Checks if a proposed nickname is unique.
  Future<bool> checkNicknameAvailability(String nickname) async {
    final response = await _client.get(
      ApiEndpoints.checkNickname(nickname),
      requiresAuth: false,
    );
    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      return (data['isAvailable'] as bool?) ?? false;
    }
    return true;
  }

  /// Deducts coins for hint usage on server; falls back to offline coin update.
  Future<ApiResponse<dynamic>> useHint() async {
    final response = await _client.post(ApiEndpoints.useHint);
    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final remaining = (data['remainingCoins'] as num?)?.toInt();
      if (remaining != null) {
        final profile = _storage.getPlayerProfile();
        profile['coins'] = remaining;
        await _storage.savePlayerProfile(profile);
      }
    } else {
      // Offline fallback: deduct 25 coins locally
      await _storage.updateCoins(-25);
    }
    return response;
  }
}
