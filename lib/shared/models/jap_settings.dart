import 'package:flutter/material.dart';

import '../../core/constants/jap_constants.dart';
import '../../shared/enums/count_method.dart';
import '../../theme/app_colors.dart';

class JapSettings {
  const JapSettings({
    required this.soundEnabled,
    required this.hapticEnabled,
    required this.enclosureEnabled,
    required this.floatingTextEnabled,
    required this.textSize,
    required this.dailyGoal,
    required this.floatingTextColor,
    required this.countMethod,
    required this.showMalaRing,
    required this.divineWallpaperEnabled,
  });

  final bool soundEnabled;
  final bool hapticEnabled;
  final bool enclosureEnabled;
  final bool floatingTextEnabled;
  final double textSize;
  final int dailyGoal;
  final Color floatingTextColor;
  final CountMethod countMethod;
  final bool showMalaRing;
  final bool divineWallpaperEnabled;

  static JapSettings defaults() {
    return const JapSettings(
      soundEnabled: true,
      hapticEnabled: true,
      enclosureEnabled: true,
      floatingTextEnabled: true,
      textSize: JapConstants.defaultTextSize,
      dailyGoal: JapConstants.defaultDailyGoal,
      floatingTextColor: AppColors.primaryGold,
      countMethod: CountMethod.tap,
      showMalaRing: false,
      divineWallpaperEnabled: false,
    );
  }

  JapSettings copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? enclosureEnabled,
    bool? floatingTextEnabled,
    double? textSize,
    int? dailyGoal,
    Color? floatingTextColor,
    CountMethod? countMethod,
    bool? showMalaRing,
    bool? divineWallpaperEnabled,
  }) {
    return JapSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      enclosureEnabled: enclosureEnabled ?? this.enclosureEnabled,
      floatingTextEnabled: floatingTextEnabled ?? this.floatingTextEnabled,
      textSize: textSize ?? this.textSize,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      floatingTextColor: floatingTextColor ?? this.floatingTextColor,
      countMethod: countMethod ?? this.countMethod,
      showMalaRing: showMalaRing ?? this.showMalaRing,
      divineWallpaperEnabled:
          divineWallpaperEnabled ?? this.divineWallpaperEnabled,
    );
  }
}
