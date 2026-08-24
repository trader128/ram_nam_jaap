import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/hive_keys.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/storage/hive_storage.dart';
import '../domain/bhajan.dart';

/// Loads bhajan texts, bundled first and cloud second.
///
/// Same two-layer shape as the vrat content: the bundled asset works offline
/// and is the floor, and the Firestore `bhajans` collection is merged over it by
/// id. The overlay is what carries `audioUrl`, so a recording only ever plays
/// once you have added it deliberately for a track you hold rights to.
class BhajanRepository {
  static const String _assetPath = 'assets/content/bhajans.json';

  Future<List<Bhajan>> loadBundled() async {
    final raw = await rootBundle.loadString(_assetPath);
    return _parse(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<List<Bhajan>> load() async {
    final bundled = await loadBundled();
    final overlay = _readCachedOverlay();
    if (overlay.isEmpty) {
      return bundled;
    }

    final byId = {for (final bhajan in bundled) bhajan.id: bhajan};
    for (final entry in overlay.entries) {
      final existing = byId[entry.key];
      final merged = <String, dynamic>{
        if (existing != null) ...existing.toMap(),
        ...entry.value,
      };
      byId[entry.key] = Bhajan.fromMap(entry.key, merged);
    }
    return byId.values.toList();
  }

  Future<void> refreshRemote() async {
    if (!FirebaseBootstrap.isAvailable) {
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('bhajans')
          .get();
      final overlay = <String, Map<String, dynamic>>{
        for (final document in snapshot.docs) document.id: document.data(),
      };
      await HiveStorage.settingsBox.put(
        HiveKeys.bhajanContentCache,
        jsonEncode(overlay),
      );
    } on Object catch (error) {
      debugPrint('Bhajan refresh failed, using bundled content: $error');
    }
  }

  Map<String, Map<String, dynamic>> _readCachedOverlay() {
    final raw =
        HiveStorage.settingsBox.get(HiveKeys.bhajanContentCache) as String?;
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

  static List<Bhajan> _parse(Map<String, dynamic> json) {
    final entries = json['bhajans'];
    if (entries is! List) {
      return const [];
    }

    return entries
        .whereType<Map<String, dynamic>>()
        .map((entry) => Bhajan.fromMap(entry['id'] as String, entry))
        .toList();
  }
}
