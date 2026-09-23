import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/hive_storage_service.dart';
import '../models/world_model.dart';

/// Repository managing campaign levels, completion submissions, and mystery box rewards.
class LevelsRepository {
  final ApiClient _client;
  final HiveStorageService _storage;

  LevelsRepository({ApiClient? client, HiveStorageService? storage})
      : _client = client ?? ApiClient(),
        _storage = storage ?? HiveStorageService();

  /// Fetches the level map progression from the server.
  Future<ApiResponse<dynamic>> fetchLevelMap() async {
    final response = await _client.get(ApiEndpoints.levelMap);
    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final profile = _storage.getPlayerProfile();

      if (data['highestUnlockedLevel'] != null) {
        profile['highestUnlockedLevel'] =
            (data['highestUnlockedLevel'] as num).toInt();
      }
      if (data['currentLevel'] != null) {
        profile['currentLevel'] = (data['currentLevel'] as num).toInt();
      }
      if (data['totalStars'] != null) {
        profile['totalStars'] = (data['totalStars'] as num).toInt();
      }
      if (data['coins'] != null) {
        profile['coins'] = (data['coins'] as num).toInt();
      }
      await _storage.savePlayerProfile(profile);

      // Save individual level records
      if (data['levels'] is List) {
        for (final item in data['levels'] as List) {
          if (item is Map) {
            final lvlNum = (item['levelNumber'] as num?)?.toInt() ?? 0;
            final stars = (item['stars'] as num?)?.toInt() ?? 0;
            final score = (item['score'] as num?)?.toInt() ?? 0;
            if (lvlNum > 0) {
              await _storage.saveLevelProgress(lvlNum, stars, score);
            }
          }
        }
      }
    }
    return response;
  }

  /// Fetches world system and chapter progression from backend.
  Future<List<WorldModel>> fetchWorlds() async {
    final response = await _client.get(ApiEndpoints.worlds);
    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      if (data['worlds'] is List) {
        final rawWorlds = (data['worlds'] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        await _storage.saveWorlds(rawWorlds);
        return rawWorlds.map((json) => WorldModel.fromJson(json)).toList();
      }
    }

    // Offline fallback 1: Check cached worlds from Hive
    final cached = _storage.getCachedWorlds();
    if (cached != null && cached.isNotEmpty) {
      return cached.map((json) => WorldModel.fromJson(json)).toList();
    }

    // Offline fallback 2: Baseline default worlds computed from player's highest unlocked level
    final profile = _storage.getPlayerProfile();
    final highestUnlocked =
        (profile['highestUnlockedLevel'] as num?)?.toInt() ?? 1;
    return WorldModel.getDefaultWorlds(highestUnlockedLevel: highestUnlocked);
  }

  /// Submits completed level to backend with automatic offline-first resilience.
  Future<ApiResponse<dynamic>> completeLevel({
    required int levelNumber,
    required int stars,
    required int score,
    required double elapsedTime,
    required List<String> wordsFound,
    List<List<String>>? grid,
  }) async {
    // 1. Immediately save progress locally in Hive for zero-latency gameplay
    await _storage.saveLevelProgress(levelNumber, stars, score);

    // 2. Prepare payload compatible with both traditional and alias property names
    final payload = <String, dynamic>{
      'levelNumber': levelNumber,
      'stars': stars,
      'score': score,
      'elapsedTime': elapsedTime,
      'timeSeconds': elapsedTime,
      'wordsFound': wordsFound,
      'foundWords': wordsFound,
    };
    if (grid != null) {
      payload['grid'] = grid;
    }

    // 3. Send to server
    final response = await _client.post(
      ApiEndpoints.completeLevel,
      body: payload,
    );

    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      if (data['profile'] != null) {
        final profile = Map<String, dynamic>.from(data['profile'] as Map);
        await _storage.savePlayerProfile(profile);
      }
    } else {
      // 4. Offline Fallback: Queue for batch synchronization when network resumes
      await _storage.addPendingSyncLevel({
        'levelNumber': levelNumber,
        'stars': stars,
        'score': score,
        'elapsedTime': elapsedTime,
        'wordsFound': wordsFound,
        if (grid != null) 'grid': grid,
      });
    }

    return response;
  }

  /// Claims milestone mystery box reward.
  Future<ApiResponse<dynamic>> claimMysteryBox(int levelNumber) async {
    final response = await _client.post(
      ApiEndpoints.claimMysteryBox,
      body: {'levelNumber': levelNumber},
    );

    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final newCoins = (data['newCoinBalance'] as num?)?.toInt();
      if (newCoins != null) {
        final profile = _storage.getPlayerProfile();
        profile['coins'] = newCoins;
        await _storage.savePlayerProfile(profile);
      }
    }

    return response;
  }
}
