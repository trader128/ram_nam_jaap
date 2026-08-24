import 'package:flutter_test/flutter_test.dart';

import 'package:bhakti/core/notifications/reminder_planner.dart';
import 'package:bhakti/features/calendar/domain/vrat.dart';

void main() {
  group('ReminderPlanner', () {
    test('skips today when the clock has already passed the reminder', () {
      final now = DateTime(2026, 8, 24, 10, 0);
      final planned = ReminderPlanner.plan(
        now: now,
        hour: 6,
        minute: 0,
        vrats: const [],
        vratReminderEnabled: true,
        deityName: 'राम',
      );

      expect(planned, hasLength(7));
      expect(planned.first.fireAt, DateTime(2026, 8, 25, 6));
      expect(planned.first.body, 'राम नाम का नित्य जप करें।');
    });

    test('keeps today when the reminder is still ahead', () {
      final now = DateTime(2026, 8, 24, 5, 0);
      final planned = ReminderPlanner.plan(
        now: now,
        hour: 6,
        minute: 0,
        vrats: const [],
        vratReminderEnabled: true,
        deityName: 'राम',
      );

      expect(planned.first.fireAt, DateTime(2026, 8, 24, 6));
    });

    test('names today\'s weekly vrat in the body', () {
      final monday = DateTime(2026, 8, 24, 5, 0);
      final planned = ReminderPlanner.plan(
        now: monday,
        hour: 6,
        minute: 0,
        vrats: const [
          Vrat(
            id: 'somvar',
            kind: VratKind.weekly,
            weekday: DateTime.monday,
            nameEn: 'Somvar',
            nameHi: 'सोमवार व्रत',
          ),
        ],
        vratReminderEnabled: true,
        deityName: 'राम',
      );

      expect(planned.first.body, 'आज सोमवार व्रत है। जप शुरू करें।');
    });

    test('formats the time with 0-9 digits', () {
      expect(ReminderPlanner.formatTime(6, 0), 'प्रातः 6:00');
      expect(ReminderPlanner.formatTime(18, 30), 'सायं 6:30');
    });
  });
}
