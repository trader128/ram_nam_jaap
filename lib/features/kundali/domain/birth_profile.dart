class BirthPlace {
  const BirthPlace({
    required this.id,
    required this.nameEn,
    required this.nameHi,
    required this.latitude,
    required this.longitude,
    this.timezone = 5.5,
  });

  final String id;
  final String nameEn;
  final String nameHi;
  final double latitude;
  final double longitude;
  final double timezone;

  String name({required bool hindi}) => hindi ? nameHi : nameEn;
}

/// Indian cities with coordinates. Place search stays off the device —
/// Prokerala still receives lat/lng from the backend only.
abstract final class BirthPlaceCatalog {
  static const List<BirthPlace> all = [
    BirthPlace(
      id: 'ujjain',
      nameEn: 'Ujjain',
      nameHi: 'उज्जैन',
      latitude: 23.1765,
      longitude: 75.7885,
    ),
    BirthPlace(
      id: 'varanasi',
      nameEn: 'Varanasi',
      nameHi: 'वाराणसी',
      latitude: 25.3176,
      longitude: 82.9739,
    ),
    BirthPlace(
      id: 'delhi',
      nameEn: 'Delhi',
      nameHi: 'दिल्ली',
      latitude: 28.6139,
      longitude: 77.209,
    ),
    BirthPlace(
      id: 'mumbai',
      nameEn: 'Mumbai',
      nameHi: 'मुंबई',
      latitude: 19.076,
      longitude: 72.8777,
    ),
    BirthPlace(
      id: 'kolkata',
      nameEn: 'Kolkata',
      nameHi: 'कोलकाता',
      latitude: 22.5726,
      longitude: 88.3639,
    ),
    BirthPlace(
      id: 'chennai',
      nameEn: 'Chennai',
      nameHi: 'चेन्नई',
      latitude: 13.0827,
      longitude: 80.2707,
    ),
    BirthPlace(
      id: 'bengaluru',
      nameEn: 'Bengaluru',
      nameHi: 'बेंगलुरु',
      latitude: 12.9716,
      longitude: 77.5946,
    ),
    BirthPlace(
      id: 'hyderabad',
      nameEn: 'Hyderabad',
      nameHi: 'हैदराबाद',
      latitude: 17.385,
      longitude: 78.4867,
    ),
    BirthPlace(
      id: 'pune',
      nameEn: 'Pune',
      nameHi: 'पुणे',
      latitude: 18.5204,
      longitude: 73.8567,
    ),
    BirthPlace(
      id: 'jaipur',
      nameEn: 'Jaipur',
      nameHi: 'जयपुर',
      latitude: 26.9124,
      longitude: 75.7873,
    ),
    BirthPlace(
      id: 'lucknow',
      nameEn: 'Lucknow',
      nameHi: 'लखनऊ',
      latitude: 26.8467,
      longitude: 80.9462,
    ),
    BirthPlace(
      id: 'ahmedabad',
      nameEn: 'Ahmedabad',
      nameHi: 'अहमदाबाद',
      latitude: 23.0225,
      longitude: 72.5714,
    ),
  ];

  static BirthPlace byId(String? id) {
    return all.where((place) => place.id == id).firstOrNull ?? all.first;
  }
}

class BirthProfile {
  const BirthProfile({
    required this.year,
    required this.month,
    required this.date,
    required this.hours,
    required this.minutes,
    required this.latitude,
    required this.longitude,
    required this.placeId,
    required this.placeLabel,
    this.timezone = 5.5,
  });

  final int year;
  final int month;
  final int date;
  final int hours;
  final int minutes;
  final double latitude;
  final double longitude;
  final double timezone;
  final String placeId;
  final String placeLabel;

  DateTime get localDateTime => DateTime(year, month, date, hours, minutes);

  /// ISO-8601 with the real offset. The backend encodes `+` before calling
  /// Prokerala.
  String toIso8601() {
    final offsetMinutes = (timezone * 60).round();
    final sign = offsetMinutes >= 0 ? '+' : '-';
    final abs = offsetMinutes.abs();
    final oh = (abs ~/ 60).toString().padLeft(2, '0');
    final om = (abs % 60).toString().padLeft(2, '0');
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${date.toString().padLeft(2, '0')}T'
        '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:00'
        '$sign$oh:$om';
  }

  Map<String, dynamic> toGatewayMap({required bool hindi}) {
    return {
      'year': year,
      'month': month,
      'date': date,
      'hours': hours,
      'minutes': minutes,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'placeLabel': placeLabel,
      'language': hindi ? 'hi' : 'en',
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'year': year,
      'month': month,
      'date': date,
      'hours': hours,
      'minutes': minutes,
      'latitude': latitude,
      'longitude': longitude,
      'timezone': timezone,
      'placeId': placeId,
      'placeLabel': placeLabel,
    };
  }

  static BirthProfile? fromMap(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(raw);
    final year = _int(map['year']);
    final month = _int(map['month']);
    final date = _int(map['date']);
    final hours = _int(map['hours']);
    final minutes = _int(map['minutes']);
    final latitude = _double(map['latitude']);
    final longitude = _double(map['longitude']);
    if (year == null ||
        month == null ||
        date == null ||
        hours == null ||
        minutes == null ||
        latitude == null ||
        longitude == null) {
      return null;
    }
    return BirthProfile(
      year: year,
      month: month,
      date: date,
      hours: hours,
      minutes: minutes,
      latitude: latitude,
      longitude: longitude,
      timezone: _double(map['timezone']) ?? 5.5,
      placeId: map['placeId'] as String? ?? 'ujjain',
      placeLabel: map['placeLabel'] as String? ?? 'Ujjain',
    );
  }

  static int? _int(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  static double? _double(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '');
  }
}
