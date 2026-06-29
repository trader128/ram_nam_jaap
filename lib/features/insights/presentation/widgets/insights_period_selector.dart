import 'package:flutter/material.dart';

import '../../../../shared/enums/insights_period.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_text_styles.dart';

class InsightsPeriodSelector extends StatelessWidget {
  const InsightsPeriodSelector({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final InsightsPeriod selected;
  final ValueChanged<InsightsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: InsightsPeriod.values.map((period) {
        final isSelected = period == selected;
        return ChoiceChip(
          label: Text(period.label),
          selected: isSelected,
          onSelected: (_) => onChanged(period),
          labelStyle: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? AppColors.primaryGold : AppColors.textSecondary,
          ),
          selectedColor: AppColors.primaryGold.withValues(alpha: 0.14),
          backgroundColor: AppColors.surfaceVariant,
          side: BorderSide(
            color: isSelected
                ? AppColors.primaryGold.withValues(alpha: 0.45)
                : AppColors.divider.withValues(alpha: 0.5),
          ),
        );
      }).toList(),
    );
  }
}
