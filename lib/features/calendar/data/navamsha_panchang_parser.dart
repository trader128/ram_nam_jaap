import '../domain/panchang_day.dart';
import '../domain/panchang_hindi.dart';

/// Turns a Navamsha `output` blob into [PanchangDay] without assuming one
/// exact JSON shape — vendors nest the five limbs in a few common ways.
abstract final class NavamshaPanchangParser {
  static PanchangDay parse({
    required DateTime date,
    required dynamic output,
    String placeLabel = 'उज्जैन',
  }) {
    final root = _asMap(output);
    final tithi = _current(_limb(root, const ['tithi', 'Tithi', 'lunar_day']));
    final nakshatra = _current(
      _limb(root, const ['nakshatra', 'Nakshatra', 'star']),
    );
    final yoga = _current(_limb(root, const ['yoga', 'Yoga']));
    final karana = _current(_limb(root, const ['karana', 'Karana']));
    final vara = _current(
      _limb(root, const ['vara', 'vaara', 'weekday', 'day', 'vaaram']),
    );
    final sun = _current(
      _limb(root, const ['sun', 'sun_times', 'sunrise_sunset', 'advanced']),
    );

    final tithiEn = _englishName(tithi) ?? _englishName(root['tithi_name']);
    final tithiNumber =
        _number(tithi, const [
          'number',
          'tithi_number',
          'index',
          'id',
          'day',
        ]) ??
        tithiNumberFromName(tithiEn) ??
        tithiNumberFromName(_hindiName(tithi));
    final tithiHi =
        _hindiName(tithi) ??
        _hindiName(root['tithi_name']) ??
        PanchangHindi.tithi(number: tithiNumber, englishName: tithiEn);
    final nakshatraEn = _englishName(nakshatra);
    final nakshatraHi =
        _hindiName(nakshatra) ?? PanchangHindi.nakshatra(nakshatraEn);

    return PanchangDay(
      date: DateTime(date.year, date.month, date.day),
      tithiNameEn: tithiEn,
      tithiNameHi: tithiHi,
      tithiNumber: tithiNumber,
      paksha: _paksha(tithi, root),
      nakshatraEn: nakshatraEn,
      nakshatraHi: nakshatraHi,
      yogaEn: _englishName(yoga),
      yogaHi: _hindiName(yoga),
      karanaEn: _englishName(karana),
      karanaHi: _hindiName(karana),
      varaEn: _englishName(vara),
      varaHi: _hindiName(vara),
      sunrise:
          _clock(sun, const ['sunrise', 'rise', 'sun_rise']) ??
          _clock(root, const ['sunrise']),
      sunset:
          _clock(sun, const ['sunset', 'set', 'sun_set']) ??
          _clock(root, const ['sunset']),
      placeLabel: placeLabel,
    );
  }

  /// Maps a tithi name to 1–15 / 30 when the payload omits a number.
  static int? tithiNumberFromName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return null;
    }
    final blob = name.toLowerCase();
    if (blob.contains('purnima') || blob.contains('पूर्णिमा')) {
      return 15;
    }
    if (blob.contains('amavasya') || blob.contains('अमावस्या')) {
      return 30;
    }
    if (blob.contains('chaturdashi') || blob.contains('चतुर्दशी')) {
      return 14;
    }
    if (blob.contains('trayodashi') || blob.contains('त्रयोदशी')) {
      return 13;
    }
    if (blob.contains('dwadashi') ||
        blob.contains('duadashi') ||
        blob.contains('द्वादशी')) {
      return 12;
    }
    if (blob.contains('ekadashi') || blob.contains('एकादशी')) {
      return 11;
    }
    if (blob.contains('dashami') || blob.contains('दशमी')) {
      return 10;
    }
    if (blob.contains('navami') || blob.contains('नवमी')) {
      return 9;
    }
    if (blob.contains('ashtami') || blob.contains('अष्टमी')) {
      return 8;
    }
    if (blob.contains('saptami') || blob.contains('सप्तमी')) {
      return 7;
    }
    if (blob.contains('shashthi') ||
        blob.contains('sashti') ||
        blob.contains('षष्ठी')) {
      return 6;
    }
    if (blob.contains('panchami') || blob.contains('पंचमी')) {
      return 5;
    }
    if (blob.contains('chaturthi') || blob.contains('चतुर्थी')) {
      return 4;
    }
    if (blob.contains('tritiya') || blob.contains('तृतीया')) {
      return 3;
    }
    if (blob.contains('dwitiya') || blob.contains('द्वितीया')) {
      return 2;
    }
    if (blob.contains('pratipada') ||
        blob.contains('prathama') ||
        blob.contains('प्रतिपदा')) {
      return 1;
    }
    return null;
  }

  /// Navamsha returns each limb as a list of periods; the first is current.
  static dynamic _current(dynamic value) {
    if (value is List && value.isNotEmpty) {
      return value.first;
    }
    return value;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    if (value is List && value.isNotEmpty) {
      return _asMap(value.first);
    }
    return const {};
  }

  static dynamic _limb(Map<String, dynamic> output, List<String> keys) {
    for (final key in keys) {
      if (output.containsKey(key)) {
        return output[key];
      }
    }
    for (final nestedKey in const ['panchang', 'panchanga', 'advanced']) {
      final nested = output[nestedKey];
      if (nested is Map) {
        final map = Map<String, dynamic>.from(nested);
        for (final key in keys) {
          if (map.containsKey(key)) {
            return map[key];
          }
        }
      }
    }
    return null;
  }

  static String? _englishName(dynamic value) {
    final names = _names(value);
    return names.english ??
        (names.single != null && !_isDevanagari(names.single!)
            ? names.single
            : null);
  }

  static String? _hindiName(dynamic value) {
    final names = _names(value);
    return names.hindi ??
        (names.single != null && _isDevanagari(names.single!)
            ? names.single
            : null);
  }

  static ({String? english, String? hindi, String? single}) _names(
    dynamic value,
  ) {
    if (value == null) {
      return (english: null, hindi: null, single: null);
    }
    if (value is String && value.trim().isNotEmpty) {
      return (english: null, hindi: null, single: value.trim());
    }
    if (value is Map) {
      String? pick(List<String> keys) {
        for (final key in keys) {
          final candidate = value[key];
          if (candidate is String && candidate.trim().isNotEmpty) {
            return candidate.trim();
          }
        }
        return null;
      }

      return (
        english: pick(const ['name_en', 'nameEn', 'english', 'en']),
        hindi: pick(const ['name_hi', 'nameHi', 'hindi', 'hi']),
        single: pick(const ['name', 'tithi', 'nakshatra', 'yoga', 'karana']),
      );
    }
    return (english: null, hindi: null, single: null);
  }

  static int? _number(dynamic value, List<String> keys) {
    if (value is num) {
      return value.toInt();
    }
    if (value is Map) {
      for (final key in keys) {
        final candidate = value[key];
        if (candidate is num) {
          return candidate.toInt();
        }
        if (candidate is String) {
          return int.tryParse(candidate);
        }
      }
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static String? _paksha(dynamic tithi, Map<String, dynamic> output) {
    final fromTithi = tithi is Map
        ? (_englishName(tithi['paksha'] ?? tithi['paksha_name']) ??
              (tithi['paksha'] is String ? tithi['paksha'] as String : null))
        : null;
    final fromRoot = _englishName(output['paksha']) ??
        (output['paksha'] is String ? output['paksha'] as String : null);
    final combined =
        '${fromTithi ?? ''} ${fromRoot ?? ''} ${_englishName(tithi) ?? ''} ${_hindiName(tithi) ?? ''}'
            .toLowerCase();
    if (combined.contains('krishna') ||
        combined.contains('waning') ||
        combined.contains('bahula') ||
        combined.contains('कृष्ण')) {
      return 'krishna';
    }
    if (combined.contains('shukla') ||
        combined.contains('waxing') ||
        combined.contains('bright') ||
        combined.contains('शुक्ल')) {
      return 'shukla';
    }
    return fromTithi ?? fromRoot;
  }

  static String? _clock(dynamic value, List<String> keys) {
    if (value is String && value.contains(':')) {
      return _trimSeconds(value);
    }
    if (value is Map) {
      for (final key in keys) {
        final candidate = value[key];
        if (candidate is String && candidate.contains(':')) {
          return _trimSeconds(candidate);
        }
        if (candidate is Map) {
          final time =
              candidate['time'] ?? candidate['hhmm'] ?? candidate['value'];
          if (time is String && time.contains(':')) {
            return _trimSeconds(time);
          }
        }
      }
    }
    return null;
  }

  static String _trimSeconds(String raw) {
    final parts = raw.trim().split(RegExp(r'[ T]')).last.split(':');
    if (parts.length >= 2) {
      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = parts[1].padLeft(2, '0');
      return '$hour:$minute';
    }
    return raw.trim();
  }

  static bool _isDevanagari(String value) =>
      RegExp(r'[\u0900-\u097F]').hasMatch(value);
}
