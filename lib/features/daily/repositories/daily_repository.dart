import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/storage/hive_storage_service.dart';

/// Repository managing daily challenges, entry fees/tickets, completion, and calendar history.
class DailyRepository {
  final ApiClient _client;
  final HiveStorageService _storage;

  DailyRepository({ApiClient? client, HiveStorageService? storage})
      : _client = client ?? ApiClient(),
        _storage = storage ?? HiveStorageService();

  /// Fetches today's daily puzzle challenge config.
  Future<ApiResponse<dynamic>> fetchTodayChallenge() async {
    return _client.get(ApiEndpoints.dailyToday);
  }

  /// Stakes coins to enter daily challenge and receives a validated server ticket.
  Future<ApiResponse<dynamic>> enterChallenge({String? date}) async {
    final payload = <String, dynamic>{};
    if (date != null) {
      payload['date'] = date;
      payload['dateKey'] = date;
    }
    final response = await _client.post(
      ApiEndpoints.dailyEnter,
      body: payload.isNotEmpty ? payload : null,
    );

    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final remainingCoins = (data['remainingCoins'] as num?)?.toInt();
      if (remainingCoins != null) {
        final profile = _storage.getPlayerProfile();
        profile['coins'] = remainingCoins;
        await _storage.savePlayerProfile(profile);
      }
    }
    return response;
  }

  /// Submits completed daily challenge.
  Future<ApiResponse<dynamic>> completeChallenge({
    required String ticketId,
    required int stars,
    required int score,
    required double elapsedTime,
    required List<String> wordsFound,
    List<List<String>>? grid,
    String? dateKey,
  }) async {
    final todayStr = dateKey ??
        DateTime.now().toIso8601String().split('T').first;

    // Immediately mark locally in Hive for offline resilience
    await _storage.markDailyCompleted(todayStr);

    final payload = <String, dynamic>{
      'ticketId': ticketId,
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

    final response = await _client.post(
      ApiEndpoints.dailyComplete,
      body: payload,
    );

    if (response.isSuccessful && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      if (data['profile'] != null) {
        final profile = Map<String, dynamic>.from(data['profile'] as Map);
        await _storage.savePlayerProfile(profile);
      }
    }

    return response;
  }

  /// Fetches monthly daily challenge calendar history.
  Future<ApiResponse<dynamic>> fetchCalendar() async {
    return _client.get(ApiEndpoints.dailyCalendar);
  }
}
