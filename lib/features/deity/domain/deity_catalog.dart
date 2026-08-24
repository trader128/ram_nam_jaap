import 'package:flutter/material.dart';

import 'deity_pack.dart';

/// Static registry of every deity available in the app.
///
/// To add a deity, append a [DeityPack] here — no other code changes required.
abstract final class DeityCatalog {
  static const String defaultDeityId = 'ram';

  static const List<DeityPack> all = [
    DeityPack(
      id: 'ram',
      name: 'राम',
      transliteration: 'Ram',
      mantra: 'श्री राम जय राम जय जय राम',
      meaning: 'राम नाम जप से शांति और पवित्रता आती है।',
      primary: Color(0xFFD4AF37),
      accent: Color(0xFFE07A1F),
      backdropTop: Color(0xFF1A1206),
      backdropBottom: Color(0xFF130C04),
    ),
    DeityPack(
      id: 'krishna',
      name: 'कृष्ण',
      transliteration: 'Krishna',
      mantra: 'हरे कृष्ण हरे कृष्ण कृष्ण कृष्ण हरे हरे',
      meaning: 'कृष्ण नाम से प्रेम और भक्ति जागती है।',
      primary: Color(0xFF3FB7C9),
      accent: Color(0xFFF6C66B),
      backdropTop: Color(0xFF06151C),
      backdropBottom: Color(0xFF041016),
    ),
    DeityPack(
      id: 'mahadev',
      name: 'महादेव',
      transliteration: 'Mahadev',
      mantra: 'ॐ नमः शिवाय',
      meaning: 'मैं शिव को प्रणाम करता हूँ, जो परम चेतना हैं।',
      primary: Color(0xFF9DB6DA),
      accent: Color(0xFFBFE3EA),
      backdropTop: Color(0xFF0C1018),
      backdropBottom: Color(0xFF080A11),
    ),
    DeityPack(
      id: 'ganesh',
      name: 'गणेश',
      transliteration: 'Ganesh',
      mantra: 'ॐ गं गणपतये नमः',
      meaning: 'मैं विघ्नहर्ता गणेश को प्रणाम करता हूँ।',
      primary: Color(0xFFEB6A3A),
      accent: Color(0xFFF2A93B),
      backdropTop: Color(0xFF1B0D07),
      backdropBottom: Color(0xFF140904),
    ),
    DeityPack(
      id: 'durga',
      name: 'दुर्गा',
      transliteration: 'Durga',
      mantra: 'ॐ दुं दुर्गायै नमः',
      meaning: 'मैं दुःखहर्ता दुर्गा को प्रणाम करता हूँ।',
      primary: Color(0xFFE03A50),
      accent: Color(0xFFF0A500),
      backdropTop: Color(0xFF1A070C),
      backdropBottom: Color(0xFF130507),
    ),
    DeityPack(
      id: 'hanuman',
      name: 'हनुमान',
      transliteration: 'Hanuman',
      mantra: 'ॐ हं हनुमते नमः',
      meaning: 'मैं बल और भक्ति के प्रतीक हनुमान को प्रणाम करता हूँ।',
      primary: Color(0xFFF15A24),
      accent: Color(0xFFF7B733),
      backdropTop: Color(0xFF1B0C05),
      backdropBottom: Color(0xFF140803),
    ),
  ];

  static DeityPack get fallback => byId(defaultDeityId);

  static DeityPack byId(String? id) {
    return all.firstWhere((deity) => deity.id == id, orElse: () => all.first);
  }
}
