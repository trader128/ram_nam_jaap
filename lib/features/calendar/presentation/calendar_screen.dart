import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_routes.dart';
import '../../../l10n/localized_strings_provider.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/widgets/motion_entrance.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../deity/providers/deity_providers.dart';
import '../domain/vrat.dart';
import '../providers/calendar_providers.dart';
import 'widgets/kundali_interest_card.dart';
import 'widgets/prasadam_interest_card.dart';
import 'widgets/today_panchang_card.dart';
import 'widgets/vrat_list_tile.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(localizedStringsProvider);
    final accent = ref.watch(deityColorProvider);
    final snapshot = ref.watch(calendarSnapshotProvider);

    void openVrat(Vrat vrat) =>
        context.push('${AppRoutes.calendar}/${vrat.id}');

    return AppScaffold(
      body: SafeArea(
        child: snapshot.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                strings.calendarNoUpcoming,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (calendar) => ScreenEntrance(
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(strings.calendar, style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppSpacing.lg),
                TodayPanchangCard(
                  date: calendar.date,
                  todaysVrats: calendar.todaysVrats,
                  panchang: calendar.todayPanchang,
                  strings: strings,
                  accent: accent,
                  onVratTap: openVrat,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (calendar.hasUpcoming) ...[
                  Text(
                    strings.calendarUpcoming,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final (index, occurrence)
                      in calendar.upcoming.indexed)
                    StaggeredEntrance(
                      index: index,
                      child: VratListTile(
                        vrat: occurrence.vrat,
                        strings: strings,
                        accent: accent,
                        date: occurrence.date,
                        daysAway: occurrence.daysFrom(calendar.date),
                        onTap: () => openVrat(occurrence.vrat),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (calendar.observances.isNotEmpty) ...[
                  Text(
                    strings.calendarObservances,
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    calendar.todayPanchang == null
                        ? strings.calendarObservancesHint
                        : strings.calendarObservancesHintWithPanchang,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final (index, vrat) in calendar.observances.indexed)
                    StaggeredEntrance(
                      index: index,
                      child: VratListTile(
                        vrat: vrat,
                        strings: strings,
                        accent: accent,
                        onTap: () => openVrat(vrat),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                const KundaliInterestCard(),
                const SizedBox(height: AppSpacing.lg),
                const PrasadamInterestCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
