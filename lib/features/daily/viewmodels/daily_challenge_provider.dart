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

  String get _todayKey {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int get streak => (_dailyData['streak'] as num?)?.toInt() ?? 7;
  int get monthlyCount => (_dailyData['monthlyCount'] as num?)?.toInt() ?? 21;
  bool get isTodayCompleted {
    final completed = List<String>.from(
      _dailyData['completedDates'] as List? ?? [],
    );
    return completed.contains(_todayKey);
  }

  List<CalendarDayItem> get weeklyCalendar {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'SAT', 'SUN'];

    final completed = List<String>.from(
      _dailyData['completedDates'] as List? ?? [],
    );

    return List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      final dateKey =
          '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final isToday = date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
      final isFuture = date.isAfter(DateTime(now.year, now.month, now.day));
      final isDateCompleted = completed.contains(dateKey);

      return CalendarDayItem(
        dayName: dayNames[i],
        dateNumber: date.day,
        isCompleted: isDateCompleted,
        isToday: isToday,
        isLocked: isFuture,
      );
    });
  }

  void completeToday() {
    _storage.markDailyCompleted(_todayKey);
    _loadDaily();
  }
}
