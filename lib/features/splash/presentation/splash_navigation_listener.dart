import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_routes.dart';
import '../../../theme/app_durations.dart';

class SplashNavigationListener extends StatefulWidget {
  const SplashNavigationListener({required this.child, super.key});

  final Widget child;

  @override
  State<SplashNavigationListener> createState() =>
      _SplashNavigationListenerState();
}

class _SplashNavigationListenerState extends State<SplashNavigationListener> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future<void>.delayed(AppDurations.splash);
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
