import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:catodo/features/presentation/viewmodels/audio_controller.dart';
import 'package:catodo/features/presentation/views/audio_box.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('백색소음 목록', () {
    test('노출하는 종류마다 번들에 mp3가 있다', () async {
      // 목록에만 추가하고 파일을 안 넣으면 켤 때 조용히 실패한다.
      for (final type in whiteNoiseTypes) {
        final path = 'assets/sounds/${type.name}.mp3';
        final data = await rootBundle.load(path);

        expect(data.lengthInBytes, greaterThan(0), reason: '$path 가 비어 있다');
      }
    });

    test('모든 종류에 한국어 이름이 있다', () {
      for (final type in AudioType.values) {
        expect(whiteNoiseLabel(type), isNotEmpty);
      }
    });

    test('빗소리·새소리·파도소리·모닥불을 고를 수 있다', () {
      expect(whiteNoiseTypes, [
        AudioType.rain,
        AudioType.birds,
        AudioType.wave,
        AudioType.fire,
      ]);
      expect(
        whiteNoiseTypes.map(whiteNoiseLabel),
        ['빗소리', '새소리', '파도소리', '모닥불'],
      );
    });

    test('저장되는 값은 enum 이름이라 목록이 늘어도 기존 선택이 유지된다', () {
      // AudioManager는 whiteNoise를 List<String>(type.name)으로 저장한다.
      expect(AudioType.rain.name, 'rain');
      expect(AudioType.birds.name, 'birds');
    });
  });
}
