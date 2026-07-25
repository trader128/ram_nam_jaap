import 'package:flutter_test/flutter_test.dart';

import 'package:ram_nam_jap/core/constants/hive_keys.dart';
import 'package:ram_nam_jap/features/deity/domain/deity_catalog.dart';

void main() {
  test('catalog exposes the expected deities', () {
    final ids = DeityCatalog.all.map((deity) => deity.id).toList();
    expect(
      ids,
      containsAll(<String>[
        'ram',
        'krishna',
        'mahadev',
        'ganesh',
        'durga',
        'hanuman',
      ]),
    );
  });

  test('byId falls back to Ram for unknown ids', () {
    expect(DeityCatalog.byId('unknown').id, 'ram');
    expect(DeityCatalog.byId(null).id, 'ram');
    expect(DeityCatalog.fallback.id, 'ram');
  });

  test('each deity carries complete, distinct branding', () {
    final names = DeityCatalog.all.map((deity) => deity.name).toSet();
    final colors = DeityCatalog.all.map((deity) => deity.primary).toSet();
    expect(names.length, DeityCatalog.all.length);
    expect(colors.length, DeityCatalog.all.length);
    for (final deity in DeityCatalog.all) {
      expect(deity.mantra, isNotEmpty);
      expect(deity.meaning, isNotEmpty);
      expect(deity.transliteration, isNotEmpty);
    }
  });

  test('per-deity keys are namespaced', () {
    expect(HiveKeys.forDeity('ram', HiveKeys.todayCount), 'ram_today_count');
    expect(
      HiveKeys.forDeity('krishna', HiveKeys.totalLifetime),
      'krishna_total_lifetime',
    );
  });
}
