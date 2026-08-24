import '../../../core/constants/hive_keys.dart';
import '../../../core/constants/jap_constants.dart';
import '../../../core/helpers/color_helper.dart';
import '../../../core/storage/hive_storage.dart';
import '../../../shared/enums/app_language.dart';
import '../../../shared/enums/count_method.dart';
import '../../../shared/models/jap_settings.dart';
import '../../../theme/app_colors.dart';

class JapSettingsRepository {
  JapSettings load() {
    final box = HiveStorage.settingsBox;
    final colorValue = box.get(HiveKeys.floatingTextColor) as int?;

    return JapSettings(
      soundEnabled: box.get(HiveKeys.soundEnabled, defaultValue: true) as bool,
      hapticEnabled:
          box.get(HiveKeys.hapticEnabled, defaultValue: true) as bool,
      floatingTextEnabled:
          box.get(HiveKeys.floatingTextEnabled, defaultValue: true) as bool,
      backTapEnabled:
          box.get(HiveKeys.backTapEnabled, defaultValue: false) as bool,
      textSize:
          (box.get(HiveKeys.textSize) as num?)?.toDouble() ??
          JapConstants.defaultTextSize,
      dailyGoal:
          box.get(
                HiveKeys.dailyGoal,
                defaultValue: JapConstants.defaultDailyGoal,
              )
              as int,
      floatingTextColor: ColorHelper.fromStorageValue(
        colorValue ?? AppColors.primaryGold.toARGB32(),
        fallback: AppColors.primaryGold,
      ),
      countMethod: CountMethod.fromStorageKey(
        box.get(HiveKeys.countMethod) as String?,
      ),
      showMalaRing: box.get(HiveKeys.showMalaRing, defaultValue: false) as bool,
      divineWallpaperEnabled:
          box.get(HiveKeys.divineWallpaperEnabled, defaultValue: true) as bool,
      idleMusicEnabled:
          box.get(HiveKeys.idleMusicEnabled, defaultValue: true) as bool,
      bookModeEnabled:
          box.get(HiveKeys.bookModeEnabled, defaultValue: false) as bool,
      language: AppLanguage.hindi,
      reminderEnabled:
          box.get(HiveKeys.reminderEnabled, defaultValue: false) as bool,
      reminderHour:
          (box.get(HiveKeys.reminderHour, defaultValue: 6) as num).toInt(),
      reminderMinute:
          (box.get(HiveKeys.reminderMinute, defaultValue: 0) as num).toInt(),
      vratReminderEnabled:
          box.get(HiveKeys.vratReminderEnabled, defaultValue: true) as bool,
    );
  }

  Future<void> save(JapSettings settings) async {
    final box = HiveStorage.settingsBox;
    await box.put(HiveKeys.soundEnabled, settings.soundEnabled);
    await box.put(HiveKeys.hapticEnabled, settings.hapticEnabled);
    await box.put(HiveKeys.floatingTextEnabled, settings.floatingTextEnabled);
    await box.put(HiveKeys.backTapEnabled, settings.backTapEnabled);
    await box.put(HiveKeys.textSize, settings.textSize);
    await box.put(HiveKeys.dailyGoal, settings.dailyGoal);
    await box.put(
      HiveKeys.floatingTextColor,
      ColorHelper.toStorageValue(settings.floatingTextColor),
    );
    await box.put(HiveKeys.countMethod, settings.countMethod.storageKey);
    await box.put(HiveKeys.showMalaRing, settings.showMalaRing);
    await box.put(
      HiveKeys.divineWallpaperEnabled,
      settings.divineWallpaperEnabled,
    );
    await box.put(HiveKeys.idleMusicEnabled, settings.idleMusicEnabled);
    await box.put(HiveKeys.bookModeEnabled, settings.bookModeEnabled);
    await box.put(HiveKeys.appLanguage, settings.language.code);
    await box.put(HiveKeys.reminderEnabled, settings.reminderEnabled);
    await box.put(HiveKeys.reminderHour, settings.reminderHour);
    await box.put(HiveKeys.reminderMinute, settings.reminderMinute);
    await box.put(HiveKeys.vratReminderEnabled, settings.vratReminderEnabled);
  }
}
