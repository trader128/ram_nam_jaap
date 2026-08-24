import 'package:flutter_test/flutter_test.dart';
import 'package:bhakti/features/calendar/data/navamsha_panchang_parser.dart';
import 'package:bhakti/features/calendar/domain/calendar_engine.dart';
import 'package:bhakti/features/calendar/domain/panchang_day.dart';
import 'package:bhakti/features/calendar/domain/panchang_vrat_merger.dart';
import 'package:bhakti/features/calendar/domain/vrat.dart';

void main() {
  final monday = DateTime(2026, 8, 24);

  group('NavamshaPanchangParser', () {
    test('reads nested limb objects with numbers and sunrise', () {
      final day = NavamshaPanchangParser.parse(
        date: monday,
        output: {
          'tithi': {
            'name': 'Shukla Paksha Ekadashi',
            'number': 11,
            'paksha': 'Shukla',
          },
          'nakshatra': {'name': 'Rohini'},
          'yoga': {'name': 'Siddha'},
          'karana': {'name': 'Vanija'},
          'vaara': 'Monday',
          'sunrise': '06:12:33',
          'sunset': '18:45:01',
        },
      );

      expect(day.tithiNumber, 11);
      expect(day.paksha, 'shukla');
      expect(day.tithiNameEn, 'Shukla Paksha Ekadashi');
      expect(day.nakshatraEn, 'Rohini');
      expect(day.sunrise, '6:12');
      expect(day.sunset, '18:45');
    });

    test('derives the tithi number from a Hindi or English name', () {
      expect(
        NavamshaPanchangParser.tithiNumberFromName('शुक्ल पक्ष एकादशी'),
        11,
      );
      expect(NavamshaPanchangParser.tithiNumberFromName('Purnima'), 15);
      expect(NavamshaPanchangParser.tithiNumberFromName('अमावस्या'), 30);
      expect(
        NavamshaPanchangParser.parse(
          date: monday,
          output: {'tithi': 'Krishna Paksha Chaturthi'},
        ).tithiNumber,
        4,
      );
    });

    test('keeps Hindi names when the payload is Devanagari', () {
      final day = NavamshaPanchangParser.parse(
        date: monday,
        output: {
          'tithi': {'name': 'एकादशी', 'name_en': 'Ekadashi'},
          'nakshatra': {'name_hi': 'रोहिणी'},
        },
      );

      expect(day.tithi(hindi: true), 'एकादशी');
      expect(day.tithi(hindi: false), 'Ekadashi');
      expect(day.nakshatra(hindi: true), 'रोहिणी');
    });

    test('reads the live Navamsha array-of-periods payload', () {
      final day = NavamshaPanchangParser.parse(
        date: monday,
        output: {
          'vaara': 'Monday',
          'nakshatra': [
            {'id': 20, 'name': 'Purva Ashadha'},
          ],
          'tithi': [
            {
              'id': 12,
              'index': 12,
              'name': 'Dwadashi',
              'paksha': 'Shukla',
            },
          ],
          'sunrise': '2026-08-24T06:06:19.753777+05:30',
          'sunset': '2026-08-24T18:51:54.951937+05:30',
        },
      );

      expect(day.tithiNumber, 12);
      expect(day.paksha, 'shukla');
      expect(day.tithiNameEn, 'Dwadashi');
      expect(day.tithi(hindi: true), 'शुक्ल द्वादशी');
      expect(day.nakshatraEn, 'Purva Ashadha');
      expect(day.nakshatra(hindi: true), 'पूर्वाषाढ़ा');
      expect(day.sunrise, '6:06');
      expect(day.sunset, '18:51');
    });

    test('accepts a wrapped panchang object or a one-item array', () {
      final nested = NavamshaPanchangParser.parse(
        date: monday,
        output: {
          'panchang': {
            'tithi': {'name': 'Purnima', 'number': 15},
          },
        },
      );
      final listed = NavamshaPanchangParser.parse(
        date: monday,
        output: [
          {
            'tithi': {'name': 'Purnima', 'number': 15},
          },
        ],
      );

      expect(nested.tithiNumber, 15);
      expect(listed.tithiNumber, 15);
    });
  });

  group('PanchangVratMerger', () {
    Vrat template(String id) => Vrat(
      id: id,
      kind: VratKind.tithi,
      nameEn: id,
      nameHi: id,
    );

    final templates = [
      template('ekadashi'),
      template('purnima'),
      template('amavasya'),
      template('pradosh'),
      template('sankashti-chaturthi'),
    ];

    test('pins bundled tithi vrats onto matching civil dates', () {
      final days = [
        PanchangDay(date: DateTime(2026, 9, 12), tithiNumber: 11),
        PanchangDay(
          date: DateTime(2026, 9, 16),
          tithiNameEn: 'Purnima',
          tithiNumber: 15,
        ),
        PanchangDay(date: DateTime(2026, 9, 1), tithiNumber: 30),
        PanchangDay(date: DateTime(2026, 9, 2), tithiNumber: 13),
        PanchangDay(
          date: DateTime(2026, 9, 3),
          tithiNumber: 4,
          paksha: 'krishna',
        ),
      ];

      final merged = PanchangVratMerger.merge(templates, days);
      final dated = merged.where((vrat) => vrat.date != null).toList();

      expect(dated.map((vrat) => vrat.id), [
        'ekadashi-2026-09-12',
        'purnima-2026-09-16',
        'amavasya-2026-09-01',
        'pradosh-2026-09-02',
        'sankashti-chaturthi-2026-09-03',
      ]);
      expect(dated.first.date, DateTime(2026, 9, 12));
      expect(
        dated.first.nameHi,
        'ekadashi',
        reason: 'dated clones inherit katha and vidhi from the template',
      );
    });

    test('does not treat Shukla Chaturthi as Sankashti', () {
      expect(
        PanchangVratMerger.vratIdFor(
          PanchangDay(
            date: monday,
            tithiNumber: 4,
            paksha: 'shukla',
          ),
        ),
        isNull,
      );
    });
  });

  group('CalendarEngine with dated tithi clones', () {
    test('lists the dated occurrence and hides the undated template', () {
      final snapshot = CalendarEngine.build(
        vrats: [
          const Vrat(
            id: 'ekadashi',
            kind: VratKind.tithi,
            nameEn: 'Ekadashi',
            nameHi: 'एकादशी',
          ),
          Vrat(
            id: 'ekadashi-2026-08-26',
            kind: VratKind.tithi,
            nameEn: 'Ekadashi',
            nameHi: 'एकादशी',
            date: DateTime(2026, 8, 26),
          ),
        ],
        today: monday,
      );

      expect(snapshot.upcoming.map((entry) => entry.vrat.id), [
        'ekadashi-2026-08-26',
      ]);
      expect(snapshot.observances, isEmpty);
    });
  });
}
