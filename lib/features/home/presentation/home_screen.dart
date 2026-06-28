import 'package:flutter/material.dart';

import '../../../constants/app_strings.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/widgets/divine_name_text.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_durations.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _heroFade;
  late final Animation<double> _heroScale;
  late final Animation<double> _statsFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: AppDurations.slow);

    _heroFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.6, curve: Curves.easeOut),
    );

    _heroScale = Tween<double>(begin: 0.94, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _statsFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.85, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxxl),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeTransition(
                      opacity: _heroFade,
                      child: ScaleTransition(
                        scale: _heroScale,
                        child: const DivineNameText(fontSize: 96),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FadeTransition(
                      opacity: _statsFade,
                      child: const _HomeStatsRow(),
                    ),
                  ],
                ),
              ),
              FadeTransition(
                opacity: _statsFade,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                  child: PrimaryButtonAnimated(
                    label: AppStrings.beginJap,
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeStatsRow extends StatelessWidget {
  const _HomeStatsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(label: AppStrings.today, value: '0'),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(label: AppStrings.totalJaps, value: '0'),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatCard(label: AppStrings.streak, value: '0'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSmall,
          ),
        ],
      ),
    );
  }
}
