import '../../../core/constants/hive_keys.dart';
import '../../../core/helpers/date_helper.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../shared/models/daily_jap_record.dart';

class JapHistoryRepository {
  Map<String, int> _loadRawRecords(String deityId) {
    final raw = HiveStorage.historyBox.get(
      HiveKeys.forDeity(deityId, HiveKeys.dailyRecords),
    );
    if (raw is Map) {
      return raw.map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      );
    }
    return {};
  }

  Future<void> saveDailyCount({
    required String deityId,
    required DateTime date,
    required int count,
    required int dailyGoal,
  }) async {
    final records = _loadRawRecords(deityId);
    records[DateHelper.toDateKey(date)] = count;
    await HiveStorage.historyBox.put(
      HiveKeys.forDeity(deityId, HiveKeys.dailyRecords),
      records,
    );
  }

  List<DailyJapRecord> loadRecords({
    required String deityId,
    required int dailyGoal,
  }) {
    final records = _loadRawRecords(deityId);
    return records.entries
        .map((entry) {
          final date = DateHelper.fromDateKey(entry.key);
          if (date == null) {
            return null;
          }
          return DailyJapRecord(
            date: date,
            count: entry.value,
            dailyGoal: dailyGoal,
          );
        })
        .whereType<DailyJapRecord>()
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  DailyJapRecord? recordForDate({
    required String deityId,
    required DateTime date,
    required int dailyGoal,
  }) {
    final count = _loadRawRecords(deityId)[DateHelper.toDateKey(date)];
    if (count == null) {
      return null;
    }

    return DailyJapRecord(date: date, count: count, dailyGoal: dailyGoal);
  }
}
