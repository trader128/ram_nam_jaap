import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/localized_strings_provider.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../deity/providers/deity_providers.dart';
import '../providers/kundali_providers.dart';

class KundaliChatScreen extends ConsumerStatefulWidget {
  const KundaliChatScreen({super.key});

  @override
  ConsumerState<KundaliChatScreen> createState() => _KundaliChatScreenState();
}

class _KundaliChatScreenState extends ConsumerState<KundaliChatScreen> {
  final _controller = TextEditingController();

  static const _chips = ['mangal', 'dasha', 'sadesati', 'today'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }
    _controller.clear();
    await ref.read(horoscopeControllerProvider.notifier).ask(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(localizedStringsProvider);
    final accent = ref.watch(deityColorProvider);
    final state = ref.watch(horoscopeControllerProvider);

    if (state.reading == null || state.profile == null) {
      return AppScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(strings.kundaliChatTitle),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              strings.kundaliNeedChart,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(strings.kundaliChatTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                0,
              ),
              child: Text(
                strings.kundaliChatPaidNote,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: state.chat.length,
                itemBuilder: (context, index) {
                  final turn = state.chat[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Text(
                              turn.question,
                              style: AppTextStyles.bodyLarge,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (turn.title != null) ...[
                                Text(
                                  turn.title!,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                              ],
                              Text(
                                turn.answer,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  state.error!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final id in _chips)
                    ActionChip(
                      label: Text(strings.kundaliChip(id)),
                      onPressed: state.busy
                          ? null
                          : () => _send(strings.kundaliChip(id)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      enabled: !state.busy,
                      minLines: 1,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: strings.kundaliChatHint,
                      ),
                      onSubmitted: state.busy ? null : _send,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  IconButton.filled(
                    onPressed: state.busy
                        ? null
                        : () => _send(_controller.text),
                    icon: state.busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
