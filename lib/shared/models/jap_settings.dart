import '../../core/constants/jap_constants.dart';

class JapSettings {
  const JapSettings({
    required this.soundEnabled,
    required this.hapticEnabled,
    required this.enclosureEnabled,
    required this.floatingTextEnabled,
    required this.textSize,
    required this.dailyGoal,
  });

  final bool soundEnabled;
  final bool hapticEnabled;
  final bool enclosureEnabled;
  final bool floatingTextEnabled;
  final double textSize;
  final int dailyGoal;

  static JapSettings defaults() {
    return const JapSettings(
      soundEnabled: true,
      hapticEnabled: true,
      enclosureEnabled: true,
      floatingTextEnabled: true,
      textSize: JapConstants.defaultTextSize,
      dailyGoal: JapConstants.defaultDailyGoal,
    );
  }

  JapSettings copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? enclosureEnabled,
    bool? floatingTextEnabled,
    double? textSize,
    int? dailyGoal,
  }) {
    return JapSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      enclosureEnabled: enclosureEnabled ?? this.enclosureEnabled,
      floatingTextEnabled: floatingTextEnabled ?? this.floatingTextEnabled,
      textSize: textSize ?? this.textSize,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }
}
