import 'package:flutter/material.dart';

import '../../../../theme/app_durations.dart';

/// Soft golden ripple on each jap tap — immediate visual feedback.
class JapTapPulse extends StatefulWidget {
  const JapTapPulse({required this.pulse, required this.color, super.key});

  final int pulse;
  final Color color;

  @override
  State<JapTapPulse> createState() => _JapTapPulseState();
}

class _JapTapPulseState extends State<JapTapPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expand;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.normal);
    _expand = Tween<double>(begin: 0.12, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _fade = Tween<double>(begin: 0.5, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void didUpdateWidget(JapTapPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse != oldWidget.pulse && widget.pulse > 0) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final diameter = MediaQuery.sizeOf(context).shortestSide * _expand.value;
          return Center(
            child: Opacity(
              opacity: _fade.value,
              child: Container(
                width: diameter,
                height: diameter,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
