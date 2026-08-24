import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/deity/providers/deity_providers.dart';
import '../../theme/app_text_styles.dart';

/// Shows the currently selected deity's name in that deity's color.
class DivineNameText extends ConsumerWidget {
  const DivineNameText({super.key, this.fontSize = 72, this.opacity = 1});

  final double fontSize;
  final double opacity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deity = ref.watch(selectedDeityProvider);

    return Text(
      deity.name,
      textAlign: TextAlign.center,
      style: AppTextStyles.displayLarge.copyWith(
        fontSize: fontSize,
        color: deity.primary.withValues(alpha: opacity),
      ),
    );
  }
}
