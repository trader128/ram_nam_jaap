import '../../../l10n/localized_strings.dart';
import '../../../shared/enums/app_language.dart';
import '../../../shared/models/jap_settings.dart';
import '../../../shared/models/jap_statistics.dart';
import '../../deity/domain/deity_pack.dart';

class SadhanaGuideInsight {
  const SadhanaGuideInsight({
    required this.title,
    required this.message,
    required this.affirmation,
  });

  final String title;
  final String message;
  final String affirmation;
}

/// On-device “smart” guidance from streak, goal, and time — no cloud or AI API.
abstract final class SadhanaGuideEngine {
  static SadhanaGuideInsight generate({
    required AppLanguage language,
    required JapStatistics statistics,
    required JapSettings settings,
    required DeityPack deity,
  }) {
    final l10n = LocalizedStrings(language);
    final hour = DateTime.now().hour;
    final goal = settings.dailyGoal;
    final today = statistics.todayCount;
    final progress = goal <= 0 ? 0.0 : (today / goal).clamp(0.0, 1.0);
    final streak = statistics.currentStreak;

    if (today == 0 && streak == 0) {
      return SadhanaGuideInsight(
        title: l10n.guideTitle,
        message: language == AppLanguage.hindi
            ? '${deity.transliteration} के नाम से आज की यात्रा शुरू करें। छोटा सा जप भी मन को शांत करता है।'
            : 'Begin today\'s journey with ${deity.transliteration}. Even a few calm repetitions settle the mind.',
        affirmation: deity.mantra,
      );
    }

    if (progress >= 1) {
      return SadhanaGuideInsight(
        title: language == AppLanguage.hindi ? 'लक्ष्य पूर्ण' : 'Goal reached',
        message: language == AppLanguage.hindi
            ? 'आज का दैनिक लक्ष्य पूरा हो गया। अतिरिक्त जप भक्ति का उपहार है, दबाव नहीं।'
            : 'You met today\'s goal. Extra japs are devotion, not pressure.',
        affirmation: language == AppLanguage.hindi
            ? 'शुभ कर्म — शांत चित्त'
            : 'Well done — stay peaceful',
      );
    }

    if (hour < 10) {
      return SadhanaGuideInsight(
        title: l10n.guideTitle,
        message: language == AppLanguage.hindi
            ? 'प्रातः का समय नाम जप के लिए उत्तम है। आज $today/$goal — $streak दिन की लकीर।'
            : 'Morning is ideal for naam jap. Today $today/$goal — $streak-day streak.',
        affirmation: deity.mantra,
      );
    }

    if (hour >= 20) {
      return SadhanaGuideInsight(
        title: l10n.guideTitle,
        message: language == AppLanguage.hindi
            ? 'शाम को कुछ मिनट का जप मन को हल्का करता है। अभी $today/$goal पूरे हुए।'
            : 'A few evening minutes of jap lighten the mind. $today/$goal done so far.',
        affirmation: deity.mantra,
      );
    }

    final remaining = (goal - today).clamp(0, goal);
    return SadhanaGuideInsight(
      title: l10n.guideTitle,
      message: language == AppLanguage.hindi
          ? 'स्थिर गति से आगे बढ़ें। लक्ष्य तक $remaining जप शेष — ${deity.name} का स्मरण करें।'
          : 'Move at a steady pace. $remaining japs to today\'s goal — remember ${deity.name}.',
      affirmation: deity.mantra,
    );
  }
}
