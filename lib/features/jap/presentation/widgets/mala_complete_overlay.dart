import 'package:flutter/material.dart';

import '../../../../l10n/localized_strings.dart';
import '../../../../theme/app_durations.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

class MalaCompleteOverlay extends StatefulWidget {
  const MalaCompleteOverlay({
    required this.pulse,
    required this.color,
    required this.strings,
    super.key,
  });

  final int pulse;
  final Color color;
  final LocalizedStrings strings;

  @override
  State<MalaCompleteOverlay> createState() => _MalaCompleteOverlayState();
}

class _MalaCompleteOverlayState extends State<MalaCompleteOverlay>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scale;
  Animation<double>? _fade;

  @override
  void didUpdateWidget(MalaCompleteOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse != oldWidget.pulse && widget.pulse > 0) {
      _play();
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.slow,
    );
    _scale = Tween<double>(begin: 0.6, end: 1).animate(
      CurvedAnimation(parent: _controller!, curve: Curves.elasticOut),
    );
    _fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0, 0.85, curve: Curves.easeOut),
      ),
    );
  }

  Future<void> _play() async {
    await _controller!.forward(from: 0);
    if (mounted) {
      await _controller!.reverse();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _scale == null || _fade == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: FadeTransition(
        opacity: _fade!,
        child: Center(
          child: ScaleTransition(
            scale: _scale!,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: widget.color.withValues(alpha: 0.6)),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.35),
                    blurRadius: 32,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.filter_vintage_rounded, color: widget.color, size: 36),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.strings.malaCompleteTitle,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: widget.color,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      widget.strings.malaCompleteBody,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
