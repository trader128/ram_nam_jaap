import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ram_nam_jap/constants/app_strings.dart';
import 'package:ram_nam_jap/features/home/presentation/home_screen.dart';
import 'package:ram_nam_jap/theme/app_theme.dart';

void main() {
  testWidgets('HomeScreen displays divine name as hero', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: const HomeScreen(),
      ),
    );

    await tester.pump();

    expect(find.text(AppStrings.divineName), findsOneWidget);
    expect(find.text(AppStrings.beginJap), findsOneWidget);
  });
}
