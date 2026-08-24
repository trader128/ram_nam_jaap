import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/localized_strings_provider.dart';
import '../data/horoscope_gateway.dart';
import '../data/horoscope_local_store.dart';
import '../domain/birth_profile.dart';
import '../domain/horoscope_reading.dart';

final horoscopeLocalStoreProvider = Provider<HoroscopeLocalStore>(
  (ref) => HoroscopeLocalStore(),
);

final horoscopeGatewayProvider = Provider<HoroscopeGateway>(
  (ref) => HoroscopeGateway(),
);

class HoroscopeState {
  const HoroscopeState({
    this.profile,
    this.reading,
    this.chat = const [],
    this.busy = false,
    this.error,
  });

  final BirthProfile? profile;
  final HoroscopeReading? reading;
  final List<HoroscopeChatTurn> chat;
  final bool busy;
  final String? error;

  HoroscopeState copyWith({
    BirthProfile? profile,
    HoroscopeReading? reading,
    List<HoroscopeChatTurn>? chat,
    bool? busy,
    String? error,
    bool clearError = false,
  }) {
    return HoroscopeState(
      profile: profile ?? this.profile,
      reading: reading ?? this.reading,
      chat: chat ?? this.chat,
      busy: busy ?? this.busy,
      error: clearError ? null : error ?? this.error,
    );
  }
}

final horoscopeControllerProvider =
    StateNotifierProvider<HoroscopeController, HoroscopeState>((ref) {
      return HoroscopeController(
        store: ref.watch(horoscopeLocalStoreProvider),
        gateway: ref.watch(horoscopeGatewayProvider),
        hindi: ref.watch(
          localizedStringsProvider.select((strings) => strings.isHindi),
        ),
      );
    });

class HoroscopeController extends StateNotifier<HoroscopeState> {
  HoroscopeController({
    required HoroscopeLocalStore store,
    required HoroscopeGateway gateway,
    required bool hindi,
  }) : _store = store,
       _gateway = gateway,
       _hindi = hindi,
       super(
         HoroscopeState(
           profile: store.loadProfile(),
           reading: store.loadReading(),
           chat: store.loadChat(),
         ),
       );

  final HoroscopeLocalStore _store;
  final HoroscopeGateway _gateway;
  final bool _hindi;

  Future<void> draw(BirthProfile profile) async {
    if (state.busy) {
      return;
    }
    state = state.copyWith(profile: profile, busy: true, clearError: true);
    await _store.saveProfile(profile);
    try {
      final reading = await _gateway.draw(profile, hindi: _hindi);
      await _store.saveReading(reading);
      state = state.copyWith(reading: reading, busy: false, clearError: true);
    } on HoroscopeException catch (error) {
      state = state.copyWith(busy: false, error: error.message);
    }
  }

  Future<void> ask(String message) async {
    final profile = state.profile;
    final trimmed = message.trim();
    if (profile == null || trimmed.isEmpty || state.busy) {
      return;
    }
    state = state.copyWith(busy: true, clearError: true);
    try {
      final turn = await _gateway.ask(profile, trimmed, hindi: _hindi);
      final chat = [...state.chat, turn];
      await _store.saveChat(chat);
      state = state.copyWith(chat: chat, busy: false, clearError: true);
    } on HoroscopeException catch (error) {
      state = state.copyWith(busy: false, error: error.message);
    }
  }
}
