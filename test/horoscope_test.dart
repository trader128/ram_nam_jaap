import 'package:flutter_test/flutter_test.dart';
import 'package:bhakti/features/kundali/domain/birth_profile.dart';
import 'package:bhakti/features/kundali/domain/horoscope_reading.dart';

void main() {
  group('BirthProfile', () {
    test('formats IST datetimes the way Prokerala expects', () {
      const profile = BirthProfile(
        year: 2004,
        month: 2,
        date: 12,
        hours: 15,
        minutes: 19,
        latitude: 23.1765,
        longitude: 75.7885,
        placeId: 'ujjain',
        placeLabel: 'Ujjain',
      );

      expect(profile.toIso8601(), '2004-02-12T15:19:00+05:30');
      expect(profile.toGatewayMap(hindi: true)['language'], 'hi');
      expect(profile.toGatewayMap(hindi: false)['coordinates'], isNull);
      expect(profile.toGatewayMap(hindi: false)['latitude'], 23.1765);
    });

    test('round-trips through Hive maps', () {
      const profile = BirthProfile(
        year: 1990,
        month: 5,
        date: 15,
        hours: 10,
        minutes: 30,
        latitude: 19.076,
        longitude: 72.8777,
        placeId: 'mumbai',
        placeLabel: 'मुंबई',
      );

      expect(BirthProfile.fromMap(profile.toMap())?.placeId, 'mumbai');
      expect(BirthProfile.fromMap(profile.toMap())?.toIso8601(), profile.toIso8601());
    });
  });

  group('HoroscopeReading', () {
    test('reads the Prokerala kundli example', () {
      final reading = HoroscopeReading.fromVendor(
        data: {
          'nakshatra_details': {
            'nakshatra': {
              'id': 25,
              'name': 'Uttara Bhadrapada',
              'pada': 3,
              'lord': {'name': 'Saturn', 'vedic_name': 'Shani'},
            },
            'chandra_rasi': {'name': 'Meena'},
            'soorya_rasi': {'name': 'Tula'},
            'zodiac': {'name': 'Scorpio'},
          },
          'mangal_dosha': {
            'has_dosha': false,
            'description': 'The person is Not Manglik',
          },
          'yoga_details': [
            {
              'name': 'Major Yogas',
              'description': 'Your kundli have 2 major yogas.',
            },
          ],
        },
        placeLabel: 'Ujjain',
        datetime: '2004-02-12T15:19:00+05:30',
      );

      expect(reading.nakshatra, 'Uttara Bhadrapada');
      expect(reading.nakshatraPada, 3);
      expect(reading.chandraRasi, 'Meena');
      expect(reading.sooryaRasi, 'Tula');
      expect(reading.zodiac, 'Scorpio');
      expect(reading.mangalHasDosha, isFalse);
      expect(reading.yogas.single.description, contains('major yogas'));
      expect(reading.hasLimbs, isTrue);
    });

    test('reads the Cloud Function camelCase payload', () {
      final reading = HoroscopeReading.fromMap({
        'placeLabel': 'उज्जैन',
        'datetime': '2004-02-12T15:19:00+05:30',
        'nakshatra': 'Uttara Bhadrapada',
        'chandraRasi': 'Meena',
        'mangalDosha': {
          'hasDosha': true,
          'description': 'Manglik',
        },
        'yogas': [
          {'name': 'Major Yogas', 'description': 'Two yogas'},
        ],
      });

      expect(reading?.mangalHasDosha, isTrue);
      expect(reading?.mangalDescription, 'Manglik');
      expect(reading?.yogas.single.name, 'Major Yogas');
    });
  });
}
