import 'package:flutter/material.dart';

import '../../../../theme/app_durations.dart';
import '../../../../shared/widgets/naam_display_text.dart';
import '../widgets/floating_naam_stack.dart';

class JapNaamDisplay extends StatelessWidget {
  const JapNaamDisplay({
    required this.japTrigger,
    required this.textSize,
    required this.enclosureEnabled,
    required this.naamColor,
    required this.floatingTextEnabled,
    super.key,
  });

  final int japTrigger;
  final double textSize;
  final bool enclosureEnabled;
  final Color naamColor;
  final bool floatingTextEnabled;

  @override
  Widget build(BuildContext context) {
    if (floatingTextEnabled) {
      return FloatingNaamStack(
        japTrigger: japTrigger,
        textSize: textSize,
        enclosureEnabled: enclosureEnabled,
        naamColor: naamColor,
      );
    }

    return StaticNaamDisplay(
      japTrigger: japTrigger,
      textSize: textSize,
      enclosureEnabled: enclosureEnabled,
      naamColor: naamColor,
    );
  }
}

class StaticNaamDisplay extends StatelessWidget {
  const StaticNaamDisplay({
    required this.japTrigger,
    required this.textSize,
    required this.enclosureEnabled,
    required this.naamColor,
    super.key,
  });

  final int japTrigger;
  final double textSize;
  final bool enclosureEnabled;
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
      child: NaamDisplayText(
        fontSize: textSize,
        enclosureEnabled: enclosureEnabled,
        color: naamColor,
      ),
    );
  }
}
