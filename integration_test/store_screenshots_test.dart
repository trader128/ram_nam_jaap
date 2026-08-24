import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bhakti/app/app.dart';
import 'package:bhakti/app/bootstrap.dart';
import 'package:bhakti/app/router.dart';
import 'package:bhakti/constants/app_routes.dart';
import 'package:bhakti/constants/app_strings.dart';

/// Captures Play Store screenshots on a connected Android emulator/device.
///
/// Run:
///   flutter test integration_test/store_screenshots_test.dart -d <device_id>
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await bootstrap();
  });

  testWidgets('capture store listing screenshots', (tester) async {
    // Phone portrait — standard Play Store screenshot size.
    await binding.setSurfaceSize(const Size(1080, 1920));

    await tester.pumpWidget(const ProviderScope(child: BhaktiApp()));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await binding.takeScreenshot('01-home');

    // Deity selection
    rootNavigatorKey.currentContext!.push(AppRoutes.deitySelection);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await binding.takeScreenshot('02-deity');

    // Jap session
    rootNavigatorKey.currentContext!.pop();
    await tester.pumpAndSettle();
    rootNavigatorKey.currentContext!.push(AppRoutes.jap);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await binding.takeScreenshot('03-jap');

    // Close jap overlay
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Insights tab
    await tester.tap(find.text(AppStrings.insights));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('04-insights');

    // Settings (More tab)
    await tester.tap(find.text(AppStrings.more));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('05-settings');
  });
}
