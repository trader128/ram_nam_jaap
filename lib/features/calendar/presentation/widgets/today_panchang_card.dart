import 'package:flutter/material.dart';

import '../../../../l10n/localized_strings.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/calendar_engine.dart';
import '../../domain/panchang_day.dart';
import '../../domain/vrat.dart';

/// The "what day is it" box that anchors the Calendar screen.
class TodayPanchangCard extends StatelessWidget {
  const TodayPanchangCard({
    required this.date,
    required this.todaysVrats,
    required this.strings,
    required this.accent,
    this.panchang,
    this.onVratTap,
    super.key,
  });

  final DateTime date;
  final List<VratOccurrence> todaysVrats;
  final LocalizedStrings strings;
  final Color accent;
  final PanchangDay? panchang;
  final ValueChanged<Vrat>? onVratTap;

  @override
  Widget build(BuildContext context) {
    final hindi = strings.isHindi;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.16),
            AppColors.surfaceVariant.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HinduCalendarNames.weekday(date, hindi: hindi),
            style: AppTextStyles.headlineMedium.copyWith(color: accent),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            HinduCalendarNames.longDate(date, hindi: hindi),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (panchang != null && panchang!.hasLimbs) ...[
            const SizedBox(height: AppSpacing.sm),
            _PanchangLimbs(day: panchang!, strings: strings, hindi: hindi),
          ],
          const SizedBox(height: AppSpacing.md),
          if (todaysVrats.isEmpty)
            Text(
              strings.calendarNoVratToday,
              style: AppTextStyles.bodyMedium,
            )
          else
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final occurrence in todaysVrats)
                  _TodayVratChip(
                    vrat: occurrence.vrat,
                    hindi: hindi,
                    accent: accent,
                    onTap: onVratTap == null
                        ? null
                        : () => onVratTap!(occurrence.vrat),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _TodayVratChip extends StatelessWidget {
  const _TodayVratChip({
    required this.vrat,
    required this.hindi,
    required this.accent,
    this.onTap,
  });

  final Vrat vrat;
  final bool hindi;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: AppColors.background.withValues(alpha: 0.45),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.brightness_low_rounded, size: 16, color: accent),
              const SizedBox(width: AppSpacing.xs),
              Text(
                vrat.name(hindi: hindi),
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(width: AppSpacing.xs),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanchangLimbs extends StatelessWidget {
  const _PanchangLimbs({
    required this.day,
    required this.strings,
    required this.hindi,
  });

  final PanchangDay day;
  final LocalizedStrings strings;
  final bool hindi;

  @override
  Widget build(BuildContext context) {
    final tithi = day.tithi(hindi: hindi);
    final nakshatra = day.nakshatra(hindi: hindi);
    final rows = <(String, String)>[
      if (tithi != null) (strings.calendarTithi, tithi),
      if (nakshatra != null) (strings.calendarNakshatra, nakshatra),
      if (day.sunrise != null) (strings.calendarSunrise, day.sunrise!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${row.$1}  ',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  TextSpan(text: row.$2, style: AppTextStyles.bodyLarge),
                ],
              ),
            ),
          ),
        Text(
          strings.calendarPanchangPlace(day.placeLabel),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
