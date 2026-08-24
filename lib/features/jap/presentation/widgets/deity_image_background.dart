import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../deity/providers/deity_providers.dart';
import 'divine_wallpaper_background.dart';

/// Full-bleed devotional artwork of the active deity, with a top-and-bottom
/// scrim so foreground text stays readable. Falls back to the painted
/// [DivineWallpaperBackground] if the image asset is ever missing.
class DeityImageBackground extends ConsumerWidget {
  const DeityImageBackground({this.imageOpacity = 1, super.key});

  /// Lets callers dim the artwork (e.g. softer on the home screen).
  final double imageOpacity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deity = ref.watch(selectedDeityProvider);

    final cacheWidth = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .round();

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: deity.backdropBottom),
          Opacity(
            opacity: imageOpacity,
            child: Image.asset(
              deity.backgroundImage,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
              cacheWidth: cacheWidth,
              errorBuilder: (context, error, stackTrace) =>
                  const DivineWallpaperBackground(),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  deity.backdropTop.withValues(alpha: 0.55),
                  Colors.transparent,
                  deity.backdropBottom.withValues(alpha: 0.82),
                  deity.backdropBottom,
                ],
                stops: const [0, 0.32, 0.82, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
