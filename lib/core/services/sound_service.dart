import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../constants/sound_assets.dart';

class SoundService {
  SoundService() : _tapPlayer = AudioPlayer(), _malaPlayer = AudioPlayer();

  final AudioPlayer _tapPlayer;
  final AudioPlayer _malaPlayer;
  var _initialized = false;
  var _initializing = false;

  Future<void> init() async {
    if (_initialized || _initializing) {
      return;
    }

    _initializing = true;
    try {
      await _tapPlayer.setReleaseMode(ReleaseMode.stop);
      await _malaPlayer.setReleaseMode(ReleaseMode.stop);
      await _tapPlayer.setVolume(0.55);
      await _malaPlayer.setVolume(0.7);
      _initialized = true;
    } finally {
      _initializing = false;
    }
  }

  void playJapTap({required bool enabled}) {
    if (!enabled) {
      return;
    }

    unawaited(_playTap());
  }

  void playMalaComplete({required bool enabled}) {
    if (!enabled) {
      return;
    }

    unawaited(_playMala());
  }

  Future<void> _playTap() async {
    await init();
    try {
      unawaited(_tapPlayer.stop());
      unawaited(_tapPlayer.play(AssetSource(SoundAssets.japTap)));
    } on Object catch (error, stackTrace) {
      debugPrint('SoundService.playJapTap failed: $error');
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
    await _tapPlayer.dispose();
    await _malaPlayer.dispose();
  }
}
