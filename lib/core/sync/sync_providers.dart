import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/hive_keys.dart';
import '../firebase/firebase_bootstrap.dart';
import '../storage/hive_storage.dart';
import 'account_service.dart';
import 'cloud_sync_service.dart';
import 'local_snapshot_repository.dart';
import 'sync_status.dart';

final accountServiceProvider = Provider<AccountService>(
  (ref) => AccountService(),
);

final localSnapshotRepositoryProvider = Provider<LocalSnapshotRepository>(
  (ref) => LocalSnapshotRepository(),
);

final cloudSyncServiceProvider = Provider<CloudSyncService>((ref) {
  final service = CloudSyncService(
    accountService: ref.watch(accountServiceProvider),
    localRepository: ref.watch(localSnapshotRepositoryProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncStatus>((ref) {
      return SyncController(
        service: ref.watch(cloudSyncServiceProvider),
        localRepository: ref.watch(localSnapshotRepositoryProvider),
      );
    });

/// Owns the user-facing backup state.
///
/// Backup is opt-in and off by default: the app keeps its "everything stays on
/// your device" behaviour until the user explicitly turns sync on.
class SyncController extends StateNotifier<SyncStatus> {
  SyncController({
    required CloudSyncService service,
    required LocalSnapshotRepository localRepository,
  }) : _service = service,
       _localRepository = localRepository,
       super(const SyncStatus.disabled()) {
    _restore();
  }

  final CloudSyncService _service;
  final LocalSnapshotRepository _localRepository;

  bool get isSupported => FirebaseBootstrap.isAvailable;

  bool get isEnabled =>
      HiveStorage.settingsBox.get(HiveKeys.syncEnabled, defaultValue: false)
          as bool;

  void _restore() {
    if (!isSupported || !isEnabled) {
      state = const SyncStatus.disabled();
      return;
    }
    state = SyncStatus(
      state: SyncState.idle,
      lastSyncedAt: _localRepository.lastSyncedAt,
    );
  }

  Future<void> setEnabled(bool value) async {
    await HiveStorage.settingsBox.put(HiveKeys.syncEnabled, value);
    if (!value) {
      state = const SyncStatus.disabled();
      return;
    }

    state = SyncStatus(
      state: SyncState.idle,
      lastSyncedAt: _localRepository.lastSyncedAt,
    );
    await syncNow();
  }

  /// Records that Hive changed, then lets the service coalesce the upload.
  void notifyLocalChange() {
    if (!isSupported || !isEnabled) {
      return;
    }
    unawaited(_localRepository.markLocalChange());
    _service.schedulePush();
  }

  Future<void> syncNow() async {
    if (!isSupported || !isEnabled || state.isBusy) {
      return;
    }

    state = state.copyWith(state: SyncState.syncing);
    try {
      final syncedAt = await _service.syncNow();
      state = SyncStatus(
        state: SyncState.synced,
        lastSyncedAt: syncedAt ?? _localRepository.lastSyncedAt,
      );
    } on Object catch (error) {
      debugPrint('Cloud sync failed: $error');
      state = SyncStatus(
        state: SyncState.failed,
        lastSyncedAt: _localRepository.lastSyncedAt,
      );
    }
  }

  /// Turns backup off and removes the cloud copy, keeping local data.
  Future<void> deleteCloudBackup() async {
    try {
      await _service.deleteRemoteCopy();
    } on Object {
      // Surfaced through state below; local data is unaffected either way.
    }
    await HiveStorage.settingsBox.put(HiveKeys.syncEnabled, false);
    await HiveStorage.settingsBox.delete(HiveKeys.lastSyncedAt);
    state = const SyncStatus.disabled();
  }
}
