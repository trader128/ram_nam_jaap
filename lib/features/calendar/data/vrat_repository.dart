import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/hive_keys.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/storage/hive_storage.dart';
import '../domain/vrat.dart';

/// Loads vrat content, bundled first and cloud second.
///
/// The bundled asset always works offline and is the floor. The Firestore
/// `vrats` collection is layered on top by id, which is what lets panchang
/// dates — the part that cannot be computed and must not be guessed — be
/// corrected or extended without shipping an app update. Remote content is
/// cached in Hive so the second launch is instant and works offline too.
class VratRepository {
  static const String _assetPath = 'assets/content/vrats.json';

  Future<List<Vrat>> loadBundled() async {
    final raw = await rootBundle.loadString(_assetPath);
    return _parse(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Bundled content merged with the cached remote overlay. Never throws.
  Future<List<Vrat>> load() async {
    final bundled = await loadBundled();
    final overlay = _readCachedOverlay();
    if (overlay.isEmpty) {
      return bundled;
    }
    return _merge(bundled, overlay);
  }

  /// Fetches the remote overlay and caches it. Safe to call and ignore.
  Future<void> refreshRemote() async {
    if (!FirebaseBootstrap.isAvailable) {
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('vrats')
          .get();
      final overlay = <String, Map<String, dynamic>>{
        for (final document in snapshot.docs) document.id: document.data(),
      };
      await HiveStorage.settingsBox.put(
        HiveKeys.vratContentCache,
        jsonEncode(overlay),
      );
    } on Object catch (error) {
      debugPrint('Vrat content refresh failed, using bundled content: $error');
    }
  }

  Map<String, Map<String, dynamic>> _readCachedOverlay() {
    final raw =
        HiveStorage.settingsBox.get(HiveKeys.vratContentCache) as String?;
    if (raw == null || raw.isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final entry in decoded.entries)
          entry.key: Map<String, dynamic>.from(entry.value as Map),
      };
    } on Object {
      return const {};
    }
  }

  List<Vrat> _merge(
    List<Vrat> bundled,
    Map<String, Map<String, dynamic>> overlay,
  ) {
    final byId = {for (final vrat in bundled) vrat.id: vrat};

    for (final entry in overlay.entries) {
      final existing = byId[entry.key];
      // Remote entries carry only the fields being corrected, so fall back to
      // the bundled copy for anything the overlay leaves out.
      final merged = <String, dynamic>{
        if (existing != null) ..._toMap(existing),
        ...entry.value,
      };
      byId[entry.key] = Vrat.fromMap(entry.key, merged);
    }

    return byId.values.toList();
  }

  Map<String, dynamic> _toMap(Vrat vrat) {
    return {
      'kind': vrat.kind.name,
      'nameEn': vrat.nameEn,
      'nameHi': vrat.nameHi,
      'date': vrat.date?.toIso8601String(),
      'weekday': vrat.weekday,
      'deityId': vrat.deityId,
      'summaryEn': vrat.summaryEn,
      'summaryHi': vrat.summaryHi,
      'kathaEn': vrat.kathaEn,
      'kathaHi': vrat.kathaHi,
      'vidhiEn': vrat.vidhiEn,
      'vidhiHi': vrat.vidhiHi,
      'muhuratEn': vrat.muhuratEn,
      'muhuratHi': vrat.muhuratHi,
      'isMajor': vrat.isMajor,
    };
  }

  static List<Vrat> _parse(Map<String, dynamic> json) {
    final entries = json['vrats'];
    if (entries is! List) {
      return const [];
    }

    return entries
        .whereType<Map<String, dynamic>>()
        .map((entry) => Vrat.fromMap(entry['id'] as String, entry))
        .toList();
  }
}
