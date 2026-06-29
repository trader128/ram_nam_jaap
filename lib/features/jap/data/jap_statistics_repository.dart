import '../../../core/constants/hive_keys.dart';
import '../../../core/helpers/date_helper.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../shared/models/jap_statistics.dart';

class JapStatisticsRepository {
  JapStatistics load() {
    final box = HiveStorage.statisticsBox;
    final todayKey = DateHelper.toDateKey(DateHelper.today());
    final storedTodayDate =
        box.get(HiveKeys.todayDate, defaultValue: todayKey) as String;

    var todayCount = box.get(HiveKeys.todayCount, defaultValue: 0) as int;
    if (storedTodayDate != todayKey) {
      todayCount = 0;
    }

    return JapStatistics(
      todayCount: todayCount,
      lifetimeCount: box.get(HiveKeys.totalLifetime, defaultValue: 0) as int,
      currentStreak: box.get(HiveKeys.currentStreak, defaultValue: 0) as int,
      longestStreak: box.get(HiveKeys.longestStreak, defaultValue: 0) as int,
      todayDate: DateHelper.fromDateKey(todayKey) ?? DateHelper.today(),
    );
  }

  Future<void> save(JapStatistics statistics) async {
    final box = HiveStorage.statisticsBox;
    await box.put(HiveKeys.todayCount, statistics.todayCount);
    await box.put(HiveKeys.totalLifetime, statistics.lifetimeCount);
    await box.put(HiveKeys.currentStreak, statistics.currentStreak);
    await box.put(HiveKeys.longestStreak, statistics.longestStreak);
    await box.put(
      HiveKeys.todayDate,
      DateHelper.toDateKey(statistics.todayDate),
    );
  }

  Future<void> saveLastActiveDate(DateTime date) async {
    await HiveStorage.statisticsBox.put(
      HiveKeys.lastActiveDate,
      DateHelper.toDateKey(date),
    );
  }

  DateTime? loadLastActiveDate() {
    return DateHelper.fromDateKey(
      HiveStorage.statisticsBox.get(HiveKeys.lastActiveDate) as String?,
    );
  }
}
