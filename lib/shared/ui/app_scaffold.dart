import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'adaptive_content_frame.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = false,
    this.useAdaptiveFrame = true,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final bool useAdaptiveFrame;

  @override
  Widget build(BuildContext context) {
    final content = useAdaptiveFrame ? AdaptiveContentFrame(child: body) : body;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      body: content,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
