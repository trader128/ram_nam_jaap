import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../domain/bhajan_audio_service.dart';
import '../providers/bhajan_providers.dart';

class BhajanDetailScreen extends ConsumerWidget {
  const BhajanDetailScreen({required this.bhajanId, super.key});

  final String bhajanId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(localizedStringsProvider);
    final bhajan = ref.watch(bhajanByIdProvider(bhajanId));
    final hindi = strings.isHindi;

    if (bhajan == null) {
      return AppScaffold(
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Center(
          child: Text(strings.bhajanEmpty, style: AppTextStyles.bodyMedium),
        ),
      );
    }

    final deity = bhajan.deityId == null
        ? null
        : DeityCatalog.byId(bhajan.deityId);
    final Color accent = deity?.primary ?? ref.watch(deityColorProvider);
    final showRoman = ref.watch(bhajanTransliterationProvider);
    final about = bhajan.about(hindi: hindi);

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(bhajan.title(hindi: hindi)),
        actions: [
          if (bhajan.hasTransliteration)
            IconButton(
              tooltip: strings.bhajanShowRoman,
              onPressed: () =>
                  ref.read(bhajanTransliterationProvider.notifier).toggle(),
              icon: Icon(
                showRoman ? Icons.translate_rounded : Icons.translate_outlined,
                color: showRoman ? accent : AppColors.textSecondary,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ScreenEntrance(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (about != null) ...[
                Text(about, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.md),
              ],
              if (bhajan.hasAudio)
                _PlayerBar(bhajan: bhajan, accent: accent)
              else
                Text(
                  strings.bhajanNoAudio,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              for (final (index, verse) in bhajan.verses.indexed)
                _VerseBlock(
                  verse: verse,
                  number: index + 1,
                  accent: accent,
                  showRoman: showRoman,
                ),
              if (bhajan.attribution case final attribution?) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  attribution,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerseBlock extends StatelessWidget {
  const _VerseBlock({
    required this.verse,
    required this.number,
    required this.accent,
    required this.showRoman,
  });

  final BhajanVerse verse;
  final int number;
  final Color accent;
  final bool showRoman;

  @override
  Widget build(BuildContext context) {
    final transliteration = verse.transliteration;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$number',
              style: AppTextStyles.labelSmall.copyWith(
                color: accent.withValues(alpha: 0.7),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verse.devanagari,
                  style: AppTextStyles.bodyLarge.copyWith(height: 1.7),
                ),
                if (showRoman && transliteration != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    transliteration,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerBar extends ConsumerWidget {
  const _PlayerBar({required this.bhajan, required this.accent});

  final Bhajan bhajan;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(localizedStringsProvider);
    final playback = ref
        .watch(bhajanPlaybackProvider)
        .valueOrNull ??
        const BhajanPlayback();
    final isThisTrack = playback.bhajanId == bhajan.id;
    final failed =
        isThisTrack && playback.state == BhajanPlaybackState.failed;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        color: accent.withValues(alpha: 0.12),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _PlayButton(
                accent: accent,
                loading: playback.isLoading(bhajan.id),
                playing: playback.isPlaying(bhajan.id),
                onTap: () => ref
                    .read(bhajanAudioServiceProvider)
                    .toggle(bhajan),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  failed
                      ? strings.bhajanAudioFailed
                      : _label(playback, isThisTrack),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: failed ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          if (isThisTrack && playback.duration != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Slider(
              value: playback.progress,
              activeColor: accent,
              inactiveColor: accent.withValues(alpha: 0.2),
              onChanged: (value) {
                final total = playback.duration;
                if (total == null) {
                  return;
                }
                ref.read(bhajanAudioServiceProvider).seek(
                  Duration(
                    milliseconds: (total.inMilliseconds * value).round(),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  String _label(BhajanPlayback playback, bool isThisTrack) {
    if (!isThisTrack) {
      return bhajan.title(hindi: false);
    }
    final total = playback.duration;
    if (total == null) {
      return _format(playback.position);
    }
    return '${_format(playback.position)} / ${_format(total)}';
  }

  static String _format(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.accent,
    required this.loading,
    required this.playing,
    required this.onTap,
  });

  final Color accent;
  final bool loading;
  final bool playing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: loading ? null : onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: accent,
                    ),
                  )
                : Icon(
                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: accent,
                    size: 28,
                  ),
          ),
        ),
      ),
    );
  }
}
