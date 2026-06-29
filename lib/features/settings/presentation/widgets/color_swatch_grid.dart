import 'package:flutter/material.dart';

import '../../../../shared/widgets/naam_display_text.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';

class ColorSwatchGrid extends StatelessWidget {
  const ColorSwatchGrid({
    required this.colors,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: colors.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
      ),
      itemBuilder: (context, index) {
        final color = colors[index];
        final isSelected = color.toARGB32() == selected.toARGB32();

        return GestureDetector(
          onTap: () => onSelected(color),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.divider.withValues(alpha: 0.4),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    color: _checkColorFor(color),
                    size: 18,
                  )
                : null,
          ),
        );
      },
    );
  }

  Color _checkColorFor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.55 ? AppColors.background : AppColors.textPrimary;
  }
}

class ColorPreviewCard extends StatelessWidget {
  const ColorPreviewCard({
    required this.color,
    required this.textSize,
    required this.enclosureEnabled,
    super.key,
  });

  final Color color;
  final double textSize;
  final bool enclosureEnabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: NaamPreviewText(
        color: color,
        textSize: textSize,
        enclosureEnabled: enclosureEnabled,
      ),
    );
  }
}

class NaamPreviewText extends StatelessWidget {
  const NaamPreviewText({
    required this.color,
    required this.textSize,
    required this.enclosureEnabled,
    super.key,
  });

  final Color color;
  final double textSize;
  final bool enclosureEnabled;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NaamDisplayText(
        fontSize: textSize * 0.72,
        enclosureEnabled: enclosureEnabled,
        color: color,
      ),
    );
  }
}
