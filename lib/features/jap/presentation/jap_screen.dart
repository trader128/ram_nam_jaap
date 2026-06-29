import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_strings.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_durations.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../../shared/widgets/naam_display_text.dart';
import '../providers/jap_providers.dart';
import 'widgets/floating_naam_stack.dart';
import 'widgets/jap_stats_bar.dart';

class JapScreen extends ConsumerStatefulWidget {
  const JapScreen({super.key});

  @override
  ConsumerState<JapScreen> createState() => _JapScreenState();
}

class _JapScreenState extends ConsumerState<JapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(japSessionProvider.notifier).beginSession();
    });
  }

  Future<void> _closeSession() async {
    await ref.read(japSessionProvider.notifier).endSession();
    ref.read(japStatisticsProvider.notifier).refresh();
    ref.read(japHistoryProvider.notifier).refresh();
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _onJapTap() async {
    await ref
        .read(japSessionProvider.notifier)
        .registerJap(
          ref.read(japStatisticsProvider.notifier),
          ref.read(japHistoryProvider.notifier),
        );
  }

  @override
  Widget build(BuildContext context) {
    final sessionBundle = ref.watch(japSessionProvider);
    final statistics = ref.watch(japStatisticsProvider);
    final settings = ref.watch(japSettingsProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        await _closeSession();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _onJapTap,
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xxxl),
                      Expanded(
                        child: Center(
                          child: settings.floatingTextEnabled
                              ? FloatingNaamStack(
                                  japTrigger: sessionBundle.japTrigger,
                                  textSize: settings.textSize,
                                  enclosureEnabled: settings.enclosureEnabled,
                                )
                              : StaticNaamDisplay(
                                  japTrigger: sessionBundle.japTrigger,
                                  textSize: settings.textSize,
                                  enclosureEnabled: settings.enclosureEnabled,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Text(
                          AppStrings.tapToChant,
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
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                left: AppSpacing.md,
                child: IconButton(
                  onPressed: _closeSession,
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.textSecondary,
                  tooltip: AppStrings.closeJap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StaticNaamDisplay extends StatelessWidget {
  const StaticNaamDisplay({
    required this.japTrigger,
    required this.textSize,
    required this.enclosureEnabled,
    super.key,
  });

  final int japTrigger;
  final double textSize;
  final bool enclosureEnabled;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(japTrigger),
      tween: Tween(begin: 0.94, end: 1),
      duration: AppDurations.fast,
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: NaamDisplayText(
        fontSize: textSize,
        enclosureEnabled: enclosureEnabled,
      ),
    );
  }
}
