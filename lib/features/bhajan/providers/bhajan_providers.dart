import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hive_keys.dart';
import '../../../core/storage/hive_storage.dart';
import '../data/bhajan_repository.dart';
import '../domain/bhajan.dart';
import '../domain/bhajan_audio_service.dart';

final bhajanRepositoryProvider = Provider<BhajanRepository>(
  (ref) => BhajanRepository(),
);

/// Bundled bhajan texts merged with any cached cloud additions.
///
/// Remote refresh is owned by the app lifecycle observer, not this provider.
final bhajanContentProvider = FutureProvider<List<Bhajan>>((ref) async {
  return ref.watch(bhajanRepositoryProvider).load();
});

final bhajanByIdProvider = Provider.family<Bhajan?, String>((ref, id) {
  return ref.watch(bhajanContentProvider).maybeWhen(
    data: (bhajans) => bhajans.where((bhajan) => bhajan.id == id).firstOrNull,
    orElse: () => null,
  );
});

/// Bhajans grouped by category, in a stable display order.
final bhajansByCategoryProvider =
    Provider<AsyncValue<Map<BhajanCategory, List<Bhajan>>>>((ref) {
      return ref.watch(bhajanContentProvider).whenData((bhajans) {
        final grouped = <BhajanCategory, List<Bhajan>>{};
        for (final category in BhajanCategory.values) {
          final matching = bhajans
              .where((bhajan) => bhajan.category == category)
              .toList()
            ..sort((a, b) => a.titleEn.compareTo(b.titleEn));
          if (matching.isNotEmpty) {
            grouped[category] = matching;
          }
        }
        return grouped;
      });
    });

/// Bhajans tied to a deity, so a vrat can point straight at the text that is
/// actually recited on that day — a Tuesday to the Hanuman Chalisa.
final bhajansForDeityProvider = Provider.family<List<Bhajan>, String?>((
  ref,
  deityId,
) {
  if (deityId == null) {
    return const [];
  }
  return ref.watch(bhajanContentProvider).maybeWhen(
    data: (bhajans) =>
        bhajans.where((bhajan) => bhajan.deityId == deityId).toList(),
    orElse: () => const [],
  );
});

final bhajanAudioServiceProvider = Provider<BhajanAudioService>((ref) {
  final service = BhajanAudioService();
  ref.onDispose(service.dispose);
  return service;
});

final bhajanPlaybackProvider = StreamProvider<BhajanPlayback>((ref) {
  final service = ref.watch(bhajanAudioServiceProvider);
  return service.stream;
});

/// Whether to show Roman transliteration alongside the Devanagari.
///
/// Persisted and synced, because for a diaspora user who cannot read
/// Devanagari this is the difference between the screen being usable or not.
final bhajanTransliterationProvider =
    StateNotifierProvider<BhajanTransliterationNotifier, bool>((ref) {
      return BhajanTransliterationNotifier();
    });

class BhajanTransliterationNotifier extends StateNotifier<bool> {
  BhajanTransliterationNotifier()
    : super(
        HiveStorage.settingsBox.get(
              HiveKeys.bhajanTransliteration,
              defaultValue: false,
            )
            as bool,
      );

  Future<void> toggle() async {
    state = !state;
    await HiveStorage.settingsBox.put(HiveKeys.bhajanTransliteration, state);
  }
}
