import '../../constants/app_strings.dart';
import '../../core/helpers/date_helper.dart';

abstract final class DisplayDateHelper {
  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String labelFor(DateTime date) {
    final today = DateHelper.today();
    if (DateHelper.isSameDay(date, today)) {
      return AppStrings.today;
    }
    if (DateHelper.isYesterday(date, today)) {
      return AppStrings.yesterday;
    }

    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  static String shortLabelFor(DateTime date) {
    return '${date.day} ${_months[date.month - 1]}';
  }
}
