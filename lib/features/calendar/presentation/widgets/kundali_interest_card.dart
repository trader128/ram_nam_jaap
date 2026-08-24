import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/localized_strings_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../providers/calendar_providers.dart';

/// Demand signal for a future kundali draw.
///
/// Birth data and Navamsha kundali calls stay out of this stub. Billing and a
/// trusted backend have to exist before either is collected or charged for.
class KundaliInterestCard extends ConsumerStatefulWidget {
  const KundaliInterestCard({super.key});

  @override
  ConsumerState<KundaliInterestCard> createState() =>
      _KundaliInterestCardState();
}

class _KundaliInterestCardState extends ConsumerState<KundaliInterestCard> {
  bool _noted = false;

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(localizedStringsProvider);

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
            _noted ? strings.kundaliNoted : strings.kundaliBody,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (!_noted) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonal(
                onPressed: () async {
                  await ref.read(kundaliInterestProvider.notifier).record();
                  if (mounted) {
                    setState(() => _noted = true);
                  }
                },
                child: Text(strings.kundaliCta),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
