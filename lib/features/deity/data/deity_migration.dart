import 'package:hive/hive.dart';

import '../../../core/constants/hive_keys.dart';
import '../../../core/storage/hive_storage.dart';
import '../domain/deity_catalog.dart';

/// Migrates legacy single-deity (Ram-only) data into the per-deity namespace.
///
/// Earlier versions stored statistics, history, and session under unprefixed
/// keys. Those values belong to Ram, so on first launch of the multi-deity
/// build we copy them into the `ram_` namespace exactly once.
abstract final class DeityMigration {
  static const String _ram = DeityCatalog.defaultDeityId;

  static const List<String> _statisticsKeys = [
    HiveKeys.totalLifetime,
    HiveKeys.todayCount,
    HiveKeys.todayDate,
    HiveKeys.currentStreak,
    HiveKeys.longestStreak,
    HiveKeys.lastActiveDate,
  ];

  static const List<String> _sessionKeys = [
    HiveKeys.sessionCount,
    HiveKeys.sessionStartedAt,
    HiveKeys.isSessionActive,
  ];

  static Future<void> run() async {
    final settings = HiveStorage.settingsBox;
    final alreadyMigrated =
        settings.get(HiveKeys.deityMigrated, defaultValue: false) as bool;
    if (alreadyMigrated) {
      return;
    }

    await _migrateBox(HiveStorage.statisticsBox, _statisticsKeys);
    await _migrateBox(HiveStorage.sessionBox, _sessionKeys);
    await _migrateKey(HiveStorage.historyBox, HiveKeys.dailyRecords);

    if (settings.get(HiveKeys.selectedDeity) == null) {
      await settings.put(HiveKeys.selectedDeity, _ram);
    }
    await settings.put(HiveKeys.deityMigrated, true);
  }

  static Future<void> _migrateBox(Box<dynamic> box, List<String> keys) async {
    for (final key in keys) {
      await _migrateKey(box, key);
    }
  }

  static Future<void> _migrateKey(Box<dynamic> box, String key) async {
    final namespacedKey = HiveKeys.forDeity(_ram, key);
    if (box.containsKey(namespacedKey)) {
      return;
    }
    final legacyValue = box.get(key);
    if (legacyValue != null) {
      await box.put(namespacedKey, legacyValue);
    }
  }
}
