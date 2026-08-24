import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../deity/providers/deity_providers.dart';

/// Immersive, deity-themed backdrop painted entirely on the GPU.
///
/// Lightweight by design (no video decoding): a vertical gradient, a soft
/// radial glow, faint concentric rings, god-rays, and a few drifting motes —
/// all in one [CustomPainter] wrapped in a [RepaintBoundary].
class DivineWallpaperBackground extends ConsumerWidget {
  const DivineWallpaperBackground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deity = ref.watch(selectedDeityProvider);

    return RepaintBoundary(
      child: CustomPaint(
        painter: _DivineWallpaperPainter(
          top: deity.backdropTop,
          bottom: deity.backdropBottom,
          glow: deity.primary,
          ray: deity.accent,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _DivineWallpaperPainter extends CustomPainter {
  const _DivineWallpaperPainter({
    required this.top,
    required this.bottom,
    required this.glow,
    required this.ray,
  });

  final Color top;
  final Color bottom;
  final Color glow;
  final Color ray;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [top, AppColors.background, bottom],
        stops: const [0, 0.55, 1],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final halo = Offset(size.width / 2, size.height * 0.4);

    final rays = Paint()
      ..shader = RadialGradient(
        center: Alignment(0, (halo.dy / size.height) * 2 - 1),
        radius: 0.95,
        colors: [ray.withValues(alpha: 0.10), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, rays);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0, (halo.dy / size.height) * 2 - 1),
        radius: 0.6,
        colors: [glow.withValues(alpha: 0.16), Colors.transparent],
      ).createShader(rect);
    canvas.drawRect(rect, glowPaint);

    final ringPaint = Paint()
      ..color = glow.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(halo, size.width * 0.31, ringPaint);
    canvas.drawCircle(halo, size.width * 0.42, ringPaint);

    final motes = Paint()..color = glow.withValues(alpha: 0.18);
    for (final offset in [
      Offset(size.width * 0.18, size.height * 0.22),
      Offset(size.width * 0.82, size.height * 0.68),
      Offset(size.width * 0.24, size.height * 0.74),
      Offset(size.width * 0.66, size.height * 0.18),
      Offset(size.width * 0.5, size.height * 0.85),
    ]) {
      canvas.drawCircle(offset, 2, motes);
    }
  }

  @override
  bool shouldRepaint(covariant _DivineWallpaperPainter oldDelegate) {
    return oldDelegate.top != top ||
        oldDelegate.bottom != bottom ||
        oldDelegate.glow != glow ||
        oldDelegate.ray != ray;
  }
}
