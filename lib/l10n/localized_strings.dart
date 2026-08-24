import '../shared/enums/app_language.dart';

/// User-facing copy in English and Hindi (offline, no network).
class LocalizedStrings {
  const LocalizedStrings(this.language);

  final AppLanguage language;

  bool get isHindi => language == AppLanguage.hindi;

  String get appName => isHindi ? 'भक्ति' : 'BHAKTi';

  String get tagline => isHindi
      ? 'भक्ति भाव से पूजा तक'
      : 'Bhakti bhav se pooja tak';

  String get beginJap => isHindi ? 'जप शुरू करें' : 'Begin Jap';

  String get home => isHindi ? 'होम' : 'Home';

  String get insights => isHindi ? 'अंतर्दृष्टि' : 'Insights';

  String get history => isHindi ? 'इतिहास' : 'History';

  String get more => isHindi ? 'अधिक' : 'More';

  String get profile => isHindi ? 'प्रोफ़ाइल' : 'Profile';

  String get profileSubtitle => isHindi
      ? 'आपका नाम, साधना और बैकअप'
      : 'Your naam, practice, and backup';

  String get profileBackupOff => isHindi
      ? 'बैकअप बंद — सब कुछ इसी फ़ोन पर है'
      : 'Backup off — everything stays on this phone';

  String get today => isHindi ? 'आज' : 'Today';

  String get totalJaps => isHindi ? 'कुल जप' : 'Total Japs';

  String get streak => isHindi ? 'लगातार दिन' : 'Streak';

  String get ofGoal => isHindi ? 'लक्ष्य में से' : 'of goal';

  String get welcomeContinue => isHindi ? 'शुरू करें' : 'Get started';

  String get welcomeStep1 => isHindi
      ? 'होम पर «जप शुरू करें» दबाकर सत्र शुरू करें।'
      : 'Tap Begin Jap on the home screen to start a session.';

  String get welcomeStep2 => isHindi
      ? 'प्रत्येक जप गिनने के लिए स्क्रीन, वॉल्यूम बटन, या बैक-टैप (सेटिंग्स) का उपयोग करें।'
      : 'Tap the screen, use volume buttons, or back-tap (in Settings) to count each jap.';

  String get welcomeStep3 => isHindi
      ? 'पंचांग पर आज का व्रत देखें, भजन पढ़ें, और होम से जप शुरू करें।'
      : 'See today\'s vrat on Calendar, read a bhajan, and begin jap from Home.';

  String get guideTitle => isHindi ? 'आज का मार्गदर्शन' : 'Today\'s guidance';

  String get guideSubtitle => isHindi
      ? 'आपके जप पर आधारित — पूर्णतः डिवाइस पर'
      : 'Based on your practice — fully on your device';

  String get languageSection => isHindi ? 'भाषा' : 'Language';

  String get languageHint => isHindi
      ? 'ऐप इंटरफ़ेस की भाषा'
      : 'App interface language';

  String get tapToChant =>
      isHindi ? 'जप के लिए कहीं भी टैप करें' : 'Tap anywhere to chant';

  String get malaCompleteTitle =>
      isHindi ? 'एक माला पूर्ण' : 'One mala complete';

  String get malaCompleteBody => isHindi
      ? '108 नाम — शांत मन से आगे बढ़ें'
      : '108 names — continue with a calm mind';

  String get helpTitle => isHindi ? 'कैसे उपयोग करें' : 'How to use';

  String get helpIntro => isHindi
      ? 'भक्ति आपके रोज़ाना नाम जप का निजी साथी है। जप पूरी तरह ऑफ़लाइन चलता है; क्लाउड बैकअप वैकल्पिक है।'
      : 'BHAKTi is a private companion for your daily naam jap. Chanting works fully offline; cloud backup is optional.';

  String get aboutTitle => isHindi ? 'ऐप के बारे में' : 'About this app';

  String get aboutPurposeTitle =>
      isHindi ? 'उद्देश्य' : 'Purpose';

  String get aboutPurposeBody => isHindi
      ? 'यह ऐप रोज़ाना नाम जप को सरल, शांत और नियमित बनाने के लिए बनाया गया है — बिना विज्ञापन और बिना खाते। जप पूरी तरह ऑफ़लाइन चलता है; बैकअप वैकल्पिक है।'
      : 'This app helps you practice daily naam jap with calm focus — no ads and no account needed. Chanting works fully offline; cloud backup is optional.';

  String get aboutFeaturesTitle =>
      isHindi ? 'मुख्य सुविधाएँ' : 'What you can do';

  List<String> get aboutFeatureBullets => isHindi
      ? [
          'छह देवता थीम — राम, कृष्ण, महादेव, गणेश, दुर्गा, हनुमान',
          'टैप, वॉल्यूम बटन, या फ़ोन बॉडी टैप से गिनती',
          'रोज़ का व्रत, कथा-विधि, और भजन पाठ',
          'दैनिक लक्ष्य, स्ट्रीक, इतिहास और चार्ट',
          'दैनिक जप और व्रत स्मरण',
          'लिखित जप (पुस्तक) और माला रिंग मोड',
          'स्थानीय ध्वनि और मंदिर वातावरण संगीत',
        ]
      : [
          'Six deity themes — Ram, Krishna, Mahadev, Ganesh, Durga, Hanuman',
          'Count by tap, volume buttons, or back-of-phone tap',
          'Daily vrat, katha and vidhi, and bhajan recitation',
          'Daily goals, streaks, history, and charts',
          'Daily jap and vrat reminders',
          'Likhit jap book mode and mala ring',
          'Local chant audio and gentle temple ambience',
        ];

  String get aboutCreditsTitle => isHindi ? 'सामग्री' : 'Content';

  String get aboutCreditsBody => isHindi
      ? 'देवता कलाकृति और ध्वनि ऐप के साथ शामिल हैं। कोई तृतीय-पक्ष ट्रैकिंग नहीं।'
      : 'Deity artwork and audio are bundled with the app. There is no third-party tracking.';

  String get coachTapTitle => isHindi ? 'पहला जप' : 'Your first jap';

  String get coachTapBody => isHindi
      ? 'स्क्रीन पर कहीं भी टैप करें। प्रत्येक टैप एक जप गिनता है। बंद करने के लिए ऊपर ✕ दबाएँ।'
      : 'Tap anywhere on the screen. Each tap counts one jap. Press ✕ at the top to finish.';

  String get coachGotIt => isHindi ? 'समझ गया' : 'Got it';

  String get emptyHistoryTitle =>
      isHindi ? 'यात्रा अभी शुरू होगी' : 'Your journey starts here';

  String get emptyHistorySubtitle => isHindi
      ? 'पहला जप पूरा करें — यहाँ दैनिक इतिहास दिखेगा।'
      : 'Complete your first jap session — daily history will appear here.';

  String get backupSection => isHindi ? 'बैकअप और सिंक' : 'Backup & Sync';

  String get backupToggleTitle =>
      isHindi ? 'क्लाउड बैकअप' : 'Cloud backup';

  String get backupToggleHint => isHindi
      ? 'जप गिनती और सेटिंग्स सुरक्षित रखें ताकि फ़ोन बदलने पर भी बनी रहें।'
      : 'Keep your counts and settings safe so they survive a new phone.';

  String get backupOffHint => isHindi
      ? 'बंद है — सब कुछ केवल इसी फ़ोन पर रहता है।'
      : 'Off — everything stays on this phone only.';

  String get backupUnavailable => isHindi
      ? 'इस बिल्ड में क्लाउड बैकअप उपलब्ध नहीं है।'
      : 'Cloud backup is not available in this build.';

  String get backupSyncing => isHindi ? 'सिंक हो रहा है…' : 'Syncing…';

  String get backupFailed => isHindi
      ? 'सिंक नहीं हो सका — आपका डेटा फ़ोन पर सुरक्षित है।'
      : 'Sync failed — your data is safe on this phone.';

  String get backupNeverSynced => isHindi ? 'अभी तक सिंक नहीं' : 'Not synced yet';

  String get backupSyncNow => isHindi ? 'अभी सिंक करें' : 'Sync now';

  String backupLastSynced(String when) =>
      isHindi ? 'अंतिम सिंक: $when' : 'Last synced $when';

  String get backupDelete =>
      isHindi ? 'क्लाउड बैकअप हटाएँ' : 'Delete cloud backup';

  String get backupDeleteHint => isHindi
      ? 'क्लाउड कॉपी हटती है; इस फ़ोन का डेटा वैसा ही रहता है।'
      : 'Removes the cloud copy. Data on this phone is untouched.';

  String get calendar => isHindi ? 'पंचांग' : 'Calendar';

  String get calendarToday => isHindi ? 'आज' : 'Today';

  String get calendarNoVratToday => isHindi
      ? 'आज कोई विशेष व्रत नहीं — जप सदैव शुभ है।'
      : 'No special vrat today — jap is always auspicious.';

  String get calendarUpcoming => isHindi ? 'आगामी व्रत' : 'Upcoming vrats';

  String get calendarObservances =>
      isHindi ? 'व्रत और पर्व' : 'Vrats & observances';

  String get calendarObservancesHint => isHindi
      ? 'तिथि आधारित व्रत — सही तिथि के लिए पंचांग देखें।'
      : 'Tithi-based vrats — check a panchang for exact dates.';

  String get calendarObservancesHintWithPanchang => isHindi
      ? 'तिथि व्रत — तिथियाँ उज्जैन पंचांग से जुड़ती हैं।'
      : 'Tithi vrats — dates come from the Ujjain panchang.';

  String get calendarTithi => isHindi ? 'तिथि' : 'Tithi';

  String get calendarNakshatra => isHindi ? 'नक्षत्र' : 'Nakshatra';

  String get calendarSunrise => isHindi ? 'सूर्योदय' : 'Sunrise';

  String calendarPanchangPlace(String place) =>
      isHindi ? '$place पंचांग' : '$place panchang';

  String get calendarNoUpcoming => isHindi
      ? 'आगामी तिथियाँ जोड़ी जा रही हैं।'
      : 'Upcoming dates are being added.';

  String get vratKatha => isHindi ? 'कथा' : 'Katha';

  String get vratVidhi => isHindi ? 'विधि' : 'Vidhi';

  String get vratMuhurat => isHindi ? 'मुहूर्त' : 'Muhurat';

  String get vratChantCta => isHindi ? 'इस नाम का जप करें' : 'Chant this naam';

  String get prasadamTitle => isHindi ? 'प्रसादम' : 'Prasadam';

  String get prasadamBody => isHindi
      ? 'व्रत के लिए प्रसाद घर मंगवाएँ — शीघ्र आ रहा है।'
      : 'Order prasad for your vrat, delivered home — coming soon.';

  String get prasadamCta => isHindi ? 'मुझे सूचित करें' : 'Notify me';

  String get prasadamNoted => isHindi
      ? 'धन्यवाद — उपलब्ध होने पर सूचित करेंगे।'
      : 'Thank you — we will let you know when it is ready.';

  String get kundaliTitle => isHindi ? 'कुंडली' : 'Kundali';

  String get kundaliBody => isHindi
      ? 'जन्म कुंडली उज्जैन पंचांग से — शीघ्र आ रहा है। कुंजी ऐप में नहीं रहेगी।'
      : 'Birth kundali from the Ujjain panchang — coming soon. The API key stays off the device.';

  String get kundaliCta => isHindi ? 'मुझे सूचित करें' : 'Notify me';

  String get kundaliNoted => isHindi
      ? 'धन्यवाद — कुंडली आने पर सूचित करेंगे।'
      : 'Thank you — we will let you know when kundali is ready.';

  String get bhajans => isHindi ? 'भजन' : 'Bhajans';

  String get bhajansSubtitle => isHindi
      ? 'आरती, चालीसा और स्तोत्र — पाठ के लिए'
      : 'Aarti, chalisa, and stotra — to read and recite';

  String get bhajanShowRoman =>
      isHindi ? 'रोमन में देखें' : 'Show in Roman script';

  String get bhajanNoAudio => isHindi
      ? 'केवल पाठ — इस भजन के लिए रिकॉर्डिंग उपलब्ध नहीं।'
      : 'Text only — no recording available for this bhajan.';

  String get bhajanAudioFailed => isHindi
      ? 'रिकॉर्डिंग नहीं चल पाई।'
      : 'The recording could not be played.';

  String get bhajanEmpty =>
      isHindi ? 'भजन जोड़े जा रहे हैं।' : 'Bhajans are being added.';

  String bhajanCategory(String category) {
    return switch (category) {
      'chalisa' => isHindi ? 'चालीसा' : 'Chalisa',
      'aarti' => isHindi ? 'आरती' : 'Aarti',
      'stotra' => isHindi ? 'स्तोत्र' : 'Stotra',
      'mantra' => isHindi ? 'मंत्र' : 'Mantra',
      _ => isHindi ? 'भजन' : 'Bhajan',
    };
  }

  String verseCount(int count) => isHindi ? '$count छंद' : '$count verses';

  String get practiceSection => isHindi ? 'आपकी साधना' : 'Your practice';

  String readBhajan(String title) =>
      isHindi ? '$title पढ़ें' : 'Read $title';

  String daysAway(int days) {
    if (days == 0) {
      return isHindi ? 'आज' : 'Today';
    }
    if (days == 1) {
      return isHindi ? 'कल' : 'Tomorrow';
    }
    return isHindi ? '$days दिन में' : 'in $days days';
  }

  String get cancel => isHindi ? 'रद्द करें' : 'Cancel';

  String relativeTime(DateTime at) {
    final delta = DateTime.now().difference(at);
    if (delta.inMinutes < 1) {
      return isHindi ? 'अभी' : 'just now';
    }
    if (delta.inHours < 1) {
      return isHindi ? '${delta.inMinutes} मिनट पहले' : '${delta.inMinutes}m ago';
    }
    if (delta.inDays < 1) {
      return isHindi ? '${delta.inHours} घंटे पहले' : '${delta.inHours}h ago';
    }
    return isHindi ? '${delta.inDays} दिन पहले' : '${delta.inDays}d ago';
  }
}
