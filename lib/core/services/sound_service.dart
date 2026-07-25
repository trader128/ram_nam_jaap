import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../constants/sound_assets.dart';

/// Plays all session audio: the spoken chant of the divine name on each tap,
/// the mala-completion chime, and a gently looping ambient idle track.
///
/// All playback is fire-and-forget (never awaited on the tap path) so chanting
/// stays perfectly responsive. The idle music fades in/out to avoid abrupt cuts.
class SoundService {
  SoundService()
    : _chantPlayer = AudioPlayer(),
      _malaPlayer = AudioPlayer(),
      _musicPlayer = AudioPlayer();

  final AudioPlayer _chantPlayer;
  final AudioPlayer _malaPlayer;
  final AudioPlayer _musicPlayer;

  var _initialized = false;
  var _initializing = false;

  static const double _musicTargetVolume = 0.32;
  Timer? _fadeTimer;
  double _musicVolume = 0;
  String? _currentMusicAsset;

  Future<void> init() async {
    if (_initialized || _initializing) {
      return;
    }

    _initializing = true;
    try {
      await _chantPlayer.setReleaseMode(ReleaseMode.stop);
      await _malaPlayer.setReleaseMode(ReleaseMode.stop);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _chantPlayer.setVolume(0.9);
      await _malaPlayer.setVolume(0.7);
      await _musicPlayer.setVolume(0);
      _initialized = true;
    } finally {
      _initializing = false;
    }
  }

  /// Speaks the deity's name on each tap (replaces the old click sound).
  void playChant({required bool enabled, required String asset}) {
    if (!enabled) {
      return;
    }
    unawaited(_playChant(asset));
  }

  void playMalaComplete({required bool enabled}) {
    if (!enabled) {
      return;
    }
    unawaited(_playMala());
  }

  /// Starts (or switches to) the deity's ambient idle loop with a soft fade-in.
  Future<void> startIdleMusic({
    required String asset,
    required bool enabled,
  }) async {
    if (!enabled) {
      await stopIdleMusic();
      return;
    }

    await init();
    if (_currentMusicAsset == asset) {
      return;
    }

    _currentMusicAsset = asset;
    try {
      _musicVolume = 0;
      await _musicPlayer.setVolume(0);
      await _musicPlayer.play(AssetSource(asset));
      _fadeMusicTo(_musicTargetVolume);
    } on Object catch (error, stackTrace) {
      debugPrint('SoundService.startIdleMusic failed: $error');
      debugPrint('$stackTrace');
      _currentMusicAsset = null;
    }
  }

  Future<void> stopIdleMusic() async {
    _currentMusicAsset = null;
    _fadeTimer?.cancel();
    try {
      await _musicPlayer.stop();
    } on Object catch (error) {
      debugPrint('SoundService.stopIdleMusic failed: $error');
    }
    _musicVolume = 0;
  }

  void _fadeMusicTo(double target) {
    _fadeTimer?.cancel();
    _fadeTimer = Timer.periodic(const Duration(milliseconds: 70), (
      timer,
    ) async {
      final diff = target - _musicVolume;
      if (diff.abs() <= 0.03) {
        _musicVolume = target;
        timer.cancel();
        try {
          await _musicPlayer.setVolume(_musicVolume);
        } on Object catch (_) {}
        return;
      }
      _musicVolume = (_musicVolume + (diff.isNegative ? -0.03 : 0.03)).clamp(
        0.0,
        1.0,
      );
      try {
        await _musicPlayer.setVolume(_musicVolume);
      } on Object catch (_) {}
    });
  }

  Future<void> _playChant(String asset) async {
    await init();
    try {
      unawaited(_chantPlayer.stop());
      unawaited(_chantPlayer.play(AssetSource(asset)));
    } on Object catch (error, stackTrace) {
      debugPrint('SoundService.playChant failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> _playMala() async {
    await init();
    try {
      unawaited(_malaPlayer.stop());
      unawaited(_malaPlayer.play(AssetSource(SoundAssets.malaComplete)));
    } on Object catch (error, stackTrace) {
      debugPrint('SoundService.playMalaComplete failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> dispose() async {
    _fadeTimer?.cancel();
    await _chantPlayer.dispose();
    await _malaPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
