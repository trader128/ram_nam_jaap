import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/helpers/insights_calculator.dart';
import '../../../core/services/haptic_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../shared/enums/insights_period.dart';
import '../../../shared/models/daily_jap_record.dart';
import '../../../shared/models/insights_snapshot.dart';
import '../../../shared/models/jap_session.dart';
import '../../../shared/models/jap_settings.dart';
import '../../../shared/models/jap_statistics.dart';
import '../data/jap_history_repository.dart';
import '../data/jap_session_repository.dart';
import '../data/jap_settings_repository.dart';
import '../data/jap_statistics_repository.dart';
import '../domain/jap_controller.dart';

final japStatisticsRepositoryProvider = Provider<JapStatisticsRepository>(
  (ref) => JapStatisticsRepository(),
);

final japSessionRepositoryProvider = Provider<JapSessionRepository>(
  (ref) => JapSessionRepository(),
);

final japSettingsRepositoryProvider = Provider<JapSettingsRepository>(
  (ref) => JapSettingsRepository(),
);

final japHistoryRepositoryProvider = Provider<JapHistoryRepository>(
  (ref) => JapHistoryRepository(),
);

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(service.dispose);
  return service;
});

final hapticServiceProvider = Provider<HapticService>((ref) => HapticService());

final japControllerProvider = Provider<JapController>((ref) {
  return JapController(
    statisticsRepository: ref.watch(japStatisticsRepositoryProvider),
    sessionRepository: ref.watch(japSessionRepositoryProvider),
    settingsRepository: ref.watch(japSettingsRepositoryProvider),
    historyRepository: ref.watch(japHistoryRepositoryProvider),
    soundService: ref.watch(soundServiceProvider),
    hapticService: ref.watch(hapticServiceProvider),
  );
});

final japStatisticsProvider =
    StateNotifierProvider<JapStatisticsNotifier, JapStatistics>((ref) {
      return JapStatisticsNotifier(ref.watch(japControllerProvider));
    });

final japSettingsProvider =
    StateNotifierProvider<JapSettingsNotifier, JapSettings>((ref) {
      return JapSettingsNotifier(ref.watch(japControllerProvider));
    });

final japSessionProvider =
    StateNotifierProvider<JapSessionNotifier, JapSessionStateBundle>((ref) {
      return JapSessionNotifier(ref.watch(japControllerProvider));
    });

final japHistoryProvider =
    StateNotifierProvider<JapHistoryNotifier, List<DailyJapRecord>>((ref) {
      return JapHistoryNotifier(
        ref.watch(japHistoryRepositoryProvider),
        ref.watch(japSettingsRepositoryProvider),
      );
    });

final insightsPeriodProvider = StateProvider<InsightsPeriod>(
  (ref) => InsightsPeriod.thirtyDays,
);

final insightsProvider = Provider<InsightsSnapshot>((ref) {
  final period = ref.watch(insightsPeriodProvider);
  final records = ref.watch(japHistoryProvider);
  final dailyGoal = ref.watch(japSettingsProvider).dailyGoal;

  return InsightsCalculator.calculate(
    records: records,
    period: period,
    dailyGoal: dailyGoal,
  );
});

class JapStatisticsNotifier extends StateNotifier<JapStatistics> {
  JapStatisticsNotifier(this._controller) : super(_controller.loadStatistics());

  final JapController _controller;

  void refresh() {
    state = _controller.loadStatistics();
  }
}

class JapSettingsNotifier extends StateNotifier<JapSettings> {
  JapSettingsNotifier(JapController controller)
    : super(controller.loadSettings());
}

class JapSessionStateBundle {
  const JapSessionStateBundle({
    required this.session,
    required this.japTrigger,
  });

  final JapSession session;
  final int japTrigger;

  static const empty = JapSessionStateBundle(
    session: JapSession.empty,
    japTrigger: 0,
  );
}

class JapSessionNotifier extends StateNotifier<JapSessionStateBundle> {
  JapSessionNotifier(this._controller) : super(JapSessionStateBundle.empty) {
    _restore();
  }

  final JapController _controller;

  Future<void> _restore() async {
    final session = _controller.loadSession();
    state = JapSessionStateBundle(session: session, japTrigger: session.count);
  }

  Future<void> beginSession() async {
    final session = await _controller.startSession();
    state = JapSessionStateBundle(session: session, japTrigger: session.count);
  }

  Future<void> registerJap(
    JapStatisticsNotifier statisticsNotifier,
    JapHistoryNotifier historyNotifier,
  ) async {
    final result = await _controller.registerJap();
    state = JapSessionStateBundle(
      session: result.session,
      japTrigger: result.japTrigger,
    );
    statisticsNotifier.state = result.statistics;
    historyNotifier.refresh();
  }

  Future<void> endSession() async {
    await _controller.endSession();
    state = JapSessionStateBundle.empty;
  }
}

class JapHistoryNotifier extends StateNotifier<List<DailyJapRecord>> {
  JapHistoryNotifier(this._repository, this._settingsRepository)
    : super(const []) {
    refresh();
  }

  final JapHistoryRepository _repository;
  final JapSettingsRepository _settingsRepository;

  void refresh() {
    final dailyGoal = _settingsRepository.load().dailyGoal;
    state = _repository.loadRecords(dailyGoal: dailyGoal);
  }
}
