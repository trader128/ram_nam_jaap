/// How a vrat's date is determined, which decides how much we can trust it.
enum VratKind {
  /// Falls on a fixed weekday every week — computed locally and always correct.
  weekly,

  /// Tied to a lunar tithi (Ekadashi, Purnima, Amavasya, Pradosh, Chaturthi).
  /// Dates must come from an authoritative panchang; they cannot be derived
  /// from the Gregorian calendar.
  tithi,

  /// A dated festival, also panchang-derived for most Hindu festivals.
  festival,
}

class Vrat {
  const Vrat({
    required this.id,
    required this.kind,
    required this.nameEn,
    required this.nameHi,
    this.date,
    this.weekday,
    this.deityId,
    this.summaryEn,
    this.summaryHi,
    this.kathaEn,
    this.kathaHi,
    this.vidhiEn = const [],
    this.vidhiHi = const [],
    this.muhuratEn,
    this.muhuratHi,
    this.isMajor = false,
  });

  final String id;
  final VratKind kind;
  final String nameEn;
  final String nameHi;

  /// Set for [VratKind.tithi] and [VratKind.festival]; null for weekly vrats,
  /// which are resolved against whichever week is being displayed.
  final DateTime? date;

  /// 1 = Monday … 7 = Sunday, matching [DateTime.weekday]. Weekly vrats only.
  final int? weekday;

  /// Links the vrat back to a deity in the catalog, so the calendar can offer
  /// "chant this naam today" and feed the habit the whole app is built on.
  final String? deityId;

  final String? summaryEn;
  final String? summaryHi;
  final String? kathaEn;
  final String? kathaHi;
  final List<String> vidhiEn;
  final List<String> vidhiHi;
  final String? muhuratEn;
  final String? muhuratHi;
  final bool isMajor;

  String name({required bool hindi}) => hindi ? nameHi : nameEn;

  String? summary({required bool hindi}) => hindi ? summaryHi : summaryEn;

  String? katha({required bool hindi}) => hindi ? kathaHi : kathaEn;

  List<String> vidhi({required bool hindi}) => hindi ? vidhiHi : vidhiEn;

  String? muhurat({required bool hindi}) => hindi ? muhuratHi : muhuratEn;

  Vrat copyWith({
    String? id,
    DateTime? date,
    String? nameEn,
    String? nameHi,
  }) {
    return Vrat(
      id: id ?? this.id,
      kind: kind,
      nameEn: nameEn ?? this.nameEn,
      nameHi: nameHi ?? this.nameHi,
      date: date ?? this.date,
      weekday: weekday,
      deityId: deityId,
      summaryEn: summaryEn,
      summaryHi: summaryHi,
      kathaEn: kathaEn,
      kathaHi: kathaHi,
      vidhiEn: vidhiEn,
      vidhiHi: vidhiHi,
      muhuratEn: muhuratEn,
      muhuratHi: muhuratHi,
      isMajor: isMajor,
    );
  }

  /// Resolves this vrat to a concrete date on or after [from].
  ///
  /// Weekly vrats always resolve; tithi and festival vrats only resolve if
  /// their stored date has not already passed.
  DateTime? occurrenceOnOrAfter(DateTime from) {
    final start = DateTime(from.year, from.month, from.day);

    if (kind == VratKind.weekly) {
      final target = weekday;
      if (target == null) {
        return null;
      }
      final delta = (target - start.weekday + 7) % 7;
      return start.add(Duration(days: delta));
    }

    final stored = date;
    if (stored == null) {
      return null;
    }
    final normalized = DateTime(stored.year, stored.month, stored.day);
    return normalized.isBefore(start) ? null : normalized;
  }

  static Vrat fromMap(String id, Map<String, dynamic> map) {
    return Vrat(
      id: id,
      kind: VratKind.values.firstWhere(
        (value) => value.name == map['kind'],
        orElse: () => VratKind.festival,
      ),
      nameEn: map['nameEn'] as String? ?? id,
      nameHi: map['nameHi'] as String? ?? map['nameEn'] as String? ?? id,
      date: DateTime.tryParse(map['date'] as String? ?? ''),
      weekday: (map['weekday'] as num?)?.toInt(),
      deityId: map['deityId'] as String?,
      summaryEn: map['summaryEn'] as String?,
      summaryHi: map['summaryHi'] as String?,
      kathaEn: map['kathaEn'] as String?,
      kathaHi: map['kathaHi'] as String?,
      vidhiEn: _stringList(map['vidhiEn']),
      vidhiHi: _stringList(map['vidhiHi']),
      muhuratEn: map['muhuratEn'] as String?,
      muhuratHi: map['muhuratHi'] as String?,
      isMajor: map['isMajor'] as bool? ?? false,
    );
  }

  static List<String> _stringList(Object? value) {
    if (value is List) {
      return value.map((entry) => entry.toString()).toList();
    }
    return const [];
  }
}

/// A vrat pinned to a specific date, ready to render.
class VratOccurrence {
  const VratOccurrence({required this.vrat, required this.date});

  final Vrat vrat;
  final DateTime date;

  int daysFrom(DateTime reference) {
    final from = DateTime(reference.year, reference.month, reference.day);
    return date.difference(from).inDays;
  }

  bool isToday(DateTime reference) => daysFrom(reference) == 0;
}
