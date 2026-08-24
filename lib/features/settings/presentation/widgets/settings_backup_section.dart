import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sync/sync_providers.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../l10n/localized_strings.dart';
import '../../../../l10n/localized_strings_provider.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_spacing.dart';
import '../../../../theme/app_text_styles.dart';
import 'settings_section.dart';
import 'settings_toggle_tile.dart';

class SettingsBackupSection extends ConsumerWidget {
  const SettingsBackupSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(localizedStringsProvider);
    final status = ref.watch(syncControllerProvider);
    final controller = ref.read(syncControllerProvider.notifier);
    final supported = controller.isSupported;
    final enabled = supported && controller.isEnabled;

    return SettingsSection(
      title: strings.backupSection,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: Text(
            supported ? strings.backupToggleHint : strings.backupUnavailable,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        SettingsToggleTile(
          title: strings.backupToggleTitle,
          value: enabled,
          onChanged: supported ? controller.setEnabled : (_) {},
        ),
        if (enabled) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _statusLabel(strings, status),
                    style: AppTextStyles.labelSmall.copyWith(
                      color: status.state == SyncState.failed
                          ? AppColors.error
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                if (status.isBusy)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  TextButton(
                    onPressed: controller.syncNow,
                    child: Text(strings.backupSyncNow),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListTile(
            title: Text(
              strings.backupDelete,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
            subtitle: Text(
              strings.backupDeleteHint,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            onTap: () => _confirmDelete(context, ref, strings),
          ),
        ] else if (supported) ...[
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              strings.backupOffHint,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _statusLabel(LocalizedStrings strings, SyncStatus status) {
    switch (status.state) {
      case SyncState.syncing:
        return strings.backupSyncing;
      case SyncState.failed:
        return strings.backupFailed;
      case SyncState.disabled:
        return strings.backupOffHint;
      case SyncState.idle:
      case SyncState.synced:
        final at = status.lastSyncedAt;
        if (at == null) {
          return strings.backupNeverSynced;
        }
        return strings.backupLastSynced(strings.relativeTime(at));
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    LocalizedStrings strings,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.backupDelete),
        content: Text(strings.backupDeleteHint),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              strings.backupDelete,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await ref.read(syncControllerProvider.notifier).deleteCloudBackup();
    }
  }
}
