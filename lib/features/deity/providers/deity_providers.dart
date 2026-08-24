import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/deity_repository.dart';
import '../domain/deity_pack.dart';

final deityRepositoryProvider = Provider<DeityRepository>(
  (ref) => DeityRepository(),
);

final selectedDeityProvider =
    StateNotifierProvider<SelectedDeityNotifier, DeityPack>((ref) {
      return SelectedDeityNotifier(ref.watch(deityRepositoryProvider));
    });

/// Convenience accessor for the active deity's primary color.
final deityColorProvider = Provider<Color>((ref) {
  return ref.watch(selectedDeityProvider).primary;
});

class SelectedDeityNotifier extends StateNotifier<DeityPack> {
  SelectedDeityNotifier(this._repository) : super(_repository.loadSelected());

  final DeityRepository _repository;

  Future<void> select(DeityPack deity) async {
    if (deity.id == state.id) {
      return;
    }
    state = deity;
    await _repository.saveSelected(deity);
  }
}
