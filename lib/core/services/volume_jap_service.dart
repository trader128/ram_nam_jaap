import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:volume_controller/volume_controller.dart';

import '../../shared/enums/count_method.dart';

class VolumeJapService {
  VolumeJapService() : _controller = VolumeController.instance;

  final VolumeController _controller;
  StreamSubscription<double>? _subscription;
  double? _lockedVolume;
  VoidCallback? _onVolumeJap;
  var _isListening = false;

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> start({
    required CountMethod countMethod,
    required VoidCallback onVolumeJap,
  }) async {
    if (!isSupported) {
      return;
    }

    final usesVolume =
        countMethod == CountMethod.volume || countMethod == CountMethod.both;
    if (!usesVolume) {
      await stop();
      return;
    }

    _onVolumeJap = onVolumeJap;
    if (_isListening) {
      return;
    }

    _controller.showSystemUI = false;
    _lockedVolume = await _controller.getVolume();
    _subscription = _controller.addListener(
      _handleVolumeChanged,
      fetchInitialVolume: false,
    );
    _isListening = true;
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _controller.removeListener();
    _onVolumeJap = null;
    _lockedVolume = null;
    _isListening = false;
  }

  Future<void> _handleVolumeChanged(double volume) async {
    if (_lockedVolume == null) {
      _lockedVolume = volume;
      return;
    }

    if ((volume - _lockedVolume!).abs() < 0.001) {
      return;
    }

    _onVolumeJap?.call();
    await _controller.setVolume(_lockedVolume!);
  }
}
