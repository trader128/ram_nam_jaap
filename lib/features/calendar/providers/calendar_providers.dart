import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/hive_keys.dart';
import '../../../core/helpers/date_helper.dart';
import '../../../core/storage/hive_storage.dart';
import '../data/panchang_repository.dart';
import '../data/vrat_repository.dart';
import '../domain/calendar_engine.dart';
import '../domain/panchang_day.dart';
import '../domain/panchang_vrat_merger.dart';
import '../domain/vrat.dart';

final vratRepositoryProvider = Provider<VratRepository>(
  (ref) => VratRepository(),
);

final panchangRepositoryProvider = Provider<PanchangRepository>(
  (ref) => PanchangRepository(),
);

/// Vrat content, bundled and merged with any cached cloud corrections.
///
/// Remote refresh is owned by the app lifecycle observer, not this provider,
/// so a first paint never waits on the network.
final vratContentProvider = FutureProvider<List<Vrat>>((ref) async {
  return ref.watch(vratRepositoryProvider).load();
});

/// Cached Navamsha days. Empty until the sync tool has written Firestore.
final panchangContentProvider = FutureProvider<List<PanchangDay>>((ref) async {
  return ref.watch(panchangRepositoryProvider).load();
});

/// Bundled vrats plus tithi dates derived from the panchang cache.
final calendarVratsProvider = Provider<AsyncValue<List<Vrat>>>((ref) {
  final content = ref.watch(vratContentProvider);
  final panchang = ref.watch(panchangContentProvider);
  return content.whenData(
    (vrats) => PanchangVratMerger.merge(
      vrats,
      panchang.valueOrNull ?? const [],
    ),
  );
});

final calendarSnapshotProvider = Provider<AsyncValue<CalendarSnapshot>>((ref) {
  final vrats = ref.watch(calendarVratsProvider);
  final panchang = ref.watch(panchangContentProvider);
  final today = DateHelper.today();
  return vrats.whenData((list) {
    final days = panchang.valueOrNull ?? const <PanchangDay>[];
    PanchangDay? todayPanchang;
    for (final day in days) {
      if (DateHelper.isSameDay(day.date, today)) {
        todayPanchang = day;
        break;
      }
    }
    return CalendarEngine.build(vrats: list, today: today)
        .copyWith(todayPanchang: todayPanchang);
  });
});

final vratByIdProvider = Provider.family<Vrat?, String>((ref, id) {
  final content = ref.watch(calendarVratsProvider);
  return content.maybeWhen(
    data: (vrats) => vrats.where((vrat) => vrat.id == id).firstOrNull,
    orElse: () => null,
  );
});

/// Counts taps on the prasadam "coming soon" box.
///
/// This is the demand signal the plan calls for before any fulfilment is
/// committed to. It rides along in the synced settings snapshot, so with backup
/// on it becomes visible per user in Firestore without needing its own
/// collection or any rules change.
final prasadamInterestProvider =
    StateNotifierProvider<PrasadamInterestNotifier, int>((ref) {
      return PrasadamInterestNotifier();
    });

class PrasadamInterestNotifier extends StateNotifier<int> {
  PrasadamInterestNotifier()
    : super(
        HiveStorage.settingsBox.get(
              HiveKeys.prasadamInterest,
              defaultValue: 0,
            )
            as int,
      );

  Future<void> record() async {
    state = state + 1;
    await HiveStorage.settingsBox.put(HiveKeys.prasadamInterest, state);
  }
}

final kundaliInterestProvider =
    StateNotifierProvider<KundaliInterestNotifier, int>((ref) {
      return KundaliInterestNotifier();
    });

class KundaliInterestNotifier extends StateNotifier<int> {
  KundaliInterestNotifier()
    : super(
        HiveStorage.settingsBox.get(
              HiveKeys.kundaliInterest,
              defaultValue: 0,
            )
            as int,
      );

  Future<void> record() async {
    state = state + 1;
    await HiveStorage.settingsBox.put(HiveKeys.kundaliInterest, state);
  }
}
