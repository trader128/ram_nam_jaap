import 'dart:async';

import '../../../core/constants/jap_constants.dart';
import '../../../core/helpers/date_helper.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../shared/models/jap_session.dart';
import '../../../shared/models/jap_settings.dart';
import '../../../shared/models/jap_statistics.dart';
import '../data/jap_history_repository.dart';
import '../data/jap_session_repository.dart';
import '../data/jap_settings_repository.dart';
import '../data/jap_statistics_repository.dart';

/// Orchestrates a chanting session for a single deity.
///
/// A fresh controller is created per active deity, so all reads/writes are
/// scoped to [deityId]. Counts are held in memory and flushed to Hive on a
/// short debounce to keep tapping perfectly smooth.
class JapController {
  JapController({
    required String deityId,
    required JapStatisticsRepository statisticsRepository,
    required JapSessionRepository sessionRepository,
    required JapSettingsRepository settingsRepository,
    required JapHistoryRepository historyRepository,
    required SoundService soundService,
    required HapticService hapticService,
  }) : _deityId = deityId,
       _statisticsRepository = statisticsRepository,
       _sessionRepository = sessionRepository,
       _settingsRepository = settingsRepository,
       _historyRepository = historyRepository,
       _soundService = soundService,
       _hapticService = hapticService;

  final String _deityId;
  final JapStatisticsRepository _statisticsRepository;
  final JapSessionRepository _sessionRepository;
  final JapSettingsRepository _settingsRepository;
  final JapHistoryRepository _historyRepository;
  final SoundService _soundService;
  final HapticService _hapticService;

  JapSession? _memorySession;
  JapStatistics? _memoryStatistics;
  Timer? _persistDebounce;
  Future<void>? _persistChain;

  JapStatistics loadStatistics() {
    return _memoryStatistics ?? _statisticsRepository.load(_deityId);
  }

  JapSession loadSession() {
    return _memorySession ?? _sessionRepository.load(_deityId);
  }

  JapSettings loadSettings() => _settingsRepository.load();

  Future<JapSession> startSession() async {
    final existing = loadSession();
    if (existing.isActive) {
      _memorySession = existing;
      return existing;
    }

    final session = JapSession(
      count: 0,
      isActive: true,
      startedAt: DateTime.now(),
    );
    _memorySession = session;
    await _sessionRepository.save(_deityId, session);
    return session;
  }

  Future<JapSessionState> registerJap() async {
    final settings = _settingsRepository.load();
    var session = loadSession();
    if (!session.isActive) {
      session = await startSession();
    }

    final updatedSession = session.copyWith(count: session.count + 1);
    final updatedStatistics = _incrementStatistics(
      _memoryStatistics ?? _statisticsRepository.load(_deityId),
    );

    _memorySession = updatedSession;
    _memoryStatistics = updatedStatistics;

    final isMalaComplete =
        updatedSession.count % JapConstants.beadsPerMala == 0;

    _schedulePersist(settings);
    _playFeedback(settings: settings, malaCompleted: isMalaComplete);

    return JapSessionState(
      session: updatedSession,
      statistics: updatedStatistics,
      settings: settings,
      japTrigger: updatedSession.count,
      malaCompleted: isMalaComplete,
    );
  }

  Future<void> endSession() async {
    _persistDebounce?.cancel();
    _persistDebounce = null;
    await _flushPersist();
    await _sessionRepository.clear(_deityId);
    _memorySession = null;
    _memoryStatistics = null;
  }

  void _schedulePersist(JapSettings settings) {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 120), () {
      unawaited(_flushPersist(settings: settings));
    });
  }

  Future<void> _flushPersist({JapSettings? settings}) async {
    final session = _memorySession;
    final statistics = _memoryStatistics;
    if (session == null || statistics == null) {
      return;
    }

    final resolvedSettings = settings ?? _settingsRepository.load();
    Future<void> persist() async {
      await Future.wait([
        _sessionRepository.save(_deityId, session),
        _statisticsRepository.save(_deityId, statistics),
        _statisticsRepository.saveLastActiveDate(_deityId, DateHelper.today()),
        _historyRepository.saveDailyCount(
          deityId: _deityId,
          date: statistics.todayDate,
          count: statistics.todayCount,
          dailyGoal: resolvedSettings.dailyGoal,
        ),
      ]);
    }

    _persistChain = (_persistChain ?? Future.value()).then((_) => persist());
    await _persistChain;
  }

  void _playFeedback({
    required JapSettings settings,
    required bool malaCompleted,
  }) {
    _hapticService.japTap(enabled: settings.hapticEnabled);
    _soundService.playJapTap(enabled: settings.soundEnabled);

    if (malaCompleted) {
      _hapticService.malaComplete(enabled: settings.hapticEnabled);
      _soundService.playMalaComplete(enabled: settings.soundEnabled);
    }
  }

  JapStatistics _incrementStatistics(JapStatistics statistics) {
    final today = DateHelper.today();
    var todayCount = statistics.todayCount;
    var currentStreak = statistics.currentStreak;

    if (!DateHelper.isSameDay(statistics.todayDate, today)) {
      todayCount = 0;
    }

    todayCount += 1;

    final lastActive = _statisticsRepository.loadLastActiveDate(_deityId);
    if (lastActive == null) {
      currentStreak = 1;
    } else if (DateHelper.isSameDay(lastActive, today)) {
      currentStreak = statistics.currentStreak == 0
          ? 1
          : statistics.currentStreak;
    } else if (DateHelper.isYesterday(lastActive, today)) {
      currentStreak = statistics.currentStreak + 1;
    } else {
      currentStreak = 1;
    }

    final longestStreak = currentStreak > statistics.longestStreak
        ? currentStreak
        : statistics.longestStreak;
    final lifetimeCount = statistics.lifetimeCount + 1;

    return statistics.copyWith(
      todayCount: todayCount,
      lifetimeCount: lifetimeCount < todayCount ? todayCount : lifetimeCount,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      todayDate: today,
    );
  }
}

class JapSessionState {
  const JapSessionState({
    required this.session,
    required this.statistics,
    required this.settings,
    required this.japTrigger,
    required this.malaCompleted,
  });

  final JapSession session;
  final JapStatistics statistics;
  final JapSettings settings;
  final int japTrigger;
  final bool malaCompleted;
}
