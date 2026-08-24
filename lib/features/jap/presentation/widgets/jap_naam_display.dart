import 'package:flutter/material.dart';

import '../../../../theme/app_durations.dart';
import '../../../../shared/widgets/naam_display_text.dart';
import 'floating_naam_stack.dart';

class JapNaamDisplay extends StatelessWidget {
  const JapNaamDisplay({
    required this.japTrigger,
    required this.name,
    required this.textSize,
    required this.naamColor,
    required this.floatingTextEnabled,
    super.key,
  });

  final int japTrigger;
  final String name;
  final double textSize;
  final Color naamColor;
  final bool floatingTextEnabled;

  @override
  Widget build(BuildContext context) {
    if (floatingTextEnabled) {
      return FloatingNaamStack(
        japTrigger: japTrigger,
        name: name,
        textSize: textSize,
        naamColor: naamColor,
      );
    }

    return StaticNaamDisplay(
      japTrigger: japTrigger,
      name: name,
      textSize: textSize,
      naamColor: naamColor,
    );
  }
}

class StaticNaamDisplay extends StatelessWidget {
  const StaticNaamDisplay({
    required this.japTrigger,
    required this.name,
    required this.textSize,
    required this.naamColor,
    super.key,
  });

  final int japTrigger;
  final String name;
  final double textSize;
  final Color naamColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(japTrigger),
      tween: Tween(begin: 0.94, end: 1),
      duration: AppDurations.fast,
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: NaamDisplayText(name: name, fontSize: textSize, color: naamColor),
    );
  }
}
