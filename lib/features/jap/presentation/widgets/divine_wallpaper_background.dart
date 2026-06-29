import 'package:flutter/material.dart';

import '../../../../constants/app_strings.dart';
import '../../../../theme/app_colors.dart';

class DivineWallpaperBackground extends StatelessWidget {
  const DivineWallpaperBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DivineWallpaperPainter(naam: AppStrings.divineName),
      child: const SizedBox.expand(),
    );
  }
}

class _DivineWallpaperPainter extends CustomPainter {
  _DivineWallpaperPainter({required this.naam});

  final String naam;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF120A04),
          AppColors.background,
          const Color(0xFF1A1208),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    final glow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.15),
        radius: 0.85,
        colors: [
          AppColors.primaryGold.withValues(alpha: 0.16),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, glow);

    final ringPaint = Paint()
      ..color = AppColors.primaryGold.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.42),
      size.width * 0.34,
      ringPaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.42),
      size.width * 0.28,
      ringPaint,
    );

    _drawVerticalNaam(canvas, size);
    _drawParticles(canvas, size);
  }

  void _drawVerticalNaam(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: List.generate(4, (_) => naam).join('\n'),
        style: TextStyle(
          fontSize: size.width * 0.11,
          height: 1.15,
          color: AppColors.primaryGold.withValues(alpha: 0.14),
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width * 0.3);

    textPainter.paint(canvas, Offset(size.width * 0.72, size.height * 0.18));
  }

  void _drawParticles(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGold.withValues(alpha: 0.25);
    final randomOffsets = [
      Offset(size.width * 0.18, size.height * 0.22),
      Offset(size.width * 0.82, size.height * 0.68),
      Offset(size.width * 0.24, size.height * 0.74),
      Offset(size.width * 0.66, size.height * 0.18),
    ];

    for (final offset in randomOffsets) {
      canvas.drawCircle(offset, 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
