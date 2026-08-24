import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../core/helpers/number_formatter.dart';
import '../../../theme/app_durations.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class DailyGoalProgress extends StatelessWidget {
  const DailyGoalProgress({
    required this.todayCount,
    required this.dailyGoal,
    super.key,
    this.color,
  });

  final int todayCount;
  final int dailyGoal;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final progress = dailyGoal <= 0
        ? 0.0
        : (todayCount / dailyGoal).clamp(0.0, 1.0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: TweenAnimationBuilder<double>(
            duration: AppDurations.normal,
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: progress),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: 5,
                backgroundColor: AppColors.surfaceVariant,
                color: (color ?? AppColors.primaryGold).withValues(alpha: 0.9),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${NumberFormatter.formatCount(todayCount)} ${AppStrings.ofGoal} '
          '${NumberFormatter.formatCount(dailyGoal)}',
          style: AppTextStyles.labelSmall,
        ),
      ],
    );
  }
}
