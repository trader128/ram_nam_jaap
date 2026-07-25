import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/hive_keys.dart';
import '../../../../core/storage/hive_storage.dart';
import '../../../../l10n/localized_strings_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

/// One-time in-session coach so reviewers immediately understand tap-to-count.
class JapSessionCoachOverlay extends ConsumerWidget {
  const JapSessionCoachOverlay({required this.onDismiss, super.key});

  final VoidCallback onDismiss;

  static bool shouldShow() {
    return !(HiveStorage.settingsBox.get(
          HiveKeys.japCoachCompleted,
          defaultValue: false,
        )
        as bool);
  }

  static Future<void> markCompleted() async {
    await HiveStorage.settingsBox.put(HiveKeys.japCoachCompleted, true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizedStringsProvider);

    return Material(
      color: Colors.black.withValues(alpha: 0.72),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              Icon(Icons.touch_app_rounded, size: 56, color: AppColors.primaryGold),
              const SizedBox(height: AppSpacing.lg),
              Text(
                l10n.coachTapTitle,
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.coachTapBody,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onDismiss,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Text(l10n.coachGotIt),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
