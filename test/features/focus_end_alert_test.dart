import 'dart:typed_data';

import 'package:catodo/features/presentation/viewmodels/focus_end_alert.dart';
import 'package:flutter_test/flutter_test.dart';

/// 종료음은 에셋이 아니라 코드가 만든다. 헤더가 한 글자만 어긋나도 플레이어가
/// 통째로 거부하는데, 그러면 "소리가 안 난다"로만 드러나 원인을 찾기 어렵다.
void main() {
  late Uint8List wav;
  late ByteData view;

  setUpAll(() {
    wav = buildFocusEndChimeWav();
    view = ByteData.sublistView(wav);
  });

  String ascii(int offset, int length) =>
      String.fromCharCodes(wav.sublist(offset, offset + length));

  test('RIFF/WAVE 헤더가 규격대로 적힌다', () {
    expect(ascii(0, 4), 'RIFF');
    expect(ascii(8, 4), 'WAVE');
    expect(ascii(12, 4), 'fmt ');
    expect(ascii(36, 4), 'data');

    expect(view.getUint16(20, Endian.little), 1, reason: 'PCM');
    expect(view.getUint16(22, Endian.little), 1, reason: '모노');
    expect(view.getUint32(24, Endian.little), 22050, reason: '샘플레이트');
    expect(view.getUint16(34, Endian.little), 16, reason: '샘플당 비트');
  });

  test('선언한 길이와 실제 바이트 수가 맞는다', () {
    final dataSize = view.getUint32(40, Endian.little);

    expect(dataSize, wav.length - 44);
    expect(view.getUint32(4, Endian.little), wav.length - 8);
    expect(dataSize % 2, 0, reason: '16bit 샘플');
  });

  test('1초 남짓, 실제로 소리가 나는 파형이다', () {
    final samples = Int16List.sublistView(wav, 44);
    final seconds = samples.length / 22050;
    expect(seconds, closeTo(1.22, 0.05));

    var peak = 0;
    var nonSilent = 0;
    for (final s in samples) {
      final level = s.abs();
      if (level > peak) peak = level;
      if (level > 100) nonSilent++;
    }

    // 소리가 나되 클리핑 직전까지 가지는 않는다.
    expect(peak, greaterThan(20000));
    expect(peak, lessThan(32767));
    // 뒤쪽은 잦아들어 조용하므로 전체의 절반 정도면 충분하다.
    expect(nonSilent, greaterThan(samples.length ~/ 2));
  });
}
