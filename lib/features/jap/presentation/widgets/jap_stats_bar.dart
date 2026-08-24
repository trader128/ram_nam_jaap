import 'package:flutter/material.dart';

import '../../../../constants/app_strings.dart';
import '../../../../core/helpers/number_formatter.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

class JapStatsBar extends StatelessWidget {
  const JapStatsBar({
    required this.sessionCount,
    required this.todayCount,
    required this.lifetimeCount,
    super.key,
  });

  final int sessionCount;
  final int todayCount;
  final int lifetimeCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatColumn(
              label: AppStrings.session,
              value: NumberFormatter.formatCount(sessionCount),
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatColumn(
              label: AppStrings.today,
              value: NumberFormatter.formatCount(todayCount),
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatColumn(
              label: AppStrings.malas,
              value: NumberFormatter.formatMalas(sessionCount),
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatColumn(
              label: AppStrings.totalJaps,
              value: NumberFormatter.formatCount(lifetimeCount),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.titleLarge.copyWith(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: AppTextStyles.labelSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      color: AppColors.divider.withValues(alpha: 0.5),
    );
  }
}
