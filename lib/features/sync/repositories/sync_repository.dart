import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/hive_storage_service.dart';

/// Repository managing offline batch synchronization and cloud state reconciliation.
class SyncRepository {
  final ApiClient _client;
  final HiveStorageService _storage;

  SyncRepository({ApiClient? client, HiveStorageService? storage})
      : _client = client ?? ApiClient(),
        _storage = storage ?? HiveStorageService();

  /// Reconciles all pending offline level completions with the backend.
  Future<ApiResponse<dynamic>> reconcilePendingOfflineData() async {
    final pending = _storage.getPendingSyncLevels();
    final profile = _storage.getPlayerProfile();

    final highest = (profile['highestUnlockedLevel'] as num?)?.toInt() ?? 1;
    final current = (profile['currentLevel'] as num?)?.toInt() ?? 1;

    final payload = <String, dynamic>{
      'clientTimestamp': DateTime.now().toIso8601String(),
      'highestUnlockedLevel': highest,
      'currentLevel': current,
      'pendingLevels': pending,
      'levels': pending,
    };

    final response = await _client.post(
      ApiEndpoints.batchSync,
      body: payload,
    );

    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;

      // Clear the offline queue now that server has processed it
      await _storage.clearPendingSyncLevels();

      // Reconcile updated profile stats
      if (data['profile'] != null) {
        final serverProfile =
            Map<String, dynamic>.from(data['profile'] as Map);
        await _storage.savePlayerProfile(serverProfile);
      }
    }

    return response;
  }
}
