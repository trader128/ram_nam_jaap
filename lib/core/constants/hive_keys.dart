abstract final class HiveKeys {
  static const String totalLifetime = 'total_lifetime';
  static const String todayCount = 'today_count';
  static const String todayDate = 'today_date';
  static const String currentStreak = 'current_streak';
  static const String longestStreak = 'longest_streak';
  static const String lastActiveDate = 'last_active_date';

  static const String sessionCount = 'session_count';
  static const String sessionStartedAt = 'session_started_at';
  static const String isSessionActive = 'is_session_active';

  static const String soundEnabled = 'sound_enabled';
  static const String hapticEnabled = 'haptic_enabled';
  static const String floatingTextEnabled = 'floating_text_enabled';
  static const String backTapEnabled = 'back_tap_enabled';
  static const String textSize = 'text_size';
  static const String dailyGoal = 'daily_goal';
  static const String dailyRecords = 'daily_records';
  static const String floatingTextColor = 'floating_text_color';
  static const String countMethod = 'count_method';
  static const String showMalaRing = 'show_mala_ring';
  static const String divineWallpaperEnabled = 'divine_wallpaper_enabled';
  static const String idleMusicEnabled = 'idle_music_enabled';
  static const String bookModeEnabled = 'book_mode_enabled';
  static const String appLanguage = 'app_language';

  static const String selectedDeity = 'selected_deity';
  static const String deityMigrated = 'deity_namespace_migrated';
  static const String welcomeCompleted = 'welcome_completed';
  static const String japCoachCompleted = 'jap_coach_completed';

  static const String syncEnabled = 'cloud_sync_enabled';
  static const String lastSyncedAt = 'cloud_last_synced_at';
  static const String localChangedAt = 'cloud_local_changed_at';

  /// Builds a per-deity namespaced key, e.g. `ram_today_count`.
  static String forDeity(String deityId, String baseKey) =>
      '${deityId}_$baseKey';
}
