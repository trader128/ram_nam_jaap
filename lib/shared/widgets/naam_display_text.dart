import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Renders a single sacred name (no enclosure) in the deity's color.
class NaamDisplayText extends StatelessWidget {
  const NaamDisplayText({
    required this.name,
    super.key,
    this.fontSize = 72,
    this.opacity = 1,
    this.color,
  });

  final String name;
  final double fontSize;
  final double opacity;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      textAlign: TextAlign.center,
      style: AppTextStyles.displayLarge.copyWith(
        fontSize: fontSize,
        color: (color ?? AppColors.primaryGold).withValues(alpha: opacity),
      ),
    );
  }
}
