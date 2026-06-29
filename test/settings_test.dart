import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:ram_nam_jap/constants/app_strings.dart';
import 'package:ram_nam_jap/core/constants/hive_box_names.dart';
import 'package:ram_nam_jap/core/constants/hive_keys.dart';
import 'package:ram_nam_jap/core/helpers/color_helper.dart';
import 'package:ram_nam_jap/features/jap/data/jap_settings_repository.dart';
import 'package:ram_nam_jap/features/settings/presentation/settings_screen.dart';
import 'package:ram_nam_jap/shared/enums/count_method.dart';
import 'package:ram_nam_jap/shared/models/jap_settings.dart';
import 'package:ram_nam_jap/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = await Directory.systemTemp.createTemp('settings_test');
    Hive.init(tempDir.path);
    await Future.wait([
      Hive.openBox<dynamic>(HiveBoxNames.settings),
      Hive.openBox<dynamic>(HiveBoxNames.history),
      Hive.openBox<dynamic>(HiveBoxNames.statistics),
      Hive.openBox<dynamic>(HiveBoxNames.session),
    ]);
  });

  test('JapSettingsRepository persists floating text color', () async {
    final repository = JapSettingsRepository();
    final custom = JapSettings.defaults().copyWith(
      floatingTextColor: const Color(0xFF4DA3FF),
      dailyGoal: 1008,
      soundEnabled: false,
    );

    await repository.save(custom);
    final loaded = repository.load();

    expect(
      loaded.floatingTextColor.toARGB32(),
      custom.floatingTextColor.toARGB32(),
    );
    expect(loaded.dailyGoal, 1008);
    expect(loaded.soundEnabled, false);
    expect(
      Hive.box(HiveBoxNames.settings).get(HiveKeys.floatingTextColor),
      ColorHelper.toStorageValue(custom.floatingTextColor),
    );
  });

  test('JapSettingsRepository persists milestone 5 preferences', () async {
    final repository = JapSettingsRepository();
    final custom = JapSettings.defaults().copyWith(
      countMethod: CountMethod.volume,
      showMalaRing: false,
      divineWallpaperEnabled: false,
    );

    await repository.save(custom);
    final loaded = repository.load();

    expect(loaded.countMethod, CountMethod.volume);
    expect(loaded.showMalaRing, isFalse);
    expect(loaded.divineWallpaperEnabled, isFalse);
  });

  testWidgets('SettingsScreen shows core toggles', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const SettingsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text(AppStrings.currentNaam), findsOneWidget);
    expect(find.text(AppStrings.countWith), findsOneWidget);
    expect(find.text(AppStrings.backTapTitle), findsOneWidget);

    final scrollable = find.byType(Scrollable).first;

    await tester.scrollUntilVisible(
      find.text(AppStrings.hapticsAndVibrations),
      120,
      scrollable: scrollable,
    );
    expect(find.text(AppStrings.hapticsAndVibrations), findsOneWidget);
    expect(find.text(AppStrings.soundEffects), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(AppStrings.showFloatingNaam),
      120,
      scrollable: scrollable,
    );
    expect(find.text(AppStrings.showFloatingNaam), findsOneWidget);
    expect(find.text(AppStrings.floatingTextColor), findsOneWidget);
  });
}
