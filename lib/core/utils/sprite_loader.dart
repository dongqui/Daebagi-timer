import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/flame.dart';

/// 번들 에셋에서 스프라이트 시트를 읽는다.
///
/// [cache]를 넘기면 그 [Images]를 쓰고, 아니면 전역 [Flame.images]를 쓴다.
/// 같은 경로를 다시 요청하면 캐시가 응답한다.
///
/// 예전에는 원격 URL도 처리했다. 서버에서 리소스를 내려받는 기능이 사라지면서
/// 스프라이트 경로는 전부 번들 에셋이 되었고, 그 분기는 함께 걷어냈다.
Future<ui.Image> loadSprite(String path, {Images? cache}) {
  return (cache ?? Flame.images).load(path);
}
