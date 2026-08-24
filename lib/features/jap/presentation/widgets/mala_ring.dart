import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/jap_constants.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_durations.dart';

class MalaRing extends StatefulWidget {
  const MalaRing({required this.sessionCount, required this.color, super.key});

  final int sessionCount;
  final Color color;

  @override
  State<MalaRing> createState() => _MalaRingState();
}

class _MalaRingState extends State<MalaRing> {
  double _animatedProgress = 0;

  double _targetProgress(int sessionCount) {
    if (sessionCount == 0) {
      return 0;
    }
    final remainder = sessionCount % JapConstants.beadsPerMala;
    if (remainder == 0) {
      return 1;
    }
    return remainder / JapConstants.beadsPerMala;
  }

  @override
  void initState() {
    super.initState();
    _animatedProgress = _targetProgress(widget.sessionCount);
  }

  @override
  void didUpdateWidget(MalaRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionCount != widget.sessionCount) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = _targetProgress(widget.sessionCount);
    final remainder = widget.sessionCount % JapConstants.beadsPerMala;
    final displayCount = remainder == 0 && widget.sessionCount > 0
        ? JapConstants.beadsPerMala
        : remainder;

    return TweenAnimationBuilder<double>(
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      tween: Tween(begin: _animatedProgress, end: target),
      onEnd: () => _animatedProgress = target,
      builder: (context, progress, _) {
        return SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(220, 220),
                painter: _MalaRingPainter(progress: progress, color: widget.color),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: AppDurations.fast,
                    tween: Tween(
                      begin: displayCount.toDouble(),
                      end: displayCount.toDouble(),
                    ),
                    builder: (context, value, _) {
                      return Text(
                        value.round().toString(),
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w400,
                          color: widget.color,
                        ),
                      );
                    },
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
      },
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
