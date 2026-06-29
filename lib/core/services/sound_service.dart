import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../constants/sound_assets.dart';

class SoundService {
  SoundService() : _tapPlayer = AudioPlayer(), _malaPlayer = AudioPlayer();

  final AudioPlayer _tapPlayer;
  final AudioPlayer _malaPlayer;
  var _initialized = false;

  Future<void> init() async {
    if (_initialized) {
      return;
    }

    await _tapPlayer.setReleaseMode(ReleaseMode.stop);
    await _malaPlayer.setReleaseMode(ReleaseMode.stop);
    await _tapPlayer.setVolume(0.55);
    await _malaPlayer.setVolume(0.7);
    _initialized = true;
  }

  Future<void> playJapTap({required bool enabled}) async {
    if (!enabled) {
      return;
    }

    await init();
    try {
      await _tapPlayer.stop();
      await _tapPlayer.play(AssetSource(SoundAssets.japTap));
    } on Object catch (error, stackTrace) {
      debugPrint('SoundService.playJapTap failed: $error');
      debugPrint('$stackTrace');
    }
  }

  Future<void> playMalaComplete({required bool enabled}) async {
    if (!enabled) {
      return;
    }

    await init();
    try {
      await _malaPlayer.stop();
      await _malaPlayer.play(AssetSource(SoundAssets.malaComplete));
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
