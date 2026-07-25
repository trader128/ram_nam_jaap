import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/localized_strings_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_durations.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../deity/providers/deity_providers.dart';
import '../../guide/domain/sadhana_guide_engine.dart';
import '../../jap/providers/jap_providers.dart';

class DailyGuidanceCard extends ConsumerStatefulWidget {
  const DailyGuidanceCard({super.key});

  @override
  ConsumerState<DailyGuidanceCard> createState() => _DailyGuidanceCardState();
}

class _DailyGuidanceCardState extends ConsumerState<DailyGuidanceCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.slow);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizedStringsProvider);
    final statistics = ref.watch(japStatisticsProvider);
    final settings = ref.watch(japSettingsProvider);
    final deity = ref.watch(selectedDeityProvider);
    final color = deity.primary;

    final insight = SadhanaGuideEngine.generate(
      language: settings.language,
      statistics: statistics,
      settings: settings,
      deity: deity,
    );

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.18),
                AppColors.surfaceVariant.withValues(alpha: 0.55),
              ],
            ),
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 18, color: color),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        insight.title,
                        style: AppTextStyles.titleLarge.copyWith(color: color),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(l10n.guideSubtitle, style: AppTextStyles.labelSmall),
                const SizedBox(height: AppSpacing.sm),
                Text(insight.message, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  insight.affirmation,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: color.withValues(alpha: 0.9),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
