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
import '../../deity/domain/deity_catalog.dart';
import '../../deity/providers/deity_providers.dart';
import '../domain/bhajan.dart';
import '../providers/bhajan_providers.dart';

class BhajanLibraryScreen extends ConsumerWidget {
  const BhajanLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(localizedStringsProvider);
    final fallbackAccent = ref.watch(deityColorProvider);
    final grouped = ref.watch(bhajansByCategoryProvider);

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(strings.bhajans),
      ),
      body: SafeArea(
        child: grouped.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => _Empty(message: strings.bhajanEmpty),
          data: (categories) {
            if (categories.isEmpty) {
              return _Empty(message: strings.bhajanEmpty);
            }

            var index = 0;
            final children = <Widget>[
              Text(strings.bhajansSubtitle, style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.lg),
            ];

            for (final entry in categories.entries) {
              children.addAll([
                Text(
                  strings.bhajanCategory(entry.key.name),
                  style: AppTextStyles.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
              ]);

              for (final bhajan in entry.value) {
                children.add(
                  StaggeredEntrance(
                    index: index++,
                    child: _BhajanTile(
                      bhajan: bhajan,
                      hindi: strings.isHindi,
                      subtitle: strings.verseCount(bhajan.verses.length),
                      fallbackAccent: fallbackAccent,
                      onTap: () => context.push(
                        '${AppRoutes.bhajans}/${bhajan.id}',
                      ),
                    ),
                  ),
                );
              }

              children.add(const SizedBox(height: AppSpacing.lg));
            }

            return ScreenEntrance(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: children,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          message,
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _BhajanTile extends StatelessWidget {
  const _BhajanTile({
    required this.bhajan,
    required this.hindi,
    required this.subtitle,
    required this.fallbackAccent,
    required this.onTap,
  });

  final Bhajan bhajan;
  final bool hindi;
  final String subtitle;
  final Color fallbackAccent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final deity = bhajan.deityId == null
        ? null
        : DeityCatalog.byId(bhajan.deityId);
    final accent = deity?.primary ?? fallbackAccent;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accent.withValues(alpha: 0.16),
                    border: Border.all(color: accent.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    deity?.name.characters.first ?? 'ॐ',
                    style: AppTextStyles.titleLarge.copyWith(color: accent),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bhajan.title(hindi: hindi),
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        subtitle,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (bhajan.hasAudio)
                  Icon(
                    Icons.headphones_rounded,
                    size: 18,
                    color: accent.withValues(alpha: 0.8),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
