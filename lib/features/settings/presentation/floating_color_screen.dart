import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_strings.dart';
import '../../../core/constants/settings_constants.dart';
import '../../../features/jap/providers/jap_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'widgets/color_swatch_grid.dart';

class FloatingColorScreen extends ConsumerWidget {
  const FloatingColorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(japSettingsProvider);
    final notifier = ref.read(japSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.floatingTextColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(AppStrings.preview, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            ColorPreviewCard(
              color: settings.floatingTextColor,
              textSize: settings.textSize,
              enclosureEnabled: settings.enclosureEnabled,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(AppStrings.presetColors, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.md),
            ColorSwatchGrid(
              colors: SettingsConstants.floatingColorPresets,
              selected: settings.floatingTextColor,
              onSelected: notifier.setFloatingTextColor,
            ),
          ],
        ),
      ),
    );
  }
}
