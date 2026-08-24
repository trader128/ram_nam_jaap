import 'package:flutter_test/flutter_test.dart';

import 'package:bhakti/features/deity/domain/deity_catalog.dart';
import 'package:bhakti/features/guide/domain/sadhana_guide_engine.dart';
import 'package:bhakti/shared/enums/app_language.dart';
import 'package:bhakti/shared/models/jap_settings.dart';
import 'package:bhakti/shared/models/jap_statistics.dart';

void main() {
  test('SadhanaGuideEngine suggests starting when counts are zero', () {
    final insight = SadhanaGuideEngine.generate(
        language: AppLanguage.hindi,
      statistics: JapStatistics.initial(),
      settings: JapSettings.defaults(),
      deity: DeityCatalog.byId('ram'),
    );

    expect(insight.message, contains('राम'));
    expect(insight.affirmation, isNotEmpty);
  });
}
