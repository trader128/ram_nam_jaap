import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

class SettingsNavTile extends StatelessWidget {
  const SettingsNavTile({
    required this.title,
    required this.onTap,
    super.key,
    this.subtitle,
    this.trailingColor,
    this.trailingLabel,
  });

  final String title;
  final String? subtitle;
  final Color? trailingColor;
  final String? trailingLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: AppTextStyles.bodyLarge),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: AppTextStyles.bodyMedium),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingLabel != null) ...[
            Text(
              trailingLabel!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: trailingColor ?? AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          if (trailingColor != null) ...[
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: trailingColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xxs,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
    );
  }
}
