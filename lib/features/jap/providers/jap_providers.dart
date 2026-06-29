import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/haptic_service.dart';
import '../../../core/services/sound_service.dart';
import '../../../shared/models/jap_session.dart';
import '../../../shared/models/jap_settings.dart';
import '../../../shared/models/jap_statistics.dart';
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

  Future<void> registerJap(JapStatisticsNotifier statisticsNotifier) async {
    final result = await _controller.registerJap();
    state = JapSessionStateBundle(
      session: result.session,
      japTrigger: result.japTrigger,
    );
    statisticsNotifier.state = result.statistics;
  }

  Future<void> endSession() async {
    await _controller.endSession();
    state = JapSessionStateBundle.empty;
  }
}
