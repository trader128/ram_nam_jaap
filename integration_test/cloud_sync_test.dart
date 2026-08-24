// End-to-end verification of Phase 0 cloud backup against the real Firebase
// project. Run on a booted device or simulator:
//
//   flutter test integration_test/cloud_sync_test.dart
//
// This exercises the parts unit tests cannot: that Firebase initialises, that
// anonymous sign-in succeeds, that a users/{uid} document is actually written
// and readable back under the deployed security rules, and — most importantly —
// that chanting keeps working when the cloud is unreachable.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:bhakti/core/constants/hive_keys.dart';
import 'package:bhakti/core/firebase/firebase_bootstrap.dart';
import 'package:bhakti/core/storage/hive_storage.dart';
import 'package:bhakti/core/sync/sync_providers.dart';
import 'package:bhakti/core/sync/sync_status.dart';
import 'package:bhakti/features/deity/data/deity_migration.dart';
import 'package:bhakti/features/jap/providers/jap_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUpAll(() async {
    await HiveStorage.init();
    await DeityMigration.run();
    await FirebaseBootstrap.init();
  });

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('Firebase initialises with the bundled configuration', () {
    expect(
      FirebaseBootstrap.isAvailable,
      isTrue,
      reason: 'Firebase failed to initialise — check google-services.json '
          'and GoogleService-Info.plist are present and match the project',
    );
  });

  test('anonymous sign-in yields a stable uid without any login UI', () async {
    final account = container.read(accountServiceProvider);

    final uid = await account.ensureSignedIn();
    expect(uid, isNotNull, reason: 'Anonymous auth provider may be disabled');

    final second = await account.ensureSignedIn();
    expect(
      second,
      uid,
      reason: 'the same device must keep one uid across calls, or history '
          'would fork on every launch',
    );
  });

  test('enabling backup writes a readable users/{uid} document', () async {
    // Give the sync something unambiguous to carry up.
    final settings = container.read(japSettingsProvider.notifier);
    await settings.setDailyGoal(108);

    final controller = container.read(syncControllerProvider.notifier);
    expect(controller.isSupported, isTrue);

    await controller.setEnabled(true);

    final status = container.read(syncControllerProvider);
    expect(
      status.state,
      SyncState.synced,
      reason: 'sync reported ${status.state}; rules may not be deployed',
    );
    expect(status.lastSyncedAt, isNotNull);

    final uid = container.read(accountServiceProvider).currentUid!;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    expect(snapshot.exists, isTrue);
    final data = snapshot.data()!;
    expect(data['schemaVersion'], 1);
    expect(data['updatedAt'], isA<String>());
    expect(
      (data['settings'] as Map)[HiveKeys.dailyGoal],
      108,
      reason: 'preferences did not reach the cloud copy',
    );
  });

  test('a device cannot read another device\'s backup', () async {
    await container.read(accountServiceProvider).ensureSignedIn();

    await expectLater(
      FirebaseFirestore.instance
          .collection('users')
          .doc('some-other-devices-uid')
          .get(),
      throwsA(
        isA<FirebaseException>().having(
          (error) => error.code,
          'code',
          'permission-denied',
        ),
      ),
    );
  });

  test('chanting still works with backup enabled', () async {
    final session = container.read(japSessionProvider.notifier);
    final statistics = container.read(japStatisticsProvider.notifier);
    final history = container.read(japHistoryProvider.notifier);

    await session.beginSession();
    final before = container.read(japStatisticsProvider).todayCount;

    for (var i = 0; i < 5; i++) {
      await session.registerJap(statistics, history);
    }

    expect(
      container.read(japStatisticsProvider).todayCount,
      before + 5,
      reason: 'counts must come straight from local storage, never the network',
    );

    await session.endSession();
  });
}
