import 'package:flutter/material.dart';

import '../../../core/storage/hive_storage_service.dart';
import '../models/achievement_mock_data.dart';

/// Provider managing achievement milestones, completion fraction, and coin claims.
class AchievementsProvider extends ChangeNotifier {
  final HiveStorageService _storage = HiveStorageService();

  late Set<String> _claimedIds;
  List<AchievementMockItem> _achievements = [];

  AchievementsProvider() {
    _loadAchievements();
  }

  void _loadAchievements() {
    _claimedIds = _storage.getClaimedAchievements();
    final baseList = AchievementMockItem.getMockAchievements();

    _achievements = baseList.map((a) {
      final isClaimed = _claimedIds.contains(a.id);
      return AchievementMockItem(
        id: a.id,
        title: a.title,
        description: a.description,
        icon: a.icon,
        currentProgress: a.currentProgress,
        targetProgress: a.targetProgress,
        rewardCoins: a.rewardCoins,
        isClaimed: isClaimed,
      );
    }).toList();

    notifyListeners();
  }

  List<AchievementMockItem> get allAchievements => _achievements;
  int get totalAchievements => _achievements.length;
  int get completedCount => _achievements.where((a) => a.isCompleted).length;
  double get totalProgressFraction =>
      totalAchievements == 0 ? 0.0 : (completedCount / totalAchievements);

  Future<int?> claimReward(String id) async {
    final index = _achievements.indexWhere((a) => a.id == id);
    if (index == -1) return null;

    final item = _achievements[index];
    if (!item.isCompleted || item.isClaimed) return null;

    await _storage.claimAchievement(id);
    await _storage.updateCoins(item.rewardCoins);

    _claimedIds.add(id);
    _achievements[index] = AchievementMockItem(
      id: item.id,
      title: item.title,
      description: item.description,
      icon: item.icon,
      currentProgress: item.currentProgress,
      targetProgress: item.targetProgress,
      rewardCoins: item.rewardCoins,
      isClaimed: true,
    );

    notifyListeners();
    return item.rewardCoins;
  }
}
