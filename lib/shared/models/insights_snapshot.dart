import '../../shared/models/daily_jap_record.dart';

class InsightsSnapshot {
  const InsightsSnapshot({
    required this.total,
    required this.activeDays,
    required this.averagePerDay,
    required this.goalStreak,
    required this.longestGoalStreak,
    required this.dailyPoints,
    required this.dailyGoal,
  });

  final int total;
  final int activeDays;
  final double averagePerDay;
  final int goalStreak;
  final int longestGoalStreak;
  final List<DailyJapRecord> dailyPoints;
  final int dailyGoal;
}
