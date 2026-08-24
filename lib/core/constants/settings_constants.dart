import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

abstract final class SettingsConstants {
  static const double minTextSize = 48;
  static const double maxTextSize = 96;
  static const int minDailyGoal = 1;
  static const int maxDailyGoal = 10000000;

  static const List<int> dailyGoalPresets = [108, 1008, 10000];

  static const List<Color> floatingColorPresets = [
    AppColors.primaryGold,
    Color(0xFF4DA3FF),
    Color(0xFF9B6DFF),
    Color(0xFF4FD1C5),
    Color(0xFF2ECC71),
    Color(0xFFE05252),
    Color(0xFFE05AA0),
    Color(0xFFFF6B35),
    Color(0xFFFFD166),
    Color(0xFFA67C52),
    Color(0xFFFFFFFF),
    Color(0xFFE07A1F),
  ];
}
