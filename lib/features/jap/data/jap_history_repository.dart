import '../../../core/constants/hive_keys.dart';
import '../../../core/helpers/date_helper.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../shared/models/daily_jap_record.dart';

class JapHistoryRepository {
  Map<String, int> _loadRawRecords() {
    final raw = HiveStorage.historyBox.get(HiveKeys.dailyRecords);
    if (raw is Map) {
      return raw.map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      );
    }
    return {};
  }

  Future<void> saveDailyCount({
    required DateTime date,
    required int count,
    required int dailyGoal,
  }) async {
    final records = _loadRawRecords();
    records[DateHelper.toDateKey(date)] = count;
    await HiveStorage.historyBox.put(HiveKeys.dailyRecords, records);
  }

  List<DailyJapRecord> loadRecords({required int dailyGoal}) {
    final records = _loadRawRecords();
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
    required DateTime date,
    required int dailyGoal,
  }) {
    final count = _loadRawRecords()[DateHelper.toDateKey(date)];
    if (count == null) {
      return null;
    }

    return DailyJapRecord(date: date, count: count, dailyGoal: dailyGoal);
  }
}
