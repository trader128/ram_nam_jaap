import '../../../core/constants/hive_keys.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../shared/models/jap_session.dart';

class JapSessionRepository {
  JapSession load() {
    final box = HiveStorage.sessionBox;
    final startedAtRaw = box.get(HiveKeys.sessionStartedAt) as String?;

    return JapSession(
      count: box.get(HiveKeys.sessionCount, defaultValue: 0) as int,
      isActive: box.get(HiveKeys.isSessionActive, defaultValue: false) as bool,
      startedAt: startedAtRaw == null ? null : DateTime.tryParse(startedAtRaw),
    );
  }

  Future<void> save(JapSession session) async {
    final box = HiveStorage.sessionBox;
    await box.put(HiveKeys.sessionCount, session.count);
    await box.put(HiveKeys.isSessionActive, session.isActive);
    await box.put(
      HiveKeys.sessionStartedAt,
      session.startedAt?.toIso8601String(),
    );
  }

  Future<void> clear() async {
    await save(JapSession.empty);
  }
}
