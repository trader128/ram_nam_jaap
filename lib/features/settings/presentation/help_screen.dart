import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_strings.dart';
import '../../../l10n/localized_strings_provider.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizedStringsProvider);

    return AppScaffold(
      appBar: AppBar(
        title: Text(l10n.helpTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.helpIntro, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          Text(AppStrings.helpHowToTitle, style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          ...AppStrings.helpSteps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text('• $step', style: AppTextStyles.bodyMedium),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(AppStrings.privacyTitle, style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(AppStrings.privacyBody, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
