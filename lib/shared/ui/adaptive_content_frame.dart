import 'package:flutter/material.dart';

/// Keeps phone layouts centered and readable on iPad instead of stretched edge-to-edge.
class AdaptiveContentFrame extends StatelessWidget {
  const AdaptiveContentFrame({required this.child, super.key, this.maxWidth = 520});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= maxWidth + 32) {
          return child;
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: child,
          ),
        );
      },
    );
  }
}
