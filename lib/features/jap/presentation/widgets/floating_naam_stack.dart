import 'package:flutter/material.dart';

import '../../../../core/constants/jap_constants.dart';
import '../../../../theme/app_durations.dart';
import '../../../../shared/widgets/naam_display_text.dart';

class FloatingNaamStack extends StatefulWidget {
  const FloatingNaamStack({
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
  State<FloatingNaamStack> createState() => _FloatingNaamStackState();
}

class _FloatingNaamStackState extends State<FloatingNaamStack>
    with TickerProviderStateMixin {
  final List<_FloatingEntry> _entries = [];

  @override
  void didUpdateWidget(covariant FloatingNaamStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.japTrigger != oldWidget.japTrigger && widget.japTrigger > 0) {
      _spawnEntry();
    }
  }

  void _spawnEntry() {
    final controller = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );

    final entry = _FloatingEntry(
      controller: controller,
      opacity: Tween<double>(begin: 0.92, end: 0).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0.15, 1, curve: Curves.easeOut),
        ),
      ),
      offset: Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.22))
          .animate(
            CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
          ),
      scale: Tween<double>(begin: 0.96, end: 1.04).animate(
        CurvedAnimation(
          parent: controller,
          curve: const Interval(0, 0.35, curve: Curves.easeOut),
        ),
      ),
    );

    setState(() {
      _entries.add(entry);
      if (_entries.length > JapConstants.maxFloatingEntries) {
        final removed = _entries.removeAt(0);
        removed.controller.dispose();
      }
    });

    controller.forward().whenComplete(() {
      if (!mounted) {
        return;
      }
      setState(() {
        _entries.remove(entry);
      });
      entry.controller.dispose();
    });
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        NaamDisplayText(
          fontSize: widget.textSize,
          enclosureEnabled: widget.enclosureEnabled,
          color: widget.naamColor,
          opacity: 0.18,
        ),
        for (final entry in _entries)
          AnimatedBuilder(
            animation: entry.controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  entry.offset.value.dy * MediaQuery.sizeOf(context).height,
                ),
                child: Transform.scale(
                  scale: entry.scale.value,
                  child: Opacity(opacity: entry.opacity.value, child: child),
                ),
              );
            },
            child: NaamDisplayText(
              fontSize: widget.textSize,
              enclosureEnabled: widget.enclosureEnabled,
              color: widget.naamColor,
            ),
          ),
        NaamDisplayText(
          fontSize: widget.textSize,
          enclosureEnabled: widget.enclosureEnabled,
          color: widget.naamColor,
        ),
      ],
    );
  }
}

class _FloatingEntry {
  _FloatingEntry({
    required this.controller,
    required this.opacity,
    required this.offset,
    required this.scale,
  });

  final AnimationController controller;
  final Animation<double> opacity;
  final Animation<Offset> offset;
  final Animation<double> scale;
}
