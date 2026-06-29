import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/jap_constants.dart';
import '../../../../theme/app_colors.dart';

class MalaRing extends StatelessWidget {
  const MalaRing({required this.sessionCount, required this.color, super.key});

  final int sessionCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final remainder = sessionCount % JapConstants.beadsPerMala;
    final displayCount = remainder == 0 && sessionCount > 0
        ? JapConstants.beadsPerMala
        : remainder;
    final progress = sessionCount == 0
        ? 0.0
        : remainder == 0
        ? 1.0
        : remainder / JapConstants.beadsPerMala;

    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(220, 220),
            painter: _MalaRingPainter(progress: progress, color: color),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$displayCount',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w400,
                  color: color,
                ),
              ),
              Text(
                '/ ${JapConstants.beadsPerMala}',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MalaRingPainter extends CustomPainter {
  _MalaRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const beadCount = JapConstants.beadsPerMala;
    final completedBeads = (progress * beadCount).floor();

    for (var i = 0; i < beadCount; i++) {
      final angle = (i / beadCount) * 2 * math.pi - math.pi / 2;
      final offset = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      final isActive = i < completedBeads;
      final paint = Paint()
        ..color = isActive
            ? color.withValues(alpha: 0.95)
            : AppColors.surfaceVariant.withValues(alpha: 0.85)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offset, isActive ? 4.2 : 3.4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MalaRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
