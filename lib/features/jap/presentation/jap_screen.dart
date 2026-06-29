import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/volume_jap_service.dart';
import '../../../../theme/app_colors.dart';
import '../providers/jap_providers.dart';
import '../providers/jap_session_ui_provider.dart';
import 'widgets/jap_session_content.dart';

class JapScreen extends ConsumerStatefulWidget {
  const JapScreen({super.key});

  @override
  ConsumerState<JapScreen> createState() => _JapScreenState();
}

class _JapScreenState extends ConsumerState<JapScreen>
    with JapSessionLifecycle {
  late final VolumeJapService _volumeService;

  @override
  VolumeJapService get volumeService => _volumeService;

  @override
  void initState() {
    super.initState();
    _volumeService = ref.read(volumeJapServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await initializeJapSession(ref);
    });
  }

  @override
  void dispose() {
    _volumeService.stop();
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
      if (previous?.countMethod != next.countMethod) {
        syncVolumeListener(ref);
      }
    });

    final wallpaperMode = ref.watch(japSessionUiProvider).wallpaperMode;

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
          body: SafeArea(
            top: !wallpaperMode,
            bottom: !wallpaperMode,
            child: JapSessionContent(
              onJap: () => registerJap(ref),
              onClose: _closeSession,
            ),
          ),
        ),
      ),
    );
  }
}
