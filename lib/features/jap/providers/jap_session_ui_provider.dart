import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/jap_session_ui_state.dart';
import '../../../shared/models/jap_settings.dart';

final japSessionUiProvider =
    StateNotifierProvider.autoDispose<JapSessionUiNotifier, JapSessionUiState>(
      (ref) => JapSessionUiNotifier(),
    );

class JapSessionUiNotifier extends StateNotifier<JapSessionUiState> {
  JapSessionUiNotifier()
    : super(
        const JapSessionUiState(
          focusMode: false,
          wallpaperMode: false,
          malaRingVisible: false,
        ),
      );

  void initializeFromSettings(JapSettings settings) {
    state = JapSessionUiState(
      focusMode: false,
      wallpaperMode: settings.divineWallpaperEnabled,
      malaRingVisible: settings.showMalaRing,
    );
  }

  void setFocusMode(bool value) {
    state = state.copyWith(focusMode: value);
  }

  void setWallpaperMode(bool value) {
    state = state.copyWith(wallpaperMode: value);
  }

  void setMalaRingVisible(bool value) {
    state = state.copyWith(malaRingVisible: value);
  }
}
