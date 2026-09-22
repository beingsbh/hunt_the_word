import 'package:flutter/material.dart';

import '../../../core/storage/hive_storage_service.dart';

/// State provider for player profile, coins, lifetime statistics, and rank.
class PlayerProfileProvider extends ChangeNotifier {
  final HiveStorageService _storage = HiveStorageService();

  late Map<String, dynamic> _profile;

  PlayerProfileProvider() {
    _loadProfile();
  }

  void _loadProfile() {
    _profile = _storage.getPlayerProfile();
    notifyListeners();
  }

  String get nickname => _profile['nickname'] as String? ?? 'Subha WordMaster';
  String get playerTag => _profile['playerTag'] as String? ?? '#WH-9824';
  String get playerTitle =>
      _profile['playerTitle'] as String? ?? 'Explorer Tier II';
  int get playerLevel => (_profile['playerLevel'] as num?)?.toInt() ?? 12;
  int get coins => (_profile['coins'] as num?)?.toInt() ?? 500;
  int get totalStars => (_profile['totalStars'] as num?)?.toInt() ?? 78;
  int get currentLevel => (_profile['currentLevel'] as num?)?.toInt() ?? 27;
  int get highestUnlockedLevel =>
      (_profile['highestUnlockedLevel'] as num?)?.toInt() ?? 27;
  int get streak => (_profile['streak'] as num?)?.toInt() ?? 7;
  int get puzzlesSolved => (_profile['puzzlesSolved'] as num?)?.toInt() ?? 72;
  int get wordsFound => (_profile['wordsFound'] as num?)?.toInt() ?? 845;
  double get accuracyRate =>
      (_profile['accuracyRate'] as num?)?.toDouble() ?? 94.2;
  int get bestScore => (_profile['bestScore'] as num?)?.toInt() ?? 4820;
  String get playTime => _profile['playTime'] as String? ?? '18.5h';
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

  void updateNickname(String name) {
    _profile['nickname'] = name;
    _storage.savePlayerProfile(_profile);
    notifyListeners();
  }

  void setUniqueUsername(String name, {String? tag}) {
    _profile['nickname'] = name;
    if (tag != null) {
      _profile['playerTag'] = tag;
    }
    _profile['hasSetUniqueUsername'] = true;
    _profile['needsUsernameSetup'] = false;
    _storage.savePlayerProfile(_profile);
    notifyListeners();
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

  void refreshFromStorage() {
    _loadProfile();
  }
}
