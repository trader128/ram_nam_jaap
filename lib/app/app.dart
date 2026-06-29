import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_strings.dart';
import '../features/deity/providers/deity_providers.dart';
import '../theme/app_theme.dart';
import 'router.dart';

class RamNamJapApp extends ConsumerWidget {
  const RamNamJapApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final deity = ref.watch(selectedDeityProvider);
    final theme = AppTheme.themed(primary: deity.primary, accent: deity.accent);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
