import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_strings.dart';
import '../../../../core/services/volume_jap_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../shared/enums/count_method.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../providers/jap_providers.dart';
import '../../providers/jap_session_ui_provider.dart';
import '../widgets/divine_wallpaper_background.dart';
import '../widgets/jap_minimal_counter.dart';
import '../widgets/jap_mode_toolbar.dart';
import '../widgets/jap_naam_display.dart';
import '../widgets/jap_stats_bar.dart';
import '../widgets/mala_ring.dart';

class JapSessionContent extends ConsumerWidget {
  const JapSessionContent({
    required this.onJap,
    required this.onClose,
    super.key,
  });

  final VoidCallback onJap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionBundle = ref.watch(japSessionProvider);
    final statistics = ref.watch(japStatisticsProvider);
    final settings = ref.watch(japSettingsProvider);
    final ui = ref.watch(japSessionUiProvider);

    final isFocus = ui.focusMode;
    final isWallpaper = ui.wallpaperMode;
    final allowsTap = settings.countMethod != CountMethod.volume;
    final showMalaRing = ui.malaRingVisible;

    return Stack(
      children: [
        if (isWallpaper) const DivineWallpaperBackground(),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: allowsTap ? onJap : null,
            child: Column(
              children: [
                SizedBox(height: isFocus ? AppSpacing.xl : AppSpacing.xxxl),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (showMalaRing) ...[
                          MalaRing(sessionCount: sessionBundle.session.count),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                        JapNaamDisplay(
                          japTrigger: sessionBundle.japTrigger,
                          textSize: settings.textSize,
                          enclosureEnabled: settings.enclosureEnabled,
                          naamColor: settings.floatingTextColor,
                          floatingTextEnabled: settings.floatingTextEnabled,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isFocus) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: Text(
                      _hintText(settings.countMethod),
                      style: AppTextStyles.bodyMedium.copyWith(
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    child: JapStatsBar(
                      sessionCount: sessionBundle.session.count,
                      todayCount: statistics.todayCount,
                      lifetimeCount: statistics.lifetimeCount,
                    ),
                  ),
                ] else
                  JapMinimalCounter(sessionCount: sessionBundle.session.count),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
        Positioned(
          top: AppSpacing.sm,
          left: AppSpacing.md,
          child: IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
            color: AppColors.textSecondary,
            tooltip: AppStrings.closeJap,
          ),
        ),
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.md,
          child: JapModeToolbar(
            focusMode: ui.focusMode,
            wallpaperMode: ui.wallpaperMode,
            malaRingVisible: ui.malaRingVisible,
            onFocusChanged: (value) =>
                ref.read(japSessionUiProvider.notifier).setFocusMode(value),
            onWallpaperChanged: (value) =>
                ref.read(japSessionUiProvider.notifier).setWallpaperMode(value),
            onMalaRingChanged: (value) => ref
                .read(japSessionUiProvider.notifier)
                .setMalaRingVisible(value),
          ),
        ),
      ],
    );
  }

  String _hintText(CountMethod method) {
    return switch (method) {
      CountMethod.tap => AppStrings.tapToChant,
      CountMethod.volume => AppStrings.volumeToChant,
      CountMethod.both => AppStrings.tapOrVolumeToChant,
    };
  }
}

mixin JapSessionLifecycle<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  VolumeJapService get volumeService;

  Future<void> initializeJapSession(WidgetRef ref) async {
    final settings = ref.read(japSettingsProvider);
    ref.read(japSessionUiProvider.notifier).initializeFromSettings(settings);
    await ref.read(japSessionProvider.notifier).beginSession();
    await syncVolumeListener(ref);
  }

  Future<void> syncVolumeListener(WidgetRef ref) async {
    final settings = ref.read(japSettingsProvider);
    await volumeService.start(
      countMethod: settings.countMethod,
      onVolumeJap: () => registerJap(ref),
    );
  }

  Future<void> disposeJapSession(WidgetRef ref) async {
    await volumeService.stop();
  }

  Future<void> registerJap(WidgetRef ref) async {
    await ref
        .read(japSessionProvider.notifier)
        .registerJap(
          ref.read(japStatisticsProvider.notifier),
          ref.read(japHistoryProvider.notifier),
        );
  }
}
