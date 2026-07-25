import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_routes.dart';
import '../../../constants/app_strings.dart';
import '../../../l10n/localized_strings_provider.dart';
import '../../../core/constants/settings_constants.dart';
import '../../../features/deity/providers/deity_providers.dart';
import '../../../features/jap/providers/jap_providers.dart';
import '../../../l10n/localized_strings_provider.dart';
import '../../../shared/enums/app_language.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import 'widgets/settings_count_method_selector.dart';
import 'widgets/settings_nav_tile.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_toggle_tile.dart';
import 'widgets/settings_value_tiles.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(japSettingsProvider);
    final notifier = ref.read(japSettingsProvider.notifier);
    final deity = ref.watch(selectedDeityProvider);

    return AppScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(AppStrings.settingsTitle, style: AppTextStyles.headlineLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(AppStrings.moreSubtitle, style: AppTextStyles.bodyMedium),
            const SizedBox(height: AppSpacing.lg),
            SettingsSection(
              title: AppStrings.deitySection,
              children: [
                SettingsNavTile(
                  title: AppStrings.currentNaam,
                  trailingLabel: deity.transliteration,
                  trailingColor: deity.primary,
                  onTap: () => context.push(AppRoutes.deitySelection),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            const SettingsCountMethodSelector(),
            const SizedBox(height: AppSpacing.lg),
            SettingsSection(
              title: AppStrings.feedbackSection,
              children: [
                SettingsToggleTile(
                  title: AppStrings.hapticsAndVibrations,
                  value: settings.hapticEnabled,
                  onChanged: notifier.setHapticEnabled,
                ),
                const Divider(height: 1),
                SettingsToggleTile(
                  title: AppStrings.soundEffects,
                  value: settings.soundEnabled,
                  onChanged: notifier.setSoundEnabled,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SettingsSection(
              title: AppStrings.goalsSection,
              children: [
                SettingsGoalTile(
                  value: settings.dailyGoal,
                  presets: SettingsConstants.dailyGoalPresets,
                  onSave: (goal) async {
                    await notifier.setDailyGoal(goal);
                    ref.read(japHistoryProvider.notifier).refresh();
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SettingsSection(
              title: AppStrings.displaySection,
              children: [
                SettingsSliderTile(
                  title: AppStrings.naamTextSize,
                  value: settings.textSize,
                  min: SettingsConstants.minTextSize,
                  max: SettingsConstants.maxTextSize,
                  divisions:
                      (SettingsConstants.maxTextSize -
                              SettingsConstants.minTextSize)
                          .round(),
                  onChanged: (value) => notifier.setTextSize(value),
                ),
                const Divider(height: 1),
                SettingsToggleTile(
                  title: AppStrings.showFloatingNaam,
                  value: settings.floatingTextEnabled,
                  onChanged: notifier.setFloatingTextEnabled,
                ),
                const Divider(height: 1),
                SettingsNavTile(
                  title: AppStrings.floatingTextColor,
                  trailingColor: settings.floatingTextColor,
                  onTap: () => context.push(AppRoutes.floatingTextColor),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SettingsSection(
              title: ref.watch(localizedStringsProvider).languageSection,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Text(
                    ref.watch(localizedStringsProvider).languageHint,
                    style: AppTextStyles.labelSmall,
                  ),
                ),
                SegmentedButton<AppLanguage>(
                  segments: AppLanguage.values
                      .map(
                        (language) => ButtonSegment(
                          value: language,
                          label: Text(language.label),
                        ),
                      )
                      .toList(),
                  selected: {settings.language},
                  onSelectionChanged: (selection) {
                    notifier.setLanguage(selection.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            SettingsSection(
              title: AppStrings.supportSection,
              children: [
                SettingsNavTile(
                  title: AppStrings.helpAndPrivacy,
                  onTap: () => context.push(AppRoutes.help),
                ),
                const Divider(height: 1),
                SettingsNavTile(
                  title: ref.watch(localizedStringsProvider).aboutTitle,
                  onTap: () => context.push(AppRoutes.about),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
