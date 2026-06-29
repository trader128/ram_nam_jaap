import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_strings.dart';
import '../../../../shared/enums/count_method.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../jap/providers/jap_providers.dart';
import 'settings_section.dart';

class SettingsCountMethodSelector extends ConsumerWidget {
  const SettingsCountMethodSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(japSettingsProvider);
    final notifier = ref.read(japSettingsProvider.notifier);

    return SettingsSection(
      title: AppStrings.japSessionSection,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppStrings.countWith, style: AppTextStyles.bodyLarge),
              const SizedBox(height: AppSpacing.sm),
              SegmentedButton<CountMethod>(
                segments: const [
                  ButtonSegment(
                    value: CountMethod.tap,
                    label: Text(AppStrings.countTap),
                  ),
                  ButtonSegment(
                    value: CountMethod.volume,
                    label: Text(AppStrings.countVolume),
                  ),
                  ButtonSegment(
                    value: CountMethod.both,
                    label: Text(AppStrings.countBoth),
                  ),
                ],
                selected: {settings.countMethod},
                onSelectionChanged: (selection) {
                  notifier.setCountMethod(selection.first);
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        SwitchListTile(
          title: Text(AppStrings.showMalaRing, style: AppTextStyles.bodyLarge),
          value: settings.showMalaRing,
          onChanged: notifier.setShowMalaRing,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
        ),
        const Divider(height: 1),
        SwitchListTile(
          title: Text(
            AppStrings.divineWallpaperMode,
            style: AppTextStyles.bodyLarge,
          ),
          subtitle: Text(
            AppStrings.divineWallpaperHint,
            style: AppTextStyles.bodyMedium,
          ),
          value: settings.divineWallpaperEnabled,
          onChanged: notifier.setDivineWallpaperEnabled,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xxs,
          ),
        ),
      ],
    );
  }
}
