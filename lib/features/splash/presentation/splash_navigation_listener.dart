import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_routes.dart';
import '../../../core/constants/hive_keys.dart';
import '../../../core/storage/hive_storage.dart';
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
    _navigateNext();
  }

  Future<void> _navigateNext() async {
    await Future<void>.delayed(AppDurations.splash);
    if (!mounted) {
      return;
    }
    final completed = HiveStorage.settingsBox.get(
          HiveKeys.welcomeCompleted,
          defaultValue: false,
        )
        as bool;
    if (completed) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
