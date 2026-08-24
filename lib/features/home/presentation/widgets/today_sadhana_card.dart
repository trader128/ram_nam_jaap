import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_routes.dart';
import '../../../../l10n/localized_strings_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../bhajan/providers/bhajan_providers.dart';
import '../../../calendar/domain/calendar_engine.dart';
import '../../../calendar/providers/calendar_providers.dart';
import '../../../deity/providers/deity_providers.dart';

/// Compact "what today asks of you" strip on Home.
///
/// The calendar tab is the full panchang; this is the reason to open the app
/// every morning without leaving the screen you chant from.
class TodaySadhanaCard extends ConsumerWidget {
  const TodaySadhanaCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(calendarSnapshotProvider);
    final strings = ref.watch(localizedStringsProvider);
    final accent = ref.watch(deityColorProvider);

    return snapshot.maybeWhen(
      data: (calendar) {
        final todayVrat = calendar.todaysVrats.firstOrNull?.vrat;
        final bhajans = ref.watch(bhajansForDeityProvider(todayVrat?.deityId));
        final bhajan = bhajans.firstOrNull;
        final hindi = strings.isHindi;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            color: AppColors.surface.withValues(alpha: 0.72),
            border: Border.all(color: accent.withValues(alpha: 0.32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => context.go(AppRoutes.calendar),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: accent,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        '${HinduCalendarNames.weekday(calendar.date, hindi: hindi)}'
                        '  ·  ${HinduCalendarNames.longDate(calendar.date, hindi: hindi)}'
                        '${calendar.todayPanchang?.tithi(hindi: hindi) == null ? '' : '  ·  ${calendar.todayPanchang!.tithi(hindi: hindi)}'}',
                        style: AppTextStyles.labelSmall.copyWith(color: accent),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (todayVrat == null)
                Text(
                  strings.calendarNoVratToday,
                  style: AppTextStyles.bodyMedium,
                )
              else
                _ActionRow(
                  icon: Icons.brightness_low_rounded,
                  label: todayVrat.name(hindi: hindi),
                  hint: todayVrat.summary(hindi: hindi),
                  accent: accent,
                  onTap: () =>
                      context.push('${AppRoutes.calendar}/${todayVrat.id}'),
                ),
              if (bhajan != null) ...[
                const SizedBox(height: AppSpacing.xs),
                _ActionRow(
                  icon: Icons.menu_book_rounded,
                  label: strings.readBhajan(bhajan.title(hindi: hindi)),
                  accent: accent,
                  onTap: () =>
                      context.push('${AppRoutes.bhajans}/${bhajan.id}'),
                ),
              ],
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
    this.hint,
  });

  final IconData icon;
  final String label;
  final String? hint;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
          child: Row(
            children: [
              Icon(icon, size: 18, color: accent),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: AppTextStyles.bodyLarge),
                    if (hint != null)
                      Text(
                        hint!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
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
