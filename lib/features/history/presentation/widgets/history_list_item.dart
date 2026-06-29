import 'package:flutter/material.dart';

import '../../../../constants/app_strings.dart';
import '../../../../core/helpers/display_date_helper.dart';
import '../../../../core/helpers/number_formatter.dart';
import '../../../../shared/models/daily_jap_record.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

class HistoryListItem extends StatelessWidget {
  const HistoryListItem({required this.record, super.key});

  final DailyJapRecord record;

  @override
  Widget build(BuildContext context) {
    final dateLabel = DisplayDateHelper.labelFor(record.date);
    final progressLabel =
        '${NumberFormatter.formatCount(record.count)} • '
        '${(record.goalProgress * 100).toStringAsFixed(0)}% '
        '${AppStrings.ofGoal} ${NumberFormatter.formatCount(record.dailyGoal)}';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  NumberFormatter.formatCount(record.count),
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  '$dateLabel • $progressLabel',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
          if (record.goalMet)
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGold.withValues(alpha: 0.85),
                    AppColors.accent.withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.background,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
