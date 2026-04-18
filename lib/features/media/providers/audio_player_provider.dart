import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../data/models/sound_track_model.dart';

class AudioPlayerState {
  const AudioPlayerState({
    this.currentTrack,
    this.isPlaying = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.sleepTimerEndsAt,
  });

  final SoundTrackModel? currentTrack;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final DateTime? sleepTimerEndsAt;

  AudioPlayerState copyWith({
    SoundTrackModel? currentTrack,
    bool? isPlaying,
    Duration? position,
    Duration? duration,
    DateTime? sleepTimerEndsAt,
    bool clearSleepTimer = false,
  }) {
    return AudioPlayerState(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      sleepTimerEndsAt:
          clearSleepTimer ? null : sleepTimerEndsAt ?? this.sleepTimerEndsAt,
    );
  }
}

class AudioPlayerController extends StateNotifier<AudioPlayerState> {
  AudioPlayerController() : super(const AudioPlayerState()) {
    _player.setLoopMode(LoopMode.one);

    _playerStateSub = _player.playerStateStream.listen((playerState) {
      state = state.copyWith(isPlaying: playerState.playing);
    });

    _positionSub = _player.positionStream.listen((position) {
      state = state.copyWith(position: position);
    });

    _durationSub = _player.durationStream.listen((duration) {
      state = state.copyWith(duration: duration ?? Duration.zero);
    });
  }

  final AudioPlayer _player = AudioPlayer();
  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration?>? _durationSub;
  Timer? _sleepTimer;

  Future<void> playTrack(SoundTrackModel track) async {
    try {
      if (state.currentTrack?.id != track.id) {
        await _player.setUrl(track.audioUrl);
      }
      await _player.play();
      state = state.copyWith(currentTrack: track, isPlaying: true);
    } catch (_) {
      // Sessizce düş: medya hatası app akışını kesmemeli.
    }
  }

  Future<void> pause() async {
    try {
      await _player.pause();
      state = state.copyWith(isPlaying: false);
    } catch (_) {}
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _cancelSleepTimer();
      state = const AudioPlayerState();
    } catch (_) {}
  }

  void setSleepTimer(Duration duration) {
    _cancelSleepTimer();
    if (duration <= Duration.zero) return;

    final endAt = DateTime.now().add(duration);
    state = state.copyWith(sleepTimerEndsAt: endAt);
    _sleepTimer = Timer(duration, () {
      stop();
    });
  }

  void clearSleepTimer() {
    _cancelSleepTimer();
    state = state.copyWith(clearSleepTimer: true);
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }

  @override
  void dispose() {
    _cancelSleepTimer();
    _playerStateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerController, AudioPlayerState>(
  (ref) => AudioPlayerController(),
);
