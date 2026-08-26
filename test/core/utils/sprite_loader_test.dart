import 'package:catodo/core/utils/sprite_loader.dart';
import 'package:flame/cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Images cache;

  setUp(() => cache = Images());

  test('번들 에셋을 읽어 캐시에 넣는다', () async {
    final image = await loadSprite('characters/dog_white_idle.png', cache: cache);

    expect(image.width, 256);
    expect(image.height, 256);
    expect(cache.containsKey('characters/dog_white_idle.png'), isTrue);
  });

  test('같은 경로를 다시 요청하면 같은 이미지를 돌려준다', () async {
    final first = await loadSprite('characters/astronaut_idle.png', cache: cache);
    final second =
        await loadSprite('characters/astronaut_idle.png', cache: cache);

    expect(identical(first, second), isTrue);
  });

  // 없는 에셋을 넣는 실패 경로는 테스트하지 않는다. Flame의 Images 캐시가 실패한
  // future를 내부 맵에 그대로 담아둬서, 예외를 잡아도 zone으로 한 번 더 새어나온다.
}
