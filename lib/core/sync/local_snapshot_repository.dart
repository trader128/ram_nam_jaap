import '../../features/deity/domain/deity_catalog.dart';
import '../constants/hive_keys.dart';
import '../storage/hive_storage.dart';
import 'sync_snapshot.dart';

/// Reads and writes the synced slice of Hive.
///
/// Only durable, cross-device state travels: chanting progress and user
/// preferences. Device-local UX flags (welcome seen, coach dismissed, migration
/// markers) deliberately stay out so restoring a backup never re-triggers or
/// skips onboarding on a different phone.
class LocalSnapshotRepository {
  static const List<String> syncedSettingKeys = [
    HiveKeys.soundEnabled,
    HiveKeys.hapticEnabled,
    HiveKeys.floatingTextEnabled,
    HiveKeys.backTapEnabled,
    HiveKeys.textSize,
    HiveKeys.dailyGoal,
    HiveKeys.floatingTextColor,
    HiveKeys.countMethod,
    HiveKeys.showMalaRing,
    HiveKeys.divineWallpaperEnabled,
    HiveKeys.idleMusicEnabled,
    HiveKeys.bookModeEnabled,
    HiveKeys.appLanguage,
    HiveKeys.selectedDeity,
  ];

  SyncSnapshot read() {
    final deities = <String, DeityStatsSnapshot>{};
    for (final deity in DeityCatalog.all) {
      final snapshot = _readDeity(deity.id);
      if (snapshot != null) {
        deities[deity.id] = snapshot;
      }
    }

    final settingsBox = HiveStorage.settingsBox;
    final settings = <String, dynamic>{};
    for (final key in syncedSettingKeys) {
      final value = settingsBox.get(key);
      if (value != null) {
        settings[key] = value;
      }
    }

    return SyncSnapshot(
      deities: deities,
      settings: settings,
      updatedAt: _lastLocalChange(),
    );
  }

  Future<void> write(SyncSnapshot snapshot) async {
    final statisticsBox = HiveStorage.statisticsBox;
    final historyBox = HiveStorage.historyBox;

    for (final entry in snapshot.deities.entries) {
      final deityId = entry.key;
      final stats = entry.value;

      await statisticsBox.putAll({
        HiveKeys.forDeity(deityId, HiveKeys.todayCount): stats.todayCount,
        HiveKeys.forDeity(deityId, HiveKeys.todayDate): stats.todayDate,
        HiveKeys.forDeity(deityId, HiveKeys.totalLifetime): stats.lifetimeCount,
        HiveKeys.forDeity(deityId, HiveKeys.currentStreak): stats.currentStreak,
        HiveKeys.forDeity(deityId, HiveKeys.longestStreak): stats.longestStreak,
      });

      if (stats.lastActiveDate != null) {
        await statisticsBox.put(
          HiveKeys.forDeity(deityId, HiveKeys.lastActiveDate),
          stats.lastActiveDate,
        );
      }

      if (stats.dailyRecords.isNotEmpty) {
        await historyBox.put(
          HiveKeys.forDeity(deityId, HiveKeys.dailyRecords),
          stats.dailyRecords,
        );
      }
    }

    final settingsBox = HiveStorage.settingsBox;
    for (final entry in snapshot.settings.entries) {
      if (syncedSettingKeys.contains(entry.key)) {
        await settingsBox.put(entry.key, entry.value);
      }
    }
  }

  Future<void> markLocalChange() async {
    await HiveStorage.settingsBox.put(
      HiveKeys.localChangedAt,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<void> markSynced(DateTime at) async {
    await HiveStorage.settingsBox.put(
      HiveKeys.lastSyncedAt,
      at.toUtc().toIso8601String(),
    );
  }

  DateTime? get lastSyncedAt => DateTime.tryParse(
    HiveStorage.settingsBox.get(HiveKeys.lastSyncedAt) as String? ?? '',
  )?.toLocal();

  DateTime _lastLocalChange() {
    return DateTime.tryParse(
          HiveStorage.settingsBox.get(HiveKeys.localChangedAt) as String? ?? '',
        )?.toLocal() ??
        DateTime.now();
  }

  DeityStatsSnapshot? _readDeity(String deityId) {
    final statisticsBox = HiveStorage.statisticsBox;
    final todayDate =
        statisticsBox.get(HiveKeys.forDeity(deityId, HiveKeys.todayDate))
            as String?;
    final lifetime =
        statisticsBox.get(HiveKeys.forDeity(deityId, HiveKeys.totalLifetime))
            as int?;

    final rawRecords = HiveStorage.historyBox.get(
      HiveKeys.forDeity(deityId, HiveKeys.dailyRecords),
    );
    final records = <String, int>{};
    if (rawRecords is Map) {
      for (final entry in rawRecords.entries) {
        final value = entry.value;
        if (value is num) {
          records[entry.key.toString()] = value.toInt();
        }
      }
    }

    // Nothing has ever been chanted for this deity — skip it entirely so the
    // remote document stays small.
    if (todayDate == null && lifetime == null && records.isEmpty) {
      return null;
    }

    return DeityStatsSnapshot(
      deityId: deityId,
      todayCount:
          statisticsBox.get(
                HiveKeys.forDeity(deityId, HiveKeys.todayCount),
                defaultValue: 0,
              )
              as int,
      todayDate: todayDate ?? '',
      lifetimeCount: lifetime ?? 0,
      currentStreak:
          statisticsBox.get(
                HiveKeys.forDeity(deityId, HiveKeys.currentStreak),
                defaultValue: 0,
              )
              as int,
      longestStreak:
          statisticsBox.get(
                HiveKeys.forDeity(deityId, HiveKeys.longestStreak),
                defaultValue: 0,
              )
              as int,
      lastActiveDate:
          statisticsBox.get(HiveKeys.forDeity(deityId, HiveKeys.lastActiveDate))
              as String?,
      dailyRecords: records,
    );
  }
}
