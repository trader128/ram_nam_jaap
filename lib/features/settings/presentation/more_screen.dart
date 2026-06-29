import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.more, style: AppTextStyles.headlineLarge),
              const SizedBox(height: AppSpacing.xxs),
              Text(AppStrings.moreSubtitle, style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.xxxl),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: AppColors.divider.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  AppStrings.comingSoon,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
