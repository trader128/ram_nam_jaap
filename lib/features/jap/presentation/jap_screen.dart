import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/motion_jap_service.dart';
import '../../../../core/services/volume_jap_service.dart';
import '../../../../l10n/localized_strings_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../deity/providers/deity_providers.dart';
import '../providers/jap_providers.dart';
import '../providers/jap_session_ui_provider.dart';
import 'widgets/deity_image_background.dart';
import 'widgets/jap_session_content.dart';
import 'widgets/jap_session_coach_overlay.dart';
import 'widgets/mala_complete_overlay.dart';

class JapScreen extends ConsumerStatefulWidget {
  const JapScreen({super.key});

  @override
  ConsumerState<JapScreen> createState() => _JapScreenState();
}

class _JapScreenState extends ConsumerState<JapScreen>
    with JapSessionLifecycle {
  late final VolumeJapService _volumeService;
  late final MotionJapService _motionService;
  var _showCoach = JapSessionCoachOverlay.shouldShow();

  void _dismissCoach() {
    setState(() => _showCoach = false);
    unawaited(JapSessionCoachOverlay.markCompleted());
  }

  @override
  VolumeJapService get volumeService => _volumeService;

  @override
  MotionJapService get motionService => _motionService;

  @override
  void initState() {
    super.initState();
    _volumeService = ref.read(volumeJapServiceProvider);
    _motionService = ref.read(motionJapServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeJapSession(ref);
    });
  }

  @override
  void dispose() {
    _volumeService.stop();
    _motionService.stop();
    super.dispose();
  }

  Future<void> _closeSession() async {
    await disposeJapSession(ref);
    await ref.read(japSessionProvider.notifier).endSession();
    ref.read(japStatisticsProvider.notifier).refresh();
    ref.read(japHistoryProvider.notifier).refresh();
    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(japSettingsProvider, (previous, next) {
      if (previous?.countMethod != next.countMethod ||
          previous?.backTapEnabled != next.backTapEnabled) {
        syncInputListeners(ref);
      }
    });

    final wallpaperMode = ref.watch(
      japSessionUiProvider.select((state) => state.wallpaperMode),
    );
    final malaPulse = ref.watch(
      japSessionProvider.select((bundle) => bundle.malaPulse),
    );
    final l10n = ref.watch(localizedStringsProvider);
    final deityColor = ref.watch(deityColorProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _closeSession();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: wallpaperMode
              ? Colors.transparent
              : AppColors.background,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: wallpaperMode
              ? Colors.transparent
              : AppColors.background,
          body: Stack(
            fit: StackFit.expand,
            children: [
              if (wallpaperMode) const DeityImageBackground(),
              SafeArea(
                top: true,
                bottom: !wallpaperMode,
                child: JapSessionContent(
                  onJap: () => registerJap(ref),
                  onClose: _closeSession,
                ),
              ),
              MalaCompleteOverlay(
                pulse: malaPulse,
                color: deityColor,
                strings: l10n,
              ),
              if (_showCoach)
                Positioned.fill(
                  child: JapSessionCoachOverlay(onDismiss: _dismissCoach),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
