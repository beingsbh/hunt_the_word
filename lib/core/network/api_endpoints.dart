import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Centralized API endpoint routes and base URL configuration.
class ApiEndpoints {
  ApiEndpoints._();

  static bool isServerOnline = false;

  /// Default base URL resolving appropriate host for emulator, web, and desktop.
  static String get defaultBaseUrl {
    return 'http://localhost:5000/api/v1';
  }

  static String baseUrl = defaultBaseUrl;

  /// Initializes connectivity by testing reachable development host.
  /// On physical Android devices (with adb reverse), localhost:5000 is reachable.
  /// On Android Emulators without adb reverse, 10.0.2.2:5000 is reachable.
  static Future<bool> init() async {
    final client = http.Client();
    try {
      // 1. Try localhost first (Desktop, Web, or Android device via adb reverse)
      try {
        final res = await client
            .get(Uri.parse('http://localhost:5000/health'))
            .timeout(const Duration(milliseconds: 1500));
        if (res.statusCode == 200) {
          baseUrl = 'http://localhost:5000/api/v1';
          isServerOnline = true;
          debugPrint('🚀 [ApiEndpoints] Connected to Word Hunter Backend via localhost:5000');
          return true;
        }
      } catch (_) {}

      // 2. Fall back to Android emulator host (10.0.2.2) if on Android
      if (!kIsWeb) {
        try {
          if (Platform.isAndroid) {
            final res = await client
                .get(Uri.parse('http://10.0.2.2:5000/health'))
                .timeout(const Duration(milliseconds: 1500));
            if (res.statusCode == 200) {
              baseUrl = 'http://10.0.2.2:5000/api/v1';
              isServerOnline = true;
              debugPrint('🚀 [ApiEndpoints] Connected to Word Hunter Backend via 10.0.2.2:5000');
              return true;
            }
          }
        } catch (_) {}
      }

      baseUrl = defaultBaseUrl;
      isServerOnline = false;
      debugPrint('⚠️ [ApiEndpoints] Backend offline or unreachable. Offline fallback mode active.');
      return false;
    } finally {
      client.close();
    }
  }

  // --- Auth ---
  static String get register => '$baseUrl/auth/register';
  static String get login => '$baseUrl/auth/login';
  static String get guest => '$baseUrl/auth/guest';
  static String get social => '$baseUrl/auth/social';
  static String get refresh => '$baseUrl/auth/refresh';
  static String get logout => '$baseUrl/auth/logout';

  // --- Profile ---
  static String get profile => '$baseUrl/profile';
  static String get updateNickname => '$baseUrl/profile/nickname';
  static String get useHint => '$baseUrl/profile/hint';
  static String checkNickname(String nickname) =>
      '$baseUrl/profile/check-nickname/${Uri.encodeComponent(nickname)}';

  // --- Levels ---
  static String get levelMap => '$baseUrl/levels/map';
  static String get worlds => '$baseUrl/levels/worlds';
  static String get completeLevel => '$baseUrl/levels/complete';
  static String get claimMysteryBox => '$baseUrl/levels/mystery-box';
  static String get generateBoard => '$baseUrl/levels/generate-board';
  static String get vocabulary => '$baseUrl/levels/vocabulary';

  // --- Daily Challenge ---
  static String get dailyToday => '$baseUrl/daily/today';
  static String get dailyEnter => '$baseUrl/daily/enter';
  static String get dailyComplete => '$baseUrl/daily/complete';
  static String get dailyCalendar => '$baseUrl/daily/calendar';

  // --- Offline Batch Sync ---
  static String get batchSync => '$baseUrl/sync/batch';

  // --- Themes ---
  static String get themes => '$baseUrl/themes';
  static String purchaseTheme(String themeId) =>
      '$baseUrl/themes/${Uri.encodeComponent(themeId)}/purchase';
  static String selectTheme(String themeId) =>
      '$baseUrl/themes/${Uri.encodeComponent(themeId)}/select';

  // --- Achievements ---
  static String get achievements => '$baseUrl/achievements';
  static String claimAchievement(String achId) =>
      '$baseUrl/achievements/${Uri.encodeComponent(achId)}/claim';

  // --- Leaderboard ---
  static String get leaderboardGlobal => '$baseUrl/leaderboard/global';
  static String get leaderboardStreak => '$baseUrl/leaderboard/streak';
}
