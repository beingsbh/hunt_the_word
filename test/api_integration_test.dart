import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_the_word/core/network/api_endpoints.dart';
import 'package:hunt_the_word/core/network/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('API Endpoints Tests', () {
    test('ApiEndpoints builds proper routes with default base URL', () {
      expect(ApiEndpoints.guest, contains('/auth/guest'));
      expect(ApiEndpoints.login, contains('/auth/login'));
      expect(ApiEndpoints.register, contains('/auth/register'));
      expect(ApiEndpoints.levelMap, contains('/levels/map'));
      expect(ApiEndpoints.completeLevel, contains('/levels/complete'));
      expect(ApiEndpoints.claimMysteryBox, contains('/levels/mystery-box'));
      expect(ApiEndpoints.dailyToday, contains('/daily/today'));
      expect(ApiEndpoints.dailyEnter, contains('/daily/enter'));
      expect(ApiEndpoints.dailyComplete, contains('/daily/complete'));
      expect(ApiEndpoints.batchSync, contains('/sync/batch'));
      expect(ApiEndpoints.themes, contains('/themes'));
      expect(ApiEndpoints.achievements, contains('/achievements'));
      expect(ApiEndpoints.checkNickname('Hero'), contains('/profile/check-nickname/Hero'));
      expect(ApiEndpoints.claimAchievement('first_word'), contains('/achievements/first_word/claim'));
      expect(ApiEndpoints.purchaseTheme('cosmic_midnight'), contains('/themes/cosmic_midnight/purchase'));
    });

    test('ApiEndpoints allows custom base URL configuration', () {
      final original = ApiEndpoints.baseUrl;
      ApiEndpoints.baseUrl = 'https://api.wordhunter.example.com/api/v1';

      expect(ApiEndpoints.profile, equals('https://api.wordhunter.example.com/api/v1/profile'));
      expect(ApiEndpoints.batchSync, equals('https://api.wordhunter.example.com/api/v1/sync/batch'));

      // Restore
      ApiEndpoints.baseUrl = original;
    });
  });

  group('ApiResponse & Error Tests', () {
    test('ApiResponse correctly reflects status codes', () {
      final ok = ApiResponse(success: true, data: {'coins': 500}, statusCode: 200);
      expect(ok.isSuccessful, isTrue);

      final created = ApiResponse(success: true, data: {'ticketId': 't1'}, statusCode: 201);
      expect(created.isSuccessful, isTrue);

      final error = ApiResponse(success: false, message: 'Invalid credentials', statusCode: 401);
      expect(error.isSuccessful, isFalse);

      final offline = ApiResponse(success: false, errorCode: 'OFFLINE_OR_TIMEOUT', statusCode: 0);
      expect(offline.isSuccessful, isFalse);
    });
  });
}
