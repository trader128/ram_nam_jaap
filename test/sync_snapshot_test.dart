import 'package:flutter_test/flutter_test.dart';
import 'package:bhakti/core/sync/sync_snapshot.dart';

DeityStatsSnapshot stats({
  String deityId = 'ram',
  int todayCount = 0,
  String todayDate = '2026-08-24',
  int lifetimeCount = 0,
  int currentStreak = 0,
  int longestStreak = 0,
  String? lastActiveDate,
  Map<String, int> dailyRecords = const {},
}) {
  return DeityStatsSnapshot(
    deityId: deityId,
    todayCount: todayCount,
    todayDate: todayDate,
    lifetimeCount: lifetimeCount,
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    lastActiveDate: lastActiveDate,
    dailyRecords: dailyRecords,
  );
}

void main() {
  group('DeityStatsSnapshot.mergeWith', () {
    test('keeps the higher lifetime count regardless of write order', () {
      final local = stats(lifetimeCount: 500);
      final remote = stats(lifetimeCount: 1200);

      expect(local.mergeWith(remote).lifetimeCount, 1200);
      expect(remote.mergeWith(local).lifetimeCount, 1200);
    });

    test('takes the higher count when both sides mean the same day', () {
      final local = stats(todayCount: 108, todayDate: '2026-08-24');
      final remote = stats(todayCount: 54, todayDate: '2026-08-24');

      final merged = local.mergeWith(remote);
      expect(merged.todayCount, 108);
      expect(merged.todayDate, '2026-08-24');
    });

    test('prefers the newer day rather than max when days differ', () {
      final today = stats(todayCount: 12, todayDate: '2026-08-24');
      final yesterday = stats(todayCount: 900, todayDate: '2026-08-23');

      final merged = today.mergeWith(yesterday);
      expect(merged.todayDate, '2026-08-24');
      expect(
        merged.todayCount,
        12,
        reason: 'yesterday\'s total must not leak into today',
      );
    });

    test('never reports a lifetime lower than today', () {
      final local = stats(todayCount: 300, lifetimeCount: 100);
      final merged = local.mergeWith(stats(lifetimeCount: 50));

      expect(merged.lifetimeCount, greaterThanOrEqualTo(merged.todayCount));
    });

    test('unions daily history and keeps the higher count per day', () {
      final local = stats(dailyRecords: {'2026-08-22': 108, '2026-08-23': 20});
      final remote = stats(dailyRecords: {'2026-08-23': 216, '2026-08-21': 54});

      final merged = local.mergeWith(remote);
      expect(merged.dailyRecords, {
        '2026-08-21': 54,
        '2026-08-22': 108,
        '2026-08-23': 216,
      });
    });

    test('keeps the longest streak ever recorded on either device', () {
      final merged = stats(longestStreak: 9).mergeWith(stats(longestStreak: 31));
      expect(merged.longestStreak, 31);
    });
  });

  group('SyncSnapshot', () {
    test('round-trips through a Firestore-shaped map', () {
      final original = SyncSnapshot(
        deities: {
          'ram': stats(
            todayCount: 108,
            lifetimeCount: 5400,
            currentStreak: 7,
            longestStreak: 21,
            lastActiveDate: '2026-08-24',
            dailyRecords: {'2026-08-24': 108},
          ),
        },
        settings: const {'daily_goal': 108, 'app_language': 'hi'},
        updatedAt: DateTime.parse('2026-08-24T10:30:00Z').toLocal(),
      );

      final restored = SyncSnapshot.fromMap(original.toMap());

      expect(restored.schemaVersion, SyncSnapshot.currentSchemaVersion);
      expect(restored.settings, original.settings);
      expect(restored.updatedAt, original.updatedAt);

      final deity = restored.deities['ram']!;
      expect(deity.todayCount, 108);
      expect(deity.lifetimeCount, 5400);
      expect(deity.longestStreak, 21);
      expect(deity.dailyRecords, {'2026-08-24': 108});
    });

    test('adopts a deity present only in the remote copy', () {
      final local = SyncSnapshot(
        deities: {'ram': stats(lifetimeCount: 10)},
        settings: const {},
        updatedAt: DateTime(2026, 8, 24),
      );
      final remote = SyncSnapshot(
        deities: {'krishna': stats(deityId: 'krishna', lifetimeCount: 99)},
        settings: const {},
        updatedAt: DateTime(2026, 8, 23),
      );

      final merged = local.mergeWith(remote);
      expect(merged.deities.keys, containsAll(['ram', 'krishna']));
      expect(merged.deities['krishna']!.lifetimeCount, 99);
    });

    test('lets the more recently changed side win on preferences', () {
      final older = SyncSnapshot(
        deities: const {},
        settings: const {'daily_goal': 108, 'sound_enabled': true},
        updatedAt: DateTime(2026, 8, 20),
      );
      final newer = SyncSnapshot(
        deities: const {},
        settings: const {'daily_goal': 1008},
        updatedAt: DateTime(2026, 8, 24),
      );

      final merged = older.mergeWith(newer);
      expect(merged.settings['daily_goal'], 1008);
      expect(
        merged.settings['sound_enabled'],
        true,
        reason: 'keys absent from the newer side should survive',
      );
    });

    test('an empty remote document leaves local data untouched', () {
      final local = SyncSnapshot(
        deities: {'ram': stats(todayCount: 54, lifetimeCount: 54)},
        settings: const {'daily_goal': 108},
        updatedAt: DateTime(2026, 8, 24),
      );

      final merged = local.mergeWith(
        SyncSnapshot(
          deities: const {},
          settings: const {},
          updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );

      expect(merged.deities['ram']!.todayCount, 54);
      expect(merged.settings['daily_goal'], 108);
    });
  });
}
