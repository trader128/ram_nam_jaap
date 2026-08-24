enum BhajanCategory { chalisa, aarti, bhajan, stotra, mantra }

/// One line or couplet of a devotional text.
class BhajanVerse {
  const BhajanVerse({required this.devanagari, this.transliteration});

  final String devanagari;

  /// Roman transliteration, so someone who cannot read Devanagari can still
  /// sing along. Optional, because a half-guessed transliteration is worse
  /// than none.
  final String? transliteration;

  static BhajanVerse fromMap(Map<String, dynamic> map) {
    return BhajanVerse(
      devanagari: map['hi'] as String? ?? '',
      transliteration: map['en'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'hi': devanagari,
    if (transliteration != null) 'en': transliteration,
  };
}

class Bhajan {
  const Bhajan({
    required this.id,
    required this.category,
    required this.titleEn,
    required this.titleHi,
    this.deityId,
    this.attribution,
    this.aboutEn,
    this.aboutHi,
    this.verses = const [],
    this.audioUrl,
    this.audioAsset,
  });

  final String id;
  final BhajanCategory category;
  final String titleEn;
  final String titleHi;
  final String? deityId;

  /// Author and period, which is also the licensing record. Every bundled text
  /// is old enough to be public domain, and this field is where that is stated.
  final String? attribution;

  final String? aboutEn;
  final String? aboutHi;
  final List<BhajanVerse> verses;

  /// Remote recording, supplied through Firestore. Left null for everything
  /// bundled: no commercial devotional recording ships in this app, because
  /// almost all of them are label-owned.
  final String? audioUrl;

  /// A recording bundled in the app, if one is ever commissioned outright.
  final String? audioAsset;

  bool get hasAudio => audioUrl != null || audioAsset != null;

  bool get hasTransliteration =>
      verses.any((verse) => verse.transliteration != null);

  String title({required bool hindi}) => hindi ? titleHi : titleEn;

  String? about({required bool hindi}) => hindi ? aboutHi : aboutEn;

  static Bhajan fromMap(String id, Map<String, dynamic> map) {
    return Bhajan(
      id: id,
      category: BhajanCategory.values.firstWhere(
        (value) => value.name == map['category'],
        orElse: () => BhajanCategory.bhajan,
      ),
      titleEn: map['titleEn'] as String? ?? id,
      titleHi: map['titleHi'] as String? ?? map['titleEn'] as String? ?? id,
      deityId: map['deityId'] as String?,
      attribution: map['attribution'] as String?,
      aboutEn: map['aboutEn'] as String?,
      aboutHi: map['aboutHi'] as String?,
      verses: switch (map['verses']) {
        final List entries => entries
            .whereType<Map>()
            .map(
              (entry) => BhajanVerse.fromMap(Map<String, dynamic>.from(entry)),
            )
            .toList(),
        _ => const [],
      },
      audioUrl: map['audioUrl'] as String?,
      audioAsset: map['audioAsset'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'category': category.name,
    'titleEn': titleEn,
    'titleHi': titleHi,
    'deityId': deityId,
    'attribution': attribution,
    'aboutEn': aboutEn,
    'aboutHi': aboutHi,
    'verses': verses.map((verse) => verse.toMap()).toList(),
    'audioUrl': audioUrl,
    'audioAsset': audioAsset,
  };
}
