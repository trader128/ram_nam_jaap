import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../domain/deity_pack.dart';

class DeityCard extends StatelessWidget {
  const DeityCard({
    required this.deity,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final DeityPack deity;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                deity.primary.withValues(alpha: selected ? 0.22 : 0.10),
                deity.accent.withValues(alpha: selected ? 0.12 : 0.04),
              ],
            ),
            border: Border.all(
              color: selected
                  ? deity.primary.withValues(alpha: 0.9)
                  : AppColors.divider.withValues(alpha: 0.5),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _NaamGlyph(deity: deity),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deity.transliteration,
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        deity.mantra,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: deity.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(deity.meaning, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  color: selected
                      ? deity.primary
                      : AppColors.textSecondary.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NaamGlyph extends StatelessWidget {
  const _NaamGlyph({required this.deity});

  final DeityPack deity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: deity.primary.withValues(alpha: 0.14),
        border: Border.all(color: deity.primary.withValues(alpha: 0.5)),
      ),
      child: Text(
        deity.name,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: deity.primary,
        ),
      ),
    );
  }
}
