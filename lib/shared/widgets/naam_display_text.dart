import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class NaamDisplayText extends StatelessWidget {
  const NaamDisplayText({
    super.key,
    this.fontSize = 72,
    this.opacity = 1,
    this.enclosureEnabled = true,
    this.color,
  });

  final double fontSize;
  final double opacity;
  final bool enclosureEnabled;
  final Color? color;

  String get _displayText {
    if (enclosureEnabled) {
      return '${AppStrings.naamEnclosureStart} '
          '${AppStrings.divineName} '
          '${AppStrings.naamEnclosureEnd}';
    }
    return AppStrings.divineName;
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      textAlign: TextAlign.center,
      style: AppTextStyles.displayLarge.copyWith(
        fontSize: fontSize,
        color: (color ?? AppColors.primaryGold).withValues(alpha: opacity),
      ),
    );
  }
}
