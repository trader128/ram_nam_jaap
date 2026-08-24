import '../../../features/calendar/domain/calendar_engine.dart';
import '../../../features/calendar/domain/vrat.dart';

class PlannedReminder {
  const PlannedReminder({
    required this.id,
    required this.fireAt,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime fireAt;
  final String title;
  final String body;
}

/// Builds the next week's jap/vrat reminders. Pure — no plugin, no timezone.
abstract final class ReminderPlanner {
  static const int horizonDays = 7;
  static const int idBase = 7100;
  static const String title = 'भक्ति';

  static List<PlannedReminder> plan({
    required DateTime now,
    required int hour,
    required int minute,
    required List<Vrat> vrats,
    required bool vratReminderEnabled,
    required String deityName,
  }) {
    var first = DateTime(now.year, now.month, now.day, hour, minute);
    if (!first.isAfter(now)) {
      first = first.add(const Duration(days: 1));
    }

    return List<PlannedReminder>.generate(horizonDays, (index) {
      final fireAt = first.add(Duration(days: index));
      final day = DateTime(fireAt.year, fireAt.month, fireAt.day);
      final snapshot = CalendarEngine.build(vrats: vrats, today: day);
      final vratNames = snapshot.todaysVrats
          .map((entry) => entry.vrat.nameHi)
          .where((name) => name.isNotEmpty)
          .toList();

      return PlannedReminder(
        id: idBase + index,
        fireAt: fireAt,
        title: title,
        body: _body(
          deityName: deityName,
          vratNames: vratNames,
          vratReminderEnabled: vratReminderEnabled,
        ),
      );
    });
  }

  static String _body({
    required String deityName,
    required List<String> vratNames,
    required bool vratReminderEnabled,
  }) {
    if (vratReminderEnabled && vratNames.isNotEmpty) {
      return 'आज ${vratNames.join(' और ')} है। जप शुरू करें।';
    }
    return '$deityName नाम का नित्य जप करें।';
  }

  static String formatTime(int hour, int minute) {
    final period = hour < 12
        ? 'प्रातः'
        : hour < 16
        ? 'दोपहर'
        : hour < 20
        ? 'सायं'
        : 'रात्रि';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    final mm = minute.toString().padLeft(2, '0');
    return '$period $hour12:$mm';
  }
}
