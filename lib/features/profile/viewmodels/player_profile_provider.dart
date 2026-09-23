import 'package:flutter/material.dart';

import '../../../core/storage/hive_storage_service.dart';
import '../../auth/repositories/auth_repository.dart';
import '../repositories/profile_repository.dart';

/// State provider for player profile, coins, lifetime statistics, and rank.
class PlayerProfileProvider extends ChangeNotifier {
  final HiveStorageService _storage;
  final ProfileRepository _profileRepo;
  final AuthRepository _authRepo;

  late Map<String, dynamic> _profile;
  bool _isLoading = false;

  PlayerProfileProvider({
    HiveStorageService? storage,
    ProfileRepository? profileRepository,
    AuthRepository? authRepository,
  })  : _storage = storage ?? HiveStorageService(),
        _profileRepo = profileRepository ?? ProfileRepository(),
        _authRepo = authRepository ?? AuthRepository() {
    _loadProfile();
    _initializeRemoteSession();
  }

  void _loadProfile() {
    _profile = _storage.getPlayerProfile();
    notifyListeners();
  }

  /// Automatically authenticates guest or synchronizes latest profile stats from the cloud
  Future<void> _initializeRemoteSession() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (!_authRepo.isAuthenticated) {
        // Authenticate guest in background without blocking local experience
        final res = await _authRepo.guestLogin();
        if (res.isSuccessful) {
          _loadProfile();
        }
      } else {
        // Refresh latest profile from backend
        final remoteProfile = await _profileRepo.fetchProfile();
        _profile = remoteProfile;
        notifyListeners();
      }
    } catch (_) {
      // Offline fallback: keep local Hive profile
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isLoading => _isLoading;

  String get nickname => _profile['nickname'] as String? ?? 'Word Hunter';
  String get playerTag => _profile['playerTag'] as String? ?? '#WH-1001';
  String get playerTitle =>
      _profile['playerTitle'] as String? ?? 'Word Novice';
  int get playerLevel => (_profile['playerLevel'] as num?)?.toInt() ?? 1;
  int get coins => (_profile['coins'] as num?)?.toInt() ?? 100;
  int get totalStars => (_profile['totalStars'] as num?)?.toInt() ?? 0;
  int get currentLevel => (_profile['currentLevel'] as num?)?.toInt() ?? 1;
  int get highestUnlockedLevel =>
      (_profile['highestUnlockedLevel'] as num?)?.toInt() ?? 1;
  int get streak => (_profile['streak'] as num?)?.toInt() ?? 0;
  int get puzzlesSolved => (_profile['puzzlesSolved'] as num?)?.toInt() ?? 0;
  int get wordsFound => (_profile['wordsFound'] as num?)?.toInt() ?? 0;
  double get accuracyRate =>
      (_profile['accuracyRate'] as num?)?.toDouble() ?? 100.0;
  int get bestScore => (_profile['bestScore'] as num?)?.toInt() ?? 0;
  String get playTime => _profile['playTime'] as String? ?? '0m';
  List<String> get unlockedThemes =>
      List<String>.from(_profile['unlockedThemes'] as List? ?? ['emerald_meadow']);
  bool get hasSetUniqueUsername =>
      _profile['hasSetUniqueUsername'] as bool? ?? false;
  bool get needsUsernameSetup =>
      _profile['needsUsernameSetup'] as bool? ?? false;

  bool get isCloudSaveEnabled => _profile['cloudSaveEnabled'] as bool? ?? true;

  void toggleCloudSave(bool enabled) {
    _profile['cloudSaveEnabled'] = enabled;
    _storage.savePlayerProfile(_profile);
    notifyListeners();
  }

  void updateCoins(int delta) {
    final newCoins = (coins + delta).clamp(0, 999999);
    _profile['coins'] = newCoins;
    _storage.savePlayerProfile(_profile);
    notifyListeners();
  }

  void incrementWordsFound(int count) {
    _profile['wordsFound'] = wordsFound + count;
    _storage.savePlayerProfile(_profile);
    notifyListeners();
  }

  void advanceLevel(int newLevel) {
    if (newLevel > currentLevel) {
      _profile['currentLevel'] = newLevel;
    }
    if (newLevel > highestUnlockedLevel) {
      _profile['highestUnlockedLevel'] = newLevel;
    }
    _profile['playerLevel'] = _profile['currentLevel'];
    _profile['puzzlesSolved'] = puzzlesSolved + 1;
    _storage.savePlayerProfile(_profile);
    notifyListeners();
  }

  Future<void> updateNickname(String name) async {
    _profile['nickname'] = name;
    _storage.savePlayerProfile(_profile);
    notifyListeners();

    try {
      await _profileRepo.updateNickname(name);
    } catch (_) {}
  }

  Future<void> setUniqueUsername(String name, {String? tag}) async {
    _profile['nickname'] = name;
    if (tag != null) {
      _profile['playerTag'] = tag;
    }
    _profile['hasSetUniqueUsername'] = true;
    _profile['needsUsernameSetup'] = false;
    _storage.savePlayerProfile(_profile);
    notifyListeners();

    try {
      await _profileRepo.updateNickname(name);
    } catch (_) {}
  }

  void flagNeedsUsernameSetup() {
    _profile['needsUsernameSetup'] = true;
    _storage.savePlayerProfile(_profile);
    notifyListeners();
  }

  void initializeNewLogin({required String provider}) {
    if (!hasSetUniqueUsername) {
      _profile['coins'] = 500;
      _profile['needsUsernameSetup'] = true;
      _storage.savePlayerProfile(_profile);
      notifyListeners();
    }
  }

  /// Deducts coins for hint server-side with local offline fallback
  Future<bool> useHint() async {
    if (coins < 25) return false;
    updateCoins(-25);
    try {
      await _profileRepo.useHint();
    } catch (_) {}
    return true;
  }

  void refreshFromStorage() {
    _loadProfile();
  }
}
