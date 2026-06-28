import 'package:flutter/material.dart';

import '../../constants/app_strings.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class DivineNameText extends StatelessWidget {
  const DivineNameText({super.key, this.fontSize = 72, this.opacity = 1});

  final double fontSize;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Text(
      AppStrings.divineName,
      textAlign: TextAlign.center,
      style: AppTextStyles.displayLarge.copyWith(
        fontSize: fontSize,
        color: AppColors.primaryGold.withValues(alpha: opacity),
      ),
    );
  }
}
