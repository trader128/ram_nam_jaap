import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

/// First launch welcome — explains core flow for App Review clarity.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(AppStrings.appName, style: AppTextStyles.headlineLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppStrings.tagline,
                style: AppTextStyles.bodyLarge,
              ),
              const SizedBox(height: AppSpacing.xl),
              _step('1', AppStrings.welcomeStep1),
              const SizedBox(height: AppSpacing.md),
              _step('2', AppStrings.welcomeStep2),
              const SizedBox(height: AppSpacing.md),
              _step('3', AppStrings.welcomeStep3),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onContinue,
                  child: const Text(AppStrings.welcomeContinue),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _step(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 14,
          child: Text(number, style: const TextStyle(fontSize: 12)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(text, style: AppTextStyles.bodyMedium),
        ),
      ],
    );
  }
}
