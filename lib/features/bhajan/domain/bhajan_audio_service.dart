import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import 'bhajan.dart';

enum BhajanPlaybackState { idle, loading, playing, paused, failed }

class BhajanPlayback {
  const BhajanPlayback({
    this.bhajanId,
    this.state = BhajanPlaybackState.idle,
    this.position = Duration.zero,
    this.duration,
  });

  final String? bhajanId;
  final BhajanPlaybackState state;
  final Duration position;
  final Duration? duration;

  bool get isActive =>
      state == BhajanPlaybackState.playing ||
      state == BhajanPlaybackState.paused;

  bool isPlaying(String id) =>
      bhajanId == id && state == BhajanPlaybackState.playing;

  bool isLoading(String id) =>
      bhajanId == id && state == BhajanPlaybackState.loading;

  double get progress {
    final total = duration;
    if (total == null || total.inMilliseconds <= 0) {
      return 0;
    }
    return (position.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  BhajanPlayback copyWith({
    String? bhajanId,
    BhajanPlaybackState? state,
    Duration? position,
    Duration? duration,
    bool clearDuration = false,
  }) {
    return BhajanPlayback(
      bhajanId: bhajanId ?? this.bhajanId,
      state: state ?? this.state,
      position: position ?? this.position,
      duration: clearDuration ? null : (duration ?? this.duration),
    );
  }
}

/// Plays full-length bhajan recordings.
///
/// Deliberately its own [AudioPlayer], separate from [SoundService]: that one is
/// tuned for short interruptible chant clips and a looping ambient bed, and
/// reusing its music player would make a bhajan and the jap session's ambient
/// track fight over the same channel.
class BhajanAudioService {
  BhajanAudioService() : _player = AudioPlayer();

  final AudioPlayer _player;
  final _controller = StreamController<BhajanPlayback>.broadcast();
  final List<StreamSubscription<Object?>> _subscriptions = [];

  BhajanPlayback _playback = const BhajanPlayback();
  bool _initialized = false;

  Stream<BhajanPlayback> get stream => _controller.stream;
  BhajanPlayback get playback => _playback;

  Future<void> init() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    await _player.setReleaseMode(ReleaseMode.stop);

    _subscriptions.addAll([
      _player.onPositionChanged.listen((position) {
        _emit(_playback.copyWith(position: position));
      }),
      _player.onDurationChanged.listen((duration) {
        _emit(_playback.copyWith(duration: duration));
      }),
      _player.onPlayerComplete.listen((_) {
        _emit(
          const BhajanPlayback(
            state: BhajanPlaybackState.idle,
            position: Duration.zero,
          ),
        );
      }),
    ]);
  }

  /// Starts [bhajan], or toggles pause if it is already the active track.
  Future<void> toggle(Bhajan bhajan) async {
    if (!bhajan.hasAudio) {
      return;
    }

    await init();

    if (_playback.bhajanId == bhajan.id) {
      if (_playback.state == BhajanPlaybackState.playing) {
        await pause();
        return;
      }
      if (_playback.state == BhajanPlaybackState.paused) {
        await _player.resume();
        _emit(_playback.copyWith(state: BhajanPlaybackState.playing));
        return;
      }
    }

    _emit(
      BhajanPlayback(
        bhajanId: bhajan.id,
        state: BhajanPlaybackState.loading,
      ),
    );

    try {
      final asset = bhajan.audioAsset;
      final url = bhajan.audioUrl;
      final source = asset != null ? AssetSource(asset) : UrlSource(url!);

      await _player.stop();
      await _player.play(source);
      _emit(
        BhajanPlayback(
          bhajanId: bhajan.id,
          state: BhajanPlaybackState.playing,
        ),
      );
    } on Object catch (error) {
      debugPrint('BhajanAudioService.toggle failed for ${bhajan.id}: $error');
      _emit(
        BhajanPlayback(
          bhajanId: bhajan.id,
          state: BhajanPlaybackState.failed,
        ),
      );
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      _emit(_playback.copyWith(state: BhajanPlaybackState.paused));
    } on Object catch (error) {
      debugPrint('BhajanAudioService.pause failed: $error');
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } on Object catch (error) {
      debugPrint('BhajanAudioService.stop failed: $error');
    }
    _emit(const BhajanPlayback());
  }

  Future<void> seek(Duration position) async {
    if (!_playback.isActive) {
      return;
    }
    try {
      await _player.seek(position);
      _emit(_playback.copyWith(position: position));
    } on Object catch (error) {
      debugPrint('BhajanAudioService.seek failed: $error');
    }
  }

  void _emit(BhajanPlayback playback) {
    _playback = playback;
    if (!_controller.isClosed) {
      _controller.add(playback);
    }
  }

  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _controller.close();
    await _player.dispose();
  }
}
