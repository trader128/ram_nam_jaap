import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../firebase/firebase_bootstrap.dart';
import 'account_service.dart';
import 'local_snapshot_repository.dart';
import 'sync_snapshot.dart';

/// Mirrors local chanting data to `users/{uid}` and back.
///
/// Firestore is a backup, never the read path for the counter: every jap is
/// written to Hive first and the UI only ever reads Hive. Sync failures are
/// therefore silent and non-fatal — the worst case is that a backup is stale.
class CloudSyncService {
  CloudSyncService({
    required AccountService accountService,
    required LocalSnapshotRepository localRepository,
  }) : _accountService = accountService,
       _localRepository = localRepository;

  static const Duration _pushDebounce = Duration(seconds: 5);

  final AccountService _accountService;
  final LocalSnapshotRepository _localRepository;

  Timer? _debounce;
  Future<void>? _inFlight;

  bool get isAvailable => FirebaseBootstrap.isAvailable;

  /// Coalesces bursts of japs into a single upload.
  void schedulePush() {
    if (!isAvailable) {
      return;
    }
    _debounce?.cancel();
    _debounce = Timer(_pushDebounce, () => unawaited(syncNow()));
  }

  /// Pull, merge, push — safe to call on launch and on resume.
  Future<DateTime?> syncNow() async {
    if (!isAvailable) {
      return null;
    }

    // Collapse concurrent callers onto one round trip.
    final pending = _inFlight;
    if (pending != null) {
      await pending;
      return _localRepository.lastSyncedAt;
    }

    final operation = _sync();
    _inFlight = operation;
    try {
      await operation;
    } finally {
      _inFlight = null;
    }
    return _localRepository.lastSyncedAt;
  }

  Future<void> _sync() async {
    final uid = await _accountService.ensureSignedIn();
    if (uid == null) {
      throw StateError('No account available for sync');
    }

    final document = FirebaseFirestore.instance.collection('users').doc(uid);
    final local = _localRepository.read();

    final remoteDoc = await document.get();
    final remoteData = remoteDoc.data();

    final merged = remoteData == null
        ? local
        : local.mergeWith(SyncSnapshot.fromMap(remoteData));

    // Only touch local storage when the cloud actually contributed something,
    // so a routine backup never rewrites Hive underneath an active session.
    if (remoteData != null) {
      await _localRepository.write(merged);
    }

    await document.set(merged.toMap(), SetOptions(merge: true));
    await _localRepository.markSynced(DateTime.now());
  }

  /// Removes the cloud copy. Local data is intentionally left intact.
  Future<void> deleteRemoteCopy() async {
    if (!isAvailable) {
      return;
    }

    final uid = _accountService.currentUid;
    if (uid == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
    } on Object catch (error) {
      debugPrint('Failed to delete cloud backup: $error');
      rethrow;
    }
  }

  void dispose() {
    _debounce?.cancel();
    _debounce = null;
  }
}
