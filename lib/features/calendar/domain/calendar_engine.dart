import 'panchang_day.dart';
import 'vrat.dart';

/// What the Calendar screen needs to render for a given day.
class CalendarSnapshot {
  const CalendarSnapshot({
    required this.date,
    required this.todaysVrats,
    required this.upcoming,
    required this.observances,
    this.todayPanchang,
  });

  final DateTime date;

  /// Flattened Navamsha limbs for [date], if the sync tool has written them.
  final PanchangDay? todayPanchang;

  /// Vrats falling on [date] — in practice the weekly vrat, plus any dated
  /// tithi or festival entry that lands today.
  final List<VratOccurrence> todaysVrats;

  /// Dated vrats still ahead, nearest first.
  final List<VratOccurrence> upcoming;

  /// Recurring vrats that have no date supplied yet. They are still worth
  /// showing — the katha and vidhi are useful independently of the calendar —
  /// but they are deliberately displayed without a date rather than with a
  /// guessed one.
  final List<Vrat> observances;

  bool get hasUpcoming => upcoming.isNotEmpty;

  CalendarSnapshot copyWith({PanchangDay? todayPanchang}) {
    return CalendarSnapshot(
      date: date,
      todaysVrats: todaysVrats,
      upcoming: upcoming,
      observances: observances,
      todayPanchang: todayPanchang ?? this.todayPanchang,
    );
  }
}

abstract final class CalendarEngine {
  static const int defaultHorizonDays = 45;

  static CalendarSnapshot build({
    required List<Vrat> vrats,
    required DateTime today,
    int horizonDays = defaultHorizonDays,
  }) {
    final start = DateTime(today.year, today.month, today.day);
    final horizon = start.add(Duration(days: horizonDays));

    final todaysVrats = <VratOccurrence>[];
    final upcoming = <VratOccurrence>[];
    final observances = <Vrat>[];

    for (final vrat in vrats) {
      final occurrence = vrat.occurrenceOnOrAfter(start);

      if (occurrence == null) {
        // A tithi or festival vrat whose date has passed or was never supplied.
        if (vrat.kind != VratKind.weekly) {
          observances.add(vrat);
        }
        continue;
      }

      final entry = VratOccurrence(vrat: vrat, date: occurrence);
      if (occurrence == start) {
        todaysVrats.add(entry);
      } else if (!occurrence.isAfter(horizon)) {
        upcoming.add(entry);
      }
    }

    upcoming.sort((a, b) {
      final byDate = a.date.compareTo(b.date);
      return byDate != 0 ? byDate : a.vrat.nameEn.compareTo(b.vrat.nameEn);
    });

    // Major festivals first, so a crowded list still leads with what matters.
    observances.sort((a, b) {
      if (a.isMajor != b.isMajor) {
        return a.isMajor ? -1 : 1;
      }
      return a.nameEn.compareTo(b.nameEn);
    });

    // Hide the undated template (e.g. `ekadashi`) once a dated clone is
    // already on the calendar, so the same vrat is not listed twice.
    final placedTemplates = <String>{
      for (final entry in [...todaysVrats, ...upcoming])
        ?_templateId(entry.vrat.id),
    };
    observances.removeWhere((vrat) => placedTemplates.contains(vrat.id));

    return CalendarSnapshot(
      date: start,
      todaysVrats: todaysVrats,
      upcoming: upcoming,
      observances: observances,
    );
  }

  static final _datedId = RegExp(r'^(.+)-\d{4}-\d{2}-\d{2}$');

  static String? _templateId(String id) => _datedId.firstMatch(id)?.group(1);
}

abstract final class HinduCalendarNames {
  static const List<String> weekdaysHi = [
    'सोमवार',
    'मंगलवार',
    'बुधवार',
    'गुरुवार',
    'शुक्रवार',
    'शनिवार',
    'रविवार',
  ];

  static const List<String> weekdaysEn = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  static const List<String> monthsHi = [
    'जनवरी',
    'फ़रवरी',
    'मार्च',
    'अप्रैल',
    'मई',
    'जून',
    'जुलाई',
    'अगस्त',
    'सितंबर',
    'अक्तूबर',
    'नवंबर',
    'दिसंबर',
  ];

  static const List<String> monthsEn = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static String weekday(DateTime date, {required bool hindi}) {
    final names = hindi ? weekdaysHi : weekdaysEn;
    return names[date.weekday - 1];
  }

  static String longDate(DateTime date, {required bool hindi}) {
    final months = hindi ? monthsHi : monthsEn;
    final month = months[date.month - 1];
    return hindi
        ? '${date.day} $month ${date.year}'
        : '$month ${date.day}, ${date.year}';
  }
}
