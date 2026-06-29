class JapSessionUiState {
  const JapSessionUiState({
    required this.focusMode,
    required this.wallpaperMode,
    required this.malaRingVisible,
  });

  final bool focusMode;
  final bool wallpaperMode;
  final bool malaRingVisible;

  JapSessionUiState copyWith({
    bool? focusMode,
    bool? wallpaperMode,
    bool? malaRingVisible,
  }) {
    return JapSessionUiState(
      focusMode: focusMode ?? this.focusMode,
      wallpaperMode: wallpaperMode ?? this.wallpaperMode,
      malaRingVisible: malaRingVisible ?? this.malaRingVisible,
    );
  }
}
