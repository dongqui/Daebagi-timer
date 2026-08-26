import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:catodo/core/observer.dart';
import 'package:catodo/features/data/repositories/audio_repository.dart';
import 'package:catodo/features/data/models/audio_model.dart';

class AudioState {
  final List<String> whiteNoise;
  final String currentMusic;
  final bool isMusicOn;

  AudioState({
    required this.whiteNoise,
    required this.currentMusic,
    required this.isMusicOn,
  });

  AudioState copyWith({
    List<String>? whiteNoise,
    String? currentMusic,
    bool? isMusicOn,
  }) {
    return AudioState(
      whiteNoise: whiteNoise ?? this.whiteNoise,
      currentMusic: currentMusic ?? this.currentMusic,
      isMusicOn: isMusicOn ?? this.isMusicOn,
    );
  }
}

class AudioManager extends Observer<AudioState> {
  static final AudioManager _instance = AudioManager._internal();
  static AudioManager get instance => _instance;

  AudioState _state;

  AudioManager._internal()
      : _state = AudioState(
          whiteNoise: [],
          currentMusic: '',
          isMusicOn: false,
        );

  AudioState get state => _state;

  Future<void> getAudioList() async {
    final audio = await AudioRepository.instance.getOrCreateAudio();
    _updateState(_state.copyWith(
      whiteNoise: audio.whiteNoise,
      currentMusic: audio.currentMusic,
      isMusicOn: audio.isMusicOn,
    ));
  }

  Future<void> updateAudio({
    List<String>? whiteNoise,
    String? currentMusic,
    bool? isMusicOn,
  }) async {
    final updatedAudio = Audio(
      whiteNoise: whiteNoise ?? _state.whiteNoise,
      currentMusic: currentMusic ?? _state.currentMusic,
      isMusicOn: isMusicOn ?? _state.isMusicOn,
    );

    _updateState(_state.copyWith(
      whiteNoise: updatedAudio.whiteNoise,
      currentMusic: updatedAudio.currentMusic,
      isMusicOn: updatedAudio.isMusicOn,
    ));
    await AudioRepository.instance.updateAudio(updatedAudio);
  }

  void updateWhiteNoise(String key, bool value) {
    final whiteNoise = value
        ? [..._state.whiteNoise, key]
        : _state.whiteNoise.where((e) => e != key).toList();

    _updateState(_state.copyWith(whiteNoise: whiteNoise));
    // 체크박스 반응이 저장을 기다릴 이유는 없지만, 실패를 삼키면 안 된다.
    unawaited(
      updateAudio(whiteNoise: whiteNoise).catchError(
        (Object e) => debugPrint('백색소음 설정 저장 실패: $e'),
      ),
    );
  }

  void _updateState(AudioState state) {
    _state = state;
    notifyListeners(state);
  }
}
