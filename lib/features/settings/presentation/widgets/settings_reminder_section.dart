import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../constants/app_strings.dart';
import '../../../../core/notifications/reminder_planner.dart';
import '../../../../core/notifications/reminder_service.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import '../../../calendar/providers/calendar_providers.dart';
import '../../../deity/providers/deity_providers.dart';
import '../../../jap/providers/jap_providers.dart';
import 'settings_nav_tile.dart';
import 'settings_section.dart';
import 'settings_toggle_tile.dart';

class SettingsReminderSection extends ConsumerWidget {
  const SettingsReminderSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(japSettingsProvider);
    final notifier = ref.read(japSettingsProvider.notifier);

    return SettingsSection(
      title: AppStrings.reminderSection,
      children: [
        SettingsToggleTile(
          title: AppStrings.dailyJapReminder,
          subtitle: AppStrings.dailyJapReminderHint,
          value: settings.reminderEnabled,
          onChanged: (enabled) => _setEnabled(context, ref, enabled),
        ),
        if (settings.reminderEnabled) ...[
          const Divider(height: 1),
          SettingsNavTile(
            title: AppStrings.reminderTime,
            trailingLabel: ReminderPlanner.formatTime(
              settings.reminderHour,
              settings.reminderMinute,
            ),
            onTap: () => _pickTime(context, ref),
          ),
          const Divider(height: 1),
          SettingsToggleTile(
            title: AppStrings.vratReminder,
            subtitle: AppStrings.vratReminderHint,
            value: settings.vratReminderEnabled,
            onChanged: (enabled) async {
              await notifier.setVratReminderEnabled(enabled);
              await _reschedule(ref);
            },
          ),
        ],
        if (kIsWeb) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Text(
              AppStrings.reminderWebHint,
              style: AppTextStyles.labelSmall,
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _setEnabled(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    if (enabled) {
      final allowed = await ReminderService.instance.requestPermission();
      if (!allowed) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.reminderPermissionDenied)),
          );
        }
        return;
      }
    }
    await ref.read(japSettingsProvider.notifier).setReminderEnabled(enabled);
    await _reschedule(ref);
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(japSettingsProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: settings.reminderHour,
        minute: settings.reminderMinute,
      ),
      helpText: AppStrings.reminderTime,
    );
    if (picked == null) {
      return;
    }
    await ref
        .read(japSettingsProvider.notifier)
        .setReminderTime(picked.hour, picked.minute);
    await _reschedule(ref);
  }

  Future<void> _reschedule(WidgetRef ref) {
    return ReminderService.instance.apply(
      settings: ref.read(japSettingsProvider),
      deityName: ref.read(selectedDeityProvider).name,
      vrats: ref.read(vratContentProvider).asData?.value ?? const [],
    );
  }
}
