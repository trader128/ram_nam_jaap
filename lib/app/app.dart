import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_strings.dart';
import '../core/sync/sync_lifecycle_observer.dart';
import '../core/widgets/deity_asset_precache.dart';
import '../features/deity/providers/deity_providers.dart';
import '../theme/app_theme.dart';
import 'router.dart';

class BhaktiApp extends ConsumerWidget {
  const BhaktiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final deity = ref.watch(selectedDeityProvider);
    final theme = AppTheme.themed(primary: deity.primary, accent: deity.accent);

    return SyncLifecycleObserver(
      child: DeityAssetPrecache(
        child: MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: theme,
          themeMode: ThemeMode.dark,
          locale: const Locale('hi'),
          supportedLocales: const [Locale('hi')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
  }
}
