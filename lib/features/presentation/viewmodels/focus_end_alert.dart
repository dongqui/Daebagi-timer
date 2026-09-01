import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'package:catodo/core/toss_haptic.dart';

/// 목표 시간을 채웠을 때 울리는 알림 — 종소리 한 번과 2초짜리 진동 한 번.
///
/// 오버레이가 아니라 싱글턴이 들고 있다. 알림이 울리는 순간 타이머 화면은
/// 종료 화면으로 교체되며 사라지는데, 화면과 함께 플레이어까지 정리되면
/// 소리가 시작하자마자 끊긴다.
///
/// 종소리는 에셋이 아니라 코드가 만든다. mp3 한 장을 더 넣는 대신 사인파를
/// 합성해 WAV로 만든다 — 50KB 남짓이라 번들이 커지지 않고, 앱인토스 웹 빌드도
/// 추가로 받아올 게 없다.
class FocusEndAlert {
  static final FocusEndAlert _instance = FocusEndAlert._internal();
  static FocusEndAlert get instance => _instance;
  FocusEndAlert._internal();

  /// 진동이 이어지는 시간. 폰을 엎어둔 사람도 알아챌 만큼은 길어야 하고,
  /// 놀랄 만큼 길면 안 된다.
  ///
  /// 이 길이를 어떻게 채울지는 플랫폼이 정한다 — `toss_haptic.dart` 참고.
  static const _hapticDuration = Duration(seconds: 2);

  AudioPlayer? _player;
  Future<void>? _loading;

  /// 종료 순간에 소리를 합성해 물리면 그때 화면이 멈칫한다. 타이머가 시작될 때
  /// 미리 만들어 둔다. 두 번 불러도 한 번만 만든다.
  Future<void> preload() {
    return _loading ??= _load().catchError((Object e) {
      debugPrint('집중 종료음 준비 실패 (무시): $e');
      // 다음 집중 때 다시 시도한다.
      _loading = null;
    });
  }

  Future<void> _load() async {
    final player = _player ??= AudioPlayer();
    final wav = buildFocusEndChimeWav();

    if (kIsWeb) {
      // 웹은 data URI를 <audio>에 그대로 물릴 수 있다.
      await player.setUrl('data:audio/wav;base64,${base64Encode(wav)}');
    } else {
      // 네이티브는 data URI를 제대로 못 읽는 플레이어가 있어 바이트를 직접 흘린다.
      await player.setAudioSource(_ChimeAudioSource(wav));
    }
  }

  /// 소리와 진동을 함께 울린다. 어느 쪽이 실패해도 다른 쪽은 그대로 간다.
  void fire() {
    unawaited(_playChime());
    unawaited(_vibrate());
  }

  Future<void> _playChime() async {
    try {
      await preload();
      final player = _player;
      if (player == null) return;

      // 한 번 더 집중하고 끝냈을 때도 울려야 하므로 매번 처음으로 되감는다.
      await player.seek(Duration.zero);
      await player.play();
    } catch (e) {
      debugPrint('집중 종료음 재생 실패 (무시): $e');
    }
  }

  Future<void> _vibrate() => playAlertHaptic(_hapticDuration);

  void dispose() {
    _player?.dispose();
    _player = null;
    _loading = null;
  }
}

/// 도-미-솔로 올라가는 짧은 종소리를 16bit PCM WAV로 만든다.
@visibleForTesting
Uint8List buildFocusEndChimeWav() {
  const sampleRate = 22050;

  // C6 · E6 · G6. 배경음(빗소리 등)에 묻히지 않게 높은 옥타브를 쓴다.
  const notes = <double>[1046.502, 1318.510, 1567.982];

  const noteGap = 0.16; // 다음 음이 들어오기까지(초)
  const tail = 0.9; // 마지막 음이 잦아드는 시간(초)

  final length =
      (sampleRate * ((notes.length - 1) * noteGap + tail)).round();
  final mixed = Float64List(length);

  for (var n = 0; n < notes.length; n++) {
    final start = (n * noteGap * sampleRate).round();
    final omega = 2 * math.pi * notes[n];

    for (var i = start; i < length; i++) {
      final t = (i - start) / sampleRate;
      // 튕기듯 시작해서 천천히 사라지는 포락선. 뒤 항이 없으면 시작이 딱 끊겨
      // 소리에 잡음이 낀다.
      final envelope = math.exp(-t * 4.2) * (1 - math.exp(-t * 400));
      // 2배음을 섞어 사인파 특유의 밋밋함을 덜어낸다.
      final wave = math.sin(omega * t) + 0.25 * math.sin(2 * omega * t);
      mixed[i] += envelope * wave;
    }
  }

  var peak = 0.0;
  for (final sample in mixed) {
    peak = math.max(peak, sample.abs());
  }
  // 0dB에 딱 붙이면 기기에 따라 찢어진다. 조금 여유를 둔다.
  final gain = peak > 0 ? 0.85 * 32767 / peak : 0.0;

  const headerSize = 44;
  final dataSize = length * 2;
  final out = ByteData(headerSize + dataSize);

  void writeAscii(int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      out.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  writeAscii(0, 'RIFF');
  out.setUint32(4, 36 + dataSize, Endian.little);
  writeAscii(8, 'WAVE');
  writeAscii(12, 'fmt ');
  out.setUint32(16, 16, Endian.little); // fmt 청크 크기
  out.setUint16(20, 1, Endian.little); // PCM
  out.setUint16(22, 1, Endian.little); // 모노
  out.setUint32(24, sampleRate, Endian.little);
  out.setUint32(28, sampleRate * 2, Endian.little); // 초당 바이트
  out.setUint16(32, 2, Endian.little); // 블록 정렬
  out.setUint16(34, 16, Endian.little); // 샘플당 비트
  writeAscii(36, 'data');
  out.setUint32(40, dataSize, Endian.little);

  for (var i = 0; i < length; i++) {
    final value = (mixed[i] * gain).round().clamp(-32768, 32767);
    out.setInt16(headerSize + i * 2, value, Endian.little);
  }

  return out.buffer.asUint8List();
}

/// 메모리에 있는 WAV 바이트를 그대로 재생원으로 넘긴다 (네이티브 전용).
class _ChimeAudioSource extends StreamAudioSource {
  _ChimeAudioSource(this._bytes) : super(tag: 'focus-end-chime');

  final Uint8List _bytes;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final from = start ?? 0;
    final to = end ?? _bytes.length;

    return StreamAudioResponse(
      sourceLength: _bytes.length,
      contentLength: to - from,
      offset: from,
      stream: Stream.value(_bytes.sublist(from, to)),
      contentType: 'audio/wav',
    );
  }
}
