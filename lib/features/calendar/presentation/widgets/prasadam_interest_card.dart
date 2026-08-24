import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/localized_strings_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../providers/calendar_providers.dart';

/// The prasadam "coming soon" box.
///
/// Deliberately a stub: it records interest and nothing more. Tap-through here
/// is the demand signal that should decide whether prasadam fulfilment is worth
/// standing up at all, so it ships long before any logistics do.
class PrasadamInterestCard extends ConsumerStatefulWidget {
  const PrasadamInterestCard({super.key});

  @override
  ConsumerState<PrasadamInterestCard> createState() =>
      _PrasadamInterestCardState();
}

class _PrasadamInterestCardState
    extends ConsumerState<PrasadamInterestCard> {
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
                Icons.card_giftcard_rounded,
                color: AppColors.primaryGold,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(strings.prasadamTitle, style: AppTextStyles.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _noted ? strings.prasadamNoted : strings.prasadamBody,
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
                  await ref.read(prasadamInterestProvider.notifier).record();
                  if (mounted) {
                    setState(() => _noted = true);
                  }
                },
                child: Text(strings.prasadamCta),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
