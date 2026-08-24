import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/bhajan/providers/bhajan_providers.dart';
import '../../features/calendar/domain/panchang_vrat_merger.dart';
import '../../features/calendar/providers/calendar_providers.dart';
import '../../features/deity/providers/deity_providers.dart';
import '../../features/jap/providers/jap_providers.dart';
import '../../core/notifications/reminder_service.dart';
import 'sync_providers.dart';

/// Syncs once after first frame and again whenever the app returns to the
/// foreground, so a backup is never on the critical path of a jap session.
class SyncLifecycleObserver extends ConsumerStatefulWidget {
  const SyncLifecycleObserver({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<SyncLifecycleObserver> createState() =>
      _SyncLifecycleObserverState();
}

class _SyncLifecycleObserverState extends ConsumerState<SyncLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    await ref.read(syncControllerProvider.notifier).syncNow();
    await Future.wait([
      ref.read(vratRepositoryProvider).refreshRemote(),
      ref.read(bhajanRepositoryProvider).refreshRemote(),
      ref.read(panchangRepositoryProvider).refreshRemote(),
    ]);
    if (!mounted) {
      return;
    }
    ref.invalidate(vratContentProvider);
    ref.invalidate(bhajanContentProvider);
    ref.invalidate(panchangContentProvider);
    final vrats = await ref.read(vratRepositoryProvider).load();
    final days = await ref.read(panchangRepositoryProvider).load();
    await ReminderService.instance.apply(
      settings: ref.read(japSettingsProvider),
      deityName: ref.read(selectedDeityProvider).name,
      vrats: PanchangVratMerger.merge(vrats, days),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
