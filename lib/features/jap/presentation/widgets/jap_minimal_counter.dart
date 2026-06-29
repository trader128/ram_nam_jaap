import 'package:flutter/material.dart';

import '../../../../constants/app_strings.dart';
import '../../../../core/helpers/number_formatter.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

class JapMinimalCounter extends StatelessWidget {
  const JapMinimalCounter({required this.sessionCount, super.key});

  final int sessionCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.45)),
      ),
      child: Text(
        '${NumberFormatter.formatCount(sessionCount)} • '
        '${NumberFormatter.formatMalas(sessionCount)} ${AppStrings.malas}',
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
