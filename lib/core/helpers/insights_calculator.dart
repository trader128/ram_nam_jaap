import '../../shared/enums/insights_period.dart';
import '../../shared/models/daily_jap_record.dart';
import '../../shared/models/insights_snapshot.dart';
import 'date_helper.dart';

abstract final class InsightsCalculator {
  static InsightsSnapshot calculate({
    required List<DailyJapRecord> records,
    required InsightsPeriod period,
    required int dailyGoal,
  }) {
    final sorted = List<DailyJapRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    final filtered = _filterByPeriod(sorted, period);
    final total = filtered.fold<int>(0, (sum, record) => sum + record.count);
    final activeDays = filtered.where((record) => record.count > 0).length;
    final dayCount = filtered.isEmpty ? 1 : filtered.length;
    final averagePerDay = total / dayCount;

    return InsightsSnapshot(
      total: total,
      activeDays: activeDays,
      averagePerDay: averagePerDay,
      goalStreak: _currentGoalStreak(sorted, dailyGoal),
      longestGoalStreak: _longestGoalStreak(sorted, dailyGoal),
      dailyPoints: filtered,
      dailyGoal: dailyGoal,
    );
  }

  static List<DailyJapRecord> _filterByPeriod(
    List<DailyJapRecord> records,
    InsightsPeriod period,
  ) {
    if (period == InsightsPeriod.all) {
      if (records.isEmpty) {
        return [];
      }
      return _fillMissingDays(
        records,
        records.first.date,
        DateHelper.today(),
        records.first.dailyGoal,
      );
    }

    final end = DateHelper.today();
    final start = end.subtract(Duration(days: period.days - 1));
    final dailyGoal = records.isEmpty ? 108 : records.last.dailyGoal;
    final ranged = records
        .where(
          (record) => !record.date.isBefore(start) && !record.date.isAfter(end),
        )
        .toList();

    return _fillMissingDays(ranged, start, end, dailyGoal);
  }

  static List<DailyJapRecord> _fillMissingDays(
    List<DailyJapRecord> records,
    DateTime start,
    DateTime end,
    int dailyGoal,
  ) {
    final lookup = {
      for (final record in records) DateHelper.toDateKey(record.date): record,
    };

    final filled = <DailyJapRecord>[];
    var cursor = start;

    while (!cursor.isAfter(end)) {
      final key = DateHelper.toDateKey(cursor);
      filled.add(
        lookup[key] ??
            DailyJapRecord(date: cursor, count: 0, dailyGoal: dailyGoal),
      );
      cursor = cursor.add(const Duration(days: 1));
    }

    return filled;
  }

  static int _currentGoalStreak(List<DailyJapRecord> records, int dailyGoal) {
    if (records.isEmpty) {
      return 0;
    }

    var streak = 0;
    final sorted = List<DailyJapRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final record in sorted) {
      if (record.count >= dailyGoal) {
        streak += 1;
      } else if (record.count > 0) {
        break;
      } else if (!DateHelper.isSameDay(record.date, DateHelper.today())) {
        break;
      }
    }

    return streak;
  }

  static int _longestGoalStreak(List<DailyJapRecord> records, int dailyGoal) {
    var longest = 0;
    var current = 0;

    final sorted = List<DailyJapRecord>.from(records)
      ..sort((a, b) => a.date.compareTo(b.date));

    for (final record in sorted) {
      if (record.count >= dailyGoal) {
        current += 1;
        if (current > longest) {
          longest = current;
        }
      } else {
        current = 0;
      }
    }

    return longest;
  }
}
