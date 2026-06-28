import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const String _fontFamily = 'Inter';

  static TextStyle get displayLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 72,
    fontWeight: FontWeight.w300,
    height: 1.1,
    letterSpacing: 2,
    color: AppColors.primaryGold,
  );

  static TextStyle get displayMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w300,
    height: 1.15,
    letterSpacing: 1.5,
    color: AppColors.primaryGold,
  );

  static TextStyle get headlineLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w500,
    height: 1.25,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get titleLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelLarge => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => const TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );
}
