import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/jap/providers/jap_providers.dart';
import 'localized_strings.dart';

final localizedStringsProvider = Provider<LocalizedStrings>((ref) {
  final language = ref.watch(
    japSettingsProvider.select((settings) => settings.language),
  );
  return LocalizedStrings(language);
});
