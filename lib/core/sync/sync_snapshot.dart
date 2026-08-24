/// Per-deity chanting progress in a form that can round-trip through Firestore.
class DeityStatsSnapshot {
  const DeityStatsSnapshot({
    required this.deityId,
    required this.todayCount,
    required this.todayDate,
    required this.lifetimeCount,
    required this.currentStreak,
    required this.longestStreak,
    required this.dailyRecords,
    this.lastActiveDate,
  });

  final String deityId;
  final int todayCount;

  /// `yyyy-MM-dd` key that [todayCount] belongs to.
  final String todayDate;
  final int lifetimeCount;
  final int currentStreak;
  final int longestStreak;
  final String? lastActiveDate;

  /// `yyyy-MM-dd` -> count for that day.
  final Map<String, int> dailyRecords;

  /// Merges two views of the same deity so a jap is never lost.
  ///
  /// Counters here only ever grow, so the merge takes the maximum rather than
  /// letting the most recent write clobber a higher count from another device
  /// or from an older local backup. Today's count is only comparable when both
  /// sides are talking about the same calendar day.
  DeityStatsSnapshot mergeWith(DeityStatsSnapshot other) {
    assert(other.deityId == deityId, 'Cannot merge snapshots of two deities');

    final int mergedTodayCount;
    final String mergedTodayDate;
    if (todayDate == other.todayDate) {
      mergedTodayCount = todayCount > other.todayCount
          ? todayCount
          : other.todayCount;
      mergedTodayDate = todayDate;
    } else if (todayDate.compareTo(other.todayDate) > 0) {
      mergedTodayCount = todayCount;
      mergedTodayDate = todayDate;
    } else {
      mergedTodayCount = other.todayCount;
      mergedTodayDate = other.todayDate;
    }

    final mergedRecords = Map<String, int>.from(dailyRecords);
    for (final entry in other.dailyRecords.entries) {
      final existing = mergedRecords[entry.key];
      if (existing == null || entry.value > existing) {
        mergedRecords[entry.key] = entry.value;
      }
    }

    final mergedLastActive = _laterDateKey(lastActiveDate, other.lastActiveDate);
    final mergedLifetime = lifetimeCount > other.lifetimeCount
        ? lifetimeCount
        : other.lifetimeCount;

    return DeityStatsSnapshot(
      deityId: deityId,
      todayCount: mergedTodayCount,
      todayDate: mergedTodayDate,
      lifetimeCount: mergedLifetime < mergedTodayCount
          ? mergedTodayCount
          : mergedLifetime,
      currentStreak: currentStreak > other.currentStreak
          ? currentStreak
          : other.currentStreak,
      longestStreak: longestStreak > other.longestStreak
          ? longestStreak
          : other.longestStreak,
      lastActiveDate: mergedLastActive,
      dailyRecords: mergedRecords,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'todayCount': todayCount,
      'todayDate': todayDate,
      'lifetimeCount': lifetimeCount,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActiveDate': lastActiveDate,
      'dailyRecords': dailyRecords,
    };
  }

  static DeityStatsSnapshot fromMap(String deityId, Map<String, dynamic> map) {
    final rawRecords = map['dailyRecords'];
    final records = <String, int>{};
    if (rawRecords is Map) {
      for (final entry in rawRecords.entries) {
        final value = entry.value;
        if (value is num) {
          records[entry.key.toString()] = value.toInt();
        }
      }
    }

    return DeityStatsSnapshot(
      deityId: deityId,
      todayCount: _asInt(map['todayCount']),
      todayDate: map['todayDate'] as String? ?? '',
      lifetimeCount: _asInt(map['lifetimeCount']),
      currentStreak: _asInt(map['currentStreak']),
      longestStreak: _asInt(map['longestStreak']),
      lastActiveDate: map['lastActiveDate'] as String?,
      dailyRecords: records,
    );
  }

  static int _asInt(Object? value) => value is num ? value.toInt() : 0;

  static String? _laterDateKey(String? a, String? b) {
    if (a == null) {
      return b;
    }
    if (b == null) {
      return a;
    }
    return a.compareTo(b) >= 0 ? a : b;
  }
}

/// Everything this device wants mirrored to `users/{uid}`.
class SyncSnapshot {
  const SyncSnapshot({
    required this.deities,
    required this.settings,
    required this.updatedAt,
    this.schemaVersion = currentSchemaVersion,
  });

  static const int currentSchemaVersion = 1;

  final Map<String, DeityStatsSnapshot> deities;
  final Map<String, dynamic> settings;
  final DateTime updatedAt;
  final int schemaVersion;

  bool get isEmpty => deities.isEmpty && settings.isEmpty;

  /// Combines local and remote state.
  ///
  /// Counters merge non-destructively (see [DeityStatsSnapshot.mergeWith]);
  /// preferences are a plain last-write-wins, since a stale toggle is
  /// recoverable and a lost jap count is not.
  SyncSnapshot mergeWith(SyncSnapshot other) {
    final mergedDeities = Map<String, DeityStatsSnapshot>.from(deities);
    for (final entry in other.deities.entries) {
      final existing = mergedDeities[entry.key];
      mergedDeities[entry.key] = existing == null
          ? entry.value
          : existing.mergeWith(entry.value);
    }

    final localIsNewer = updatedAt.isAfter(other.updatedAt);
    final mergedSettings = <String, dynamic>{
      ...localIsNewer ? other.settings : settings,
      ...localIsNewer ? settings : other.settings,
    };

    return SyncSnapshot(
      deities: mergedDeities,
      settings: mergedSettings,
      updatedAt: localIsNewer ? updatedAt : other.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'schemaVersion': schemaVersion,
      'updatedAt': updatedAt.toUtc().toIso8601String(),
      'settings': settings,
      'japaStats': {
        for (final entry in deities.entries) entry.key: entry.value.toMap(),
      },
    };
  }

  static SyncSnapshot fromMap(Map<String, dynamic> map) {
    final rawStats = map['japaStats'];
    final deities = <String, DeityStatsSnapshot>{};
    if (rawStats is Map) {
      for (final entry in rawStats.entries) {
        final value = entry.value;
        if (value is Map) {
          final deityId = entry.key.toString();
          deities[deityId] = DeityStatsSnapshot.fromMap(
            deityId,
            Map<String, dynamic>.from(value),
          );
        }
      }
    }

    final rawSettings = map['settings'];
    return SyncSnapshot(
      deities: deities,
      settings: rawSettings is Map
          ? Map<String, dynamic>.from(rawSettings)
          : const {},
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '')?.toLocal() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      schemaVersion: DeityStatsSnapshot._asInt(map['schemaVersion']),
    );
  }
}
