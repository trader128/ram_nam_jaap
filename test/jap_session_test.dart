import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:ram_nam_jap/constants/app_strings.dart';
import 'package:ram_nam_jap/core/constants/hive_box_names.dart';
import 'package:ram_nam_jap/core/helpers/number_formatter.dart';
import 'package:ram_nam_jap/features/home/presentation/home_screen.dart';
import 'package:ram_nam_jap/features/jap/presentation/jap_screen.dart';
import 'package:ram_nam_jap/theme/app_theme.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final tempDir = await Directory.systemTemp.createTemp('ram_nam_jap_test');
    Hive.init(tempDir.path);
    await Future.wait([
      Hive.openBox<dynamic>(HiveBoxNames.settings),
      Hive.openBox<dynamic>(HiveBoxNames.history),
      Hive.openBox<dynamic>(HiveBoxNames.statistics),
      Hive.openBox<dynamic>(HiveBoxNames.session),
    ]);
  });

  group('NumberFormatter', () {
    test('formats large counts with commas', () {
      expect(NumberFormatter.formatCount(92160), '92,160');
    });

    test('formats malas with one decimal', () {
      expect(NumberFormatter.formatMalas(481), '4.5');
    });
  });

  testWidgets('HomeScreen displays divine name as hero', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const HomeScreen()),
      ),
    );

    await tester.pump();

    expect(find.text(AppStrings.divineName), findsOneWidget);
    expect(find.text(AppStrings.beginJap), findsOneWidget);
  });

  testWidgets('JapScreen shows tap instruction', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.dark, home: const JapScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text(AppStrings.tapToChant), findsOneWidget);
  });
}
