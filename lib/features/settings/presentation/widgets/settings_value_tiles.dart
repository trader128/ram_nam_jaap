import 'package:flutter/material.dart';

import '../../../../constants/app_strings.dart';
import '../../../../core/helpers/number_formatter.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';

class SettingsSliderTile extends StatelessWidget {
  const SettingsSliderTile({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    super.key,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.bodyLarge),
              Text(
                value.round().toString(),
                style: AppTextStyles.titleLarge.copyWith(
                  color: AppColors.primaryGold,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            activeColor: AppColors.primaryGold,
            inactiveColor: AppColors.divider,
          ),
        ],
      ),
    );
  }
}

class SettingsGoalTile extends StatefulWidget {
  const SettingsGoalTile({
    required this.value,
    required this.presets,
    required this.onSave,
    super.key,
  });

  final int value;
  final List<int> presets;
  final ValueChanged<int> onSave;

  @override
  State<SettingsGoalTile> createState() => _SettingsGoalTileState();
}

class _SettingsGoalTileState extends State<SettingsGoalTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant SettingsGoalTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value &&
        _controller.text != widget.value.toString()) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed <= 0) {
      return;
    }
    widget.onSave(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.dailyNaamGoal, style: AppTextStyles.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: AppTextStyles.headlineMedium,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: AppColors.divider.withValues(alpha: 0.6),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: AppColors.divider.withValues(alpha: 0.6),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(
                  color: AppColors.primaryGold.withValues(alpha: 0.6),
                ),
              ),
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            children: widget.presets.map((preset) {
              final selected = preset == widget.value;
              return ActionChip(
                label: Text(NumberFormatter.formatCount(preset)),
                onPressed: () {
                  _controller.text = preset.toString();
                  widget.onSave(preset);
                },
                backgroundColor: selected
                    ? AppColors.primaryGold.withValues(alpha: 0.14)
                    : AppColors.surface,
                side: BorderSide(
                  color: selected
                      ? AppColors.primaryGold.withValues(alpha: 0.45)
                      : AppColors.divider.withValues(alpha: 0.5),
                ),
                labelStyle: AppTextStyles.labelLarge.copyWith(
                  color: selected
                      ? AppColors.primaryGold
                      : AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
