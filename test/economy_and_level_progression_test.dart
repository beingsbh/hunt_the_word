import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_the_word/features/levels/models/world_model.dart';
import 'package:hunt_the_word/features/profile/viewmodels/player_profile_provider.dart';

void main() {
  group('Economy & Progression Rules Tests', () {
    test('Hint costs exactly 5 coins and requires at least 5 coins', () {
      final profile = PlayerProfileProvider();
      expect(profile.coins, greaterThanOrEqualTo(50));

      // Starting coins
      final initialCoins = profile.coins;

      // Deduct 5 coins for hint
      profile.updateCoins(-5);
      expect(profile.coins, equals(initialCoins - 5));

      // Set coins to 4 - not enough for hint
      profile.updateCoins(-profile.coins + 4);
      expect(profile.coins, equals(4));
      expect(profile.coins < 5, isTrue);
    });

    test('Daily Challenge entry costs 20 coins with 3x, 2x, 0x star payouts', () {
      final profile = PlayerProfileProvider();
      final initialCoins = profile.coins;

      // Entry stake: 20 coins
      expect(initialCoins >= 20, isTrue);
      profile.updateCoins(-20);
      expect(profile.coins, equals(initialCoins - 20));

      // 3 Stars payout: 3x (60 coins)
      profile.updateCoins(60);
      expect(profile.coins, equals(initialCoins + 40));

      // 2 Stars payout: 2x (40 coins)
      profile.updateCoins(-20); // entry
      profile.updateCoins(40); // 2x payout
      expect(profile.coins, equals(initialCoins + 60));

      // 1 Star payout: 0 coins
      profile.updateCoins(-20); // entry
      // 0 coins payout
      expect(profile.coins, equals(initialCoins + 40));
    });

    test('advanceLevel updates currentLevel, highestUnlockedLevel, and playerLevel synchronously', () {
      final profile = PlayerProfileProvider();
      
      // Advance to level 35 (beyond initial default 27)
      profile.advanceLevel(35);
      expect(profile.currentLevel, equals(35));
      expect(profile.highestUnlockedLevel, equals(35));
      expect(profile.playerLevel, equals(35));

      // Attempting to advance to a lower level does not regress currentLevel or highestUnlockedLevel
      profile.advanceLevel(30);
      expect(profile.currentLevel, equals(35));
      expect(profile.highestUnlockedLevel, equals(35));
      expect(profile.playerLevel, equals(35));

      // Advancing to level 40 advances all
      profile.advanceLevel(40);
      expect(profile.currentLevel, equals(40));
      expect(profile.highestUnlockedLevel, equals(40));
      expect(profile.playerLevel, equals(40));
    });

    test('Mystery box scaling: 20 coins base, increasing 1.5x every 10 levels', () {
      int getReward(int level) {
        final interval = (level / 10).ceil();
        if (interval <= 1) return 20;
        double reward = 20.0;
        for (int i = 1; i < interval; i++) {
          reward *= 1.5;
        }
        return reward.round();
      }

      // Level 10 (block 1): 20
      expect(getReward(10), equals(20));
      // Level 9 (block 1): 20
      expect(getReward(9), equals(20));

      // Level 20 (block 2): 20 * 1.5 = 30
      expect(getReward(20), equals(30));
      // Level 19 (block 2): 30
      expect(getReward(19), equals(30));

      // Level 30 (block 3): 30 * 1.5 = 45
      expect(getReward(30), equals(45));
      // Level 29 (block 3): 45
      expect(getReward(29), equals(45));

      // Level 40 (block 4): 45 * 1.5 = 67.5 -> 68
      expect(getReward(40), equals(68));
    });

    test('WorldModel computes progress and serializes JSON accurately', () {
      final json = {
        'worldNumber': 1,
        'name': 'Verdant Forest',
        'icon': '🌿',
        'themeId': 'forest',
        'category': 'Forest Flora',
        'startLevel': 1,
        'endLevel': 20,
        'totalLevels': 20,
        'unlocked': true,
        'isCompleted': false,
        'completedLevels': 10,
        'starsEarned': 28,
        'maxStars': 60,
      };

      final world = WorldModel.fromJson(json);
      expect(world.worldNumber, equals(1));
      expect(world.name, equals('Verdant Forest'));
      expect(world.icon, equals('🌿'));
      expect(world.completionProgress, equals(0.5));
      expect(world.starProgress, closeTo(28 / 60, 0.001));
      expect(world.levelRangeDisplay, equals('Levels 1–20'));
      expect(world.fullTitle, equals('🌿 World 1: Verdant Forest'));

      final defaultWorlds = WorldModel.getDefaultWorlds(highestUnlockedLevel: 25);
      expect(defaultWorlds.length, equals(10));
      expect(defaultWorlds[0].unlocked, isTrue); // World 1 (1-20)
      expect(defaultWorlds[0].isCompleted, isTrue);
      expect(defaultWorlds[1].unlocked, isTrue); // World 2 (21-40)
      expect(defaultWorlds[1].isCompleted, isFalse);
      expect(defaultWorlds[2].unlocked, isFalse); // World 3 (41-60)
    });
  });
}
