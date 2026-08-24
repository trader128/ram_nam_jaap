import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_routes.dart';
import '../../../l10n/localized_strings_provider.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/widgets/motion_entrance.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../bhajan/providers/bhajan_providers.dart';
import '../../deity/domain/deity_catalog.dart';
import '../../deity/providers/deity_providers.dart';
import '../domain/calendar_engine.dart';
import '../providers/calendar_providers.dart';
import 'widgets/prasadam_interest_card.dart';

class VratDetailScreen extends ConsumerWidget {
  const VratDetailScreen({required this.vratId, super.key});

  final String vratId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(localizedStringsProvider);
    final vrat = ref.watch(vratByIdProvider(vratId));
    final hindi = strings.isHindi;

    if (vrat == null) {
      return AppScaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Center(
          child: Text(strings.calendar, style: AppTextStyles.bodyMedium),
        ),
      );
    }

    final deity = vrat.deityId == null
        ? null
        : DeityCatalog.byId(vrat.deityId);
    final Color accent = deity?.primary ?? ref.watch(deityColorProvider);
    final occurrence = vrat.occurrenceOnOrAfter(DateTime.now());
    final katha = vrat.katha(hindi: hindi);
    final vidhi = vrat.vidhi(hindi: hindi);
    final muhurat = vrat.muhurat(hindi: hindi);
    final relatedBhajans = ref.watch(bhajansForDeityProvider(vrat.deityId));

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(vrat.name(hindi: hindi)),
      ),
      body: SafeArea(
        child: ScreenEntrance(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (occurrence != null)
                Text(
                  '${HinduCalendarNames.weekday(occurrence, hindi: hindi)}'
                  ' · ${HinduCalendarNames.longDate(occurrence, hindi: hindi)}',
                  style: AppTextStyles.bodyMedium.copyWith(color: accent),
                ),
              if (vrat.summary(hindi: hindi) case final summary?) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(summary, style: AppTextStyles.bodyLarge),
              ],
              if (deity != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _ChantCta(
                  deityName: deity.name,
                  mantra: deity.mantra,
                  label: strings.vratChantCta,
                  accent: accent,
                  onTap: () async {
                    await ref
                        .read(selectedDeityProvider.notifier)
                        .select(deity);
                    if (context.mounted) {
                      context.push(AppRoutes.jap);
                    }
                  },
                ),
              ],
              if (relatedBhajans.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _Section(
                  title: strings.bhajans,
                  child: Column(
                    children: [
                      for (final bhajan in relatedBhajans)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Material(
                            color: AppColors.surfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(
                                AppRadius.md,
                              ),
                              onTap: () => context.push(
                                '${AppRoutes.bhajans}/${bhajan.id}',
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.menu_book_rounded,
                                      size: 18,
                                      color: accent,
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        bhajan.title(hindi: hindi),
                                        style: AppTextStyles.bodyLarge,
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (katha != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _Section(title: strings.vratKatha, child: Text(katha,
                    style: AppTextStyles.bodyMedium)),
              ],
              if (vidhi.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                _Section(
                  title: strings.vratVidhi,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final step in vidhi)
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: accent,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  step,
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (muhurat != null) ...[
                const SizedBox(height: AppSpacing.lg),
                _Section(
                  title: strings.vratMuhurat,
                  child: Text(muhurat, style: AppTextStyles.bodyMedium),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              const PrasadamInterestCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            letterSpacing: 1.4,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

/// Routes the calendar back into the chanting habit the app is built on.
class _ChantCta extends StatelessWidget {
  const _ChantCta({
    required this.deityName,
    required this.mantra,
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String deityName;
  final String mantra;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelSmall.copyWith(color: accent),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(mantra, style: AppTextStyles.bodyLarge),
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill_rounded, color: accent, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}
