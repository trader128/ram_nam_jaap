import 'panchang_hindi.dart';

/// One civil day's panchang, already flattened for the calendar.
class PanchangDay {
  const PanchangDay({
    required this.date,
    this.tithiNameEn,
    this.tithiNameHi,
    this.tithiNumber,
    this.paksha,
    this.nakshatraEn,
    this.nakshatraHi,
    this.yogaEn,
    this.yogaHi,
    this.karanaEn,
    this.karanaHi,
    this.varaEn,
    this.varaHi,
    this.sunrise,
    this.sunset,
    this.placeLabel = 'उज्जैन',
  });

  final DateTime date;
  final String? tithiNameEn;
  final String? tithiNameHi;
  final int? tithiNumber;
  final String? paksha;
  final String? nakshatraEn;
  final String? nakshatraHi;
  final String? yogaEn;
  final String? yogaHi;
  final String? karanaEn;
  final String? karanaHi;
  final String? varaEn;
  final String? varaHi;
  final String? sunrise;
  final String? sunset;
  final String placeLabel;

  String get dateKey =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  bool get hasLimbs =>
      tithiNameEn != null ||
      tithiNameHi != null ||
      nakshatraEn != null ||
      nakshatraHi != null ||
      sunrise != null;

  String? tithi({required bool hindi}) {
    final mappedHi = tithiNameHi ??
        PanchangHindi.tithi(number: tithiNumber, englishName: tithiNameEn);
    final name = hindi
        ? (mappedHi ?? tithiNameEn)
        : (tithiNameEn ?? mappedHi);
    if (name == null || name.isEmpty) {
      return null;
    }
    final prefix = PanchangHindi.paksha(hindi: hindi, paksha: paksha);
    if (prefix.isEmpty) {
      return name;
    }
    final blob = name.toLowerCase();
    if (blob.contains(prefix.toLowerCase()) ||
        blob.contains('shukla') ||
        blob.contains('krishna') ||
        blob.contains('शुक्ल') ||
        blob.contains('कृष्ण')) {
      return name;
    }
    return '$prefix $name';
  }

  String? nakshatra({required bool hindi}) {
    final mappedHi =
        nakshatraHi ?? PanchangHindi.nakshatra(nakshatraEn);
    return hindi
        ? (mappedHi ?? nakshatraEn)
        : (nakshatraEn ?? mappedHi);
  }

  String? yoga({required bool hindi}) =>
      hindi ? (yogaHi ?? yogaEn) : (yogaEn ?? yogaHi);

  String? karana({required bool hindi}) =>
      hindi ? (karanaHi ?? karanaEn) : (karanaEn ?? karanaHi);

  Map<String, dynamic> toMap() {
    return {
      'date': dateKey,
      'tithiNameEn': tithiNameEn,
      'tithiNameHi': tithiNameHi,
      'tithiNumber': tithiNumber,
      'paksha': paksha,
      'nakshatraEn': nakshatraEn,
      'nakshatraHi': nakshatraHi,
      'yogaEn': yogaEn,
      'yogaHi': yogaHi,
      'karanaEn': karanaEn,
      'karanaHi': karanaHi,
      'varaEn': varaEn,
      'varaHi': varaHi,
      'sunrise': sunrise,
      'sunset': sunset,
      'placeLabel': placeLabel,
    };
  }

  factory PanchangDay.fromMap(Map<String, dynamic> map) {
    final key = map['date'] as String? ?? '';
    final parsed = DateTime.tryParse(key) ?? DateTime.now();
    return PanchangDay(
      date: DateTime(parsed.year, parsed.month, parsed.day),
      tithiNameEn: map['tithiNameEn'] as String?,
      tithiNameHi: map['tithiNameHi'] as String?,
      tithiNumber: (map['tithiNumber'] as num?)?.toInt(),
      paksha: map['paksha'] as String?,
      nakshatraEn: map['nakshatraEn'] as String?,
      nakshatraHi: map['nakshatraHi'] as String?,
      yogaEn: map['yogaEn'] as String?,
      yogaHi: map['yogaHi'] as String?,
      karanaEn: map['karanaEn'] as String?,
      karanaHi: map['karanaHi'] as String?,
      varaEn: map['varaEn'] as String?,
      varaHi: map['varaHi'] as String?,
      sunrise: map['sunrise'] as String?,
      sunset: map['sunset'] as String?,
      placeLabel: map['placeLabel'] as String? ?? 'उज्जैन',
    );
  }
}
