class JapSessionUiState {
  const JapSessionUiState({
    required this.focusMode,
    required this.wallpaperMode,
    required this.malaRingVisible,
    required this.bookMode,
  });

  final bool focusMode;
  final bool wallpaperMode;
  final bool malaRingVisible;
  final bool bookMode;

  JapSessionUiState copyWith({
    bool? focusMode,
    bool? wallpaperMode,
    bool? malaRingVisible,
    bool? bookMode,
  }) {
    return JapSessionUiState(
      focusMode: focusMode ?? this.focusMode,
      wallpaperMode: wallpaperMode ?? this.wallpaperMode,
      malaRingVisible: malaRingVisible ?? this.malaRingVisible,
      bookMode: bookMode ?? this.bookMode,
    );
  }
}
