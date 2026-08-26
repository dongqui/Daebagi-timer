import 'package:flutter/foundation.dart';
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

  /// 불러오는 중이거나 이미 불러온 것. 같은 종류를 두 번 읽지 않게 막는다 —
  /// 배경 예열과 사용자의 체크가 겹칠 수 있다.
  final Map<AudioType, Future<void>> _loading = {};

  bool _disposed = false;

  /// 재생 직전에 몰리지 않도록 미리 불러둔다.
  ///
  /// 한 번에 하나씩 순서대로 부른다. mp3가 장당 1~3MB라 동시에 여러 개를
  /// 부르면 그 순간에 부하가 겹쳐 화면이 끊긴다.
  Future<void> preload(Iterable<AudioType> types) async {
    for (final type in types) {
      if (_disposed) return;
      await _ensureLoaded(type);
    }
  }

  Future<void> _ensureLoaded(AudioType type) {
    return _loading.putIfAbsent(type, () => _load(type));
  }

  Future<void> _load(AudioType type) async {
    final player = _players.putIfAbsent(type, AudioPlayer.new);

    // 웹에서는 에셋 URL을 그대로 넘긴다. setAsset은 mp3 전체를 Dart 메모리로
    // 읽어들이는데, 그 읽기가 메인 스레드에서 일어나 소리를 고르는 순간
    // 화면이 멈칫한다. URL을 주면 브라우저가 알아서 받아온다.
    if (kIsWeb) {
      await player.setUrl('assets/assets/sounds/${type.name}.mp3');
    } else {
      await player.setAsset('assets/sounds/${type.name}.mp3');
    }
    await player.setLoopMode(LoopMode.one);
  }

  Future<void> play(AudioType type) async {
    await _ensureLoaded(type);
    if (_disposed) return;

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
    _disposed = true;
    for (final player in _players.values) {
      player.dispose();
    }
    _players.clear();
    _loading.clear();
  }
}
