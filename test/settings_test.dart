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

  testWidgets('SettingsScreen shows core toggles', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const SettingsScreen()),
      ),
    );

    await tester.pump();

    expect(find.text(AppStrings.hapticsAndVibrations), findsOneWidget);
    expect(find.text(AppStrings.soundEffects), findsOneWidget);
    expect(find.text(AppStrings.showFloatingNaam), findsOneWidget);
    expect(find.text(AppStrings.floatingTextColor), findsOneWidget);
  });
}
