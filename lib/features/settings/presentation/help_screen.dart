import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text(AppStrings.helpTitle),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(AppStrings.helpIntro, style: AppTextStyles.bodyMedium),
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
