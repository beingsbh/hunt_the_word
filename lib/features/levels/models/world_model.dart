/// Model representing a thematic game World with progression, level bounds, and rewards.
class WorldModel {
  final int worldNumber;
  final String name;
  final String icon;
  final String themeId;
  final String category;
  final int startLevel;
  final int endLevel;
  final int totalLevels;
  final bool unlocked;
  final bool isCompleted;
  final int completedLevels;
  final int starsEarned;
  final int maxStars;

  const WorldModel({
    required this.worldNumber,
    required this.name,
    required this.icon,
    required this.themeId,
    required this.category,
    required this.startLevel,
    required this.endLevel,
    this.totalLevels = 20,
    this.unlocked = false,
    this.isCompleted = false,
    this.completedLevels = 0,
    this.starsEarned = 0,
    this.maxStars = 60,
  });

  /// Ratio of completed levels to total levels (0.0 to 1.0)
  double get completionProgress {
    if (totalLevels <= 0) return 0.0;
    return (completedLevels / totalLevels).clamp(0.0, 1.0);
  }

  /// Ratio of stars earned to maximum possible stars (0.0 to 1.0)
  double get starProgress {
    if (maxStars <= 0) return 0.0;
    return (starsEarned / maxStars).clamp(0.0, 1.0);
  }

  /// Formatted level range string e.g. "Levels 1–20"
  String get levelRangeDisplay => 'Levels $startLevel–$endLevel';

  /// Formatted title with icon and chapter number e.g. "🌿 World 1: Verdant Forest"
  String get fullTitle => '$icon World $worldNumber: $name';

  factory WorldModel.fromJson(Map<String, dynamic> json) {
    final start = (json['startLevel'] as num?)?.toInt() ?? 1;
    final end = (json['endLevel'] as num?)?.toInt() ?? (start + 19);
    final total = (json['totalLevels'] as num?)?.toInt() ?? (end - start + 1);

    return WorldModel(
      worldNumber: (json['worldNumber'] as num?)?.toInt() ?? 1,
      name: (json['name'] as String?) ?? 'Unknown World',
      icon: (json['icon'] as String?) ?? '🗺️',
      themeId: (json['themeId'] as String?) ?? 'forest',
      category: (json['category'] as String?) ?? 'General',
      startLevel: start,
      endLevel: end,
      totalLevels: total,
      unlocked: (json['unlocked'] as bool?) ?? false,
      isCompleted: (json['isCompleted'] as bool?) ?? false,
      completedLevels: (json['completedLevels'] as num?)?.toInt() ?? 0,
      starsEarned: (json['starsEarned'] as num?)?.toInt() ?? 0,
      maxStars: (json['maxStars'] as num?)?.toInt() ?? (total * 3),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'worldNumber': worldNumber,
      'name': name,
      'icon': icon,
      'themeId': themeId,
      'category': category,
      'startLevel': startLevel,
      'endLevel': endLevel,
      'totalLevels': totalLevels,
      'unlocked': unlocked,
      'isCompleted': isCompleted,
      'completedLevels': completedLevels,
      'starsEarned': starsEarned,
      'maxStars': maxStars,
    };
  }

  WorldModel copyWith({
    int? worldNumber,
    String? name,
    String? icon,
    String? themeId,
    String? category,
    int? startLevel,
    int? endLevel,
    int? totalLevels,
    bool? unlocked,
    bool? isCompleted,
    int? completedLevels,
    int? starsEarned,
    int? maxStars,
  }) {
    return WorldModel(
      worldNumber: worldNumber ?? this.worldNumber,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      themeId: themeId ?? this.themeId,
      category: category ?? this.category,
      startLevel: startLevel ?? this.startLevel,
      endLevel: endLevel ?? this.endLevel,
      totalLevels: totalLevels ?? this.totalLevels,
      unlocked: unlocked ?? this.unlocked,
      isCompleted: isCompleted ?? this.isCompleted,
      completedLevels: completedLevels ?? this.completedLevels,
      starsEarned: starsEarned ?? this.starsEarned,
      maxStars: maxStars ?? this.maxStars,
    );
  }

  /// Generates default baseline worlds configuration matching backend WORLDS_CONFIG
  static List<WorldModel> getDefaultWorlds({int highestUnlockedLevel = 1}) {
    const rawConfigs = [
      {'name': 'Verdant Forest', 'icon': '🌿', 'themeId': 'forest', 'category': 'Forest Flora'},
      {'name': 'Ocean Sanctuary', 'icon': '🌊', 'themeId': 'ocean', 'category': 'Ocean Creatures'},
      {'name': 'Space Frontier', 'icon': '🚀', 'themeId': 'midnight', 'category': 'Space Frontier'},
      {'name': 'Cyber City', 'icon': '🏙️', 'themeId': 'cyber', 'category': 'Cyber City'},
      {'name': 'Mystic Realm', 'icon': '🔮', 'themeId': 'candy', 'category': 'Mystic Realm'},
      {'name': 'Volcanic Peak', 'icon': '🌋', 'themeId': 'midnight', 'category': 'General'},
      {'name': 'Crystal Caverns', 'icon': '💎', 'themeId': 'candy', 'category': 'General'},
      {'name': 'Desert Oasis', 'icon': '🏜️', 'themeId': 'classic', 'category': 'Nature Walk'},
      {'name': 'Arctic Tundra', 'icon': '❄️', 'themeId': 'ocean', 'category': 'General'},
      {'name': 'Golden Citadel', 'icon': '🏰', 'themeId': 'classic', 'category': 'General'},
    ];

    return List.generate(rawConfigs.length, (index) {
      final worldNum = index + 1;
      final start = (worldNum - 1) * 20 + 1;
      final end = worldNum * 20;
      final cfg = rawConfigs[index];

      return WorldModel(
        worldNumber: worldNum,
        name: cfg['name']!,
        icon: cfg['icon']!,
        themeId: cfg['themeId']!,
        category: cfg['category']!,
        startLevel: start,
        endLevel: end,
        totalLevels: 20,
        unlocked: highestUnlockedLevel >= start,
        isCompleted: highestUnlockedLevel > end,
        completedLevels: (highestUnlockedLevel > end)
            ? 20
            : (highestUnlockedLevel >= start ? (highestUnlockedLevel - start) : 0),
        starsEarned: (highestUnlockedLevel > end)
            ? 60
            : (highestUnlockedLevel >= start ? (highestUnlockedLevel - start) * 3 : 0),
        maxStars: 60,
      );
    });
  }
}
