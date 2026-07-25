import 'package:flutter_test/flutter_test.dart';

import 'package:ram_nam_jap/features/deity/domain/deity_catalog.dart';
import 'package:ram_nam_jap/features/guide/domain/sadhana_guide_engine.dart';
import 'package:ram_nam_jap/shared/enums/app_language.dart';
import 'package:ram_nam_jap/shared/models/jap_settings.dart';
import 'package:ram_nam_jap/shared/models/jap_statistics.dart';

void main() {
  test('SadhanaGuideEngine suggests starting when counts are zero', () {
    final insight = SadhanaGuideEngine.generate(
      language: AppLanguage.english,
      statistics: JapStatistics.initial(),
      settings: JapSettings.defaults(),
      deity: DeityCatalog.byId('ram'),
    );

    expect(insight.message, contains('Ram'));
    expect(insight.affirmation, isNotEmpty);
  });
}
