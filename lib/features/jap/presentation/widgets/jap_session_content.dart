import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_strings.dart';
import '../../../../core/services/motion_jap_service.dart';
import '../../../../core/services/volume_jap_service.dart';
import '../../../../shared/enums/count_method.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../deity/providers/deity_providers.dart';
import '../../providers/jap_providers.dart';
import '../../providers/jap_session_ui_provider.dart';
import 'jap_minimal_counter.dart';
import 'jap_mode_toolbar.dart';
import 'jap_naam_display.dart';
import 'jap_stats_bar.dart';
import 'mala_ring.dart';

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
    final isFocus = ref.watch(
      japSessionUiProvider.select((state) => state.focusMode),
    );
    final allowsTap = ref.watch(
      japSettingsProvider.select(
        (settings) => settings.countMethod != CountMethod.volume,
      ),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: allowsTap ? onJap : null,
            child: Column(
              children: [
                SizedBox(height: isFocus ? AppSpacing.xl : AppSpacing.xxxl),
                const Expanded(child: _JapNaamCenter()),
                if (!isFocus)
                  const _JapBottomPanel()
                else
                  const _JapFocusCounter(),
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
        const Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.md,
          child: _JapModeToolbarHost(),
        ),
      ],
    );
  }
}

class _JapNaamCenter extends ConsumerWidget {
  const _JapNaamCenter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final japTrigger = ref.watch(
      japSessionProvider.select((bundle) => bundle.japTrigger),
    );
    final showMalaRing = ref.watch(
      japSessionUiProvider.select((state) => state.malaRingVisible),
    );
    final sessionCount = ref.watch(
      japSessionProvider.select((bundle) => bundle.session.count),
    );
    final deity = ref.watch(selectedDeityProvider);
    final settings = ref.watch(japSettingsProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showMalaRing) ...[
            RepaintBoundary(
              child: MalaRing(sessionCount: sessionCount, color: deity.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          RepaintBoundary(
            child: JapNaamDisplay(
              japTrigger: japTrigger,
              name: deity.name,
              textSize: settings.textSize,
              naamColor: settings.floatingTextColor,
              floatingTextEnabled: settings.floatingTextEnabled,
            ),
          ),
        ],
      ),
    );
  }
}

class _JapBottomPanel extends ConsumerWidget {
  const _JapBottomPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(japSettingsProvider);
    final sessionCount = ref.watch(
      japSessionProvider.select((bundle) => bundle.session.count),
    );
    final todayCount = ref.watch(
      japStatisticsProvider.select((stats) => stats.todayCount),
    );
    final lifetimeCount = ref.watch(
      japStatisticsProvider.select((stats) => stats.lifetimeCount),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            _hintText(settings.countMethod, settings.backTapEnabled),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              letterSpacing: 0.6,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: JapStatsBar(
            sessionCount: sessionCount,
            todayCount: todayCount,
            lifetimeCount: lifetimeCount,
          ),
        ),
      ],
    );
  }

  String _hintText(CountMethod method, bool backTap) {
    if (backTap && method == CountMethod.volume) {
      return AppStrings.tapBodyOrVolumeToChant;
    }
    if (backTap) {
      return AppStrings.tapBodyToChant;
    }
    return switch (method) {
      CountMethod.tap => AppStrings.tapToChant,
      CountMethod.volume => AppStrings.volumeToChant,
      CountMethod.both => AppStrings.tapOrVolumeToChant,
    };
  }
}

class _JapFocusCounter extends ConsumerWidget {
  const _JapFocusCounter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionCount = ref.watch(
      japSessionProvider.select((bundle) => bundle.session.count),
    );

    return JapMinimalCounter(sessionCount: sessionCount);
  }
}

class _JapModeToolbarHost extends ConsumerWidget {
  const _JapModeToolbarHost();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = ref.watch(japSessionUiProvider);
    final color = ref.watch(deityColorProvider);

    return JapModeToolbar(
      focusMode: ui.focusMode,
      wallpaperMode: ui.wallpaperMode,
      malaRingVisible: ui.malaRingVisible,
      activeColor: color,
      onFocusChanged: (value) =>
          ref.read(japSessionUiProvider.notifier).setFocusMode(value),
      onWallpaperChanged: (value) =>
          ref.read(japSessionUiProvider.notifier).setWallpaperMode(value),
      onMalaRingChanged: (value) =>
          ref.read(japSessionUiProvider.notifier).setMalaRingVisible(value),
    );
  }
}

/// Shared session lifecycle: wires tap, volume-button, and back-tap (motion)
/// counting and tears them down cleanly.
mixin JapSessionLifecycle<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  VolumeJapService get volumeService;
  MotionJapService get motionService;

  Future<void> initializeJapSession(WidgetRef ref) async {
    final settings = ref.read(japSettingsProvider);
    ref.read(japSessionUiProvider.notifier).initializeFromSettings(settings);
    await ref.read(japSessionProvider.notifier).beginSession();
    await syncInputListeners(ref);
  }

  Future<void> syncInputListeners(WidgetRef ref) async {
    final settings = ref.read(japSettingsProvider);
    await volumeService.start(
      countMethod: settings.countMethod,
      onVolumeJap: () => registerJap(ref),
    );
    await motionService.start(
      enabled: settings.backTapEnabled,
      onTap: () => registerJap(ref),
    );
  }

  Future<void> disposeJapSession(WidgetRef ref) async {
    await volumeService.stop();
    await motionService.stop();
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
