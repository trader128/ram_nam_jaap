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

class JapController {
  JapController({
    required JapStatisticsRepository statisticsRepository,
    required JapSessionRepository sessionRepository,
    required JapSettingsRepository settingsRepository,
    required JapHistoryRepository historyRepository,
    required SoundService soundService,
    required HapticService hapticService,
  }) : _statisticsRepository = statisticsRepository,
       _sessionRepository = sessionRepository,
       _settingsRepository = settingsRepository,
       _historyRepository = historyRepository,
       _soundService = soundService,
       _hapticService = hapticService;

  final JapStatisticsRepository _statisticsRepository;
  final JapSessionRepository _sessionRepository;
  final JapSettingsRepository _settingsRepository;
  final JapHistoryRepository _historyRepository;
  final SoundService _soundService;
  final HapticService _hapticService;

  JapStatistics loadStatistics() => _statisticsRepository.load();

  JapSession loadSession() => _sessionRepository.load();

  JapSettings loadSettings() => _settingsRepository.load();

  Future<JapSession> startSession() async {
    final existing = _sessionRepository.load();
    if (existing.isActive) {
      return existing;
    }

    final session = JapSession(
      count: 0,
      isActive: true,
      startedAt: DateTime.now(),
    );
    await _sessionRepository.save(session);
    return session;
  }

  Future<JapSessionState> registerJap() async {
    final settings = _settingsRepository.load();
    var session = _sessionRepository.load();
    if (!session.isActive) {
      session = await startSession();
    }

    final updatedSession = session.copyWith(count: session.count + 1);
    await _sessionRepository.save(updatedSession);

    final updatedStatistics = _incrementStatistics(
      _statisticsRepository.load(),
    );
    await _statisticsRepository.save(updatedStatistics);
    await _statisticsRepository.saveLastActiveDate(DateHelper.today());
    await _historyRepository.saveDailyCount(
      date: updatedStatistics.todayDate,
      count: updatedStatistics.todayCount,
      dailyGoal: settings.dailyGoal,
    );

    final isMalaComplete =
        updatedSession.count % JapConstants.beadsPerMala == 0;

    await _hapticService.japTap(enabled: settings.hapticEnabled);
    await _soundService.playJapTap(enabled: settings.soundEnabled);

    if (isMalaComplete) {
      await _hapticService.malaComplete(enabled: settings.hapticEnabled);
      await _soundService.playMalaComplete(enabled: settings.soundEnabled);
    }

    return JapSessionState(
      session: updatedSession,
      statistics: updatedStatistics,
      settings: settings,
      japTrigger: updatedSession.count,
      malaCompleted: isMalaComplete,
    );
  }

  Future<void> endSession() async {
    await _sessionRepository.clear();
  }

  JapStatistics _incrementStatistics(JapStatistics statistics) {
    final today = DateHelper.today();
    var todayCount = statistics.todayCount;
    var currentStreak = statistics.currentStreak;

    if (!DateHelper.isSameDay(statistics.todayDate, today)) {
      todayCount = 0;
    }

    todayCount += 1;

    final lastActive = _statisticsRepository.loadLastActiveDate();
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

    return statistics.copyWith(
      todayCount: todayCount,
      lifetimeCount: statistics.lifetimeCount + 1,
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
