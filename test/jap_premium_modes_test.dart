import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bhakti/shared/enums/app_language.dart';
import 'package:bhakti/shared/enums/count_method.dart';
import 'package:bhakti/shared/models/jap_settings.dart';

void main() {
  test('JapSettings defaults include milestone 5 preferences', () {
    const settings = JapSettings(
      soundEnabled: true,
      hapticEnabled: true,
      floatingTextEnabled: true,
      textSize: 72,
      dailyGoal: 108,
      floatingTextColor: Color(0xFFD4AF37),
      countMethod: CountMethod.both,
      backTapEnabled: true,
      showMalaRing: true,
      divineWallpaperEnabled: true,
      idleMusicEnabled: true,
      bookModeEnabled: true,
      language: AppLanguage.english,
    );

    expect(settings.countMethod, CountMethod.both);
    expect(settings.backTapEnabled, isTrue);
    expect(settings.showMalaRing, isTrue);
    expect(settings.divineWallpaperEnabled, isTrue);
    expect(settings.idleMusicEnabled, isTrue);
    expect(settings.bookModeEnabled, isTrue);
  });

  test('CountMethod restores from storage key', () {
    expect(CountMethod.fromStorageKey('volume'), CountMethod.volume);
    expect(CountMethod.fromStorageKey(null), CountMethod.tap);
  });
}
