import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/localized_strings_provider.dart';
import '../../../theme/app_durations.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

/// First launch welcome — explains core flow for App Review clarity.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.slow)
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _interval(double start, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(localizedStringsProvider);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1206), Color(0xFF050608)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                FadeTransition(
                  opacity: _interval(0, 0.45),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.08),
                      end: Offset.zero,
                    ).animate(_interval(0, 0.45)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.appName, style: AppTextStyles.headlineLarge),
                        const SizedBox(height: AppSpacing.sm),
                        Text(l10n.tagline, style: AppTextStyles.bodyLarge),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _step('1', l10n.welcomeStep1, _interval(0.2, 0.55)),
                const SizedBox(height: AppSpacing.md),
                _step('2', l10n.welcomeStep2, _interval(0.35, 0.7)),
                const SizedBox(height: AppSpacing.md),
                _step('3', l10n.welcomeStep3, _interval(0.5, 0.85)),
                const Spacer(),
                FadeTransition(
                  opacity: _interval(0.65, 1),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: widget.onContinue,
                      child: Text(l10n.welcomeContinue),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _step(String number, String text, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(animation),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              child: Text(number, style: const TextStyle(fontSize: 12)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(text, style: AppTextStyles.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
