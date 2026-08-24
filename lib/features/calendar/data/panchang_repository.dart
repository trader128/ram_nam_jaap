import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/constants/hive_keys.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../../core/helpers/date_helper.dart';
import '../../../core/storage/hive_storage.dart';
import '../domain/panchang_day.dart';
import 'navamsha_panchang_parser.dart';

/// Loads panchang days written by the Navamsha sync tool.
///
/// The API key never lives in the app. A trusted machine calls Navamsha and
/// writes `panchang/{yyyy-MM-dd}` in Firestore; this repository only reads.
class PanchangRepository {
  static const int horizonDays = 45;

  Future<List<PanchangDay>> load() async {
    final cached = _readCached();
    if (cached.isNotEmpty) {
      return cached;
    }
    await refreshRemote();
    return _readCached();
  }

  Future<void> refreshRemote() async {
    if (!FirebaseBootstrap.isAvailable) {
      return;
    }

    try {
      final startKey = DateHelper.toDateKey(DateHelper.today());
      final collection = FirebaseFirestore.instance.collection('panchang');
      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await collection
            .where(FieldPath.documentId, isGreaterThanOrEqualTo: startKey)
            .limit(horizonDays)
            .get();
      } on Object {
        snapshot = await collection
            .where('date', isGreaterThanOrEqualTo: startKey)
            .limit(horizonDays)
            .get();
      }
      final days = snapshot.docs
          .map((document) => _fromDocument(document.data()))
          .whereType<PanchangDay>()
          .where((day) => day.hasLimbs)
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      if (days.isEmpty) {
        // An empty remote set usually means the sync tool has not run yet.
        // Keep whatever Hive already has rather than wiping a good cache.
        return;
      }
      await HiveStorage.settingsBox.put(
        HiveKeys.panchangCache,
        jsonEncode([for (final day in days) day.toMap()]),
      );
    } on Object catch (error) {
      debugPrint('Panchang refresh failed, using cache: $error');
    }
  }

  List<PanchangDay> _readCached() {
    final raw = HiveStorage.settingsBox.get(HiveKeys.panchangCache) as String?;
    if (raw == null || raw.isEmpty) {
      return const [];
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map((entry) => PanchangDay.fromMap(Map<String, dynamic>.from(entry)))
          .toList();
    } on Object {
      return const [];
    }
  }

  PanchangDay? _fromDocument(Map<String, dynamic> data) {
    final normalized = _jsonish(data);
    if (normalized is! Map<String, dynamic>) {
      return null;
    }
    if (normalized['tithiNameEn'] != null ||
        normalized['tithiNumber'] != null) {
      return PanchangDay.fromMap(normalized);
    }
    final dateKey = normalized['date'] as String?;
    final date =
        DateHelper.fromDateKey(dateKey) ?? DateTime.tryParse(dateKey ?? '');
    if (date == null) {
      return null;
    }
    final output = normalized['output'] ?? normalized;
    return NavamshaPanchangParser.parse(
      date: date,
      output: output,
      placeLabel: normalized['placeLabel'] as String? ?? 'उज्जैन',
    );
  }

  static dynamic _jsonish(dynamic value) {
    if (value is Map) {
      return <String, dynamic>{
        for (final entry in value.entries)
          entry.key.toString(): _jsonish(entry.value),
      };
    }
    if (value is List) {
      return [for (final entry in value) _jsonish(entry)];
    }
    return value;
  }
}
