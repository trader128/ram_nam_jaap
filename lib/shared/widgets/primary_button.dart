import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/deity/providers/deity_providers.dart';
import '../../theme/app_durations.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

class PrimaryButton extends ConsumerWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = ref.watch(deityColorProvider);

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        splashColor: color.withValues(alpha: 0.16),
        highlightColor: color.withValues(alpha: 0.08),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: color.withValues(alpha: 0.45)),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: 0.14),
                color.withValues(alpha: 0.06),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.lg,
            ),
            child: Center(
              child: Text(
                label,
                style: AppTextStyles.titleLarge.copyWith(
                  color: color,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}

class PrimaryButtonAnimated extends StatefulWidget {
  const PrimaryButtonAnimated({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  State<PrimaryButtonAnimated> createState() => _PrimaryButtonAnimatedState();
}

class _PrimaryButtonAnimatedState extends State<PrimaryButtonAnimated>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.slow);

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: PrimaryButton(label: widget.label, onPressed: widget.onPressed),
      ),
    );
  }
}
