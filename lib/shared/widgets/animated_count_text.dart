import 'package:flutter/material.dart';

import '../../theme/app_durations.dart';

/// Smooth number transitions without rebuilding heavy parents every tap.
class AnimatedCountText extends StatelessWidget {
  const AnimatedCountText({
    required this.value,
    required this.style,
    super.key,
  });

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: value.toDouble(), end: value.toDouble()),
      duration: AppDurations.fast,
      curve: Curves.easeOutCubic,
      builder: (context, animated, child) {
        return Text(
          animated.round().toString(),
          style: style,
        );
      },
      child: Text('$value', style: style),
    );
  }
}

class AnimatedFormattedCountText extends StatelessWidget {
  const AnimatedFormattedCountText({
    required this.value,
    required this.formatter,
    required this.style,
    super.key,
  });

  final int value;
  final String Function(int value) formatter;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(value),
      tween: Tween(begin: 0.92, end: 1),
      duration: AppDurations.fast,
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: Text(formatter(value), style: style),
    );
  }
}
