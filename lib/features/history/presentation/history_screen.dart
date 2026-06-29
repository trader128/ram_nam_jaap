import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_strings.dart';
import '../../../features/jap/providers/jap_providers.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'widgets/history_list_item.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(japHistoryProvider);

    return AppScaffold(
      body: SafeArea(
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
                    ? Center(
                        child: Text(
                          AppStrings.noHistoryYet,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: records.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          return HistoryListItem(record: records[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
