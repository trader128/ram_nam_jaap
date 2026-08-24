import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_strings.dart';
import '../../../features/jap/providers/jap_providers.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/widgets/motion_entrance.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'widgets/growth_chart.dart';
import 'widgets/insights_period_selector.dart';
import 'widgets/insights_summary_section.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(insightsPeriodProvider);
    final insights = ref.watch(insightsProvider);

    return AppScaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SafeArea(
        child: ScreenEntrance(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
            Text(AppStrings.insights, style: AppTextStyles.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(AppStrings.trackingPeriod, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            InsightsPeriodSelector(
              selected: period,
              onChanged: (value) =>
                  ref.read(insightsPeriodProvider.notifier).state = value,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(AppStrings.growthTrend, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            GrowthChart(records: insights.dailyPoints),
            const SizedBox(height: AppSpacing.lg),
            InsightsSummaryRow(
              total: insights.total,
              activeDays: insights.activeDays,
              periodDays: insights.dailyPoints.length,
              averagePerDay: insights.averagePerDay,
            ),
            const SizedBox(height: AppSpacing.lg),
            StreakCardsRow(
              goalStreak: insights.goalStreak,
              longestGoalStreak: insights.longestGoalStreak,
              dailyGoal: insights.dailyGoal,
            ),
          ],
          ),
        ),
      ),
    );
  }
}
