import '../../../core/constants/hive_keys.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../shared/models/jap_session.dart';

class JapSessionRepository {
  JapSession load(String deityId) {
    final box = HiveStorage.sessionBox;
    final startedAtRaw =
        box.get(HiveKeys.forDeity(deityId, HiveKeys.sessionStartedAt))
            as String?;

    return JapSession(
      count:
          box.get(
                HiveKeys.forDeity(deityId, HiveKeys.sessionCount),
                defaultValue: 0,
              )
              as int,
      isActive:
          box.get(
                HiveKeys.forDeity(deityId, HiveKeys.isSessionActive),
                defaultValue: false,
              )
              as bool,
      startedAt: startedAtRaw == null ? null : DateTime.tryParse(startedAtRaw),
    );
  }

  Future<void> save(String deityId, JapSession session) async {
    final box = HiveStorage.sessionBox;
    await box.put(
      HiveKeys.forDeity(deityId, HiveKeys.sessionCount),
      session.count,
    );
    await box.put(
      HiveKeys.forDeity(deityId, HiveKeys.isSessionActive),
      session.isActive,
    );
    await box.put(
      HiveKeys.forDeity(deityId, HiveKeys.sessionStartedAt),
      session.startedAt?.toIso8601String(),
    );
  }

  Future<void> clear(String deityId) async {
    await save(deityId, JapSession.empty);
  }
}
