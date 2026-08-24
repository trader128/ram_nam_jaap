/// Devanagari labels for panchang limbs when the vendor only sends English.
abstract final class PanchangHindi {
  static const Map<int, String> tithiByNumber = {
    1: 'प्रतिपदा',
    2: 'द्वितीया',
    3: 'तृतीया',
    4: 'चतुर्थी',
    5: 'पंचमी',
    6: 'षष्ठी',
    7: 'सप्तमी',
    8: 'अष्टमी',
    9: 'नवमी',
    10: 'दशमी',
    11: 'एकादशी',
    12: 'द्वादशी',
    13: 'त्रयोदशी',
    14: 'चतुर्दशी',
    15: 'पूर्णिमा',
    0: 'अमावस्या',
    30: 'अमावस्या',
  };

  static const Map<String, String> nakshatraByKey = {
    'ashwini': 'अश्विनी',
    'aswini': 'अश्विनी',
    'bharani': 'भरणी',
    'krittika': 'कृत्तिका',
    'krithika': 'कृत्तिका',
    'rohini': 'रोहिणी',
    'mrigashira': 'मृगशिरा',
    'mrigashirsha': 'मृगशिरा',
    'ardra': 'आर्द्रा',
    'punarvasu': 'पुनर्वसु',
    'pushya': 'पुष्य',
    'pushyami': 'पुष्य',
    'ashlesha': 'आश्लेषा',
    'aslesha': 'आश्लेषा',
    'magha': 'मघा',
    'purvaphalguni': 'पूर्व फाल्गुनी',
    'poorvaphalguni': 'पूर्व फाल्गुनी',
    'uttaraphalguni': 'उत्तर फाल्गुनी',
    'hasta': 'हस्त',
    'chitra': 'चित्रा',
    'chithira': 'चित्रा',
    'swati': 'स्वाती',
    'vishakha': 'विशाखा',
    'visakha': 'विशाखा',
    'anuradha': 'अनुराधा',
    'jyeshtha': 'ज्येष्ठा',
    'jyeshta': 'ज्येष्ठा',
    'mula': 'मूल',
    'moola': 'मूल',
    'purvaashadha': 'पूर्वाषाढ़ा',
    'poorvaashadha': 'पूर्वाषाढ़ा',
    'purvashadha': 'पूर्वाषाढ़ा',
    'uttaraashadha': 'उत्तराषाढ़ा',
    'uttarashadha': 'उत्तराषाढ़ा',
    'shravana': 'श्रवण',
    'sravana': 'श्रवण',
    'dhanishta': 'धनिष्ठा',
    'dhanishtha': 'धनिष्ठा',
    'shatabhisha': 'शतभिषा',
    'satabhisha': 'शतभिषा',
    'purvabhadrapada': 'पूर्व भाद्रपद',
    'poorvabhadrapada': 'पूर्व भाद्रपद',
    'uttarabhadrapada': 'उत्तर भाद्रपद',
    'revati': 'रेवती',
  };

  static String? tithi({int? number, String? englishName}) {
    if (number != null && tithiByNumber.containsKey(number)) {
      return tithiByNumber[number];
    }
    final key = _key(englishName);
    if (key.contains('purnima')) {
      return 'पूर्णिमा';
    }
    if (key.contains('amavasya')) {
      return 'अमावस्या';
    }
    if (key.contains('ekadashi')) {
      return 'एकादशी';
    }
    if (key.contains('dwadashi') || key.contains('duadashi')) {
      return 'द्वादशी';
    }
    if (key.contains('trayodashi')) {
      return 'त्रयोदशी';
    }
    if (key.contains('chaturdashi')) {
      return 'चतुर्दशी';
    }
    if (key.contains('chaturthi')) {
      return 'चतुर्थी';
    }
    return null;
  }

  static String? nakshatra(String? englishName) {
    final key = _key(englishName);
    if (key.isEmpty) {
      return null;
    }
    return nakshatraByKey[key];
  }

  static String paksha({required bool hindi, String? paksha}) {
    final value = (paksha ?? '').toLowerCase();
    if (value == 'shukla') {
      return hindi ? 'शुक्ल' : 'Shukla';
    }
    if (value == 'krishna') {
      return hindi ? 'कृष्ण' : 'Krishna';
    }
    return '';
  }

  static String _key(String? raw) {
    if (raw == null) {
      return '';
    }
    return raw.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
  }
}
