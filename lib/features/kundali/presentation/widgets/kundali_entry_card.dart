import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_routes.dart';
import '../../../../l10n/localized_strings_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../calendar/providers/calendar_providers.dart';
import '../../providers/kundali_providers.dart';

class KundaliEntryCard extends ConsumerWidget {
  const KundaliEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(localizedStringsProvider);
    final reading = ref.watch(horoscopeControllerProvider).reading;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: AppColors.surfaceVariant.withValues(alpha: 0.4),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.primaryGold,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(strings.kundaliTitle, style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            reading?.hasLimbs == true
                ? [
                    if (reading!.nakshatra != null) reading.nakshatra,
                    if (reading.chandraRasi != null) reading.chandraRasi,
                  ].whereType<String>().join(' · ')
                : strings.kundaliBody,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonal(
              onPressed: () {
                ref.read(kundaliInterestProvider.notifier).record();
                context.push(AppRoutes.kundali);
              },
              child: Text(
                reading?.hasLimbs == true
                    ? strings.kundaliOpenChart
                    : strings.kundaliCta,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
