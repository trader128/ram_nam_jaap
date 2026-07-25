import 'package:flutter/material.dart';

import '../../core/constants/jap_constants.dart';
import '../../shared/enums/app_language.dart';
import '../../shared/enums/count_method.dart';
import '../../theme/app_colors.dart';

class JapSettings {
  const JapSettings({
    required this.soundEnabled,
    required this.hapticEnabled,
    required this.floatingTextEnabled,
    required this.textSize,
    required this.dailyGoal,
    required this.floatingTextColor,
    required this.countMethod,
    required this.backTapEnabled,
    required this.showMalaRing,
    required this.divineWallpaperEnabled,
    required this.idleMusicEnabled,
    required this.bookModeEnabled,
    required this.language,
  });

  final bool soundEnabled;
  final bool hapticEnabled;
  final bool floatingTextEnabled;
  final double textSize;
  final int dailyGoal;
  final Color floatingTextColor;
  final CountMethod countMethod;
  final bool backTapEnabled;
  final bool showMalaRing;
  final bool divineWallpaperEnabled;
  final bool idleMusicEnabled;
  final bool bookModeEnabled;
  final AppLanguage language;

  static JapSettings defaults() {
    return const JapSettings(
      soundEnabled: true,
      hapticEnabled: true,
      floatingTextEnabled: true,
      textSize: JapConstants.defaultTextSize,
      dailyGoal: JapConstants.defaultDailyGoal,
      floatingTextColor: AppColors.primaryGold,
      countMethod: CountMethod.tap,
      backTapEnabled: false,
      showMalaRing: false,
      divineWallpaperEnabled: true,
      idleMusicEnabled: true,
      bookModeEnabled: false,
      language: AppLanguage.english,
    );
  }

  JapSettings copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? floatingTextEnabled,
    double? textSize,
    int? dailyGoal,
    Color? floatingTextColor,
    CountMethod? countMethod,
    bool? backTapEnabled,
    bool? showMalaRing,
    bool? divineWallpaperEnabled,
    bool? idleMusicEnabled,
    bool? bookModeEnabled,
    AppLanguage? language,
  }) {
    return JapSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      floatingTextEnabled: floatingTextEnabled ?? this.floatingTextEnabled,
      textSize: textSize ?? this.textSize,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      floatingTextColor: floatingTextColor ?? this.floatingTextColor,
      countMethod: countMethod ?? this.countMethod,
      backTapEnabled: backTapEnabled ?? this.backTapEnabled,
      showMalaRing: showMalaRing ?? this.showMalaRing,
      divineWallpaperEnabled:
          divineWallpaperEnabled ?? this.divineWallpaperEnabled,
      idleMusicEnabled: idleMusicEnabled ?? this.idleMusicEnabled,
      bookModeEnabled: bookModeEnabled ?? this.bookModeEnabled,
      language: language ?? this.language,
    );
  }
}
