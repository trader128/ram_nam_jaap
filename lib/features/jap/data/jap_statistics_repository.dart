import '../../../core/constants/hive_keys.dart';
import '../../../core/helpers/date_helper.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../shared/models/jap_statistics.dart';

class JapStatisticsRepository {
  JapStatistics load(String deityId) {
    final box = HiveStorage.statisticsBox;
    final todayKey = DateHelper.toDateKey(DateHelper.today());
    final storedTodayDate =
        box.get(
              HiveKeys.forDeity(deityId, HiveKeys.todayDate),
              defaultValue: todayKey,
            )
            as String;

    var todayCount =
        box.get(
              HiveKeys.forDeity(deityId, HiveKeys.todayCount),
              defaultValue: 0,
            )
            as int;
    if (storedTodayDate != todayKey) {
      todayCount = 0;
    }

    var lifetimeCount =
        box.get(
              HiveKeys.forDeity(deityId, HiveKeys.totalLifetime),
              defaultValue: 0,
            )
            as int;
    if (lifetimeCount < todayCount) {
      lifetimeCount = todayCount;
    }

    return JapStatistics(
      todayCount: todayCount,
      lifetimeCount: lifetimeCount,
      currentStreak:
          box.get(
                HiveKeys.forDeity(deityId, HiveKeys.currentStreak),
                defaultValue: 0,
              )
              as int,
      longestStreak:
          box.get(
                HiveKeys.forDeity(deityId, HiveKeys.longestStreak),
                defaultValue: 0,
              )
              as int,
      todayDate: DateHelper.fromDateKey(todayKey) ?? DateHelper.today(),
    );
  }

  Future<void> save(String deityId, JapStatistics statistics) async {
    final box = HiveStorage.statisticsBox;
    await box.put(
      HiveKeys.forDeity(deityId, HiveKeys.todayCount),
      statistics.todayCount,
    );
    await box.put(
      HiveKeys.forDeity(deityId, HiveKeys.totalLifetime),
      statistics.lifetimeCount,
    );
    await box.put(
      HiveKeys.forDeity(deityId, HiveKeys.currentStreak),
      statistics.currentStreak,
    );
    await box.put(
      HiveKeys.forDeity(deityId, HiveKeys.longestStreak),
      statistics.longestStreak,
    );
    await box.put(
      HiveKeys.forDeity(deityId, HiveKeys.todayDate),
      DateHelper.toDateKey(statistics.todayDate),
    );
  }

  Future<void> saveLastActiveDate(String deityId, DateTime date) async {
    await HiveStorage.statisticsBox.put(
      HiveKeys.forDeity(deityId, HiveKeys.lastActiveDate),
      DateHelper.toDateKey(date),
    );
  }

  DateTime? loadLastActiveDate(String deityId) {
    return DateHelper.fromDateKey(
      HiveStorage.statisticsBox.get(
            HiveKeys.forDeity(deityId, HiveKeys.lastActiveDate),
          )
          as String?,
    );
  }
}
