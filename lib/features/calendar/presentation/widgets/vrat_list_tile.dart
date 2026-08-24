import 'package:flutter/material.dart';

import '../../../../l10n/localized_strings.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/calendar_engine.dart';
import '../../domain/vrat.dart';

class VratListTile extends StatelessWidget {
  const VratListTile({
    required this.vrat,
    required this.strings,
    required this.accent,
    required this.onTap,
    this.date,
    this.daysAway,
    super.key,
  });

  final Vrat vrat;
  final LocalizedStrings strings;
  final Color accent;
  final VoidCallback onTap;

  /// Omitted for recurring vrats with no supplied date.
  final DateTime? date;
  final int? daysAway;

  @override
  Widget build(BuildContext context) {
    final hindi = strings.isHindi;
    final summary = vrat.summary(hindi: hindi);
    final when = date;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                if (when != null)
                  _DateBadge(date: when, accent: accent, hindi: hindi)
                else
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      color: AppColors.background.withValues(alpha: 0.5),
                    ),
                    child: Icon(
                      Icons.brightness_2_outlined,
                      color: accent,
                      size: 20,
                    ),
                  ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vrat.name(hindi: hindi),
                        style: AppTextStyles.bodyLarge,
                      ),
                      if (summary != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          summary,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (daysAway != null)
                  Text(
                    strings.daysAway(daysAway!),
                    style: AppTextStyles.labelSmall.copyWith(color: accent),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  const _DateBadge({
    required this.date,
    required this.accent,
    required this.hindi,
  });

  final DateTime date;
  final Color accent;
  final bool hindi;

  @override
  Widget build(BuildContext context) {
    final months = hindi
        ? HinduCalendarNames.monthsHi
        : HinduCalendarNames.monthsEn;

    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.md),
        color: accent.withValues(alpha: 0.14),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: AppTextStyles.titleLarge.copyWith(color: accent),
          ),
          Text(
            months[date.month - 1].substring(0, 3),
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
