import '../../../core/constants/hive_keys.dart';
import '../../../core/storage/hive_storage.dart';
import '../domain/birth_profile.dart';
import '../domain/horoscope_reading.dart';

class HoroscopeLocalStore {
  BirthProfile? loadProfile() {
    return BirthProfile.fromMap(
      HiveStorage.settingsBox.get(HiveKeys.kundaliProfile),
    );
  }

  HoroscopeReading? loadReading() {
    return HoroscopeReading.fromMap(
      HiveStorage.settingsBox.get(HiveKeys.kundaliReading),
    );
  }

  List<HoroscopeChatTurn> loadChat() {
    final raw = HiveStorage.settingsBox.get(HiveKeys.kundaliChat);
    if (raw is! List) {
      return const [];
    }
    return [
      for (final item in raw)
        ?HoroscopeChatTurn.fromMap(item),
    ];
  }

  Future<void> saveProfile(BirthProfile profile) {
    return HiveStorage.settingsBox.put(HiveKeys.kundaliProfile, profile.toMap());
  }

  Future<void> saveReading(HoroscopeReading reading) {
    return HiveStorage.settingsBox.put(HiveKeys.kundaliReading, reading.toMap());
  }

  Future<void> saveChat(List<HoroscopeChatTurn> turns) {
    return HiveStorage.settingsBox.put(
      HiveKeys.kundaliChat,
      [for (final turn in turns) turn.toMap()],
    );
  }

  Future<void> clearChat() {
    return HiveStorage.settingsBox.delete(HiveKeys.kundaliChat);
  }
}
