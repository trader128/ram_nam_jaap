import 'package:flutter/material.dart';

import '../../../../constants/app_strings.dart';
import '../../../../core/helpers/number_formatter.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

class InsightsSummaryRow extends StatelessWidget {
  const InsightsSummaryRow({
    required this.total,
    required this.activeDays,
    required this.periodDays,
    required this.averagePerDay,
    super.key,
  });

  final int total;
  final int activeDays;
  final int periodDays;
  final double averagePerDay;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: AppStrings.total,
            value: NumberFormatter.formatCount(total),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(
            label: AppStrings.activeDays,
            value: '$activeDays/$periodDays',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(
            label: AppStrings.avgPerDay,
            value: NumberFormatter.formatCount(averagePerDay.round()),
          ),
        ),
      ],
    );
  }
}

class StreakCardsRow extends StatelessWidget {
  const StreakCardsRow({
    required this.goalStreak,
    required this.longestGoalStreak,
    required this.dailyGoal,
    super.key,
  });

  final int goalStreak;
  final int longestGoalStreak;
  final int dailyGoal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StreakCard(
            title: AppStrings.goalStreak,
            value: goalStreak.toString(),
            subtitle:
                '${AppStrings.goalLabel}: ${NumberFormatter.formatCount(dailyGoal)}',
            icon: Icons.local_fire_department_outlined,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StreakCard(
            title: AppStrings.longestStreak,
            value: longestGoalStreak.toString(),
            subtitle: AppStrings.bestSoFar,
            icon: Icons.auto_graph_rounded,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.xxs),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGold, size: 20),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTextStyles.displayMedium.copyWith(fontSize: 32),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(title, style: AppTextStyles.labelLarge),
          Text(subtitle, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
