import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Counts a jap when the user taps the body of the phone (e.g. the back),
/// detected via a sharp spike in the gravity-removed accelerometer signal.
///
/// This is the cross-platform equivalent of iOS "Back Tap": the system Back Tap
/// accessibility feature is not exposed to third-party apps, but a physical knock
/// on the device produces a distinctive acceleration spike we can detect on both
/// iOS and Android while the session is in the foreground.
class MotionJapService {
  StreamSubscription<UserAccelerometerEvent>? _subscription;
  VoidCallback? _onTap;
  DateTime _lastHit = DateTime.fromMillisecondsSinceEpoch(0);
  var _armed = true;

  /// Acceleration magnitude (m/s², gravity removed) that counts as a tap.
  static const double _threshold = 11.0;

  /// Signal must fall back below this before another tap can register,
  /// preventing a single knock from counting multiple times.
  static const double _rearmThreshold = 4.0;

  /// Minimum gap between two counted taps.
  static const Duration _cooldown = Duration(milliseconds: 260);

  bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  Future<void> start({
    required bool enabled,
    required VoidCallback onTap,
  }) async {
    if (!isSupported || !enabled) {
      await stop();
      return;
    }

    _onTap = onTap;
    if (_subscription != null) {
      return;
    }

    _subscription = userAccelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen(_handleEvent, onError: (_) {}, cancelOnError: false);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    _onTap = null;
    _armed = true;
  }

  void _handleEvent(UserAccelerometerEvent event) {
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    if (!_armed) {
      if (magnitude < _rearmThreshold) {
        _armed = true;
      }
      return;
    }

    if (magnitude < _threshold) {
      return;
    }

    final now = DateTime.now();
    if (now.difference(_lastHit) < _cooldown) {
      _armed = false;
      return;
    }

    _lastHit = now;
    _armed = false;
    _onTap?.call();
  }
}
