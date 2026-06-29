import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_radius.dart';
import '../../../../theme/app_spacing.dart';

class JapModeToolbar extends StatelessWidget {
  const JapModeToolbar({
    required this.focusMode,
    required this.wallpaperMode,
    required this.malaRingVisible,
    required this.onFocusChanged,
    required this.onWallpaperChanged,
    required this.onMalaRingChanged,
    super.key,
  });

  final bool focusMode;
  final bool wallpaperMode;
  final bool malaRingVisible;
  final ValueChanged<bool> onFocusChanged;
  final ValueChanged<bool> onWallpaperChanged;
  final ValueChanged<bool> onMalaRingChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ModeIconButton(
            icon: focusMode
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            selected: focusMode,
            onPressed: () => onFocusChanged(!focusMode),
          ),
          _ModeIconButton(
            icon: Icons.wallpaper_rounded,
            selected: wallpaperMode,
            onPressed: () => onWallpaperChanged(!wallpaperMode),
          ),
          _ModeIconButton(
            icon: Icons.radio_button_checked_outlined,
            selected: malaRingVisible,
            onPressed: () => onMalaRingChanged(!malaRingVisible),
          ),
        ],
      ),
    );
  }
}

class _ModeIconButton extends StatelessWidget {
  const _ModeIconButton({
    required this.icon,
    required this.selected,
    required this.onPressed,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: selected ? AppColors.primaryGold : AppColors.textSecondary,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: selected
            ? AppColors.primaryGold.withValues(alpha: 0.12)
            : Colors.transparent,
      ),
    );
  }
}
