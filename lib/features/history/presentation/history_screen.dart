import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_strings.dart';
import '../../../features/jap/providers/jap_providers.dart';
import '../../../l10n/localized_strings_provider.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/widgets/animated_empty_state.dart';
import '../../../shared/widgets/motion_entrance.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'widgets/history_list_item.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(japHistoryProvider);
    final l10n = ref.watch(localizedStringsProvider);

    return AppScaffold(
      body: SafeArea(
        child: ScreenEntrance(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.historyTitle, style: AppTextStyles.headlineLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(AppStrings.naamHistory, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: records.isEmpty
                      ? AnimatedEmptyState(
                          icon: Icons.auto_stories_rounded,
                          title: l10n.emptyHistoryTitle,
                          subtitle: l10n.emptyHistorySubtitle,
                        )
                      : ListView.separated(
                          itemCount: records.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            return StaggeredEntrance(
                              index: index,
                              child: HistoryListItem(record: records[index]),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
