import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_strings.dart';
import '../../../l10n/localized_strings_provider.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/ui/adaptive_content_frame.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

/// Credits, purpose, and offline privacy — signals a finished product to reviewers.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizedStringsProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(l10n.aboutTitle),
        centerTitle: true,
      ),
      body: AdaptiveContentFrame(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(l10n.aboutPurposeTitle, style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.aboutPurposeBody, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.aboutFeaturesTitle, style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            ...l10n.aboutFeatureBullets.map(
              (bullet) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text('• $bullet', style: AppTextStyles.bodyMedium),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(AppStrings.privacyTitle, style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(AppStrings.privacyBody, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.aboutCreditsTitle, style: AppTextStyles.headlineMedium),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.aboutCreditsBody, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }
}
