import 'package:flutter/material.dart';

import '../../../core/storage/hive_storage_service.dart';

class CalendarDayItem {
  final String dayName;
  final int dateNumber;
  final bool isCompleted;
  final bool isToday;
  final bool isLocked;

  const CalendarDayItem({
    required this.dayName,
    required this.dateNumber,
    this.isCompleted = false,
    this.isToday = false,
    this.isLocked = false,
  });
}

/// Provider managing Daily Challenge calendar, streaks, and date-seeded puzzles.
class DailyChallengeProvider extends ChangeNotifier {
  final HiveStorageService _storage = HiveStorageService();

  late Map<String, dynamic> _dailyData;

  DailyChallengeProvider() {
    _loadDaily();
  }

  void _loadDaily() {
    _dailyData = _storage.getDailyData();
    notifyListeners();
  }

  int get streak => (_dailyData['streak'] as num?)?.toInt() ?? 7;
  int get monthlyCount => (_dailyData['monthlyCount'] as num?)?.toInt() ?? 21;
  bool get isTodayCompleted {
    final completed = List<String>.from(
      _dailyData['completedDates'] as List? ?? [],
    );
    return completed.contains('2024-09-21');
  }

  List<CalendarDayItem> get weeklyCalendar => const [
    CalendarDayItem(dayName: 'M', dateNumber: 16, isCompleted: true),
    CalendarDayItem(dayName: 'T', dateNumber: 17, isCompleted: true),
    CalendarDayItem(dayName: 'W', dateNumber: 18, isCompleted: true),
    CalendarDayItem(dayName: 'T', dateNumber: 19, isCompleted: true),
    CalendarDayItem(dayName: 'F', dateNumber: 20, isCompleted: true),
    CalendarDayItem(dayName: 'SAT', dateNumber: 21, isToday: true),
    CalendarDayItem(dayName: 'SUN', dateNumber: 22, isLocked: true),
  ];

  void completeToday() {
    _storage.markDailyCompleted('2024-09-21');
    _loadDaily();
  }
}
