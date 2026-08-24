import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_routes.dart';
import '../../../l10n/localized_strings.dart';
import '../../../l10n/localized_strings_provider.dart';
import '../../../shared/ui/app_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radius.dart';
import '../../../theme/app_spacing.dart';
import '../../../theme/app_text_styles.dart';
import '../../deity/providers/deity_providers.dart';
import '../domain/birth_profile.dart';
import '../domain/horoscope_reading.dart';
import '../providers/kundali_providers.dart';

class KundaliScreen extends ConsumerStatefulWidget {
  const KundaliScreen({super.key});

  @override
  ConsumerState<KundaliScreen> createState() => _KundaliScreenState();
}

class _KundaliScreenState extends ConsumerState<KundaliScreen> {
  late DateTime _date;
  late TimeOfDay _time;
  late String _placeId;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(horoscopeControllerProvider).profile;
    final now = DateTime.now();
    _date = profile?.localDateTime ?? DateTime(now.year - 25, 1, 1);
    _time = profile == null
        ? const TimeOfDay(hour: 6, minute: 0)
        : TimeOfDay(hour: profile.hours, minute: profile.minutes);
    _placeId = profile?.placeId ?? BirthPlaceCatalog.all.first.id;
  }

  BirthProfile _profileFromForm({required bool hindi}) {
    final place = BirthPlaceCatalog.byId(_placeId);
    return BirthProfile(
      year: _date.year,
      month: _date.month,
      date: _date.day,
      hours: _time.hour,
      minutes: _time.minute,
      latitude: place.latitude,
      longitude: place.longitude,
      timezone: place.timezone,
      placeId: place.id,
      placeLabel: place.name(hindi: hindi),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(localizedStringsProvider);
    final accent = ref.watch(deityColorProvider);
    final state = ref.watch(horoscopeControllerProvider);
    final hindi = strings.isHindi;

    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(strings.kundaliTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _BirthForm(
              date: _date,
              time: _time,
              placeId: _placeId,
              hindi: hindi,
              dateLabel: strings.kundaliBirthDate,
              timeLabel: strings.kundaliBirthTime,
              placeLabel: strings.kundaliBirthPlace,
              onPickDate: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _date = picked);
                }
              },
              onPickTime: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked != null) {
                  setState(() => _time = picked);
                }
              },
              onPlace: (id) => setState(() => _placeId = id),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: state.reading == null
                  ? strings.kundaliDraw
                  : strings.kundaliRedraw,
              onPressed: state.busy
                  ? null
                  : () => ref
                        .read(horoscopeControllerProvider.notifier)
                        .draw(_profileFromForm(hindi: hindi)),
            ),
            if (state.busy) ...[
              const SizedBox(height: AppSpacing.lg),
              const Center(child: CircularProgressIndicator()),
            ],
            if (state.error != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                state.error!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
            if (state.reading case final reading?) ...[
              const SizedBox(height: AppSpacing.xl),
              _ReadingCard(reading: reading, strings: strings, accent: accent),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: strings.kundaliChatCta,
                onPressed: () => context.push(AppRoutes.kundaliChat),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BirthForm extends StatelessWidget {
  const _BirthForm({
    required this.date,
    required this.time,
    required this.placeId,
    required this.hindi,
    required this.dateLabel,
    required this.timeLabel,
    required this.placeLabel,
    required this.onPickDate,
    required this.onPickTime,
    required this.onPlace,
  });

  final DateTime date;
  final TimeOfDay time;
  final String placeId;
  final bool hindi;
  final String dateLabel;
  final String timeLabel;
  final String placeLabel;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final ValueChanged<String> onPlace;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PickerTile(
          label: dateLabel,
          value:
              '${date.day.toString().padLeft(2, '0')}/'
              '${date.month.toString().padLeft(2, '0')}/'
              '${date.year}',
          onTap: onPickDate,
        ),
        const SizedBox(height: AppSpacing.sm),
        _PickerTile(
          label: timeLabel,
          value: time.format(context),
          onTap: onPickTime,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(placeLabel, style: AppTextStyles.labelSmall),
        const SizedBox(height: AppSpacing.xxs),
        DropdownButtonFormField<String>(
          key: ValueKey(placeId),
          initialValue: placeId,
          dropdownColor: AppColors.surface,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.primaryGold.withValues(alpha: 0.28),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(
                color: AppColors.primaryGold.withValues(alpha: 0.28),
              ),
            ),
          ),
          items: [
            for (final place in BirthPlaceCatalog.all)
              DropdownMenuItem(
                value: place.id,
                child: Text(place.name(hindi: hindi)),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              onPlace(value);
            }
          },
        ),
      ],
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Ink(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.labelSmall),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(value, style: AppTextStyles.bodyLarge),
                ],
              ),
            ),
            const Icon(
              Icons.event_rounded,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({
    required this.reading,
    required this.strings,
    required this.accent,
  });

  final HoroscopeReading reading;
  final LocalizedStrings strings;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
          if (reading.nakshatra != null)
        (strings.kundaliNakshatra, reading.nakshatra!),
      if (reading.chandraRasi != null)
        (strings.kundaliMoon, reading.chandraRasi!),
      if (reading.sooryaRasi != null)
        (strings.kundaliSun, reading.sooryaRasi!),
      if (reading.zodiac != null)
        (strings.kundaliZodiac, reading.zodiac!),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reading.placeLabel, style: AppTextStyles.labelSmall),
          const SizedBox(height: AppSpacing.sm),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxs),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${row.$1}  ',
                      style: AppTextStyles.labelSmall,
                    ),
                    TextSpan(text: row.$2, style: AppTextStyles.bodyLarge),
                  ],
                ),
              ),
            ),
          if (reading.mangalDescription != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(strings.kundaliMangal, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.xxs),
            Text(reading.mangalDescription!, style: AppTextStyles.bodyMedium),
          ],
          if (reading.yogas.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(strings.kundaliYogas, style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            for (final yoga in reading.yogas)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  yoga.description.isEmpty ? yoga.name : yoga.description,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
