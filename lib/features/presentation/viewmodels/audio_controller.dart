import 'package:just_audio/just_audio.dart';

/// 백색소음 종류. 이름이 곧 에셋 파일명이다 (`assets/sounds/<name>.mp3`).
enum AudioType {
  rain,
  birds,
  forest,
  wave,
  wind,
  fire,
  thunder,
}

class AudioController {
  /// 실제로 재생한 종류만 플레이어를 만든다. 미리 다 만들어두면 쓰지도 않을
  /// 플레이어가 자원을 잡는다.
  final Map<AudioType, AudioPlayer> _players = {};
  final Set<AudioType> _loaded = {};

  /// mp3 디코딩/로드는 무겁다. 재생 직전에 몰리지 않도록 미리 불러둔다.
  Future<void> preload(Iterable<AudioType> types) async {
    await Future.wait(types.map(_ensureLoaded));
  }

  Future<void> _ensureLoaded(AudioType type) async {
    if (_loaded.contains(type)) return;

    final player = _players.putIfAbsent(type, AudioPlayer.new);
    await player.setAsset('assets/sounds/${type.name}.mp3');
    await player.setLoopMode(LoopMode.one);
    _loaded.add(type);
  }

  Future<void> play(AudioType type) async {
    await _ensureLoaded(type);
    final player = _players[type];
    if (player != null && !player.playing) {
      await player.play();
    }
  }

  Future<void> stop(AudioType type) async {
    final player = _players[type];
    if (player == null || !player.playing) return;
    await player.pause();
  }

  void dispose() {
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _loaded.clear();
  }
}
