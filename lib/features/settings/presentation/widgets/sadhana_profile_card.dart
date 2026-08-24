import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/app_routes.dart';
import '../../../../core/helpers/number_formatter.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../l10n/localized_strings.dart';
import '../../../../l10n/localized_strings_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../deity/providers/deity_providers.dart';
import '../../../jap/providers/jap_providers.dart';

/// Identity for the habit — naam, streak, backup — sitting at the top of More.
class SadhanaProfileCard extends ConsumerStatefulWidget {
  const SadhanaProfileCard({super.key});

  @override
  ConsumerState<SadhanaProfileCard> createState() => _SadhanaProfileCardState();
}

class _SadhanaProfileCardState extends ConsumerState<SadhanaProfileCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(japStatisticsProvider.notifier).refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final deity = ref.watch(selectedDeityProvider);
    final stats = ref.watch(japStatisticsProvider);
    final strings = ref.watch(localizedStringsProvider);
    final sync = ref.watch(syncControllerProvider);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: () => context.push(AppRoutes.deitySelection),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: deity.primary.withValues(alpha: 0.35)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                deity.primary.withValues(alpha: 0.18),
                AppColors.surfaceVariant.withValues(alpha: 0.55),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: deity.primary.withValues(alpha: 0.2),
                    child: Text(
                      deity.name.characters.first,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: deity.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(deity.name, style: AppTextStyles.headlineMedium),
                        Text(
                          deity.mantra,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: deity.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.expand_more_rounded,
                    color: deity.primary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _Stat(
                    value: NumberFormatter.formatCount(stats.todayCount),
                    label: strings.today,
                  ),
                  _Stat(
                    value: NumberFormatter.formatCount(stats.currentStreak),
                    label: strings.streak,
                  ),
                  _Stat(
                    value: NumberFormatter.formatCount(stats.lifetimeCount),
                    label: strings.totalJaps,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _backupLine(strings, sync),
                style: AppTextStyles.labelSmall.copyWith(
                  color: sync.state == SyncState.failed
                      ? AppColors.error
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _backupLine(LocalizedStrings strings, SyncStatus status) {
    switch (status.state) {
      case SyncState.disabled:
        return strings.profileBackupOff;
      case SyncState.syncing:
        return strings.backupSyncing;
      case SyncState.failed:
        return strings.backupFailed;
      case SyncState.idle:
      case SyncState.synced:
        final at = status.lastSyncedAt;
        if (at == null) {
          return strings.backupNeverSynced;
        }
        return strings.backupLastSynced(strings.relativeTime(at));
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.titleLarge),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}
