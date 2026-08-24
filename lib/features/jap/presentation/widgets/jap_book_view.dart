import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';

/// "Likhit Jap" book: every chant makes the divine name fly onto a parchment
/// page and settle into place. When the page fills, it flips to a fresh page —
/// a digital take on the devotional practice of writing the name repeatedly.
class JapBookView extends StatefulWidget {
  const JapBookView({
    required this.japTrigger,
    required this.name,
    required this.inkColor,
    super.key,
  });

  final int japTrigger;
  final String name;
  final Color inkColor;

  /// How many names fit on one page before it flips.
  static const int namesPerPage = 24;

  @override
  State<JapBookView> createState() => _JapBookViewState();
}

class _JapBookViewState extends State<JapBookView>
    with TickerProviderStateMixin {
  late final AnimationController _writeController;

  int _page = 1;
  int _onPage = 0;
  int _lifetimeOnBook = 0;

  @override
  void initState() {
    super.initState();
    _writeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 460),
    );
    if (widget.japTrigger > 0) {
      _onPage = ((widget.japTrigger - 1) % JapBookView.namesPerPage) + 1;
      _page = ((widget.japTrigger - 1) ~/ JapBookView.namesPerPage) + 1;
      _lifetimeOnBook = widget.japTrigger;
    }
  }

  @override
  void didUpdateWidget(covariant JapBookView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.japTrigger > oldWidget.japTrigger) {
      _writeName();
    }
  }

  void _writeName() {
    setState(() {
      _lifetimeOnBook += 1;
      if (_onPage >= JapBookView.namesPerPage) {
        _page += 1;
        _onPage = 1;
      } else {
        _onPage += 1;
      }
    });
    _writeController.forward(from: 0);
  }

  @override
  void dispose() {
    _writeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ink = Color.alphaBlend(
      widget.inkColor.withValues(alpha: 0.85),
      const Color(0xFF3A240F),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: AspectRatio(
        aspectRatio: 0.74,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 620),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: _flipTransition,
          child: _BookPage(
            key: ValueKey<int>(_page),
            page: _page,
            count: _onPage,
            name: widget.name,
            ink: ink,
            accent: widget.inkColor,
            writeAnimation: _writeController,
            totalWritten: _lifetimeOnBook,
          ),
        ),
      ),
    );
  }

  Widget _flipTransition(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        // Map 0..1 to a Y-axis rotation so old/new pages sweep like a turn.
        final angle = (1 - animation.value) * (math.pi / 2);
        return Transform(
          alignment: Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(-angle),
          child: Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }
}

class _BookPage extends StatelessWidget {
  const _BookPage({
    required this.page,
    required this.count,
    required this.name,
    required this.ink,
    required this.accent,
    required this.writeAnimation,
    required this.totalWritten,
    super.key,
  });

  final int page;
  final int count;
  final String name;
  final Color ink;
  final Color accent;
  final Animation<double> writeAnimation;
  final int totalWritten;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7EEDA), Color(0xFFEAD7B0)],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRect(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.start,
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (var i = 0; i < count; i++)
                        if (i == count - 1)
                          _AnimatedWrite(
                            animation: writeAnimation,
                            child: _NameMark(name: name, ink: ink),
                          )
                        else
                          _NameMark(name: name, ink: ink),
                    ],
                  ),
                ),
              ),
            ),
            Divider(
              color: accent.withValues(alpha: 0.35),
              height: AppSpacing.md,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'पृष्ठ $page',
                  style: TextStyle(
                    color: ink.withValues(alpha: 0.7),
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '$totalWritten',
                  style: TextStyle(
                    color: ink.withValues(alpha: 0.7),
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NameMark extends StatelessWidget {
  const _NameMark({required this.name, required this.ink});

  final String name;
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 26,
        height: 1.1,
        color: ink,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Animates the newest name: it descends from above, shrinking and fading in,
/// as if a hand just wrote it onto the page.
class _AnimatedWrite extends StatelessWidget {
  const _AnimatedWrite({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(animation.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * -36),
            child: Transform.scale(scale: 1.0 + (1 - t) * 0.7, child: child),
          ),
        );
      },
    );
  }
}
