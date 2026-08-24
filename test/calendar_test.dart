import 'package:flutter_test/flutter_test.dart';
import 'package:bhakti/features/calendar/data/vrat_repository.dart';
import 'package:bhakti/features/calendar/domain/calendar_engine.dart';
import 'package:bhakti/features/calendar/domain/vrat.dart';
import 'package:bhakti/features/deity/domain/deity_catalog.dart';

Vrat weekly(int weekday, {String id = 'w'}) => Vrat(
  id: id,
  kind: VratKind.weekly,
  nameEn: 'Weekly $weekday',
  nameHi: 'साप्ताहिक $weekday',
  weekday: weekday,
);

Vrat dated(String date, {String id = 'd', bool major = false}) => Vrat(
  id: id,
  kind: VratKind.tithi,
  nameEn: 'Dated $date',
  nameHi: 'तिथि $date',
  date: DateTime.parse(date),
  isMajor: major,
);

void main() {
  // 2026-08-24 is a Monday.
  final monday = DateTime(2026, 8, 24);

  group('Vrat.occurrenceOnOrAfter', () {
    test('a weekly vrat falling today resolves to today', () {
      expect(weekly(DateTime.monday).occurrenceOnOrAfter(monday), monday);
    });

    test('a weekly vrat later this week resolves within six days', () {
      final friday = weekly(DateTime.friday).occurrenceOnOrAfter(monday)!;
      expect(friday.weekday, DateTime.friday);
      expect(friday.difference(monday).inDays, 4);
    });

    test('a weekly vrat that just passed rolls to next week, not backwards', () {
      final tuesday = DateTime(2026, 8, 25);
      final resolved = weekly(DateTime.monday).occurrenceOnOrAfter(tuesday)!;

      expect(resolved.isAfter(tuesday), isTrue);
      expect(resolved.difference(tuesday).inDays, 6);
    });

    test('a weekly vrat resolves for every day of the week', () {
      for (var offset = 0; offset < 7; offset++) {
        final from = monday.add(Duration(days: offset));
        for (var weekdayIndex = 1; weekdayIndex <= 7; weekdayIndex++) {
          final resolved = weekly(weekdayIndex).occurrenceOnOrAfter(from)!;
          expect(resolved.weekday, weekdayIndex);
          expect(resolved.difference(from).inDays, inInclusiveRange(0, 6));
        }
      }
    });

    test('a dated vrat in the past does not resolve', () {
      expect(dated('2026-08-01').occurrenceOnOrAfter(monday), isNull);
    });

    test('a dated vrat today resolves to today', () {
      expect(dated('2026-08-24').occurrenceOnOrAfter(monday), monday);
    });

    test('a tithi vrat with no date supplied does not resolve', () {
      const undated = Vrat(
        id: 'ekadashi',
        kind: VratKind.tithi,
        nameEn: 'Ekadashi',
        nameHi: 'एकादशी',
      );
      expect(undated.occurrenceOnOrAfter(monday), isNull);
    });
  });

  group('CalendarEngine', () {
    test('separates today, upcoming, and undated observances', () {
      final snapshot = CalendarEngine.build(
        vrats: [
          weekly(DateTime.monday, id: 'somvar'),
          weekly(DateTime.friday, id: 'shukravar'),
          dated('2026-08-30', id: 'soon'),
          dated('2026-08-01', id: 'past'),
          const Vrat(
            id: 'undated',
            kind: VratKind.tithi,
            nameEn: 'Undated',
            nameHi: 'अदिनांकित',
          ),
        ],
        today: monday,
      );

      expect(snapshot.todaysVrats.map((entry) => entry.vrat.id), ['somvar']);
      expect(snapshot.upcoming.map((entry) => entry.vrat.id), [
        'shukravar',
        'soon',
      ]);
      expect(
        snapshot.observances.map((vrat) => vrat.id),
        containsAll(['past', 'undated']),
        reason: 'dateless and past vrats stay browsable without a fake date',
      );
    });

    test('upcoming is sorted nearest first', () {
      final snapshot = CalendarEngine.build(
        vrats: [
          dated('2026-09-10', id: 'later'),
          dated('2026-08-26', id: 'sooner'),
          dated('2026-09-01', id: 'middle'),
        ],
        today: monday,
      );

      expect(snapshot.upcoming.map((entry) => entry.vrat.id), [
        'sooner',
        'middle',
        'later',
      ]);
    });

    test('vrats beyond the horizon are excluded from upcoming', () {
      final snapshot = CalendarEngine.build(
        vrats: [dated('2026-12-25', id: 'far')],
        today: monday,
        horizonDays: 30,
      );

      expect(snapshot.upcoming, isEmpty);
    });

    test('major observances sort ahead of minor ones', () {
      final snapshot = CalendarEngine.build(
        vrats: [
          dated('2026-01-01', id: 'aaa-minor'),
          dated('2026-01-01', id: 'zzz-major', major: true),
        ],
        today: monday,
      );

      expect(snapshot.observances.first.id, 'zzz-major');
    });

    test('a weekly vrat is never left dateless', () {
      final snapshot = CalendarEngine.build(
        vrats: [for (var day = 1; day <= 7; day++) weekly(day, id: 'w$day')],
        today: monday,
      );

      expect(
        snapshot.todaysVrats.length + snapshot.upcoming.length,
        7,
        reason: 'every weekday vrat resolves somewhere in the coming week',
      );
      expect(snapshot.observances, isEmpty);
    });
  });

  group('HinduCalendarNames', () {
    test('names the weekday in both languages', () {
      expect(HinduCalendarNames.weekday(monday, hindi: false), 'Monday');
      expect(HinduCalendarNames.weekday(monday, hindi: true), 'सोमवार');
    });

    test('formats the date in the conventional order per language', () {
      expect(
        HinduCalendarNames.longDate(monday, hindi: false),
        'August 24, 2026',
      );
      expect(HinduCalendarNames.longDate(monday, hindi: true), '24 अगस्त 2026');
    });

    test('covers every weekday and month', () {
      expect(HinduCalendarNames.weekdaysHi, hasLength(7));
      expect(HinduCalendarNames.weekdaysEn, hasLength(7));
      expect(HinduCalendarNames.monthsHi, hasLength(12));
      expect(HinduCalendarNames.monthsEn, hasLength(12));
    });
  });

  group('bundled vrat content', () {
    test('parses and covers all seven weekdays', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final vrats = await VratRepository().loadBundled();

      expect(vrats, isNotEmpty);

      final weekdays = vrats
          .where((vrat) => vrat.kind == VratKind.weekly)
          .map((vrat) => vrat.weekday)
          .toSet();
      expect(
        weekdays,
        {1, 2, 3, 4, 5, 6, 7},
        reason: 'the today card must never be blank for lack of content',
      );
    });

    test('every deity reference resolves to a real deity in the catalog',
        () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final vrats = await VratRepository().loadBundled();
      final ids = DeityCatalog.all.map((deity) => deity.id).toSet();

      for (final vrat in vrats.where((vrat) => vrat.deityId != null)) {
        expect(
          ids,
          contains(vrat.deityId),
          reason: '${vrat.id} points at unknown deity ${vrat.deityId}',
        );
      }
    });

    test('every vrat has content in both languages', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final vrats = await VratRepository().loadBundled();

      for (final vrat in vrats) {
        expect(vrat.nameHi, isNotEmpty, reason: '${vrat.id} missing Hindi name');
        expect(vrat.summary(hindi: true), isNotNull, reason: vrat.id);
        expect(vrat.summary(hindi: false), isNotNull, reason: vrat.id);
        expect(vrat.vidhi(hindi: true), isNotEmpty, reason: vrat.id);
        expect(vrat.vidhi(hindi: false), isNotEmpty, reason: vrat.id);
      }
    });

    test('no tithi vrat ships with a guessed date', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final vrats = await VratRepository().loadBundled();

      for (final vrat in vrats.where((vrat) => vrat.kind == VratKind.tithi)) {
        expect(
          vrat.date,
          isNull,
          reason: '${vrat.id} has a hardcoded date; tithi dates must come '
              'from an authoritative panchang via Firestore',
        );
      }
    });
  });
}
