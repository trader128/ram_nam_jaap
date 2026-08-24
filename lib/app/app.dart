import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_strings.dart';
import '../core/sync/sync_lifecycle_observer.dart';
import '../core/widgets/deity_asset_precache.dart';
import '../features/deity/providers/deity_providers.dart';
import '../features/jap/providers/jap_providers.dart';
import '../shared/enums/app_language.dart';
import '../theme/app_theme.dart';
import 'router.dart';

class BhaktiApp extends ConsumerWidget {
  const BhaktiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final deity = ref.watch(selectedDeityProvider);
    final language = ref.watch(
      japSettingsProvider.select((settings) => settings.language),
    );
    final theme = AppTheme.themed(primary: deity.primary, accent: deity.accent);

    return SyncLifecycleObserver(
      child: DeityAssetPrecache(
        child: MaterialApp.router(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: theme,
          darkTheme: theme,
          themeMode: ThemeMode.dark,
          locale: language.locale,
          supportedLocales: AppLanguage.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
  }
}
