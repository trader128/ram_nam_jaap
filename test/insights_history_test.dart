import 'package:flutter_test/flutter_test.dart';

import 'package:bhakti/core/helpers/insights_calculator.dart';
import 'package:bhakti/shared/enums/insights_period.dart';
import 'package:bhakti/shared/models/daily_jap_record.dart';

void main() {
  group('InsightsCalculator', () {
    test('calculates totals and averages for period', () {
      final records = [
        DailyJapRecord(date: DateTime(2025, 6, 26), count: 100, dailyGoal: 108),
        DailyJapRecord(date: DateTime(2025, 6, 27), count: 200, dailyGoal: 108),
        DailyJapRecord(date: DateTime(2025, 6, 28), count: 50, dailyGoal: 108),
      ];

      final snapshot = InsightsCalculator.calculate(
        records: records,
        period: InsightsPeriod.all,
        dailyGoal: 108,
      );

      expect(snapshot.total, 350);
      expect(snapshot.activeDays, 3);
      expect(snapshot.longestGoalStreak, 1);
    });

    test('tracks goal streak for consecutive days', () {
      final records = [
        DailyJapRecord(date: DateTime(2025, 6, 26), count: 150, dailyGoal: 108),
        DailyJapRecord(date: DateTime(2025, 6, 27), count: 120, dailyGoal: 108),
        DailyJapRecord(date: DateTime(2025, 6, 28), count: 10, dailyGoal: 108),
      ];

      final snapshot = InsightsCalculator.calculate(
        records: records,
        period: InsightsPeriod.all,
        dailyGoal: 108,
      );

      expect(snapshot.longestGoalStreak, 2);
      expect(snapshot.goalStreak, 0);
    });
  });
}
