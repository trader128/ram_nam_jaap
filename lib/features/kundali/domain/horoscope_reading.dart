class YogaLine {
  const YogaLine({required this.name, required this.description});

  final String name;
  final String description;
}

class HoroscopeReading {
  const HoroscopeReading({
    required this.placeLabel,
    required this.datetime,
    this.nakshatra,
    this.nakshatraPada,
    this.nakshatraLord,
    this.chandraRasi,
    this.sooryaRasi,
    this.zodiac,
    this.mangalHasDosha = false,
    this.mangalDescription,
    this.yogas = const [],
  });

  final String placeLabel;
  final String datetime;
  final String? nakshatra;
  final int? nakshatraPada;
  final String? nakshatraLord;
  final String? chandraRasi;
  final String? sooryaRasi;
  final String? zodiac;
  final bool mangalHasDosha;
  final String? mangalDescription;
  final List<YogaLine> yogas;

  bool get hasLimbs =>
      (nakshatra != null && nakshatra!.isNotEmpty) ||
      (chandraRasi != null && chandraRasi!.isNotEmpty);

  Map<String, dynamic> toMap() {
    return {
      'placeLabel': placeLabel,
      'datetime': datetime,
      'nakshatra': nakshatra,
      'nakshatraPada': nakshatraPada,
      'nakshatraLord': nakshatraLord,
      'chandraRasi': chandraRasi,
      'sooryaRasi': sooryaRasi,
      'zodiac': zodiac,
      'mangalHasDosha': mangalHasDosha,
      'mangalDescription': mangalDescription,
      'yogas': [
        for (final yoga in yogas)
          {'name': yoga.name, 'description': yoga.description},
      ],
    };
  }

  static HoroscopeReading? fromMap(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(raw);
    final yogasRaw = map['yogas'];
    final yogas = <YogaLine>[];
    if (yogasRaw is List) {
      for (final item in yogasRaw) {
        if (item is! Map) {
          continue;
        }
        yogas.add(
          YogaLine(
            name: item['name'] as String? ?? '',
            description: item['description'] as String? ?? '',
          ),
        );
      }
    }
    final mangal = _asMap(map['mangalDosha']);
    return HoroscopeReading(
      placeLabel: map['placeLabel'] as String? ?? '',
      datetime: map['datetime'] as String? ?? '',
      nakshatra: map['nakshatra'] as String?,
      nakshatraPada: _int(map['nakshatraPada']),
      nakshatraLord: map['nakshatraLord'] as String?,
      chandraRasi: map['chandraRasi'] as String?,
      sooryaRasi: map['sooryaRasi'] as String?,
      zodiac: map['zodiac'] as String?,
      mangalHasDosha:
          map['mangalHasDosha'] == true || mangal['hasDosha'] == true,
      mangalDescription:
          map['mangalDescription'] as String? ??
          mangal['description'] as String?,
      yogas: yogas,
    );
  }

  /// Accepts the sanitized Cloud Function payload (camelCase) or a raw
  /// Prokerala kundli `data` object.
  static HoroscopeReading fromVendor({
    required Map<String, dynamic> data,
    String placeLabel = '',
    String datetime = '',
  }) {
    if (data.containsKey('nakshatra') && !data.containsKey('nakshatra_details')) {
      return fromMap(data) ??
          HoroscopeReading(placeLabel: placeLabel, datetime: datetime);
    }
    final nak = _asMap(data['nakshatra_details']);
    final mangal = _asMap(data['mangal_dosha']);
    final yogas = <YogaLine>[];
    final yogaRaw = data['yoga_details'];
    if (yogaRaw is List) {
      for (final item in yogaRaw) {
        final row = _asMap(item);
        yogas.add(
          YogaLine(
            name: row['name'] as String? ?? '',
            description: row['description'] as String? ?? '',
          ),
        );
      }
    }
    return HoroscopeReading(
      placeLabel: placeLabel,
      datetime: datetime,
      nakshatra: _named(nak['nakshatra']),
      nakshatraPada: _int(_asMap(nak['nakshatra'])['pada']),
      nakshatraLord: _named(_asMap(nak['nakshatra'])['lord']),
      chandraRasi: _named(nak['chandra_rasi']),
      sooryaRasi: _named(nak['soorya_rasi']),
      zodiac: _named(nak['zodiac']),
      mangalHasDosha: mangal['has_dosha'] == true,
      mangalDescription: mangal['description'] as String?,
      yogas: yogas,
    );
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return {};
  }

  static String? _named(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return value;
    }
    if (value is Map) {
      return value['name_hi'] as String? ??
          value['name'] as String? ??
          value['vedic_name'] as String?;
    }
    return null;
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
}

class HoroscopeChatTurn {
  const HoroscopeChatTurn({
    required this.question,
    required this.answer,
    this.title,
    this.topic,
    this.at,
  });

  final String question;
  final String answer;
  final String? title;
  final String? topic;
  final DateTime? at;

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'title': title,
      'topic': topic,
      'at': at?.toIso8601String(),
    };
  }

  static HoroscopeChatTurn? fromMap(dynamic raw) {
    if (raw is! Map) {
      return null;
    }
    final map = Map<String, dynamic>.from(raw);
    final question = map['question'] as String? ?? '';
    final answer = map['answer'] as String? ?? '';
    if (question.isEmpty && answer.isEmpty) {
      return null;
    }
    return HoroscopeChatTurn(
      question: question,
      answer: answer,
      title: map['title'] as String?,
      topic: map['topic'] as String?,
      at: DateTime.tryParse(map['at'] as String? ?? ''),
    );
  }
}
