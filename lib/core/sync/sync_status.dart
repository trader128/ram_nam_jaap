enum SyncState {
  /// Firebase is not configured, or the user turned backup off.
  disabled,

  /// Enabled but nothing has happened yet this session.
  idle,

  syncing,

  synced,

  /// Last attempt failed; local data is untouched and will retry.
  failed,
}

class SyncStatus {
  const SyncStatus({required this.state, this.lastSyncedAt, this.message});

  const SyncStatus.disabled() : state = SyncState.disabled, lastSyncedAt = null, message = null;

  final SyncState state;
  final DateTime? lastSyncedAt;
  final String? message;

  bool get isBusy => state == SyncState.syncing;

  SyncStatus copyWith({
    SyncState? state,
    DateTime? lastSyncedAt,
    String? message,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: message,
    );
  }
}
