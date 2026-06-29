import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_strings.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../jap/presentation/widgets/divine_wallpaper_background.dart';
import '../../jap/providers/jap_providers.dart';
import '../domain/deity_catalog.dart';
import '../providers/deity_providers.dart';
import 'widgets/deity_card.dart';

class DeitySelectionScreen extends ConsumerWidget {
  const DeitySelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDeityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DivineWallpaperBackground(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.textSecondary,
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.chooseYourNaam,
                              style: AppTextStyles.headlineLarge,
                            ),
                            Text(
                              AppStrings.chooseNaamSubtitle,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    itemCount: DeityCatalog.all.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final deity = DeityCatalog.all[index];
                      return DeityCard(
                        deity: deity,
                        selected: deity.id == selected.id,
                        onTap: () async {
                          await ref
                              .read(selectedDeityProvider.notifier)
                              .select(deity);
                          await ref
                              .read(japSettingsProvider.notifier)
                              .setFloatingTextColor(deity.primary);
                          ref.read(japStatisticsProvider.notifier).refresh();
                          if (context.mounted) {
                            context.pop();
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
