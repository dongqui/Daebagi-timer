import 'package:just_audio/just_audio.dart';

enum AudioType {
  rain,
  birds,
  forest,
  ocean,
  wind,
  fire,
  thunder,
}

class AudioController {
  final Map<AudioType, AudioPlayer> audioPlayers = {
    AudioType.rain: AudioPlayer(),
    AudioType.birds: AudioPlayer(),
  };

  final Set<AudioType> _loaded = {};

  /// mp3 디코딩/로드는 무겁다. 타이머 UI를 열 때 한 번만 미리 로드한다.
  Future<void> preload(List<AudioType> types) async {
    await Future.wait(types.map(_ensureLoaded));
  }

  Future<void> _ensureLoaded(AudioType type) async {
    if (_loaded.contains(type)) return;

    final player = audioPlayers[type];
    if (player == null) return;

    await player.setAsset('assets/sounds/${type.name}.mp3');
    await player.setLoopMode(LoopMode.one);
    _loaded.add(type);
  }

  Future<void> play(AudioType type) async {
    final player = audioPlayers[type];
    if (player == null) return;

    await _ensureLoaded(type);
    if (!player.playing) {
      await player.play();
    }
  }

  Future<void> stop(AudioType type) async {
    final player = audioPlayers[type];
    if (player == null || !player.playing) return;
    await player.pause();
  }

  void dispose() {
    for (final player in audioPlayers.values) {
      player.dispose();
    }
  }
}
